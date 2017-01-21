# snugdc-lua-ai-client
## Installation
  * ```client.lua```파일을 프로그램이 있는 곳에 다운받으세요.
  * 다음 문장을 프로그램 첫째줄에 붙여넣어 클라이언트 라이브러리를 로드하게끔 하면 사용 준비는 끝난겁니다.
```lua
local client = require "client"
```
  * 예제코드는 sample-random.lua 를 참고하세요

## 함수

### client:end_turn_with(move)
해당 방향으로 나를 움직이고 턴을 종료합니다. 게임이 끝났으면 더이상 턴을 진행하지 않고, 마지막 턴의 결과를 그대로 돌려줍니다.

#### Arguments
   * move: 움직이길 원하는 방향 ```("UP" or "DOWN" or "LEFT" or "RIGHT")```

#### Returns
```lua
   {
     success: (true or false), -- 움직임이 성공하면 true, 실패하면 false
     pick: (0 or 1 or 2 or 3), -- 움직여서 먹은 아이템의 타입. 0은 먹은게 없음.
     enemy: ("UP" or "DOWN" or "LEFT" or "RIGHT" or "FAIL") -- 상대방이 움직인 방향.
     enemypick: (0 or 1 or 2 or 3), -- 적이 움직여서 먹은 아이템의 타입. 0은 먹은게 없음.
     result: ("CONTINUE" or "WIN" or "LOSE" or "DRAW"), -- 다음 턴 계속, 승, 패, 무
   }
```

### client:finished()
게임이 끝났는지 확인합니다.

#### Returns
```lua
true or false -- 게임이 끝났으면 true, 턴을 계속 해야하면 false
```


### client:get_last_result()
마지막 턴의 결과를 가져옵니다.

#### Returns
```client::end_turn_with(move)``` 와 동일


### client:get_board_at(x, y)
게임 보드 상의 x, y 좌표에 무엇이 있는지 가져옵니다.

#### Arguments
   * x: 가로 좌표 [1, 10]
   * y: 세로 좌표 [1, 10]

#### Returns
```lua
   nil -- x, y가 게임판 밖의 좌표일 때
   or 0 -- 해당 좌표에 아무것도 없을 때
   or 1 or 2 or 3 -- 해당 좌표에 각각 딸기, 오렌지, 사과 가 있을 때
   or "ME" -- 해당 좌표에 내가 있을 때
   or "ENEMY" -- 해당 좌표에 적이 있을 때
```


### client:get_board_dir(move)
내 캐릭터가 move 방향으로 움직였을 때, 그 자리에 무엇이 있는지 가져옵니다.

#### Arguments
   * move: 움직이길 원하는 방향 ```("UP" or "DOWN" or "LEFT" or "RIGHT")```

#### Returns
```client:get_board_at(x, y)```와 동


### client:get_my_color(), client:get_enemy_color()

#### Returns
```lua
"RED" or "BLUE"
```

### client:get_my_pos(), client:get_enemy_pos()

#### Returns
```lua
{ [1] = x, [2] = y }
```

### client:log(...)
디버그 로그를 찍는데 씁시다.
