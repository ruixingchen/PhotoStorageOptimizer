//
//  HEICViewController+OptionView.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/9/5.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Cocoa

extension HEICViewController {

    class FormatOptionView: NSView {

        let jpgCheckBox: NSButton = {
            let button: NSButton = NSButton(checkboxWithTitle: "JPG", target: nil, action: nil)
            button.state = NSButton.StateValue.on
            return button
        }()
        let pngCheckBox: NSButton = {
            let button: NSButton = NSButton(checkboxWithTitle: "PNG", target: nil, action: nil)
            button.state = NSButton.StateValue.on
            return button
        }()
        let bmpCheckBox: NSButton = {
            let button: NSButton = NSButton(checkboxWithTitle: "BMP", target: nil, action: nil)
            button.state = NSButton.StateValue.on
            return button
        }()
        let heicCheckBox: NSButton = {
            let button: NSButton = NSButton(checkboxWithTitle: "HEIC", target: nil, action: nil)
            button.state = NSButton.StateValue.off
            return button
        }()
        let keepOriginCheckBox: NSButton = {
            let button: NSButton = NSButton(checkboxWithTitle: "Keep origin file", target: nil, action: nil)
            button.state = NSButton.StateValue.on
            return button
        }()

        private lazy var formatStackView: NSStackView = NSStackView(views: [self.jpgCheckBox, self.pngCheckBox, self.bmpCheckBox, self.heicCheckBox, self.keepOriginCheckBox])

        var formats:[String] {
            var _formats:[String] = []
            if self.jpgCheckBox.state == .on {
                _formats.append("jpg")
                _formats.append("jpeg")
            }
            if self.pngCheckBox.state == .on {
                _formats.append("png")
            }
            if self.bmpCheckBox.state == .on {
                _formats.append("bmp")
            }
            if self.heicCheckBox.state == .on {
                _formats.append("heic")
            }
            return _formats
        }

        var keepOrigin: Bool {
            return self.keepOriginCheckBox.state == .on
        }

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.addSubview(self.formatStackView)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var fittingSize: NSSize {
            return self.formatStackView.fittingSize
        }

        override var intrinsicContentSize: NSSize {
            return self.formatStackView.fittingSize
        }

        override func layout() {
            super.layout()
            self.formatStackView.frame = self.bounds
        }

    }

}
