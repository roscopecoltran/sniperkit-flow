package blocks

import (
	"github.com/ryanpeach/goflow/core"
	"github.com/sirupsen/logrus"
	// "github.com/davecgh/go-spew/spew"
	// "github.com/k0kubun/pp"
	prefixed "github.com/x-cray/logrus-prefixed-formatter"
)

func RunBlock(blk flow.FunctionBlock, ins flow.ParamValues) (flow.ParamValues, *flow.FlowError) {
	// Run a Plus block
	f_out := make(chan flow.ParamValues)
	f_stop := make(chan bool)
	f_err := make(chan *flow.FlowError)

	// Run block and put a timeout on the stop channel
	go blk.Run(ins, f_out, f_stop, f_err, 0)
	//go flow.Timeout(f_stop, 100000)

	// Wait for output or error
	select {
	case out := <-f_out:
		return out, nil
	case err := <-f_err:
		return nil, err
	}

}

func TestUnary(blk flow.FunctionBlock, a, c interface{}, nA, nC, name string) *flow.FlowError {
	// Run a Plus block
	f_out := make(chan flow.ParamValues)
	f_stop := make(chan bool)
	f_err := make(chan *flow.FlowError)

	// Run block and put a timeout on the stop channel
	go blk.Run(flow.ParamValues{nA: a}, f_out, f_stop, f_err, 0)
	//go flow.Timeout(f_stop, 100000)
	addr := flow.Address{blk.GetName(), 0}

	// Wait for output or error
	var out flow.ParamValues
	select {
	case out = <-f_out:
	case err := <-f_err:
		return err
	}

	// Test the output
	if out[nC] != c {
		return flow.NewFlowError(flow.VALUE_ERROR, "Returned wrong value.", addr)
	} else {
		return nil
	}
}

func TestBinary(blk flow.FunctionBlock, a, b, c interface{}, aN, bN, cN, name string) *flow.FlowError {

	// Run a Plus block
	f_out := make(chan flow.ParamValues)
	f_stop := make(chan bool)
	f_err := make(chan *flow.FlowError)

	// Run block and put a timeout on the stop channel
	go blk.Run(flow.ParamValues{aN: a, bN: b}, f_out, f_stop, f_err, 0)
	//go flow.Timeout(f_stop, 100000)
	addr := flow.Address{blk.GetName(), 0}

	// Wait for output or error
	var out flow.ParamValues
	select {
	case out = <-f_out:
	case err := <-f_err:
		return err
	}

	// Test the output
	if out[cN] != c {
		return flow.NewFlowError(flow.VALUE_ERROR, "Returned wrong value.", addr)
	} else {
		return nil
	}
}
