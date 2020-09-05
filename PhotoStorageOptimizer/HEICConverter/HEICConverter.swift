//
//  HEICConverter.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/4/30.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Foundation
import CoreImage
import FileKit

struct HEICConverter {

    ///将图片二进制数据转换为HEIC二进制数据
    static func imageDataToHEICData(_ data: Data, quality: CGFloat) -> Result<Data, Error> {
        guard let image = CIImage.init(data: data) else {
            return Result.failure(HEICConverterError(message: "CIImage read error"))
        }
        let context = CIContext(options: nil)
        let options:[CIImageRepresentationOption: Any] = [CIImageRepresentationOption.init(rawValue: kCGImageDestinationLossyCompressionQuality as String): quality]
        var result = context.heifRepresentation(of: image, format: CIFormat.ARGB8, colorSpace: image.colorSpace ?? CGColorSpace.init(name: CGColorSpace.sRGB)!, options: options)
        if result == nil {
            result = context.heifRepresentation(of: image, format: CIFormat.ARGB8, colorSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!, options: options)
        }
        if let _data = result {
            return Result.success(_data)
        }else {
            return Result.failure(HEICConverterError(message: "heifRepresentation returns nil"))
        }
    }

    ///将文件转换为HEIC文件并返回HEIC文件的二进制数据
    private static func convert(url: URL, option: HEICConverterOption, completion: (Result<Data, Error>)->Void) {
        //读取文件后, 将转换完毕的文件写入temp文件夹, 并将新的URL回调
        var data: Data!
        do {
            let fh = try FileHandle.init(forReadingFrom: url)
            data = fh.readDataToEndOfFile()
            if data == nil || data.count < 4 {
                completion(.failure(HEICConverterError.init(message: "读取文件失败")))
                return
            }
            let heicDataResult = Self.imageDataToHEICData(data, quality: option.quality)
            switch heicDataResult {
            case .failure(let error):
                completion(.failure(error))
            case .success(let heicData):
                completion(.success(heicData))
            }
        }catch {
            completion(.failure(error))
            return
        }
    }
}
