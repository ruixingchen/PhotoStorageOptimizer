//
//  HEICConverterOption.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/9/5.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Foundation

class HEICConverterError: Error, LocalizedError, CustomStringConvertible {

    let message: String

    init(message: String) {
        self.message = message
    }

    var localizedDescription: String {
        return self.message
    }

    var description: String {
        return "Error".appending(self.message)
    }

}

struct HEICConverterOption {
    ///支持的扩展名, 大小写不敏感
    var supportedFormats:[String] = []
    ///线程数, 其实不重要
    var threads:Int = ProcessInfo().processorCount/2 + 1 //ignore hyperthreading
    ///图片质量, 系统默认为0.8
    var quality: CGFloat = 0.75 //this is a balance of quality and storage
    ///保留原始图片, 否则删除原始图片
    var keepOrigin: Bool = true
}
