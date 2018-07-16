local board = require './board'

local BOARD_SIZE_X = 6
local BOARD_SIZE_Y = 6

board.init(BOARD_SIZE_X, BOARD_SIZE_Y, 1531651838)
io.write('Game seed: ' .. board.seed)

local function printHelp()
    local help = [[
Available commands:
 - q : quit application
 - m 'x' 'y' 'dir' : where 'x' is row position, 'y' is column position, 'dir' is move direction:
                     'l' for left, 'r' for right, 'u' for up, 'd' for down
]]
    io.write(help)
end

local function parseInput(input)
    local args = {}
    for word in input:gmatch('%w+') do table.insert(args, word) end

    if #args == 0 or args[1] == 'help' then
        return printHelp
    end
    if args[1] == 'm' and #args == 4 then
        local x = tonumber(args[2])
        local y = tonumber(args[3])
        local dir = args[4]

        if x == nil or y == nil then
            return nil, 'move from position must be a number'
        end

        local from = {
            x = x,
            y = y
        }
        local to = {}

        if dir == 'l' then
            to = { x = x, y = y - 1 }
        elseif dir == 'r' then
            to = { x = x, y = y + 1 }
        elseif dir == 'u' then
            to = { x = x - 1, y = y }
        elseif dir == 'd' then
            to = { x = x + 1, y = y }
        else
            return nil, 'Unknown direction ' .. dir
        end

        return function()
            local moveResult = board.move(from, to)
            io.write('\nAfter move: \n' .. board.dump())
            if moveResult == true then
                while board.tick() == true do
                    io.write('\nAfter tick:\n' .. board.dump())
                end
                if #board.findPossibleMoves() == 0 then
                    io.write('\nNo have possible moves, mix board...')
                    board.mix()
                end
                return true
            else
                return moveResult
            end
        end
    end
    return nil, 'Unknown command, enter "help" to view available commands'
end

local input = ''
while input ~= 'q' do
    io.write('\nCurrent state:\n' .. board.dump() .. '\n>')
    io.flush()
    input = io.read('*line')

    local command, error = parseInput(input)

    if error then
        io.write(error)
    else
        local result = command()
        if type(result) == 'string' then
            io.write(result)
        end
    end
end