package graphs

import (
    "github.com/ryanpeach/goflow/core"
    "github.com/ryanpeach/goflow/core/blocks"
    "github.com/sirupsen/logrus"
    // "github.com/davecgh/go-spew/spew"
    // "github.com/k0kubun/pp"
    prefixed "github.com/x-cray/logrus-prefixed-formatter"
)

func Nand(id flow.InstanceID) (*flow.Graph, flow.Address) {
	// Create Graph
	ins := flow.ParamTypes{"A": flow.Bool, "B": flow.Bool}
	outs := flow.ParamTypes{"OUT": flow.Bool}
	graph, _ := flow.NewGraph("logical_nand", ins, outs)
	addr := flow.Address{"logical_nand", id}

	// Create Blocks
	and, and_addr := blocks.And(0)
	not, not_addr := blocks.InvBool(0)

	// Add Nodes
	graph.AddNode(and, and_addr)
	graph.AddNode(not, not_addr)

	// Add Edges
	graph.LinkIn("A", "A", and_addr)
	graph.LinkIn("B", "B", and_addr)
	graph.AddEdge(and_addr, "OUT", not_addr, "IN")
	graph.LinkOut(not_addr, "OUT", "OUT")

	return graph, addr
}

/*
func Nor(id InstanceID) FunctionBlock {
    opfunc := func(in ParamValues, out *ParamValues) {
        (*out)["OUT"] = !(in["A"].(bool) || in["B"].(bool))
    }
    name := "logical_nor"
    return opBinary(id,"bool","bool","bool",name,opfunc)
}

// Comparison
func GreaterEquals(id InstanceID) FunctionBlock {
    opfunc := func(in ParamValues, out *ParamValues) {
        (*out)["OUT"] = toNum(in["A"]) >= toNum(in["B"])
    }
    name := "greater_equals"
    return opBinary(id,"num","num","bool",name,opfunc)
}
func LesserEquals(id InstanceID) FunctionBlock {
    opfunc := func(in ParamValues, out *ParamValues) {
        (*out)["OUT"] = toNum(in["A"]) <= toNum(in["B"])
    }
    name := "lesser_equals"
    return opBinary(id,"num","num","bool",name,opfunc)
}
func NotEquals(id InstanceID) FunctionBlock {
    opfunc := func(in ParamValues, out *ParamValues) {
        (*out)["OUT"] = toNum(in["A"]) != toNum(in["B"])
    }
    name := "not_equals"
    return opBinary(id,"num","num","bool",name,opfunc)
}*/
