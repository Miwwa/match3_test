local board = require './board'

local BOARD_SIZE_X = 5
local BOARD_SIZE_Y = 3

board.init(BOARD_SIZE_X, BOARD_SIZE_Y)

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
            return board.move(from, to)
        end
    end
    return nil, 'Unknown command, enter "help" to view available commands'
end

local input = ''
while input ~= 'q' do
    io.write('\n' .. board.dump() .. '\n>')
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