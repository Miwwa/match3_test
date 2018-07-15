local DIFFERENT_ELEMENTS_COUNT = 7
local MATCHED_ELEMENTS_IN_ROW = 3

local M = {}
local board = {}

local function getAt(x, y)
    if not M.validateCoords(x, y) then
        return -1
    end
    return board[x][y]
end

local function horizontalMatch(x, y)
    local result = true
    for i = 1, MATCHED_ELEMENTS_IN_ROW - 1 do
        result = result and getAt(x, y) == getAt(x, y - i)
    end
    return result
end

local function verticalMatch(x, y)
    local result = true
    for i = 1, MATCHED_ELEMENTS_IN_ROW - 1 do
        result = result and getAt(x, y) == getAt(x - i, y)
    end
    return result
end

local function isMatch(x, y)
    return horizontalMatch(x, y) or verticalMatch(x, y)
end

local function haveMatchesOnBoard()
    for i = 1, #board do
        for j = 1, #board[1] do
            if isMatch(i, j) then
                return true
            end
        end
    end
    return false
end

---  swap board elements
-- @param from first element position
-- @param to second element position
--
local function swapElements(from, to)
    local temp = board[from.x][from.y]
    board[from.x][from.y] = board[to.x][to.y]
    board[to.x][to.y] = temp
end

--- return possible moves to have matches
function M.findPossibleMoves()
    -- yes, it's bruteforce
    -- no, I no have idea how optimize it for generic situation

    local function tryMove(from, to)
        if not M.validateCoords(from.x, from.y) or not M.validateCoords(to.x, to.y) then
            return false
        end

        swapElements(from, to)
        local haveMatches = haveMatchesOnBoard()
        swapElements(from, to)
        return haveMatches
    end

    local moves = {}
    for i = 1, #board do
        for j = 1, #board[i] do
            local from = { x = i, y = j }
            local tryMovePositions = {
                { x = i, y = j - 1 },
                { x = i, y = j + 1 },
                { x = i - 1, y = j },
                { x = i + 1, y = j }
            }
            for m, to in ipairs(tryMovePositions) do
                if tryMove(from, to) then
                    table.insert(moves, { from = from, to = to })
                end
            end
        end
    end
    return moves
end

--- Make new random board
-- @param sizeX Rows count
-- @param sizeY Columns count
-- @param seed Random seed, optional
--
function M.init(sizeX, sizeY, seed)
    if sizeX < 2 or sizeY < 2 then
        return 'Minimum board size is 2x2'
    end

    M.seed = tonumber(seed) or os.time()
    math.randomseed(M.seed)

    repeat
        board = {}

        for i = 1, sizeX do
            board[i] = {}
            for j = 1, sizeY do
                -- for generate board without matches
                repeat
                    board[i][j] = math.random(1, DIFFERENT_ELEMENTS_COUNT)
                until not isMatch(i, j)
            end
        end
    until #M.findPossibleMoves() > 0 -- regenerage board if not have possible moves
end

--- Check coords out of table border
-- @param position table with 'x' and 'y' properties
--
function M.validateCoords(x, y)
    return not (tonumber(x) == nil or tonumber(y) == nil
            or x < 1 or x > #board
            or y < 1 or y > #board[x])
end

--- swap board elements
-- @param from from position
-- @param to to position
--
function M.move(from, to)
    if not M.validateCoords(from.x, from.y) then
        return 'From position out of board: ' .. from.x .. ' ' .. from.y
    end
    if not M.validateCoords(to.x, to.y) then
        return 'To position out of board: ' .. to.x .. ' ' .. to.y
    end

    swapElements(from, to)

    if not haveMatchesOnBoard() then
        swapElements(from, to)
        return 'No have matches with this move'
    end

    return true
end

--- return a string representation of game board
function M.dump()
    -- code of 'A' symbol
    local startSymbol = 64

    -- create table header
    local out = '\t  '
    for i = 1, #board[1] do
        out = out .. i .. ' '
    end
    out = out .. '\n\t--'
    for i = 1, #board[1] do
        out = out .. '--'
    end
    out = out .. '\n'

    for i = 1, #board do
        out = out .. i .. '\t| '
        for j = 1, #board[i] do
            local symbol = string.char(startSymbol + board[i][j])
            out = out .. symbol .. ' '
        end
        out = out .. '\n'
    end
    return out
end

return M
