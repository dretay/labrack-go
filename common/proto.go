package common

import (
	"github.com/dretay/labrack/proto"
	"github.com/golang/protobuf/proto"
	"log"
)

func MakeProtoMessage() {
	sm := &simple.SimpleMessage{
		LuckyNumber: proto.Int32(42),
	}

	data, err := proto.Marshal(sm)
	if err != nil {
		log.Fatal("marshaling error: ", err)
	}
	newSM := &simple.SimpleMessage{}
	err = proto.Unmarshal(data, newSM)
	if err != nil {
		log.Fatal("unmarshaling error: ", err)
	}
	// Now test and newTest contain the same data.
	if sm.GetLuckyNumber() != newSM.GetLuckyNumber() {
		log.Fatalf("data mismatch %q != %q", sm.GetLuckyNumber(), newSM.GetLuckyNumber())
	}

	log.Printf("Unmarshalled to: %+v", newSM)
}
