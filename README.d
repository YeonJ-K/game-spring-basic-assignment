# 붉은 달의 성채 REST API 명세서

  
#ERD

has
GAME
Long
id
PK
String
playerName
int
currentFloor
int
currentHp
String
phase
String
status
LocalDateTime
createdAt
LocalDateTime
updatedAt
RUN_CARD
Long
id
PK
Long
game_id
FK
String
cardType
int
acquiredFloor
