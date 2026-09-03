import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 注册 Method Channel
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.penman.shortcut_ios", binaryMessenger: controller.binaryMessenger)
    // 处理快捷方式点击事件（冷启动时）
    if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
        self.handleShortcutItem(shortcutItem)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  // 处理快捷方式点击事件（App 已启动时）
  override func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    self.handleShortcutItem(shortcutItem)
    completionHandler(true)
  }

  // 处理快捷方式逻辑（发送事件到 Flutter）
  private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
    let type = shortcutItem.type
    // 通过 Method Channel 发送点击事件到 Flutter
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.penman.shortcut_ios", binaryMessenger: controller.binaryMessenger)
    channel.invokeMethod("onShortcutTapped", arguments: type)
  }
}
