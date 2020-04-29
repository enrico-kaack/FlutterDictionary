package main
import "github.com/nealwon/go-flutter-plugin-sqlite"
import "github.com/go-flutter-desktop/plugins/path_provider"
import "github.com/go-flutter-desktop/plugins/shared_preferences"
import (
	"github.com/go-flutter-desktop/go-flutter"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(800, 1280),
	flutter.AddPlugin(sqflite.NewSqflitePlugin("myOrganizationOrUsername","myApplicationName")),
	flutter.AddPlugin(&path_provider.PathProviderPlugin{
    	VendorName:      "myOrganizationOrUsername",
    	ApplicationName: "myApplicationName",
    }),
    flutter.AddPlugin(&shared_preferences.SharedPreferencesPlugin{
    	VendorName:      "myOrganizationOrUsername",
    	ApplicationName: "myApplicationName",
    }),
}
