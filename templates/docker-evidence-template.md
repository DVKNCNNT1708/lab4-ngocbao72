# Docker Evidence – Lab 04

## Team

- Team name: team-iot
- Service: IoT Ingestion Service
- Image tag: ghcr.io/ngocbao72/team-iot:v0.1.0-team-iot

## 1. Build evidence

Command:

```bash
docker build -t fit4110/iot-ingestion:lab04 .
docker tag fit4110/iot-ingestion:lab04 ghcr.io/ngocbao72/team-iot:v0.1.0-team-iot
```

Build log:

```text
#0 building with "desktop-linux" instance using docker driver
#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 1.12kB done
#1 DONE 0.0s
#2 resolve image config for docker-image://docker.io/docker/dockerfile:1.7
#2 DONE 2.5s
#4 docker-image://docker.io/docker/dockerfile:1.7@sha256:a57df69d0ea827fb7266491f2813635de6f17269be881f696fbfdf2d83dda33e
#4 resolve docker.io/docker/dockerfile:1.7@sha256:a57df69d0ea827fb7266491f2813635de6f17269be881f696fbfdf2d83dda33e 0.0s done
#4 CACHED
#5 [internal] load metadata for docker.io/library/python:3.11-slim
#5 DONE 1.6s
#7 [internal] load .dockerignore
#7 transferring context: 233B done
#7 DONE 0.0s
#8 [builder 1/5] FROM docker.io/library/python:3.11-slim@sha256:ae52c5bef62a6bdd42cd1e8dffef86b9cd284bde9427da79839de7a4b983e7ca
#8 DONE 0.0s
#9 [internal] load build context
#9 transferring context: 8.18kB done
#9 DONE 0.0s
#10 [builder 2/5] WORKDIR /build
#10 CACHED
#11 [runtime 2/6] WORKDIR /app
#11 CACHED
#12 [runtime 3/6] RUN addgroup --system appgroup     && adduser --system --ingroup appgroup --home /app appuser
#12 CACHED
#13 [builder 4/5] COPY requirements.txt .
#13 CACHED
#14 [builder 3/5] RUN python -m venv /opt/venv
#14 CACHED
#15 [builder 5/5] RUN /opt/venv/bin/pip install --no-cache-dir --upgrade pip     && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt
#15 CACHED
#16 [runtime 4/6] COPY --from=builder /opt/venv /opt/venv
#16 CACHED
#17 [runtime 5/6] COPY src/ ./src/
#17 DONE 0.0s
#18 [runtime 6/6] RUN chown -R appuser:appgroup /app
#18 DONE 0.3s
#19 exporting to image
#19 exporting layers 0.1s done
#19 exporting manifest sha256:8b2d2bee0f0dbb8d98833f8713211268b99040f273a285395cdaba3c59feacfe 0.0s done
#19 exporting config sha256:6579c5180df56e67f06fdb94e32a41f86087c5f4ae1bc1117bade0d22bd4e32f 0.0s done
#19 exporting attestation manifest sha256:7452c6a9791795ebeda60e0baab455f8b4be40dcb9024d39ba9d5c6af97dd8e3 0.0s done
#19 exporting manifest list sha256:7ca98f06403968d55afe485be42bd1ff91061ecbf7bad613ff2e3e77cb6d3f7b 0.0s done
#19 naming to docker.io/fit4110/iot-ingestion:lab04 done
#19 unpacking to docker.io/fit4110/iot-ingestion:lab04 0.1s done
#19 DONE 0.3s
```

## 2. Run evidence

Command:

```bash
docker run --rm --name fit4110-iot-lab04 -p 8000:8000 --env-file .env.example fit4110/iot-ingestion:lab04
```

Container logs:

```text
INFO:     Started server process [7]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     127.0.0.1:36986 - "GET /health HTTP/1.1" 200 OK
INFO:     172.17.0.1:60028 - "GET /health HTTP/1.1" 200 OK
INFO:     127.0.0.1:53280 - "GET /health HTTP/1.1" 200 OK
```

## 3. Healthcheck evidence

Command:

```bash
curl http://localhost:8000/health
```

Result:

```json
{
  "status": "ok",
  "service": "iot-ingestion",
  "version": "0.4.0"
}
```

## 4. Newman evidence

Command:

```bash
npm run test:team-iot:local
```

Report path:

```text
reports/newman-lab04-local.html
reports/newman-lab04-local.xml
```

Newman CLI summary:

```text
FIT4110 Lab04 IoT Docker Verification

□ 01_Functional
└ GET health returns 200
  GET http://127.0.0.1:8000/health [200 OK, 184B, 23ms]
  √  Status code is 200
  √  Response has status ok
  √  Response has service name and version

└ POST valid temperature reading returns 201
  POST http://127.0.0.1:8000/readings [201 Created, 271B, 10ms]
  √  Status code is 201
  √  Response follows created-reading schema
  √  Response device_id matches request

└ GET latest readings returns items array
  GET http://127.0.0.1:8000/readings/latest?device_id=ESP32-LAB-A01&limit=5 [200 OK, 332B, 7ms]
  √  Status code is 200
  √  Response has items array

└ GET reading by saved reading_id returns 200
  GET http://127.0.0.1:8000/readings/R-20260618-0001 [200 OK, 320B, 5ms]
  √  Status code is 200
  √  Response reading_id matches saved variable

□ 02_Auth
└ POST reading without token returns 401
  POST http://127.0.0.1:8000/readings [401 Unauthorized, 302B, 4ms]
  √  Missing token returns 401

└ POST reading with wrong token returns 401
  POST http://127.0.0.1:8000/readings [401 Unauthorized, 294B, 4ms]
  √  Wrong token returns 401

□ 03_Negative
└ POST reading missing device_id returns validation error
  POST http://127.0.0.1:8000/readings [422 Unprocessable Entity, 17ms]
  √  Missing required field returns 422

└ POST reading with value as string returns validation error
  POST http://127.0.0.1:8000/readings [422 Unprocessable Entity, 4ms]
  √  Wrong data type returns 422

□ 04_Boundary_Reliability
└ POST boundary temperature 80 is accepted with warning
  POST http://127.0.0.1:8000/readings [201 Created, 300B, 6ms]
  √  Boundary value 80 returns 201
  √  High temperature response includes warning header

└ POST boundary temperature 81 is rejected
  POST http://127.0.0.1:8000/readings [422 Unprocessable Entity, 342B, 10ms]
  √  Boundary value 81 returns 422

└ GET health responds under 1000ms on local/container
  GET http://127.0.0.1:8000/health [200 OK, 184B, 5ms]
  √  Response time is below 1000ms
  √  Health endpoint is reachable

┌─────────────────────────┬─────────────────┬─────────────────┐
│                         │        executed │          failed │
├─────────────────────────┼─────────────────┼─────────────────┤
│              iterations │               1 │               0 │
├─────────────────────────┼─────────────────┼─────────────────┤
│                requests │              11 │               0 │
├─────────────────────────┼─────────────────┼─────────────────┤
│            test-scripts │              11 │               0 │
├─────────────────────────┼─────────────────┼─────────────────┤
│      prerequest-scripts │               0 │               0 │
├─────────────────────────┼─────────────────┼─────────────────┤
│              assertions │              19 │               0 │
├─────────────────────────┴─────────────────┴─────────────────┤
│ total run duration: 1258ms                                  │
├─────────────────────────────────────────────────────────────┤
│ total data received: 1.68kB (approx)                        │
├─────────────────────────────────────────────────────────────┤
│ average response time: 8ms [min: 4ms, max: 23ms, s.d.: 5ms] │
└─────────────────────────────────────────────────────────────┘
```

## 5. Notes

- Known limitation: IoT Ingestion Service hiện tại mới chỉ đóng gói chạy trên một container độc lập. Dữ liệu cảm biến mới chỉ đang dùng in-memory hoặc mock data chứ chưa được tích hợp hệ quản trị cơ sở dữ liệu (Database) thực tế.
- Next step for Lab 05: Nâng cấp lên sử dụng Docker Compose để chạy IoT Ingestion Service song song với một Database container (ví dụ: PostgreSQL hoặc TimescaleDB) để lưu trữ dữ liệu cảm biến lâu dài.

