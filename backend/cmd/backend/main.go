package main

import (
	mgc "backend/pkg/generated"
	"backend/pkg/server"
	"fmt"
	"log"
	"net"

	"google.golang.org/grpc"
)

func main() {

	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", 9091))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	srv := &server.Game{}
	grpcServer := grpc.NewServer()

	mgc.RegisterGameServer(grpcServer, srv)

	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %s", err)
	}
}
