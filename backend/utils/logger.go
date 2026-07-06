package utils

import (
	"log"
	"os"
)

var (
	infoLog  = log.New(os.Stdout, "[INFO]  ", log.Ldate|log.Ltime)
	errLog   = log.New(os.Stderr, "[ERROR] ", log.Ldate|log.Ltime)
	debugLog = log.New(os.Stdout, "[DEBUG] ", log.Ldate|log.Ltime)
)

var DebugEnabled = false

// LogInfo сабти паёми иттилоотӣ
func LogInfo(format string, args ...interface{}) {
	infoLog.Printf(format, args...)
}

// LogError сабти хатогӣ
func LogError(format string, args ...interface{}) {
	errLog.Printf(format, args...)
}

// LogDebug сабти паёми debug (танҳо агар DebugEnabled=true бошад)
func LogDebug(format string, args ...interface{}) {
	if DebugEnabled {
		debugLog.Printf(format, args...)
	}
}
