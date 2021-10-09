//
//  TweakStorePersistency.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

final class TweakStorePersistency {
    private let baseURL: URL
    private var cache: [URL: Bool] = [:]
    
    init(name: String, appGroupID: String?) {
        let url: URL
        if let appGroupID = appGroupID,
           let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            url = containerURL
        } else {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            url = URL(fileURLWithPath: path)
        }
        baseURL = url.appendingPathComponent("TweaKit").appendingPathComponent(name)
    }
}

extension TweakStorePersistency {
    func hasData(forKey key: String) -> Bool {
        _hasContent(at: _url(forKey: key))
    }
    
    func data(forKey key: String) throws -> Data? {
        let url = _url(forKey: key)
        guard _hasContent(at: url) else { return nil }
        return try _content(at: url)
    }
    
    func setData(_ data: Data, forKey key: String) throws {
        let url = _url(forKey: key)
        if _hasContent(at: url) {
            try _updateContent(data, at: url)
        } else {
            try _insertContent(data, at: url)
        }
    }
    
    func removeData(forKey key: String) throws {
        let url = _url(forKey: key)
        guard _hasContent(at: url) else { return }
        try _removeContent(at: url)
    }
    
    func removeAll() throws {
        guard _hasContent(at: baseURL) else { return }
        try _removeAllContents()
    }
}

private extension TweakStorePersistency {
    func _hasContent(at url: URL) -> Bool {
        cache[url] ?? FileManager.default.fileExists(atPath: url.path)
    }
    
    func _content(at url: URL) throws -> Data? {
        try Data(contentsOf: url, options: .uncached)
    }
    
    func _insertContent(_ data: Data, at url: URL) throws {
        let fm = FileManager.default
        try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.protectionKey: FileProtectionType.none])
        fm.createFile(atPath: url.path, contents: data, attributes: [.protectionKey: FileProtectionType.none])
        cache[url] = true
    }
    
    func _updateContent(_ data: Data, at url: URL) throws {
        try data.write(to: url, options: .noFileProtection)
        cache[url] = true
    }
    
    func _removeContent(at url: URL) throws {
        try FileManager.default.removeItem(atPath: url.path)
        cache[url] = false
    }
    
    func _removeAllContents() throws {
        try FileManager.default.removeItem(atPath: baseURL.path)
        cache.keys.forEach { cache[$0] = false }
    }
}

private extension TweakStorePersistency {
    func _url(forKey key: String) -> URL {
        let raw = key.md5.utf8
        let prefix = String(raw.prefix(2))!
        let remain = String(raw.dropFirst(2))!
        return baseURL.appendingPathComponent(prefix).appendingPathComponent(remain)
    }
}
