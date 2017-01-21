local client = require "client"

math.randomseed(os.time())

-- 내 색깔 확인
client:log("My color is", client:get_my_color())
local pos = client:get_my_pos()
client:log("My position is", pos[1], pos[2])

-- 적 색깔 확인
client:log("Enemy color is", client:get_enemy_color())
local enemypos = client:get_enemy_pos()
client:log("Enemy position is", enemypos[1], enemypos[2])

-- 본격 플레이
while not client:finished() do
   local dir = nil
   while true do
      local dirs = {"UP", "DOWN", "LEFT", "RIGHT"}
      dir = dirs[math.random(4)] -- 네 방향중 무작위로 찍어서
      board = client:get_board_dir(dir) -- 그 방향에 뭐가 있는지 가져와보고
      if board ~= nil then -- 보드를 벗어난게 아니라면(뭐라도 있으면)
         break -- 그방향으로 결정
      end
   end

   client:end_turn_with(dir) -- 이 함수를 한 번 부르면 턴이 하나 소모됨.
end


-- 게임 끝났고 결과 표시
local result = client:get_last_result()
if result.result == "WIN" then
   client:log("I won")
elseif result.result == "LOSE" then
   client:log("I lose")
elseif result.result == "DRAW" then
   client:log("I draw")
else
   client:error("How could?!", result)
end
