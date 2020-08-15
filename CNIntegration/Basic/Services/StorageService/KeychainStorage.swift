//
//  KeychainStorage.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 29/04/2017.
//  Copyright © 2017 Pavel Pronin All rights reserved.
//

import Foundation
import Security

// Constant Identifiers
private let kUserAccount = "AuthenticatedUser"

/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */
private let kAuthorizationToken = "kAuthorizationToken"

// Arguments for the keychain queries
private let kSecClassValue = NSString(format: kSecClass)
private let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
private let kSecValueDataValue = NSString(format: kSecValueData)
private let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
private let kSecAttrServiceValue = NSString(format: kSecAttrService)
private let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
private let kSecReturnDataValue = NSString(format: kSecReturnData)
private let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

private let kSecAttrAccessibleValue = NSString(format: kSecAttrAccessible)
private let kSecAttrAccessibleAfterFirstUnlockValue = NSString(format: kSecAttrAccessibleAfterFirstUnlock)

struct KeychainStorage {

    // MARK: - -

    /// Remove all keys from Keychain
    static func resetAll() {
        clearKeychain()
    }

    /// Save authorization token in Keychain
    ///
    /// - Parameter token: token value
    static func saveAccessToken(_ token: String) {
        self.save(service: kAuthorizationToken, string: token)
    }

    /// Get authorization token from Keychain
    ///
    /// - Returns: token value
    static func getAccessToken() -> String? {
        return self.load(service: kAuthorizationToken)
    }

    // MARK: - Private -

    private static  func save(service: String, string: String) {

        let dataFromString = string.data(using: .utf8, allowLossyConversion: false)
        save(service: service, data: dataFromString ?? Data())
    }

    private static  func save(service: String, data: Data) {

        let keychainQuery = NSMutableDictionary(objects: [kSecClassGenericPasswordValue,
                                                          service,
                                                          kUserAccount,
                                                          data,
                                                          kSecAttrAccessibleAfterFirstUnlockValue],
                                                forKeys: [kSecClassValue,
                                                          kSecAttrServiceValue,
                                                          kSecAttrAccountValue,
                                                          kSecValueDataValue,
                                                          kSecAttrAccessibleValue])

        SecItemDelete(keychainQuery as CFDictionary)
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    private static func clearKeychain() {

        let secItemClasses = [kSecClassGenericPassword,
                              kSecClassInternetPassword,
                              kSecClassCertificate,
                              kSecClassKey,
                              kSecClassIdentity]

        for secItemClass in secItemClasses {
            let dictionary = [kSecClass as String: secItemClass]
            SecItemDelete(dictionary as CFDictionary)
        }
    }

    private static func load(service: String) -> String? {
        let keychainQuery = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: service,
            kSecAttrAccountValue: kUserAccount,
            kSecReturnDataValue: kCFBooleanTrue as Any,
            kSecMatchLimitValue: kSecMatchLimitOneValue
            ] as  CFDictionary

        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String?

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: .utf8)
            }
        } else {
            log.error("Nothing was retrieved from the keychain. Status code \(status)")
        }

        return contentsOfKeychain
    }
}
