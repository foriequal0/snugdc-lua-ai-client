local colors = {"BLUE", "RED"}
local board_values = {0, 1, 2, 3}
local moves = {"UP", "LEFT", "RIGHT", "DOWN"}
local move_results = {"SUCCESS", "FAIL"}
local enemy_results = {"UP", "LEFT", "RIGHT", "DOWN", "FAIL"}
local results = {"CONTINUE", "WIN", "LOSE"}

local function contains(tbl, val)
   for k, value in pairs(tbl) do
      if value == val then
         return true
      end
   end
   return false
end

function join(ch, ...)
   local n = select('#', ...)
   local res = ""
   for i = 1, n do
      local x = select(i, ...)
      if i > 1 then
         res = res .. ch
      end
      if x == nil then
         res = res .. "nil"
      else
         res = res .. tostring(x)
      end
   end
   return res
end

local function arr2str(arr)
   return "{" .. join(", ", unpack(arr)) .. "}"
end

local client = {}

local function moveto(curr, move)
   if move == "UP" then
      return {curr[1], curr[2] + 1}
   elseif move == "DOWN" then
      return {curr[1], curr[2] - 1}
   elseif move == "LEFT" then
      return {curr[1] - 1, curr[2]}
   elseif move == "RIGHT" then
      return {curr[1] + 1, curr[2]}
   end
end

--[[
   - Arguments
   move: 움직이길 원하는 방향 ("UP" or "DOWN" or "LEFT" or "RIGHT")

   - Returns
   {
     success: (true or false), -- 움직임이 성공하면 true, 실패하면 false
     pick: (0 or 1 or 2 or 3), -- 움직여서 먹은 아이템의 타입. 0은 먹은게 없음.
     enemy: ("UP" or "DOWN" or "LEFT" or "RIGHT" or "FAIL") -- 상대방이 움직인 방향.
     enemypick: (0 or 1 or 2 or 3), -- 적이 움직여서 먹은 아이템의 타입. 0은 먹은게 없음.
     result: ("CONTINUE" or "WIN" or "LOSE" or "DRAW"), -- 다음 턴 계속, 승, 패, 무
   }
--]]
function client:end_turn_with(move)
   if self.last_result ~= nil and self.last_result.result ~= "CONTINUE" then
      return self.last_result
   end
   
   client:assert(contains(moves, move), "Move should be one of " .. arr2str(moves) .. ":", move)
   print(move)

   local move_result = io.read("*line")
   client:assert(contains(move_results, move_result),
                 "Unexpected server response on result:", move_result)

   local success = move_result == "SUCCESS"
   local pick = 0
   if success then
      local newpos = moveto(client:get_my_pos(), move)
      pick = self:get_board_at(newpos[1], newpos[2])
      client:assert(contains(board_values, pick), "Unexpected pick", pick)

      client:_set_my_pos(newpos)
      self.board[newpos[2]][newpos[1]] = 0
   end

   local enemy = io.read("*line")
   local enemypick = 0
   client:assert(contains(enemy_results, enemy), "Unexpected server response on enemy:", enemy)
   if enemy ~= "FAIL" then
      local newpos = moveto(client:get_enemy_pos(), enemy)
      enemypick = self:get_board_at(newpos[1], newpos[2])
      client:assert(contains(board_values, enemypick), "Unexpected enemy pick", enemypick)

      client:_set_enemy_pos(newpos)
      self.board[newpos[2]][newpos[1]] = 0
   end

   local result = io.read("*line")
   client:assert(contains(results, result),
                 "Unexpected server response on turn result", result)

   self.last_result = {
      success = success,
      pick = pick,
      enemy = enemy,
      enemypick = enemypick,
      result = result
   }

   return self.last_result
end

function client:finished()
   return self.last_result ~= nil and self.last_result.result ~= "CONTINUE"
end

function client:get_last_result()
   return self.last_result
end

--[[
   - Arguments
   x: 가로 좌표 [1, 10]
   y: 세로 좌표 [1, 10]

   - Returns
   nil -- x, y가 올바르지 않은 위치일 때
   or 0 -- 해당 좌표에 아무것도 없을 때
   or 1 or 2 or 3 -- 해당 좌표에 있는 아이템
   or "ME" -- 나
   or "ENEMY" --적
--]]
function client:get_board_at(x, y)
   if not (x >= 1 and x <= 10 and y >= 1 and y <= 10) then
      return nil
   end

   local my = self:get_my_pos()
   local enemy = self:get_enemy_pos()

   if x == my[1] and y == my[2] then
      return "ME"
   elseif x == enemy[1] and y == enemy[2] then
      return "ENEMY"
   end

   return self.board[y][x]
end

--[[
   - Arguments
   move: 움직이길 원하는 방향 ("UP" | "DOWN" | "LEFT" | "RIGHT")

   - Returns
   nil -- x, y가 올바르지 않은 위치일 때
   or 0 -- 해당 좌표에 아무것도 없을 때
   or 1 or 2 or 3 -- 해당 좌표에 있는 아이템
   or "ME" -- 나
   or "ENEMY" --적
--]]
function client:get_board_dir(move)
   client:assert(contains(moves, move), "Move should be one of " .. arr2str(moves) .. ":", move)
   
   local my = self:get_my_pos()
   local to = moveto(my, move)

   return self:get_board_at(to[1], to[2])
end

--[[
   - Returns
   "RED" or "BLUE": 내 색깔
--]]
function client:get_my_color()
   return self.color
end

--[[
   - Returns
   "RED" or "BLUE": 적 색깔
--]]
function client:get_enemy_color()
   if self.color == "RED" then
      return "BLUE"
   else
      return "RED"
   end
end

--[[
   - Returns
   { [1]=x, [2]=y }: 내 현재 위치
--]]
function client:get_my_pos()
   return self.pos[self:get_my_color()]
end

function client:_set_my_pos(pos)
   self.pos[self:get_my_color()] = pos
end

--[[
   - Returns
   { [1]=x, [2]=y }: 적 현재 위치
--]]
function client:get_enemy_pos()
   return self.pos[self:get_enemy_color()]
end

function client:_set_enemy_pos(pos)
   self.pos[self:get_enemy_color()] = pos
end

function client:log(...)
   assert(self.logfile, "Log file wasn't opened")
   self.logfile:write("(" .. self.color .. ") [LOG] " .. join(" ", ...), "\n")
end

function client:error(...)
   assert(self.logfile, "Log file wasn't opened")
   self.logfile:write("(" .. self.color .. ") [ERROR] " .. join(" " , ...), "\n")
end

function client:assert(cond, ...)
   if not cond then
      self:error("Assertion Failed -", ...)
      self:error("Exit")
      os.exit(-1)
   end
end

-- Initialize
do
   -- get color
   local color = io.read("*line")
   assert(color, "Color nil")
   assert(contains(colors, color), "Wrong color received:", color) -- log file not ready
   client.color = color

   -- open error log
   client.logfile = io.open(color .. ".log", "a")
   assert(client.logfile, "Log File cannot be opened:", color .. ".log")

   -- read board
   local board = {}
   for row = 1,10 do
      local line = {}
      for column = 1,10 do
         local value = io.read("*number")
         client:assert(value, "Board value nil")
         client:assert(contains(board_values, value), "This is not valid board value: " .. value)
         table.insert(line, value)
      end
      table.insert(board, line)
   end
   client.board = board

   -- read initial position
   local red_x = io.read("*number")
   client:assert(red_x and red_x >= 1 and red_x <= 10, "Red x position out of range [1,10]: ", red_x)
   local red_y = io.read("*number")
   client:assert(red_y and red_y >= 1 and red_y <= 10, "Red y position out of range [1,10]")
   local blue_x = io.read("*number")
   client:assert(blue_x and blue_x >= 1 and blue_x <= 10, "Blue x position out of range [1,10]")
   local blue_y = io.read("*number")
   client:assert(blue_y and blue_y >= 1 and blue_y <= 10, "Blue y position out of range [1,10]")
   local consume_eol = io.read("*number")
   client.pos = {
      RED = {red_x, red_y},
      BLUE= {blue_x, blue_y}
   }

   client:log("Initialized")
end

return client
