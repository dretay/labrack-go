package common

import (
	// "bytes"
	// "encoding/binary"
	"fmt"
	"github.com/hybridgroup/gobot/platforms/beaglebone"
	// "math"
	"github.com/dretay/labrack-go/proto"
	"github.com/golang/protobuf/proto"
	"time"
)

type sensorCommand_t struct {
	cmd   byte
	value float32
}

func SendI2cMsg() {
	beagleboneAdaptor := beaglebone.NewBeagleboneAdaptor("beaglebone")

	if err := beagleboneAdaptor.I2cStart(1); err != nil {
		panic("failed to start i2c: " + err.Error())
	}

	// build a command
	command := &simple.CommandMessage{
		Verb: simple.CommandMessage_RECORD.Enum(),
		// Target: proto.Float32(1.0),
	}

	data, err := proto.Marshal(command)
	fmt.Println(data)
	if err != nil {
		panic("marshaling error: " + err.Error())
	}
	if err := beagleboneAdaptor.I2cWrite(0x04, data); err != nil {
		panic("failed to write bytes: " + err.Error())
	}

	fmt.Println("Message sent")

	time.Sleep(time.Second)

	//reading a number
	// sm = &simple.SimpleMessage{}
	// data, err = beagleboneAdaptor.I2cRead(0x04, 128)
	// if err != nil {
	// 	panic("failed to read byte: " + err.Error())
	// }

	// proto.Unmarshal(data, sm)
	// if err != nil {
	// 	panic("unmarshaling error: " + err.Error())
	// }
	// fmt.Println(sm)

	// var bin_buf bytes.Buffer
	// cmd := sensorCommand_t{cmd: 0x01, value: 0.5}
	// binary.Write(&bin_buf, binary.LittleEndian, cmd)
	// if err := beagleboneAdaptor.I2cWrite(0x04, bin_buf.Bytes()); err != nil {
	// 	panic("failed to write bytes: " + err.Error())
	// }
	// <-time.After(1 * time.Millisecond)

	// for i := 0; i < 1; i++ {
	// 	data, err := beagleboneAdaptor.I2cRead(0x04, 8)
	// 	if err != nil {
	// 		panic("failed to read byte: " + err.Error())
	// 	}
	// 	voltage_bits := binary.LittleEndian.Uint32(data[0:4])
	// 	voltage_float := math.Float32frombits(voltage_bits)

	// 	current_bits := binary.LittleEndian.Uint32(data[4:8])
	// 	current_float := math.Float32frombits(current_bits)

	// 	fmt.Println(voltage_float)
	// 	fmt.Println(current_float)
	// 	time.Sleep(time.Second)
	// }

}
