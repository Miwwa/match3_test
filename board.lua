local DIFFERENT_ELEMENTS_COUNT = 6
local MATCHED_ELEMENTS_IN_ROW = 3

local M = {}
local board = {}

--- get element from board by coords
-- @param x row
-- @param y column
-- return -1 if coords out of board
local function getAt(x, y)
    if not M.validateCoords(x, y) then
        return -1
    end
    return board[x][y]
end

--- helper function for generate board without matches
local function isMatch(x, y)
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

    return horizontalMatch(x, y) or verticalMatch(x, y)
end

--- board have at least one match?
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

--- swap board elements
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

--- Make new random board without matches
-- @param sizeX Rows count
-- @param sizeY Columns count
-- @param seed Random seed, optional
--
function M.init(sizeX, sizeY, seed)
    if sizeX < 2 or sizeY < 2 then
        return 'Minimum board size is 2x2'
    end

    if M.seed == nil or seed ~= M.seed then
        M.seed = tonumber(seed) or os.time()
        math.randomseed(M.seed)
    end

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
-- return 'true' if move makes new matches, else string error
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

--- find matches on board, remove them, fall down elements and generate new
--- return 'true' if board have matches, else 'false'
function M.tick()
    local removeMap = {}
    for i = 1, #board do
        removeMap[i] = {}
        for j = 1, #board[i] do
            removeMap[i][j] = 0
        end
    end

    local function handleHorizontalMatches()
        for i = 1, #board do
            local colorStreak = 1
            local currentColor = 0
            local startStreak = 0

            for j = 1, #board[i] do
                if getAt(i, j) == currentColor then
                    colorStreak = colorStreak + 1
                end
                if getAt(i, j) ~= currentColor or j == #board[i] then
                    if colorStreak >= MATCHED_ELEMENTS_IN_ROW then
--                        print("HORIZONTAL :: Length = " .. colorStreak .. " :: Start = (" .. i .. "," .. startStreak .. ") :: Color = " .. currentColor);
                        for k = 0, colorStreak - 1 do
                            removeMap[i][startStreak + k] = 1
                        end
                    end
                    startStreak = j
                    colorStreak = 1
                    currentColor = getAt(i, j)
                end
            end
        end
    end

    local function handleVerticalMatches()
        for i = 1, #board do
            local colorStreak = 1
            local currentColor = 0
            local startStreak = 0

            for j = 1, #board[i] do
                if getAt(j, i) == currentColor then
                    colorStreak = colorStreak + 1
                end
                if getAt(j, i) ~= currentColor or j == #board then
                    if colorStreak >= MATCHED_ELEMENTS_IN_ROW then
--                        print("VERTICAL :: Length = " .. colorStreak .. " :: Start = (" .. startStreak .. "," .. i .. ") :: Color = " .. currentColor);
                        for k = 0, colorStreak - 1 do
                            removeMap[startStreak + k][i] = 1
                        end
                    end
                    startStreak = j
                    colorStreak = 1
                    currentColor = getAt(j, i)
                end
            end
        end
    end

    local function deleteMatches()
        local deleted = 0
        for i = 1, #board do
            for j = 1, #board[i] do
                if removeMap[i][j] > 0 then
                    board[i][j] = 0
                    deleted = deleted + 1
                end
            end
        end
        return deleted
    end

    local function fallDown()
        for column = 1, #board[1] do
            local swapped = false
            repeat
                swapped = false
                for i = 2, #board do
                    if board[i][column] == 0 and board[i - 1][column] ~= 0 then
                        swapElements({ x = i, y = column }, { x = i - 1, y = column })
                        swapped = true
                    end
                end
            until not swapped
        end
    end

    local function fillBoard()
        for i = 1, #board do
            for j = 1, #board[i] do
                if board[i][j] == 0 then
                    board[i][j] = math.random(1, DIFFERENT_ELEMENTS_COUNT)
                end
            end
        end
    end

    handleHorizontalMatches()
    handleVerticalMatches()
    local deleted = deleteMatches()

--    print('Before fall')
--    print(M.dump())

    if deleted > 0 then
        fallDown()
--        print('After fall')
--        print(M.dump())
        fillBoard()
--        print('After fill')
--        print(M.dump())
        return true
    else
        return false
    end
end

--- shaffle board elements to create possible moves
function M.mix()
    M.init(#board, #board[1], M.seed)
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
