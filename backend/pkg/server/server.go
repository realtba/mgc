package server

import (
	"backend/pkg/generated"
	"context"
	"fmt"

	"github.com/google/uuid"
)

// Game .
type Game struct {
	EventsForPlayerA chan mgc.Event
	EventsForPlayerB chan mgc.Event
	uuidPlayerA      string
	uuidPlayerB      string
}

// connect.
func (srv *Game) Connect(ctx context.Context, req *mgc.ConnectRequest) (*mgc.ConnectResponse, error) {
	id := uuid.New().String()
	switch {
	case len(srv.uuidPlayerA) == 0:
		srv.uuidPlayerA = id
		srv.EventsForPlayerA = make(chan mgc.Event)
	case len(srv.uuidPlayerB) == 0:
		srv.uuidPlayerB = id
		srv.EventsForPlayerB = make(chan mgc.Event)
	default:
		return nil, fmt.Errorf("there are alreadt two playter connected")
	}

	return &mgc.ConnectResponse{
		Uuid: id,
	}, nil
}

// Interact .
func (srv *Game) Interact(ctx context.Context, req *mgc.InteractRequest) (*mgc.InteractResponse, error) {
	switch req.GetUuid() {
	case srv.uuidPlayerA:
		srv.EventsForPlayerB <- mgc.Event{
			Type: &mgc.Event_MoveCard_{
				MoveCard: &mgc.Event_MoveCard{
					X: req.Event.GetMoveCard().X,
					Y: 1 - req.GetEvent().GetMoveCard().GetY(),
				},
			},
		}
	case srv.uuidPlayerB:
		srv.EventsForPlayerA <- mgc.Event{
			Type: &mgc.Event_MoveCard_{
				MoveCard: &mgc.Event_MoveCard{
					X: req.GetEvent().GetMoveCard().X,
					Y: 1 - req.GetEvent().GetMoveCard().GetY(),
				},
			},
		}
	default:
		return nil, fmt.Errorf("unknown uuid: %s", req.GetUuid())
	}
	return &mgc.InteractResponse{}, nil
}

// Listen .
func (srv *Game) Listen(req *mgc.ListenRequest, stream mgc.Game_ListenServer) error {
	var events chan mgc.Event
	switch req.GetUuid() {
	case srv.uuidPlayerA:
		events = srv.EventsForPlayerA
	case srv.uuidPlayerB:
		events = srv.EventsForPlayerB
	default:
		return fmt.Errorf("unknown uuid: %s", req.GetUuid())
	}
	for {
		select {
		case e := <-events:
			stream.Send(&mgc.ListenResponse{
				Event: &e,
			})
		default:

		}
	}
}
