# 붉은 달의 성채(Crimson Citadel)

## 기술 스택

- Java / Spring Boot
- Spring Web (REST API)
- Spring Data JPA / Hibernate
- MySQL
- Bean Validation (Jakarta Validation)
- Lombok

## ERD
    GAME {
        Long id PK
        String playerName
        int currentFloor
        int currentHp
        String phase
        String status
        LocalDateTime createdAt
        LocalDateTime updatedAt
    }

    RUN_CARD {
        Long id PK
        Long game_id FK
        String cardType
        int acquiredFloor
            
## 정의서

### 상태(Enum) 정의

**phase** — 게임이 멈춰 있는 단계

| 값 | 설명 |
|---|---|
| `BATTLE` | 전투 중. 다시 불러오면 해당 층의 전투가 이어진다. |
| `REWARD` | 보상 카드를 고르는 중. 시작 직후와 각 전투 승리 뒤에 머문다. |
| `FINISHED` | 여정이 끝났다. `status`가 `CLEARED` 또는 `FAILED`다. |

**status** — 게임의 결과 상태

| 값 | 설명 |
|---|---|
| `PLAYING` | 진행 중. 이어서 플레이할 수 있다. |
| `CLEARED` | 10층까지 모두 클리어했다. |
| `FAILED` | 도중에 HP가 0이 되어 실패했다. |

### 에러 응답 형식

검증 실패(`400`), 리소스 없음(`404`), 상태 충돌(`409`) 등 예외 상황은 아래 형식으로 응답

```json
{
  "status": 404,
  "error": "Not Found",
  "message": "게임을 찾을 수 없습니다. id=999",
  "path": "/games/999"
}
```

## API 명세

### 게임

| Method | URL | 설명 | 성공 | 실패 |
|---|---|---|---|---|
| `POST` | `/games` | 새 게임 생성 | `201` | `400` |
| `GET` | `/games` | 게임 목록 조회 (id 내림차순, 덱 미포함) | `200` | - |
| `GET` | `/games/{gameId}` | 게임 상세 조회 (전체 덱 포함) | `200` | `404` |
| `PATCH` | `/games/{gameId}` | 플레이어 이름 변경 | `204` | `400`, `404` |
| `DELETE` | `/games/{gameId}` | 게임과 소속 카드 삭제 | `204` | `404` |
| `PUT` | `/games/{gameId}/progress` | 진행 상황(HP·층·단계·상태)과 전체 덱 저장 | `200` | `400`, `404`, `409` |

#### `POST /games` — 게임 생성

플레이어 이름과 시작 덱으로 새 게임을 만든다. 덱은 요청 순서대로 저장된다. `currentHp=99`, `currentFloor=1`, `phase=REWARD`, `status=PLAYING`으로 초기화한다.

요청 본문

```json
{
  "playerName": "밤의 후계자",
  "deck": [
    { "cardType": "STRIKE", "acquiredFloor": 0 }
  ]
}
```

응답(`201`) — 생성된 게임의 상세(`id`, `playerName`, `currentFloor`, `currentHp`, `phase`, `status`, `createdAt`, `updatedAt`, `deck[]`). `Location` 헤더로 `/games/{id}`를 함께 내려줄 수 있다(선택).

#### `GET /games` — 게임 목록 조회

저장된 모든 게임을 ID 내림차순으로 반환한다. 덱은 포함하지 않고 `deckSize`(카드 수)만 포함한다. 저장된 게임이 없으면 빈 배열을 반환한다.

응답 항목 필드: `id`, `playerName`, `currentFloor`, `currentHp`, `phase`, `status`, `deckSize`, `createdAt`, `updatedAt`

#### `GET /games/{gameId}` — 게임 상세 조회

게임 한 건과 전체 덱을 반환한다. 덱은 카드 ID 오름차순이다. 없는 ID면 `404`.

#### `PATCH /games/{gameId}` — 플레이어 이름 변경

선택한 게임의 `playerName`만 변경한다. 다른 필드는 바뀌지 않는다. 성공 시 `204`(본문 없음).

요청 본문

```json
{ "playerName": "붉은 순례자" }
```

#### `DELETE /games/{gameId}` — 게임 삭제

게임과 그에 속한 모든 카드를 삭제한다. 성공 시 `204`(본문 없음).

#### `PUT /games/{gameId}/progress` — 진행과 전체 덱 저장

HP, 층, 단계, 상태와 전체 덱을 저장한다. `deck`은 추가할 카드가 아니라 **저장할 덱 전체**다. 게임 필드 갱신과 덱 교체는 원자적으로 처리되며, 기존 카드는 모두 제거되고 요청의 덱이 순서대로 다시 저장된다(같은 본문을 반복 전송해도 카드 수가 늘지 않음). 카드 ID는 교체할 때마다 새로 발급되므로 클라이언트는 응답의 덱을 사용해야 한다.

이미 종료된(`CLEARED`/`FAILED`) 게임에 진행을 저장하려 하면 `409`.

요청 본문

```json
{
  "currentHp": 47,
  "currentFloor": 5,
  "phase": "REWARD",
  "status": "PLAYING",
  "deck": [
    { "cardType": "STRIKE", "acquiredFloor": 0 }
  ]
}
```
\
