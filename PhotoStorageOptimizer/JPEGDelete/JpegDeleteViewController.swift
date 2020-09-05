//
//  JpegDeleteViewController.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/5/11.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Cocoa
import FileKit

///删除RAW文件旁边的JPEG文件
class JpegDeleteViewController: NSViewController {

    var dragView:RXCDragDropView {return self.view as! RXCDragDropView}

    let titleLabel = NSTextField.init(labelWithString: "Drag Folder in to Delete All JPEG Files Next to RAW Files")
    let messageLabel = NSTextField.init(labelWithString: "waiting")

    var rawExtensions:[String] = [
        "3rf", //Hasselblad
        "ari", //Alexa
        "arw", "srf", "sr2", //sony
        "bay", //Casio
        "braw", //black magic
        "cri", //Cintel
        "crw", "cr2", "cr3", //Canon
        "cap", "iiq", "eip", //Phase_One
        "dcs", "dcr", "drf", "k25", "kdc", //Kodak
        "dng", //Adobe
        "erf", //Epson
        "fff", //Imacon
        "gpr", //GoPro
        "mef", //Mamiya
        "mdc", //Minolta
        "mos", //Leaf
        "mrw", //Minolta
        "nef", "nrw", //Nikon
        "orf", //Olympus
        "pef", "ptx", //Pentax
        "pxn", //Logitech
        "r3d", //RED
        "raf", //Fuji
        "raw", "rw2", //Panasonic
        "rwl", //Leica
        "rwz", //Rawzor
        "srw", //Samsung
        "x3f" //Sigma
    ]

    var jpegExtensions:[String] = ["jpg", "jpeg", "png", "heic"]

    override func loadView() {
        self.view = RXCDragDropView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.registerForDraggedTypes([.fileURL])
        self.dragView.dragClosure = { [weak self] (urls)->Void in
            self?.didSelectFiles(urls: urls)
        }
        self.titleLabel.alignment = .center
        self.messageLabel.alignment = .center
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.messageLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
        }
        self.messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
        }
    }

    @objc func didSelectFiles(urls:[URL]) {
        self.messageLabel.stringValue = "filtering files"
        let rawURLs = self.enumAllRawFiles(in: urls)
        if rawURLs.isEmpty {
            self.messageLabel.stringValue = "no RAW files found"
            return
        }
        var jpegURLs:Set<URL> = []
        for rawURL in rawURLs {
            for jpegExtension in self.jpegExtensions {
                let jpegURL = rawURL.deletingPathExtension().appendingPathExtension(jpegExtension)
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: jpegURL.path, isDirectory: &isDirectory) {
                    if !isDirectory.boolValue {
                        jpegURLs.insert(jpegURL)
                    }
                }
            }
        }

        if jpegURLs.isEmpty {
            self.messageLabel.stringValue = "no JPEG files found"
            return
        }

        var successURLs:[URL] = []
        var failedURLs:[URL] = []
        for i in jpegURLs {
            do {
                try FileManager.default.trashItem(at: i, resultingItemURL: nil)
                successURLs.append(i)
            }catch {
                failedURLs.append(i)
            }
        }
        self.messageLabel.stringValue = "finish, \(failedURLs.count) failed, \(successURLs.count) success"
    }

}

extension JpegDeleteViewController {

    fileprivate func enumAllRawFiles(in urls:[URL])->[URL] {
        var rawURLs:Set<URL> = []

        for i in urls {
            var isDirectory: ObjCBool = ObjCBool.init(false)
            if FileManager.default.fileExists(atPath: i.path, isDirectory: &isDirectory) {
                if !isDirectory.boolValue {
                    if self.rawExtensions.contains(i.pathExtension.lowercased()) {
                        rawURLs.insert(i)
                    }
                }else {
                    let contents = (try? FileManager.default.contentsOfDirectory(at: i, includingPropertiesForKeys: nil, options: .init())) ?? []
                    for j in contents {
                        self.enumAllRawFiles(in: [j]).forEach({rawURLs.insert($0)})
                    }
                }
            }

        }

        return [URL].init(rawURLs)
    }

}
