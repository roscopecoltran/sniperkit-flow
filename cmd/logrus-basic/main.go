package main 

import (
  	"os"
  	"github.com/sirupsen/logrus"
	// "github.com/davecgh/go-spew/spew"
	// "github.com/k0kubun/pp"
	prefixed "github.com/x-cray/logrus-prefixed-formatter"
)

// Create a new instance of the logger. You can have any number of instances.
var log = logrus.New()

func main() {
  // The API for setting attributes is a little different than the package level
  // exported logger. See Godoc.
  log.Out = os.Stdout

  // You could set this to any `io.Writer` such as a file
  // file, err := os.OpenFile("logrus.log", os.O_CREATE|os.O_WRONLY, 0666)
  // if err == nil {
  //  log.Out = file
  // } else {
  //  log.Info("Failed to log to file, using default stderr")
  // }

  log.WithFields(logrus.Fields{
    "goflow": "example1"
  }).Info("logrus helper initaliazed...")


}