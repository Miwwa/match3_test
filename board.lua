local inspect = require 'inspect'
local DIFFERENT_ELEMENTS_COUNT = 7

local M = {}

-- board representation
local table = {}

--- Make new random board
-- @param sizeX Rows count
-- @param sizeY Columns count
-- @param seed Random seed, optional
--
function M.init(sizeX, sizeY, seed)
    table = {}
    math.randomseed(seed or os.time())
    for i = 1, sizeX do
        table[i] = {}
        for j = 1, sizeY do
            table[i][j] = math.random(1, DIFFERENT_ELEMENTS_COUNT)
        end
    end
end

--- Check coords out of table border
-- @param position table with 'x' and 'y' properties
--
function M.validateCoords(position)
    return not (tonumber(position.x) == nil or tonumber(position.y) == nil
            or position.x < 1 or position.x > #table
            or position.y < 1 or position.y > #table[1])
end

--- swap board elements
-- @param from from position
-- @param to to position
--
function M.move(from, to)
    if not M.validateCoords(from) then
        return 'From position out of board: ' .. inspect(from)
    end
    if not M.validateCoords(to) then
        return 'To position out of board: ' .. inspect(to)
    end

    local temp = table[from.x][from.y]
    table[from.x][from.y] = table[to.x][to.y]
    table[to.x][to.y] = temp

    return true
end

--- return a string representation of game board
function M.dump()
    -- code of 'A' symbol
    local startSymbol = 64

    -- create table header
    local out = '\t  '
    for i = 1, #table[1] do
        out = out .. i .. ' '
    end
    out = out .. '\n\t--'
    for i = 1, #table[1] do
        out = out .. '--'
    end
    out = out .. '\n'

    for i = 1, #table do
        out = out .. i .. '\t| '
        for j = 1, #table[i] do
            local symbol = string.char(startSymbol + table[i][j])
            out = out .. symbol .. ' '
        end
        out = out .. '\n'
    end
    return out
end

return M
