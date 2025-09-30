-- define module
local coreinventory = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local corelog = require "corelog"
local coredht = require "coredht"
local coreutils = require "coreutils"

local db	= {
	dbFilename  = "/db/coreinventory.lua",
	protocol	= "coreinventory",
    left        = "",
    right       = "",
}

-- init, read last db from file
function coreinventory.Init()
	-- read from file
	local dbFile = coreutils.ReadTableFromFile(db.dbFilename)

	-- check for empty table --> https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
	if turtle and next(dbFile) == nil then

        -- no db file found check for peripheral on the left
        db['left'] = (peripheral.getType("left") or "")

        -- check for tool on the right
        if coreinventory.GetEmptySlot() then

            -- should be no peripheral on the right
            if peripheral.getType("right") then

                -- not welcome on the right side
                turtle.equipRight()

            else

                -- remove any item on the right
                turtle.equipRight()

                -- anything present?
                local itemDetails = turtle.getItemDetail()

                -- anything present?
                if itemDetails ~= nil then

                    -- remember
                    db['right'] = itemDetails.name

                    -- re-equip
                    turtle.equipRight()
                end
            end
        end

        -- write what we have to disk
        coreutils.WriteToFile(db.dbFilename, db, "overwrite")
    else
        -- load the table from file
        db = dbFile
    end
end

local function DHTReadySetup()
    -- controleren of dht root bestaat
    if not coredht.GetData("allItems") then coreinventory.ResetAllItems() end
end

function coreinventory.Setup()
    -- niks te doen voor setup
    coredht.DHTReadyFunction(DHTReadySetup)
end

function coreinventory.ResetAllItems()
    coredht.SaveData({}, "allItems")
end

function coreinventory.GetEmptySlot(list)
    -- list is an optional table containing which slots are allowed

    -- alle slots nalopen
    for slot = 1, 16 do

        -- alleen een optie als we geen lijst gekregen hebben of de lijst aangeeft dat deze gebruikt mag worden
        if not list or list[slot] then

            -- wat zit er in dit slot
            local data = coreinventory.GetItemDetail(slot)

            -- deze slot wel het juiste item?
            if not data then

                -- deze selecteren
                turtle.select(slot)

                -- en we zijn klaar
                return slot
            end
        end
    end

    -- geen empty slot gevonden
    return false
end

function coreinventory.GetItemDetail(slot)
    -- wrap around turtle.getItemDetail to store all known information about items

    -- informatie ophalen
    local data = turtle.getItemDetail(slot)

    -- controleren of dit item al bekend is
    if data and not coredht.GetData("allItems", data.name) and coredht.IsReady() then
        coredht.SaveData({
            name        = data.name,
            stackSize   = turtle.getItemCount(slot) + turtle.getItemSpace(slot),
        }, "allItems", data.name)
    end

    -- klaar
    return data
end

function coreinventory.GetStackSize(itemName)
    -- return what the dht has, otherwise 64 as default value
    return coredht.GetData("allItems", itemName, "stackSize") or 64
end

function coreinventory.SelectItem(itemName)
    -- eerst huidige slot onderzoeken
    local data = coreinventory.GetItemDetail()

    -- juiste?
    if data and data.name == itemName then return true end

    -- alle slots nalopen
    for slot = 1, 16 do

        -- wat zit er in dit slot
        data = coreinventory.GetItemDetail(slot)

        -- deze slot wel het juiste item?
        if data and data.name == itemName then

            -- deze selecteren
            turtle.select(slot)

            -- en we zijn klaar
            return true
        end
    end

    -- niet gevonden, niet zo best
    return false
end

function coreinventory.CountItem(itemName)
    -- keep itemCount
    local itemCount = 0

    -- loop all slots
    for slot=1,16 do

        -- get detailed information about this slot
        local itemDetail = coreinventory.GetItemDetail(slot)

        -- right item?
        if type(itemDetail) == "table" and itemDetail.name == itemName then itemCount = itemCount + itemDetail.count end
    end

    -- we're done
    return itemCount
end

function coreinventory.GetAllItems(direction)
    local f    = turtle.suck

    -- andere richting?
    if direction == "up"   or direction == "Up"     then f = turtle.suckUp    end
    if direction == "down" or direction == "Down"   then f = turtle.suckDown  end

    -- net zo langs spullen opzuigen totdat er niks meer verplaatst (om welke rede dan ook)
    while f() do end
end

function coreinventory.GetInventoryDetail()
    -- to hold the data
    local inventory = {
        items   = {},
        slots   = {},
    }

    -- loop all slots
    for slot=1,16 do

        -- get detailed information about this slot
        local itemDetail = coreinventory.GetItemDetail(slot)

        -- right item?
        if type(itemDetail) == "table" then

            -- add to items
            inventory.items[ itemDetail.name ]  = (inventory.items[ itemDetail.name ] or 0) + itemDetail.count

            -- add to slots, name and count
            inventory.slots[ slot ]             = {
                itemName    = itemDetail.name,
                itemCount   = itemDetail.count,
            }
        end
    end

    -- we're done
    return inventory
end

function coreinventory.DropAllItems(direction)
    -- check the direction, lowercase only
    direction = direction or "down"
    direction = string.lower(direction)

    -- we will organize what we dropped, who knows who cares
    local cargoList = {}

    -- alle slots nalopen
    for slot = 1, 16 do

        -- select it
        turtle.select(slot)

        -- for the cargoList
        local itemData = coreinventory.GetItemDetail(slot)

        -- add to the cargoList
        if itemData then cargoList[ itemData.name ] = (cargoList[ itemData.name ] or 0) + itemData.count end

        -- actually drop this shit in the right direction
        if      direction == "up"   then turtle.dropUp()
        elseif  direction == "down" then turtle.dropDown()
                                    else turtle.drop()
        end
    end

    -- nicely done!
    return cargoList
end

function coreinventory.DropAll(itemName, direction)
    -- check the direction, lowercase only
    direction = direction or "front"
    direction = string.lower(direction)

    -- alle slots nalopen
    for slot = 1, 16 do

        -- wat zit er in dit slot
        local data = coreinventory.GetItemDetail(slot)

        -- deze slot wel het juiste item?
        if data and data.name == itemName then

            -- deze selecteren
            turtle.select(slot)

            -- juiste richting zoeken
            if      direction == "up"   or direction == "Up"    then turtle.dropUp()
            elseif  direction == "down" or direction == "Down"  then turtle.dropDown()
                                                                else turtle.drop()
            end
        end
    end
end

function coreinventory.CanEquip(itemName)

    -- might just already be equiped or maybe in the inventory
    return db.left == itemName or db.right == itemName or coreinventory.CountItem(itemName) > 0

end

function coreinventory.LeftEquiped()
    return db.left
end

function coreinventory.RightEquiped()
    return db.right
end

function coreinventory.Equip(itemName, requestedSide)
    local slot = nil

    -- right side is default
    requestedSide = requestedSide or 'right'

    -- already equiped? We DO care about the right side!
    if (requestedSide == 'left' and db.left == itemName) or (requestedSide == 'right' and db.right == itemName) then return true end

    -- maybe the wrond side?
    if (requestedSide == 'left' and db.right == itemName) or (requestedSide == 'right' and db.left == itemName) then

        -- just unequip, the rest of the code  will take of equiping
        coreinventory.GetEmptySlot()
        if db.right == itemName then turtle.equipRight()
                                else turtle.equipLeft()
        end
    end

    -- find empty spot (remove current equiped to the right when we have an empty spot)
    if coreinventory.GetEmptySlot() then

        -- remember this slot
        slot = turtle.getSelectedSlot()

        -- remove item on the right side (modem on the left) if there is anything equiped ofcourse
        if requestedSide == 'left'  then turtle.equipLeft()
                                    else turtle.equipRight()
        end
    end

    -- find the requested item
    if coreinventory.SelectItem(itemName) then

        -- remember this
        db[requestedSide] = itemName

       	-- write to disk
        coreutils.WriteToFile(db.dbFilename, db, "overwrite")

        -- great!
        if requestedSide == 'left'  then return turtle.equipLeft()
                                    else return turtle.equipRight()
        end
    else

        -- message to the log
        corelog.Warning("coreinventory.Equip: Could not find "..itemName.." => not equiped")

        -- not found, restore
        if slot then
            turtle.select(slot)
            if requestedSide == 'left'  then turtle.equipLeft()
                                        else turtle.equipRight()
            end
        end

        -- done
        return nil
    end
end

return coreinventory
