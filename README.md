# mgc


## deps
* protoc
* protoc-gen-go
* protoc-gen-dart
* envoy
* flutter
* go

## build

* Generate the proto:
  protoc --grpc_out=grpc:backend/pkg/generated -Iprotos protos/mgc.proto
  protoc --dart_out=grpc:frontend/lib/src/generated -Iprotos protos/mgc.proto
* build the backend
  cd backend && go build backend/cmd/backend/main.go

## run
* start the backend
  ./backend/cmd/backend/backend
* start envoy
  envoy -c envoy/config.yaml
* serve flutter web app
  cd frontend && flutter run -d  web

