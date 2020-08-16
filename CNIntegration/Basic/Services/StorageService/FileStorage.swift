//
//  FileStorage.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26/06/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

enum Directory: CaseIterable {
    case documents
    case cache
}

enum FilenameExtension: String {
    case json
    case plist
}

struct Filename {
    let name: String
    let fileExtension: FilenameExtension

    var path: String {
        return "\(name).\(fileExtension.rawValue)"
    }

    init(name: String, fileExtension: FilenameExtension) {
        self.name = name
        self.fileExtension = fileExtension
    }
}

enum FileStorageError: Error, LocalizedError {
    case fileNotFound(path: String)

    var errorDescription: String? {
        switch self {
        case let .fileNotFound(path):
            return "File with path: \(path) not found"
        }
    }
}

struct FileStorage {

    private static let fileManager = FileManager.default

    @discardableResult
    static func save(data: Data,
                     with name: String,
                     for directory: Directory = .documents) throws -> URL {
        let url: URL
        do {
            let directoryURL = try self.url(for: directory)
            url = directoryURL.appendingPathComponent(name)
            try data.write(to: url)
        } catch {
            throw error
        }
        return url
    }

    static func content(from absoluteURL: URL) -> Data? {
        guard absoluteURL.isFileURL else { return nil }
        return try? Data(contentsOf: absoluteURL)
    }

    @discardableResult
    static func store<T: Encodable>(objects: T,
                                    to directory: Directory,
                                    as filename: Filename) throws -> URL {
        let url = try self.url(for: directory).appendingPathComponent(filename.path)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        let data: Data?
        switch filename.fileExtension {
        case .json:
            let encoder = JSONEncoder()
            data = try encoder.encode(objects)
        case .plist:
            let encoder = PropertyListEncoder()
            data = try encoder.encode(objects)
        }

        fileManager.createFile(atPath: url.path, contents: data, attributes: [:])
        return url
    }

    static func content<T: Decodable>(from directory: Directory,
                                      filename: Filename) throws -> T {
        let url = try self.url(for: directory).appendingPathComponent(filename.path)
        guard let data = fileManager.contents(atPath: url.path) else {
            throw FileStorageError.fileNotFound(path: url.path)
        }
        switch filename.fileExtension {
        case .json:
            let decoder = Foundation.JSONDecoder()
            return try decoder.decode(T.self, from: data)
        case .plist:
            let decoder = PropertyListDecoder()
            return try decoder.decode(T.self, from: data)
        }
    }

    static func updateInArray<T: Codable & Equatable>(object incomeObject: T,
                                                      with outcomeObject: T,
                                                      from directory: Directory,
                                                      at filename: Filename) throws {
        let retrivedItems: [T] = try content(from: directory, filename: filename)
        let itemsToStore = retrivedItems.map {
            $0 == incomeObject ? $0 : outcomeObject
        }
        try remove(from: directory, filename: filename)
        try store(objects: itemsToStore, to: directory, as: filename)
    }

    static func removeFromArray<T: Codable & Equatable>(item: T,
                                                        from directory: Directory,
                                                        at filename: Filename) throws {
        let retrivedItems: [T] = try content(from: directory, filename: filename)
        let itemsToStore = retrivedItems.filter {
            $0 != item
        }
        try remove(from: directory, filename: filename)
        try store(objects: itemsToStore, to: directory, as: filename)
    }

    static func remove(from directory: Directory,
                       filename: Filename) throws {
        let url = try self.url(for: directory).appendingPathComponent(filename.path)

        try fileManager.removeItem(at: url)
    }

    static func resetAll() throws {
        try Directory.allCases.compactMap {
            try url(for: $0)
        }.forEach {
            try fileManager.removeItem(at: $0)
        }
    }

    static func isExist(path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }

    static func fileURL(path: String) -> URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent(path)
    }

    static func getData(path: String) -> Data? {
        let file = fileURL(path: path)
        if fileManager.fileExists(atPath: file.path) {
            do {
                let data = try Data(contentsOf: file)
                return data
            } catch {
                log.error("Could not get data from path:\(path) Error:\(error)")
            }
        }
        return nil
    }

    static func save(data: Data, path: String) {
        do {
            let file = fileURL(path: path)
            try data.write(to: file, options: .atomic)
        } catch {
            log.error("Could not data to path:\(path) Error:\(error)")
        }
    }

    static func save(image: UIImage, path: String) {
        if let jpegImageData = image.jpegData(compressionQuality: 1) {
            save(data: jpegImageData, path: path)
        }
    }

    static func deleteData(path: String) {
        do {
            let filePath = fileURL(path: path).path
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(atPath: filePath)
            }
        } catch {
            log.error("Could not delete data from path:\(path) Error:\(error)")
        }
    }

    // MARK: Helpers

    private static func url(for directoryType: Directory) throws -> URL {
        let searchPathDirectory: FileManager.SearchPathDirectory
        switch directoryType {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .cache:
            searchPathDirectory = .cachesDirectory
        }
        let directory = try fileManager.url(for: searchPathDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
        return directory
    }
}
