//
//  HEICViewController+QualityOptionView.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/9/5.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Cocoa

extension HEICViewController {

    class QualityOptionView: NSView {

        let threadTitleLabel = NSTextField(labelWithString: "Parallel")
        let threadBox: NSComboBox = {
            let box = NSComboBox()
            let processorNum = ProcessInfo().processorCount
            var items = (1...processorNum).filter({$0.isMultiple(of: 2)}).map({"\($0)"})
            items.insert("1", at: 0)
            box.addItems(withObjectValues:items)
            box.stringValue = "\(processorNum)"
            return box
        }()
        let qualityLabel = NSTextField(labelWithString: "Quality: 0.75")
        lazy var qualitySlider = NSSlider(value: 0.75, minValue: 0.01, maxValue: 1.0, target: self, action: #selector(self.qualitySliderValueChanged))

        private lazy var stackView: NSStackView = NSStackView(views: [self.threadTitleLabel, self.threadBox, self.qualityLabel, self.qualitySlider])

        var parallel: Int {
            return Int(self.threadBox.stringValue)!
        }
        var quality:CGFloat {
            return CGFloat(self.qualitySlider.doubleValue)
        }

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)

            self.threadBox.snp.makeConstraints { (make) in
                make.width.equalTo(52)
            }
            self.qualitySlider.snp.makeConstraints { (make) in
                make.width.equalTo(90)
            }
            self.qualityLabel.snp.makeConstraints { (make) in
                make.width.equalTo(self.qualityLabel.intrinsicContentSize.width)
            }
            self.addSubview(self.stackView)

        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var fittingSize: NSSize {
            return self.stackView.fittingSize
        }

        override var intrinsicContentSize: NSSize {
            return self.stackView.fittingSize
        }

        override func layout() {
            super.layout()
            self.stackView.frame = self.bounds
        }

        @objc func qualitySliderValueChanged() {
            self.qualityLabel.stringValue = "Quality: ".appending(String.init(format: "%.2f", qualitySlider.doubleValue))
        }

    }

}
