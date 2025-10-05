

for n=1,3 do
	for n=1,60 do
		turtle.dig()
		turtle.forward()
		turtle.turnRight()
		turtle.dig()
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.dig()
		turtle.turnRight()
	end

	turtle.digUp()
	turtle.up()
	turtle.turnRight()
	turtle.dig()
	turtle.turnRight()
	turtle.turnRight()
	turtle.dig()
	turtle.turnLeft()

	for n=1,60 do
		turtle.dig()
		turtle.forward()
		turtle.turnRight()
		turtle.dig()
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.dig()
		turtle.turnRight()
	end

	turtle.down()
	turtle.turnRight()
	turtle.forward()
	turtle.forward()
	turtle.forward()
	turtle.turnRight()
end

--os.loadAPI( "/rom/apis/system" )

--require "/rom/apis/core/dht"
--require "/rom/apis/core/event"
--require "/rom/apis/core/utils"

--system.Run()

--local squareSize = 6
--local x = 10
--local y = 5
--
----system.Run()
--function Run()
--    -- get into position
--    MoveForward(1.5 * squareSize)
--
--    -- start doing business
--    for i=1,y do
--        MoveForward(8 * squareSize)
--        move.Right()
--        MoveForward(squareSize)
--        move.Right()
--        MoveForward(8 * squareSize)
--
--        -- don't move on when it's the last time
--        if i < y then
--            move.Left()
--            MoveForward(squareSize)
--            move.Left()
--        end
--    end
--
--    -- get back to home
--    MoveForward(squareSize)
--    move.Right()
--    MoveForward(9 * squareSize)
--    move.Right()
--    move.Backward(0.5 * squareSize)
--end
--
--function MoveForward(number)
--  while number > 0 do
--		if turtle.detect()  then CutTree()
--                            else move.Forward(1, true)
--	  end
--
--    number = number - 1
--  end
--end
--
--
--function GetSapplings()
--    turtle.dig()
--    move.Forward(1, true)
--    turtle.digUp()
--    turtle.digDown()
--end
--
--function CutTree()
--    local succes, woodType	= turtle.inspect()
--    local name              = woodType.name
--    local z                 = 0
--
--    print( succes )
--    print( woodType )
--
--    -- inspect must succeed
--    if success == false then return true end
--
--    print("Let's go!")
--
--    -- get into position
--    turtle.dig()
--    move.Forward(1, true)
--
--    --  chop down and plant a new sapling
--    turtle.digDown()
--    turtle.select(1)
--    turtle.placeDown()
--
--    -- go up while we see more wood
--   	while type(woodType) == "table" and name == woodType.name do
--		turtle.digUp()
--		move.Up(1, true)
--		z = z + 1
--		succes, woodType = turtle.inspectUp()
--	end
--
--	-- get ready for sapling gathering
--	turtle.digUp()
--    move.Down(1, true)
--
--    -- here we go!
--    GetSapplings()
--    move.Left()
--    GetSapplings()
--    move.Left()
--    GetSapplings()
--    GetSapplings()
--    move.Left()
--    GetSapplings()
--    GetSapplings()
--    move.Left()
--    GetSapplings()
--    GetSapplings()
--    GetSapplings()
--    move.Right()
--    GetSapplings()
--    move.Right()
--    GetSapplings()
--    GetSapplings()
--    GetSapplings()
--    GetSapplings()
--    move.Right()
--    GetSapplings()
--    GetSapplings()
--    GetSapplings()
--    GetSapplings()
--    move.Right()
--    GetSapplings()
--    GetSapplings()
--    GetSapplings()
--    GetSapplings()
--    move.Right()
--    GetSapplings()
--    GetSapplings()
--
--    -- back to starting position
--    move.Left()
--    move.Backward(2, true)
--    move.Down(z - 1, true)
--end
--
--Run()
