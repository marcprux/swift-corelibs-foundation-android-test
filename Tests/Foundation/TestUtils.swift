// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#if os(Android)
let isAndroid = true
#else
let isAndroid = false
#endif

func ensureFiles(_ fileNames: [String]) -> Bool {
    var result = true
    let fm = FileManager.default
    for name in fileNames {
        guard !fm.fileExists(atPath: name) else {
            continue
        }
        
        if name.hasSuffix("/") {
            do {
                try fm.createDirectory(atPath: name, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return false
            }
        } else {
        
            var isDir: ObjCBool = false
            let dir = NSString(string: name).deletingLastPathComponent
            if !fm.fileExists(atPath: dir, isDirectory: &isDir) {
                do {
                    try fm.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                    return false
                }
            } else if !isDir.boolValue {
                return false
            }
            
            result = result && fm.createFile(atPath: name, contents: nil, attributes: nil)
        }
    }
    return result
}

// Manually implement Mutex for Android, since we don't have Synchronization

#if !canImport(Synchronization)
class Mutex<T> {
    var value: T
    private let lock = NSLock()

    init(_ value: T) {
        self.value = value
    }

    public func withLock<R>(_ body: (inout T) throws -> R) rethrows -> R {
        try lock.withLock {
            try body(&value)
        }
    }
}

extension NSLocking {
    @_alwaysEmitIntoClient
    @_disfavoredOverload
    public func withLock<R>(_ body: () throws -> R) rethrows -> R {
        self.lock()
        defer {
            self.unlock()
        }

        return try body()
    }
}
#endif
