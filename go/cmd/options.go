package main
import "github.com/nealwon/go-flutter-plugin-sqlite"
import "github.com/go-flutter-desktop/plugins/path_provider"
import "github.com/go-flutter-desktop/plugins/shared_preferences"
import (
	"github.com/go-flutter-desktop/go-flutter"
)

var orgName = "de.ek"
var appName = "offlineDictionary"

var options = []flutter.Option{
	flutter.WindowInitialDimensions(800, 1280),
	flutter.AddPlugin(sqflite.NewSqflitePlugin(orgName,appName)),
	flutter.AddPlugin(&path_provider.PathProviderPlugin{
    	VendorName:      orgName,
    	ApplicationName: appName,
    }),
    flutter.AddPlugin(&shared_preferences.SharedPreferencesPlugin{
    	VendorName:      orgName,
    	ApplicationName: appName,
    }),
}
