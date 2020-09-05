//
//  Extensions.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/7/4.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Foundation
import FileKit

extension Result {

    var isSuccess: Bool {
        switch self {
        case .failure(_):
            return false
        case .success(_):
            return true
        }
    }

    var value: Success? {
        switch self {
        case .failure(_):
            return nil
        case .success(let s):
            return s
        }
    }

    var error: Failure? {
        switch self {
        case .failure(let f):
            return f
        case .success(_):
            return nil
        }
    }

}

extension FileManager {

    ///给定一组URL, 枚举出该URL下所有的文件
    static func enumAllFiles(under urls:[URL])->Set<URL> {
        var files:Set<URL> = Set<URL>.init()
        for i: URL in urls {
            if let path: Path = Path(url: i) {
                if !path.isDirectory {
                    files.insert(path.url.standardizedFileURL)
                }else {
                    //directory
                    let subFiles: Set<URL> = Self.enumAllFiles(under: path.children().map({$0.url}))
                    subFiles.forEach({files.insert($0)})
                }
            }
        }
        return files
    }

}
