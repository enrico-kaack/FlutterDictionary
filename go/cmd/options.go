package main
import "github.com/nealwon/go-flutter-plugin-sqlite"

import (
	"github.com/go-flutter-desktop/go-flutter"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(800, 1280),
	flutter.AddPlugin(sqflite.NewSqflitePlugin("myOrganizationOrUsername","myApplicationName")),
}
