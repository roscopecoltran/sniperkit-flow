package core

import (
	"time"
	"github.com/sirupsen/logrus"
	// "github.com/davecgh/go-spew/spew"
	// "github.com/k0kubun/pp"
	prefixed "github.com/x-cray/logrus-prefixed-formatter"
)

// The primary interface of the flowchart. Allows running, has a name, and has parameters.
type FunctionBlock interface {
	Run(inputs ParamValues,
		outputs chan ParamValues,
		stop chan bool,
		err chan *FlowError,
		id InstanceID)
	GetParams() (inputs ParamTypes, outputs ParamTypes)
	GetName() string
}

// A primitive function block that only
// contains a DataStream Function to run
type PrimitiveBlock struct {
	name    string
	fn      DataStream
	inputs  ParamTypes
	outputs ParamTypes
}

// Initializes a FunctionBlock object with given attributes, and an empty parameter list.
// The only way to create Methods's
var nblocks map[string]InstanceID = make(map[string]InstanceID)

func NewPrimitive(name string, function DataStream, inputs ParamTypes, outputs ParamTypes) FunctionBlock {
	nblocks[name] += 1
	return PrimitiveBlock{name: name,
		fn:      function,
		inputs:  inputs,
		outputs: outputs}
}

// Returns a copy of FunctionBlock's InstanceId
func (m PrimitiveBlock) GetName() string { return m.name }

// Returns copies of all parameters in FunctionBlock
func (m PrimitiveBlock) GetParams() (inputs ParamTypes, outputs ParamTypes) {
	return m.inputs.Copy(), m.outputs.Copy()
}

// Run the function
func (m PrimitiveBlock) Run(inputs ParamValues,
	outputs chan ParamValues,
	stop chan bool,
	err chan *FlowError,
	id InstanceID) {
	ADDR := Address{m.GetName(), id}

	// Check types to ensure inputs are the type defined in input parameters
	//chk_errs := CheckTypes(inputs, m.inputs)
	//if chk_errs != nil {
	//	err <- &FlowError{chk_errs, ADDR}
	//	return
	//}

	// Duplicate the given channel to pass to the enclosed function
	// Run the function
	f_err := make(chan *Error)
	f_out := make(chan ParamValues)
	f_stop := make(chan bool)
	go m.fn(inputs, f_out, f_stop, f_err)

	// Wait for a stop or an output
	for {
		select {
		case f_return := <-f_out: // If an output is returned
			outputs <- f_return // Return the data
			return              // And stop the function
		case <-stop: // If commanded to stop externally
			f_stop <- true // Pass it on to subfunction
			return         // And stop immediately
		case temp_err := <-f_err: // If there is an error, save it
			err <- &FlowError{temp_err, ADDR} // Pass it up the chain
			f_stop <- true
			return // And stop the function
		}
	}
}

// An easy way to initialize a block and get it's channels
func BlockRun(blk FunctionBlock, f_in ParamValues, id InstanceID) (f_out chan ParamValues,
	f_stop chan bool,
	f_err chan *FlowError) {
	// Initialize channels
	f_out = make(chan ParamValues)
	f_stop = make(chan bool)
	f_err = make(chan *FlowError)

	// Run in new goroutine
	go blk.Run(f_in, f_out, f_stop, f_err, id)
	return
}

// A Timeout block that can pass to the stop channel
func Timeout(stop chan bool, sleeptime int) {
	time.Sleep(time.Duration(sleeptime))
	stop <- true
}
