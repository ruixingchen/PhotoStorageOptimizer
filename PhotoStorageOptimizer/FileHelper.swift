//
//  FileHelper.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/7/3.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Foundation

struct FileHelper {

    static func typeFrom(fileURL: URL)->String? {
        guard let file = try? FileHandle(forReadingFrom: fileURL) else {return nil}
        let header = file.readData(ofLength: 12)
        let buffer: [UInt8] = [UInt8].init(header)

        switch (buffer[0]) {
        case 0xFF:
            return "jpg";
        case 0x89:
            return "png";
        case 0x47:
            return "gif";
        case 0x49, 0x4D:
            return "tiff";
        case 0x52:
            let testString = String.init(data: header[0..<12], encoding: .ascii) ?? ""
            if testString.hasPrefix("RIFF") && testString.hasSuffix("WEBP") {
                return "webp"
            }
        case 0x00:
            let testString = String.init(data: header[4..<12], encoding: .ascii) ?? ""
            if ["ftypheic", "ftypheix", "ftyphevc", "ftyphevx"].contains(testString) {
                return "heic"
            }else if ["ftypmif1","ftypmsf1"].contains(testString) {
                return "heif"
            }
        default:
            return nil
        }
        return nil
    }

    static func allFileSize(urls:[URL])->UInt64 {
        var allFileSize: Int64 = 0
        for i in urls {
            if let size = try? FileManager.default.attributesOfItem(atPath: i.standardized.absoluteString)[FileAttributeKey.size] as? Int64 {
                allFileSize += size
            }
        }
        return UInt64(allFileSize)
    }

}
