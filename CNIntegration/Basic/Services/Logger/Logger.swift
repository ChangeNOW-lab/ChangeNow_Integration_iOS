//
//  Logger.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 23/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

import CocoaLumberjack

extension DDLogFlag {
    static func from(_ logLevel: DDLogLevel) -> DDLogFlag {
        return DDLogFlag(rawValue: logLevel.rawValue)
    }

    init(_ logLevel: DDLogLevel) {
        self = DDLogFlag(rawValue: logLevel.rawValue)
    }

    ///returns the log level, or the lowest equivalant.
    func toLogLevel() -> DDLogLevel {
        if let ourValid = DDLogLevel(rawValue: rawValue) {
            return ourValid
        } else {
            if contains(.verbose) {
                return .verbose
            } else if contains(.debug) {
                return .debug
            } else if contains(.info) {
                return .info
            } else if contains(.warning) {
                return .warning
            } else if contains(.error) {
                return .error
            } else {
                return .off
            }
        }
    }
}

var defaultDebugLevel = DDLogLevel.verbose

func resetDefaultDebugLevel() {
    defaultDebugLevel = DDLogLevel.verbose
}

func _DDLogMessage(_ message: @autoclosure () -> String, level: DDLogLevel, flag: DDLogFlag, context: Int, file: StaticString, function: StaticString, line: UInt, tag: Any?, asynchronous: Bool, ddlog: DDLog) {
    if level.rawValue & flag.rawValue != 0 {
        // Tell the DDLogMessage constructor to copy the C strings that get passed to it.
        let logMessage = DDLogMessage(message: message(), level: level, flag: flag, context: context, file: String(describing: file), function: String(describing: function), line: line, tag: tag, options: [.copyFile, .copyFunction], timestamp: nil)
        ddlog.log(asynchronous: asynchronous, message: logMessage)
    }
}

func DDLogDebug(_ message: @autoclosure () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = true, ddlog: DDLog = DDLog.sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .debug, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

func DDLogInfo(_ message: @autoclosure () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = true, ddlog: DDLog = DDLog.sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .info, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

func DDLogWarn(_ message: @autoclosure () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = true, ddlog: DDLog = DDLog.sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .warning, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

func DDLogVerbose(_ message: @autoclosure () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = true, ddlog: DDLog = DDLog.sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .verbose, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

func DDLogError(_ message: @autoclosure () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = false, ddlog: DDLog = DDLog.sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .error, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

/// Returns a String of the current filename, without full path or extension.
///
/// Analogous to the C preprocessor macro `THIS_FILE`.
func CurrentFileName(_ fileName: StaticString = #file) -> String {
    var str = String(describing: fileName)
    if let idx = str.range(of: "/", options: .backwards)?.upperBound {
        str = String(str[idx...])
    }
    if let idx = str.range(of: ".", options: .backwards)?.lowerBound {
        str = String(str[..<idx])
    }
    return str
}

class LogTags {
    var `default`: String { return " " }
}

class Logger {

    typealias LoggerErrorBlock = (_ message: String, _ file: String) -> Void
    static var onError: LoggerErrorBlock?

    var level: LoggerLevel {
        return logLevel
    }
    private var logLevel: LoggerLevel = .off
    typealias LogTag = KeyPath<LogTags, String>
    enum LoggerLevel {
        case off
        case error // and fatal
        case warning
        case info
        case debug
        case verbose
    }

    // MARK: - Interface

    func fatal(_ message: @autoclosure () -> String, tag: LogTag? = \LogTags.default,
               file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> Never {
        DDLogError(message(), file: file, function: function, line: line, tag: tag)
        fatalError(message(), file: file, line: line)
    }

    func error(_ message: @autoclosure () -> String, tag: LogTag? = \LogTags.default,
               file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogError(message(), file: file, function: function, line: line, tag: tag)
        actionOnError(message: message(), file: file, line: line)
    }

    func warning(_ message: @autoclosure () -> String, tag: LogTag? = \LogTags.default,
                 file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogWarn(message(), file: file, function: function, line: line, tag: tag)
    }

    func info(_ message: @autoclosure () -> String, tag: LogTag? = \LogTags.default,
              file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogInfo(message(), file: file, function: function, line: line, tag: tag)
    }

    func debug(_ message: @autoclosure () -> String, tag: LogTag? = \LogTags.default,
               file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogDebug(message(), file: file, function: function, line: line, tag: tag)
    }

    func debug(_ value: @escaping @autoclosure () -> Any?, tag: LogTag? = \LogTags.default,
               file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        if defaultDebugLevel.rawValue & DDLogFlag.debug.rawValue != 0 {
            let message = value().map { "\($0)" } ?? "nil"
            DDLogDebug(message, file: file, function: function, line: line, tag: tag)
        }
    }

    func verbose(_ message:  @autoclosure () -> String, tag: LogTag? = \LogTags.default,
                 file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogVerbose(message(), file: file, function: function, line: line, tag: tag)
    }

    // MARK: - Assert, precondition

    func assert(_ condition: Bool, _ message: @autoclosure () -> String = "",
                file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        Swift.assert(condition, message(), file: file, line: line)
        if !condition {
            DDLogError(message(), file: file, function: function, line: line, tag: "assert")
        }
    }

    func assertionFailure(_ message: @autoclosure () -> String = "",
                          file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        Swift.assertionFailure(message(), file: file, line: line)
        DDLogError(message(), file: file, function: function, line: line, tag: "assert")
    }

    func precondition(_ condition: Bool, _ message: @autoclosure () -> String = "",
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        Swift.precondition(condition, message(), file: file, line: line)
        if !condition {
            DDLogError(message(), file: file, function: function, line: line, tag: "precondition")
        }
    }

    // MARK: - Actions

    private func actionOnError(message: String, file: StaticString, line: UInt) {
        var fileName = String(describing: file)
        if let index = fileName.indexOfLast(target: "/") {
            fileName = String(fileName.suffix(fileName.count - index - 1))
        }
        let domain = "\(fileName) line \(line)"
        Logger.onError?(message, domain)
    }

    // MARK: ONLY FOR CONSOLE(LLDB)

    // Setup initial tags
    static var defaultTags: Set<Logger.LogTag> = [\LogTags.default]
    internal var showTags: Set<Logger.LogTag> = Logger.defaultTags

    // Insert tag
    // Use from LLDB: in debug on breakpoint `po log.insertTag(\.yourTag)`
    func insertTag(_ tag: LogTag) {
        showTags.insert(tag)
    }

    // Insert tags
    // Use from LLDB: in debug on breakpoint `po log.insertTags([\.yourTag1, \.yourTag2]])`
    func insertTags(_ tags: [LogTag]) {
        showTags.formUnion(tags)
    }

    // Remove tag if contains
    // Use from LLDB: in debug on breakpoint `po log.removeTag(\.yourTag)`
    func removeTag(_ tag: LogTag) {
        showTags.remove(tag)
    }

    // Change log level
    // Use from LLDB: in debug on breakpoint `po log.setLevel(.warning)`
    func setLevel(_ level: LoggerLevel) {
        logLevel = level
        defaultDebugLevel = level.ddLevel
    }

    func addLogger(_ logger: DDAbstractLogger, with level: LoggerLevel) {
        DDLog.add(logger, with: level.ddLevel)
    }

    // MARK: - Realization

    internal let tags = LogTags()

    internal init() {
        let isNeedLogs = Bundle(identifier: Bundle.main.bundleIdentifier ?? "")?
            .object(forInfoDictionaryKey: "UIFileSharingEnabled") as? Bool ?? false

        #if DEBUG
        setLevel(.debug)
        #else
        if isNeedLogs {
            setLevel(.info)
        } else {
            setLevel(.warning)
        }
        #endif

        #if DEBUG
        Logger.initConsoleLogs()
        #else
        Logger.initAppleSystemLogs()
        #endif

        Logger.initFileLogs()
    }

    private static func initConsoleLogs() {
        // TTY = Xcode console
        if let ddttyLogger = DDTTYLogger.sharedInstance {
            ddttyLogger.logFormatter = TerminalLoggerFormatter()
            DDLog.add(ddttyLogger)
        }
    }

    private static func initAppleSystemLogs() {
        // ASL = Apple System Logs
        DDOSLogger.sharedInstance.logFormatter = AppleLoggerFormatter()
        DDLog.add(DDOSLogger.sharedInstance)
    }

    private static func initFileLogs() {
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let documentsPath = documentDirectories.first else {
            return
        }

        let logsDirectory = "\(documentsPath)//Logs"

        let fileManager = DDLogFileManagerDefault(logsDirectory: logsDirectory)
        fileManager.maximumNumberOfLogFiles = 7

        let fileLogger = DDFileLogger(logFileManager: fileManager)
        fileLogger.logFormatter = FileLoggerFormatter()
        DDLog.add(fileLogger)

    }

}

private func printableTag(_ tag: Any?) -> String {
    if let tag = tag as? Logger.LogTag {
        return " {\(log.tags[keyPath: tag])}"
    }
    return tag.map { " {\($0)}" } ?? ""
}

private var terminalDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss:SSS"
    return dateFormatter
}()

private class TerminalLoggerFormatter: NSObject, DDLogFormatter {
    func format(message logMsg: DDLogMessage) -> String? {
        if !log.showTags.isEmpty { // for acceleration
            if let tag = logMsg.tag as? Logger.LogTag, !log.showTags.contains(tag) {
                return nil
            }
        }

        let levelOfStr = logMsg.flag.toString()
        let time = terminalDateFormatter.string(from: logMsg.timestamp)

        let tag = printableTag(logMsg.tag)
        return "🔸\(time) [\(levelOfStr)] (\(logMsg.fileName):\(logMsg.line))\(tag): \(logMsg.message)"
    }

}

private class AppleLoggerFormatter: NSObject, DDLogFormatter {

    func format(message logMsg: DDLogMessage) -> String? {
        if !log.showTags.isEmpty { // for acceleration
            if let tag = logMsg.tag as? Logger.LogTag, !log.showTags.contains(tag) {
                return nil
            }
        }

        let levelOfStr = logMsg.flag.toString()
        let tag = printableTag(logMsg.tag)
        return "🔸[\(levelOfStr)] (\(logMsg.fileName):\(logMsg.line))\(tag): \(logMsg.message)"
    }

}

private var fileDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
    return dateFormatter
}()

private class FileLoggerFormatter: NSObject, DDLogFormatter {
    func format(message logMsg: DDLogMessage) -> String? {
        if !log.showTags.isEmpty { // for acceleration
            if let tag = logMsg.tag as? Logger.LogTag, !log.showTags.contains(tag) {
                return nil
            }
        }
        let levelOfStr = logMsg.flag.toString()
        let time = fileDateFormatter.string(from: logMsg.timestamp)
        let tag = printableTag(logMsg.tag)
        return "\(time) [\(levelOfStr)] (\(logMsg.fileName):\(logMsg.line))\(tag): \(logMsg.message)"
    }
}

private extension DDLogFlag {
    func toString() -> StaticString {
        switch self {
        case .error:
            return "‼️ERR"
        case .warning:
            return "⚠️WRN"
        case .info:
            return "INF"
        case .debug:
            return "DBG"
        case .verbose:
            return "VER"
        default:
            return "___"
        }
    }
}

private extension Logger.LoggerLevel {
    var ddLevel: DDLogLevel {
        switch self {
        case .off:
            return .off
        case .error:
            return .error
        case .warning:
            return .warning
        case .info:
            return .info
        case .debug:
            return .debug
        case .verbose:
            return .verbose
        }
    }
}
