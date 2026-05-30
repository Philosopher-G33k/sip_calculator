import Flutter
import SIPCore
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let localeChannelName = "com.ishanmalviya.sipcalculator/locale"
  private static let historyChannelName = "com.ishanmalviya.sipcalculator/history"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    let registry = engineBridge.pluginRegistry
    GeneratedPluginRegistrant.register(with: registry)
    registerLocaleChannel(with: registry)
    registerHistoryChannel(with: registry)
  }

  /// Mirrors the Flutter-selected locale into the App-Group suite so native
  /// surfaces (intents, widgets) format figures in the app's locale rather than
  /// the device default.
  private func registerLocaleChannel(with registry: FlutterPluginRegistry) {
    let messenger = registry.registrar(forPlugin: "SIPLocaleChannel")?.messenger()
    guard let messenger else { return }

    let channel = FlutterMethodChannel(
      name: Self.localeChannelName,
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "setLocale":
        guard let locale = call.arguments as? String, !locale.isEmpty else {
          result(FlutterError(
            code: "invalid_argument",
            message: "setLocale expects a non-empty String locale",
            details: nil
          ))
          return
        }
        SIPSharedStore.shared.locale = locale
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Persists calculation history into the App-Group store. Writes are funnelled
  /// through the app target (this handler) so extensions stay read-only.
  private func registerHistoryChannel(with registry: FlutterPluginRegistry) {
    let messenger = registry.registrar(forPlugin: "SIPHistoryChannel")?.messenger()
    guard let messenger else { return }

    let channel = FlutterMethodChannel(
      name: Self.historyChannelName,
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "saveEntry":
        guard let entry = Self.parseEntry(call.arguments) else {
          result(FlutterError(
            code: "invalid_argument",
            message: "saveEntry expects a map with calculatorType, inputs, result, locale",
            details: nil
          ))
          return
        }
        SIPSharedStore.shared.saveCalculation(entry)
        // Return the canonical id so Dart keys deletes/Spotlight on the same value.
        result(entry.id.uuidString)

      case "deleteEntry":
        guard let id = call.arguments as? String, !id.isEmpty else {
          result(FlutterError(
            code: "invalid_argument",
            message: "deleteEntry expects a non-empty String id",
            details: nil
          ))
          return
        }
        SIPSharedStore.shared.deleteEntry(id: id)
        result(nil)

      case "clearAll":
        SIPSharedStore.shared.clearAll()
        result(nil)

      case "loadAll":
        result(Self.encodeHistory(SIPSharedStore.shared.loadHistory()))

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Serialises history into a Dart-friendly JSON string: `id` as a UUID string
  /// and `timestamp` as ISO-8601, so the Flutter side decodes it identically to
  /// its own model regardless of the native `Codable` date strategy.
  private static func encodeHistory(_ entries: [CalculationHistoryEntry]) -> String {
    let iso = ISO8601DateFormatter()
    let payload: [[String: Any]] = entries.map { entry in
      [
        "id": entry.id.uuidString,
        "calculatorType": entry.calculatorType,
        "inputs": entry.inputs,
        "result": entry.result,
        "locale": entry.locale,
        "timestamp": iso.string(from: entry.timestamp),
      ]
    }
    guard let data = try? JSONSerialization.data(withJSONObject: payload),
          let json = String(data: data, encoding: .utf8)
    else {
      return "[]"
    }
    return json
  }

  /// Decodes the loosely-typed MethodChannel payload into a typed history entry.
  private static func parseEntry(_ arguments: Any?) -> CalculationHistoryEntry? {
    guard let map = arguments as? [String: Any],
          let calculatorType = map["calculatorType"] as? String,
          let rawInputs = map["inputs"] as? [String: Any],
          let rawResult = map["result"] as? [String: Any],
          let locale = map["locale"] as? String
    else {
      return nil
    }

    let inputs = rawInputs.compactMapValues { ($0 as? NSNumber)?.doubleValue }
    let result = rawResult.compactMapValues { ($0 as? NSNumber)?.intValue }

    return CalculationHistoryEntry(
      calculatorType: calculatorType,
      inputs: inputs,
      result: result,
      locale: locale
    )
  }
}
