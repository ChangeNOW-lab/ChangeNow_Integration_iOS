//
//  NSBundle+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19/08/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

private var associatedObjectHandle: UInt8 = 0

extension Bundle {

    private static let hostingBundle = Bundle(for: CNIntegration.self)
    private static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current

    static let initWorkBundlerOnce: () = {
        _ = object_setClass(hostingBundle, WorkBundle.classForCoder())
        return ()
    }()

    @discardableResult
    static func updateLanguage(languageCode: String?, tableName: String) -> Locale {
        struct Static {
            static var token: Int = 0
        }
        _ = Bundle.initWorkBundlerOnce

        if let value = localeBundle(tableName: tableName, preferredLanguages: languageCode == nil ? Locale.preferredLanguages : [languageCode!]) {
            objc_setAssociatedObject(hostingBundle,
                                     &associatedObjectHandle,
                                     value.1,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value.0
        } else {
            objc_setAssociatedObject(hostingBundle,
                                     &associatedObjectHandle,
                                     nil,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return Locale.current
        }
    }

    private static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
        // Filter preferredLanguages to localizations, use first locale
        var languages = preferredLanguages
            .map(Locale.init)
            .prefix(1)
            .flatMap { locale -> [String] in
                if hostingBundle.localizations.contains(locale.identifier) {
                    if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
                        return [locale.identifier, language]
                    } else {
                        return [locale.identifier]
                    }
                } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
                    return [language]
                } else {
                    return []
                }
        }

        // If there's no languages, use development language as backstop
        if languages.isEmpty {
            if let developmentLocalization = hostingBundle.developmentLocalization {
                languages = [developmentLocalization]
            }
        } else {
            // Insert Base as second item (between locale identifier and languageCode)
            languages.insert("Base", at: 1)

            // Add development language as backstop
            if let developmentLocalization = hostingBundle.developmentLocalization {
                languages.append(developmentLocalization)
            }
        }

        // Find first language for which table exists
        // Note: key might not exist in chosen language (in that case, key will be shown)
        for language in languages {
            if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
                let lbundle = Bundle(url: lproj)
            {
                let strings = lbundle.url(forResource: tableName, withExtension: "strings")
                let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

                if strings != nil || stringsdict != nil {
                    return (Locale(identifier: language), lbundle)
                }
            }
        }
        // If table is available in main bundle, don't look for localized resources
        let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
        let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

        if strings != nil || stringsdict != nil {
            return (applicationLocale, hostingBundle)
        }

        // If table is not found for requested languages, key will be shown
        return nil
    }
}

class WorkBundle: Bundle {

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &associatedObjectHandle) as? Bundle
        if let bundle = bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}
