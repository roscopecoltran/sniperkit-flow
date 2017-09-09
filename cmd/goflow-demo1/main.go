package blocks

import (
  "github.com/ryanpeach/goflow/core"
  "github.com/ryanpeach/goflow/core/blocks"
  "github.com/sirupsen/logrus"
  // "github.com/davecgh/go-spew/spew"
  // "github.com/k0kubun/pp"
  prefixed "github.com/x-cray/logrus-prefixed-formatter"
)

var (
  log = logrus.New()
)

func init() {
  formatter := new(prefixed.TextFormatter)
  log.Formatter = formatter
  log.Level = logrus.DebugLevel
}

func main() {

}
