//
//  LoggerTags.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 07/08/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

/*
 How to use?
 1. You need add new tag:
 ```
 extension LogTags {
     internal/*private*/ var yourTag: String { return "my_tag_name" }
 }
 ```
 2. You can use this tag:
 ```
 log.debug("message", tag: \.yourTag)
 log.info("message", tag: \LogTags.yourTag)
 ```

 recommendation: make file with your module tags.

 How to use?
 ```
 log.fatal("message")
 log.error("message")
 log.warning("message")
 log.info("message")
 log.debug("message")
 log.verbose("message")

 log.assert(false, "message")
 log.precondition(false, "message")
 ```

 also you can:
 change log level. see `log.setLevel(:)`
 insert tag. see `log.insertTag(:)`
 remove tag. see `log.removeTag(:)`
*/

// MARK: Logger

let log = Logger()

extension Logger {

    static func configure(onError: LoggerErrorBlock? = nil) {
//        Logger.defaultTags = [] // all
        Logger.onError = onError
        var tags: Set<Logger.LogTag> = []
        tags.insert(\LogTags.default)
        tags.insert(\.json)
        Logger.defaultTags = tags
    }
}

// MARK: Tags

extension LogTags {
    var json: String { return "JSONError" }
}
