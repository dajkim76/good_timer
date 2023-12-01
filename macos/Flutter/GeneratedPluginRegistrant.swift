//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import realm
import shared_preferences_foundation
import wakelock_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  RealmPlugin.register(with: registry.registrar(forPlugin: "RealmPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  WakelockMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockMacosPlugin"))
}
