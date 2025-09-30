-- define module
local coreevent = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coresystem = require "coresystem"
local coreenv    = require "coreenv"
local corelog
local coretask
local coredisplay
local coreutils
local coreinventory

-- allemaal event spullen
local db = {
    channel			= {},		-- list of open channels, and which protocol wanted the channel
    timer			= {},		-- list of all known timers
    reply			= {},		-- the reply envelopes by message id (serial)
	toSend			= {},		-- list of messages that still need to be send because the modem was down
	toBulkSend		= {},		-- list of messages that still need to be send because of bulk sending
	toProcess		= {},		-- list of messages from a bulk message that still needs processsing
--	bulkMode		= true,		-- send messages in bulk per tick, not one by one
    logfile			= "/log/core.event.log",
	protocol		= "coreevent",
	publicChannel	= 65535,

	debug			= false,
}

-- object / function references
local modem       	= nil
local listener    	= {}
local eventready	= {}	-- list of functions to run when ready

-- event init
function coreevent.Init()
	corelog			= corelog		or require "corelog"
	coretask		= coretask		or require "coretask"
	coredisplay		= coredisplay	or require "coredisplay"
	coreutils		= coreutils		or require "coreutils"
	coreinventory	= coreinventory	or require "coreinventory"

	-- activate the modem
	ActivateModem()

	-- computer id is for private messages
	coreevent.OpenChannel(os.getComputerID(), "system.event")
	coreevent.OpenChannel(db.publicChannel,   "system.event")
end

-- event setup
function coreevent.Setup()
	-- set env
	coreenv.RegisterVariable(db.protocol, "bulkMode", "boolean", true)

	-- tick timer
	coreevent.AddEventListener(coreevent.DoEventTickTimer, db.protocol, "tick timer")
	coreevent.DoEventTickTimer(nil, nil) -- run once so the timer get's set.

	-- bukl handler
	coreevent.AddEventListener(coreevent.DoEventBulkMessagse, db.protocol, "bulk message")

	-- idle handler
	coretask.AddIdleHandler("event", 300, DoIdle)

	-- mark the log of our new run (start a new log file)
	coreutils.WriteToFile(db.logfile, "--- Init() --- os.getComputerID() = " .. os.getComputerID() .. " ---", "overwrite")
end

-- functie om de modem te initializeren
function ActivateModem()
    -- activate the modem
	if turtle	then modem = peripheral.wrap("left")
				else modem = peripheral.find("modem")
	end

	-- find a modem
	if not modem and coreinventory.GetEmptySlot() then

		-- make left side free
		turtle.equipLeft()

		-- any modem present?
		if coreinventory.CanEquip("computercraft:wireless_modem_normal") then

			-- great, equip it
			coreinventory.Equip("computercraft:wireless_modem_normal", "left")

			-- go for the modem again
			modem = peripheral.find("modem")
		end
	end

 	-- did we find it now? if so, send all waiting messages. else stop the show
    if modem 	then for i, messageData in ipairs(db.toSend) do modem.transmit(messageData.channel, messageData.replyChannel, messageData.message) end db.toSend = nil
				else error("No modem found!")
	end
end

-- opens a channel for a specific protocol
function coreevent.OpenChannel(channel, protocol)
    -- the channel must be a number and protocol must be a string to use this function
    if type(channel) ~= "number" or type(protocol) ~= "string" then return end

	-- ever initialized?
	if modem == nil then coreevent.Init() end

    -- make a table if not one present
	if db.channel[channel] == nil then db.channel[channel] = {} end

	-- make this channel ready for this protocol
	db.channel[channel][protocol] = true

	-- open the channel (unless already open)
	if modem and modem.isOpen(channel) == false then modem.open(channel) end
end

-- closes the channel for the specific protocol. Channel is really closed then no other protocol uses the channel
function CloseChannel(channel, protocol)

	-- remember who opened this channel
	if db.channel[channel] and db.channel[channel][protocol] then db.channel[channel][protocol] = nil end

	-- is the channel open and still needed?
	if next(db.channel[channel]) == nil then

		-- remove the entry from the table since it is empty
		db.channel[channel] = nil

		-- close the channel on the modem if needed
		if modem and modem.isOpen(channel) == true then modem.close(channel) end
	end
end

-- usefull
function coreevent.PublicChannel() return db.publicChannel end

-- to send a message to an other computer
function coreevent.SendMessage(t)
	-- format input
	local from		= os.getComputerID()
	local to		= t.to      	or { db.publicChannel }    -- public channel if no other is specified
	local channel	= t.channel
	local protocol	= t.protocol	or ""
	local subject	= t.subject		or ""
	local message   = t.message

	-- input controleren
	if protocol == "" or subject == "" then corelog.WriteToLog("SendMessage(): invalid parameters: protocol = "..protocol..", subject = "..subject) return nil end

	-- make sure our message is a table
	if type(message)	~= "table"  then message    = {}                    end -- message moet altijd een table zijn, dan maar een leeg
	if type(to)			~= "table"  then to         = {to}                  end

	-- add the message id (unless already present)
	if not message.messageId then message.messageId = coreutils.NewId() end

	-- send the message, loop over the receiptants
	for i=1,#to do
	    -- use local for speed?
		local currentChannel = channel

        -- do we have a channel? if not, use id of the receiver
		if not currentChannel then currentChannel = to[i] end

		-- are we sending in bulk mode?
		if coreenv.GetVariable(db.protocol, "bulkMode") and not (protocol == db.protocol or subject == "bulk message") then

			-- we need an array table to insert, make sure there is one
			if type(db.toBulkSend[currentChannel]) ~= "table" then db.toBulkSend[currentChannel] = {} end

			-- message not actually send now, stored for sending at a later moment
			table.insert(db.toBulkSend[currentChannel], textutils.serialize({
				from        = from,
				to			= to[i],
				protocol	= protocol,
				subject		= subject,
				message		= message
			}, {compact = true}))
		else

			-- actuall sending the message
			if modem then

				-- log all messages send
				local serializedMessage = textutils.serialize({
					from        = from,
					to			= to[i],
					protocol	= protocol,
					subject		= subject,
					message		= message
				})

				-- usefull debugging
				if db.debug then
					coreutils.WriteToFile(db.logfile, os.time() .." - Sending message("..protocol..", "..subject.."), size = "..string.len(serializedMessage), "a")
					if protocol == "core:dht" and subject == "save data" then coreutils.WriteToFile(db.logfile, "	It was about '"..(message["arg"][1] or "").."'") end
				end

				-- this sends the message
				modem.transmit(currentChannel, from, serializedMessage)
			else

				-- no modem, just wait for a better moment
				table.insert(db.toSend, {
					channel 		= currentChannel,
					replyChannel	= from,
					message			= textutils.serialize({
						from        = from,
						to			= to[i],
						protocol	= protocol,
						subject		= subject,
						message		= message
					})
				})

				-- not very likely to happen, we can recover from this minor issue
				if db.debug then coreutils.WriteToFile(db.logfile, "Cannot transmit a message without a modem (protocol = "..protocol..", subject = "..subject..")", "a") end
				-- don't write to log, since that will send a message and get's us in a loop
			end
		end
	end

	-- return the (generated) message id
	return message.messageId
end

-- this function send the message, and organizes that the replies to this messages are saved
function SendMessageSaveReply(t)
    -- possible entries of the parameter table
	local to			= t.to      		or db.publicChannel -- public channel if no other is specified
	local channel		= t.channel
   	local protocol		= t.protocol		or ""
	local subject		= t.subject			or ""
	local message		= t.message			or {}
	local ticks			= t.ticks			or 0		-- no event will be created if ticks is 0
	local replysubject	= t.replysubject	or t.subject.." timer"

	-- input controleren
	if protocol == "" or subject == "" then
		corelog.WriteToLog("SendMessageSaveReply(): invalid parameters: protocol = "..protocol..", subject = "..subject, "a")
		return nil
	end

	-- send the message
	local messageId = coreevent.SendMessage({to = to, channel = channel, protocol = protocol, subject = subject, message = message})

	-- create a timed event with the message id
	if ticks and replysubject then coreevent.CreateTimeEvent(ticks, t.protocol, replysubject, messageId) end

	-- create a table for the replies
	if messageId then db.reply[messageId] = {} end

	-- return the message id
	return messageId
end

-- fast and easy way to reply to a message
function coreevent.ReplyToMessage(envelope, subject, message)
	-- we need some to send to, check!
	if not envelope.from then
		corelog.WriteToLog("ReplyToMessage(): no from found, envelope.from = " .. (envelope.from or ""), "a")
		return nil
	end

	-- let the receiptant know to which message this is a reply. Create message table if needed
	if type(message) ~= "table" then message = {} end
	message.replyto = envelope.message.messageId

	-- send the message
	return coreevent.SendMessage({to=envelope.from, protocol=envelope.protocol, subject=subject, message=message})
end

-- stores an envelope based on the original message id serial, now in the replyto field
function DoEventStoreEnvelope(subject, envelope)
	-- our serial
	local serial = coreutils.IdSerial(envelope.message.replyto)

	-- store this envelope in the array
	if db.reply[serial] then db.reply[serial][#db.reply[serial]+1] = envelope end
end

-- gets the stored envelopes, memory is freed after retrieving
function GetReplies(messageId)
	local serial	= coreutils.IdSerial(messageId)
	local tmp		= db.reply[serial]
    db.reply[serial] = nil
	return tmp
end

-- function to fire an event in a specific number of seconds
function coreevent.CreateTimeEvent(ticks, protocol, p1, p2, p3, p4, p5)
	local id = os.startTimer(ticks/20)

	-- add this one to our memory
	db.timer[id] = {protocol=protocol, p1=p1, p2=p2, p3=p3, p4=p4, p5=p5, finished=os.clock() + ticks / 20}

	-- return the id of the timer, in case our caller wants to clear the timer
	return id
end

-- not sure if anyone will ever cancel a timer or just let it run out
function coreevent.CancelTimeEvent(id)
	-- clear the timer in the os queue
	os.cancelTimer(id)

	-- clear the data from our memory
	db.timer[id] = nil
end

function coreevent.EventReadyFunction(func)
	-- just add function to the list
	table.insert(eventready, func)
end

-- to add a custom functions to the event listener
function coreevent.AddEventListener(func, protocol, subject)
    -- not sure if we allow an event listeren without a subject...
	if subject then
	    -- add this function to the listeners (create table if needed)
	    if type(listener[protocol]) ~= "table" then listener[protocol] = {} end
	    listener[protocol][subject] = func
	else
	    -- ok, but only if there is no table present!
		if type(listener[protocol]) ~= "table" then listener[protocol] = func end
	end
end

-- to remove the custom functions to the event listener. Without subject all functions for this protocol are cleared.
function coreevent.RemoveEventListener(protocol, subject)
    -- check if we need to remove all from this protocol
	if subject  then listener[protocol][subject]    = nil
			    else listener[protocol]             = nil
	end
end

local function CoreEventPullEvent()
	-- do we have any messages left we need to process?
	if #db.toProcess > 0	then return unpack(table.remove(db.toProcess, 1))	-- process a message from the bulk
							else return os.pullEvent()							-- no, mormal pull event
	end
end

-- local function to decompile a modem message
local function ProcessModemMessageEvent(side, frequency, replyFrequency, message, distance)
	-- this is our message
	local me		= os.getComputerID()
	local envelope	= textutils.unserialize(message)

	-- is this message for me?
	if envelope and envelope.to and (envelope.to > 65000 or envelope.to == me) and type(envelope.from) == "number" and envelope.protocol then
		-- add data
		envelope.distance   = distance
		envelope.received   = os.clock()
		envelope.subject    = envelope.subject or '<<no subject>>'

		-- write message to file, for debugging and documentation
--		coreutils.WriteToFile("/log/system.txt", "    message in: from = "..envelope.from..", protocol = "..envelope.protocol..", subject = "..envelope.subject, "a")
		coreutils.WriteToFile("/event/"..envelope.protocol.."/"..envelope.subject, envelope, "overwrite")

		-- log to monitor screen
--		corelog.WriteToMonitor(me..": Modem event from: "..envelope.from..", about: "..envelope.protocol..":"..envelope.subject)

		-- continue with this event
		return envelope.protocol, envelope.subject, envelope, nil, nil, nil
	else
		local msg	= message

		-- not our message, continue without ajusting anything
		coredisplay.UpdateToDisplay("Unknown modem_message", 5)
		corelog.WriteToLog("Unknown modem_message:")
		corelog.WriteToLog("    side           = "..side)
		corelog.WriteToLog("    frequency      = "..frequency)
		corelog.WriteToLog("    replyFrequency = "..replyFrequency)
		corelog.WriteToLog("    message        = "..message)
		corelog.WriteToLog("    distance       = "..distance)
		return 'modem_message', side, frequency, replyFrequency, message, distance
	end
end

-- local function to process a timer event
local function ProcessTimerEvent(id)
    local timer = db.timer

	-- is it a known timer?
	if timer[id] ~= nil then
		-- return a new event
		local tmp = timer[id]
		timer[id] = nil
		return tmp.protocol, tmp.p1, tmp.p2, tmp.p3, tmp.p4, tmp.p5
	else
		-- could be our idle timer, then create a new one
--    		if db.idleId == id then db.idleId	= os.startTimer(5) end -- part of task? !!!

		-- we don't know this timer, continue with the event as it was
		return 'timer', id
	end
end

-- listener to every event incoming
function coreevent.Run()
    -- events we ignore in the global event listener
	local ignore    = {
		["char"]				= true,
		["dummy"]				= true,
		["key"]					= true,
		["key_up"]				= true,
		["redstone"]			= true,
		["timer"]				= true,
		["turtle_inventory"]	= true,
		["turtle_response"]		= true,
	}

	-- run functions when event is (about to be) ready
	for i, func in ipairs(eventready) do func() end
	eventready = {}

	-- this function never stops as long as we have any function that could take action (or the display is active, so the human could start something)
	-- dit gaat niet werken nu, moet nog aangepast worden !!!
	while coresystem.IsRunning() do

        -- listen for new messages, remember the time
		local event, p1, p2, p3, p4, p5 = CoreEventPullEvent()
		local now                       = os.clock()
		local originalEvent             = event

		-- if it is a modem message or timer, pre process the message so it's decompiled
		if event == "modem_message" then event, p1, p2, p3, p4, p5 = ProcessModemMessageEvent(p1, p2, p3, p4, p5) end
		if event == "timer"		    then event, p1, p2, p3, p4, p5 = ProcessTimerEvent(p1) end

		-- log not ignored events
		if not ignore[event] then
 			-- log to file
			if db.debug then coreutils.WriteToFile(db.logfile, tostring(coreutils.UniversalTime()) .. " " .. "event = " .. event .. ", p1 = " .. (p1 or ""), "a") end

			-- should we log this event
			if originalEvent ~= "modem_message" or event == "modem_message" then EventToLog(event, p1) end
		end

		-- dispatch event to the right listener
		if      type(listener[event]) == "function"                                             then listener[event](p1, p2, p3, p4, p5)
		elseif  type(listener[event]) == "table" and type(listener[event][p1]) == "function"    then listener[event][p1](p1, p2, p3, p4, p5)
		end

        -- time mesurement, to see how long this took
		local period = os.clock() - now
		if period > 0.16 then
		    coredisplay.UpdateToDisplay("WARNING: "..event.." ("..(p1 or '')..") took "..period.." seconds", 5)
		    corelog.WriteToLog("WARNING: "..event.." ("..(p1 or '')..") took "..period.." seconds")
		end
	end

	-- show we are done!
	print("coreevent.Run() is complete")
end

local function SendBulkMessages()
	-- only when working in bulk mode
	if coreenv.GetVariable(db.protocol, "bulkMode") == false then return end

	-- send the bulk messages
	for channel, data in pairs(db.toBulkSend) do

		-- send data as array of messages
		coreevent.SendMessage({
			to			= channel,
			channel		= channel,
			protocol	= db.protocol,
			subject		= "bulk message",
			message		= { messageList = data }
		})

		-- done with this one
		db.toBulkSend[ channel ] = nil
	end
end

-- idle thing for event
function DoIdle()
	-- usefull for debugging, what's waiting in the reply (if anything is)
	if #db.reply > 0 then coreutils.WriteToFile(db.logfile, db.reply) end
end

-- uit een oude utils versie
function EventToLog(eventName, p1)
--	if db.logChannel then
--		SendMessage({to=db.logChannel, proto="util", subject="event to log", message={event=eventName, p1=p1}})
--	end
end

--                         _
--                        | |
--     _____   _____ _ __ | |_ ___
--    / _ \ \ / / _ \ '_ \| __/ __|
--   |  __/\ V /  __/ | | | |_\__ \
--    \___| \_/ \___|_| |_|\__|___/
--
--

function coreevent.DoEventBulkMessagse(subject, envelope)
	-- parse bulk message to local messages
	for i, messageString in ipairs(envelope.message.messageList) do

		-- this is our message
		local insideEnvelope = textutils.unserialize(messageString)

		-- this the result, an entry in the table
		table.insert(db.toProcess, {
			insideEnvelope.protocol, insideEnvelope.subject, insideEnvelope, nil, nil, nil
		})
	end
end

function coreevent.DoEventTickTimer(subject, envelope)
	-- todo: consider working with handlers

	-- send bulk messages
	SendBulkMessages()

	-- set new timer for the next tick
	coreevent.CreateTimeEvent(1, db.protocol, "tick timer")
end

return coreevent
