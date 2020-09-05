//
//  HEICViewController.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/4/28.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Cocoa
import FileKit
import SnapKit

class HEICConvertDetail {

    let url: URL
    ///nil表示尚未转换, 失败表示转换失败
    var convertedURL: Result<URL, Error>?
    var originSize: UInt64 = 0
    var convertedSize: UInt64 = 0
    var duration: TimeInterval = 0

    init(url: URL) {
        self.url = url
    }

}

class HEICViewController: NSViewController {

    var dragView:RXCDragDropView {return self.view as! RXCDragDropView}

    var processing: Bool = false

    let titleLabel:NSTextField = {
        let label = NSTextField(labelWithString: "Convert Your Photo to HEIC Format, Save 50% of Storage\nDrag Files or Folders In to Process")
        label.alignment = NSTextAlignment.center
        return label
    }()
    let logoImageView: NSImageView = {
        let view: NSImageView = NSImageView()
        view.image = NSImage(named: NSImage.Name.init(stringLiteral: "logo"))
        return view
    }()

    let formatOptionView = FormatOptionView()
    let qualityOptionView = QualityOptionView()

    let progressBar: NSProgressIndicator = {
        let bar: NSProgressIndicator = NSProgressIndicator()
        bar.style = .bar
        bar.minValue = 0
        bar.maxValue = 1
        bar.doubleValue = 0.0
        bar.isIndeterminate = false
        return bar
    }()
    let messageLabel: NSTextField = {
        let label: NSTextField = NSTextField.init(labelWithString: "waiting")
        label.alignment = NSTextAlignment.center
        return label
    }()

    override func loadView() {
        self.view = RXCDragDropView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.registerForDraggedTypes([.fileURL])
        self.dragView.dragClosure = { [weak self] (urls)->Void in
            self?.onDragFiles(urls: urls)
        }
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.logoImageView)
        self.view.addSubview(self.formatOptionView)
        self.view.addSubview(self.qualityOptionView)
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.messageLabel)
        self.addConstraints()
    }

    func addConstraints() {
        self.logoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(88)
            make.height.equalTo(88)
            make.centerX.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.logoImageView.snp.bottom).offset(12)
        }
        self.qualityOptionView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(24)
        }
        self.formatOptionView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.qualityOptionView.snp.bottom).offset(12)
        }
        self.progressBar.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.formatOptionView.snp.bottom).offset(24)
            make.width.lessThanOrEqualToSuperview().offset(-48)
        }
        self.messageLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.progressBar.snp.bottom).offset(24)
        }
    }

    func readOptions()->HEICConverterOption {
        var option = HEICConverterOption()
        option.supportedFormats = self.formatOptionView.formats
        option.keepOrigin = self.formatOptionView.keepOrigin
        option.quality = self.qualityOptionView.quality
        option.threads = self.qualityOptionView.parallel
        return option
    }

    func onDragFiles(urls:[URL]) {
        ///拖入文件后
        //1, 读取文件夹下所有的文件列表
        //2, 过滤出支持的格式
        //3, 依次将图片转换为HEIC, 并存入临时文件夹
        //4, 将图片存入目标文件夹
        guard !self.processing else {return}
        self.processing = true

        let completion:()->Void = {
            self.processing = false
            self.progressBar.doubleValue = 0.0
        }

        let option: HEICConverterOption = self.readOptions()
        NSLog("开始读取所有文件")
        var allFiles:Set<URL> = FileManager.enumAllFiles(under: urls)
        NSLog("读取所有文件完毕, 共计:\(allFiles.count)")
        self.messageLabel.stringValue = "filtering files"

        DispatchQueue.global().async {
            //读取并过滤不支持的文件
            allFiles = allFiles.filter { (url) -> Bool in
                guard let type = FileHelper.typeFrom(fileURL: url) else {return false}
                if option.supportedFormats.contains(type) {
                    return true
                }
                return false
            }
            NSLog("过滤所有文件完毕, 共计:\(allFiles.count)")
            if allFiles.isEmpty {
                DispatchQueue.main.async {
                    self.messageLabel.stringValue = "no files matche the format"
                    completion()
                }
                return
            }

            self.batchConvert(urls: [URL].init(allFiles), options: option, completion: {
                completion()
            })
        }
    }

    /// 批量转换
    /// - Parameters:
    ///   - urls: 要转换的文件列表
    ///   - options: 转换选项
    ///   - completion: 单个文件转换完成的回调, url为新文件的URL
    func batchConvert(urls:[URL], options:HEICConverterOption, completion:@escaping ()->Void) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = options.threads

        ///转换后文件的URL, 转换前的大小, 转换后的大小
        var convertDetail:[URL: HEICConvertDetail] = [:]
        urls.forEach { (url) in
            let detail = HEICConvertDetail.init(url: url)
            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path), let size = attributes[.size] as? UInt64 {
                detail.originSize = size
            }else {
                detail.originSize = 0
            }
            convertDetail[url] = detail
        }

        let group = DispatchGroup()

        for url in urls {
            group.enter()
            queue.addOperation {
                let newDetail = self.convert(url: url, options: options)
                let detail = convertDetail[url]
                detail?.convertedSize = newDetail.convertedSize
                detail?.convertedURL = newDetail.convertedURL
                detail?.convertedSize = newDetail.convertedSize
                detail?.originSize = newDetail.originSize
                detail?.duration = newDetail.duration
                DispatchQueue.main.async {
                    self.updateMessage(details: convertDetail.map({$0.value}))
                }
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main, execute: completion)

    }

    ///转换一个文件, 并且返回转换详情
    func convert(url: URL, options: HEICConverterOption)->HEICConvertDetail {
        let detail: HEICConvertDetail = HEICConvertDetail(url: url)
        detail.convertedURL = Result.failure(NSError())
        let startTime = Date().timeIntervalSince1970
        guard let originData: Data = try? Data.init(contentsOf: url) else {return detail}
        guard let convertedData: Data = HEICConverter.imageDataToHEICData(originData, quality: options.quality).value else {return detail}

        //1, 计算新文件的文件名
        //2, 写入数据
        //3, 根据需要判断是否需要删除原始文件

        detail.originSize = UInt64(originData.count)
        detail.convertedSize = UInt64(convertedData.count)

        var newFileURL = url
        if url.pathExtension.lowercased() == "heic" && options.keepOrigin {
            newFileURL.deletePathExtension()
            let userName = newFileURL.lastPathComponent + "_heic"
            newFileURL.deleteLastPathComponent()
            newFileURL.appendPathComponent(userName)
            newFileURL.appendPathExtension("heic")
        }else {
            newFileURL.deletePathExtension()
            newFileURL.appendPathExtension("heic")
        }
        if FileManager.default.fileExists(atPath: newFileURL.path) {
            do {
                try FileManager.default.trashItem(at: newFileURL, resultingItemURL: nil)
            }catch {
                return detail
            }
        }
        do {
            try convertedData.write(to: newFileURL)
            detail.convertedURL = Result.success(newFileURL)
        }catch {
            detail.convertedURL = Result.failure(NSError())
        }
        do {
            if !options.keepOrigin {
                try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            }
        }catch {
            //删除原始文件错误, 我们仍然认为转换成功了
        }
        detail.duration = Date().timeIntervalSince1970 - startTime
        return detail
    }

    func updateMessage(details:[HEICConvertDetail]) {
        var allOriginSizeSum: Int64 = 0
        var originSizeSum: Int64 = 0
        var convertedSizeSum: Int64 = 0
        var successNum: Int = 0
        var failedNum: Int = 0
        var totalDuration: TimeInterval = 0

        for i in details {
            allOriginSizeSum += Int64(i.originSize)
            if let convertedURL = i.convertedURL {
                if convertedURL.isSuccess {
                    originSizeSum += Int64(i.originSize)
                    convertedSizeSum += Int64(i.convertedSize)
                    successNum += 1
                    totalDuration += i.duration
                }else {
                    failedNum += 1
                }
            }else {
                //尚未开始转换
            }
        }

        let progress = Double(successNum+failedNum) / Double(details.count)
        self.progressBar.doubleValue = progress
        print(self.progressBar.doubleValue)

        let compressRate = Float(convertedSizeSum) / Float(max(1, originSizeSum))
        let compressedSize = originSizeSum - convertedSizeSum
        let timeRemainText:String = {
            let timeRemain = TimeInterval(details.count - successNum - failedNum) * totalDuration / TimeInterval(successNum)
            let m = Int(timeRemain/60)
            let s = Int(timeRemain) % 60
            return m.description + ":" + s.description
        }()
        let finish = successNum + failedNum == details.count

        var message: String = ""
        if finish {
            message += "Finish, "
        }else {
            message += "Converting, "
        }
        message += "\(successNum) success, \(failedNum) failed, \(ByteCountFormatter().string(fromByteCount: allOriginSizeSum))"
        if !finish {
            message += ", \(timeRemainText) remain"
        }
        message += "\n"
        message += "origin size:\(ByteCountFormatter().string(fromByteCount: originSizeSum)), converted:\(ByteCountFormatter().string(fromByteCount: convertedSizeSum)), compressed:\(ByteCountFormatter().string(fromByteCount: compressedSize)), rate:\(String.init(format: "%.2f", compressRate))"
        self.messageLabel.stringValue = message
    }

}
