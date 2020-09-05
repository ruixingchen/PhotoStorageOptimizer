//
// Created by ruixingchen on 2020/4/28.
// Copyright (c) 2020 ruixingchen. All rights reserved.
//

import Cocoa

class RXCDragDropView: NSView {

    var dragClosure:(([URL])->Void)?

    override func draggingEnded(_ sender: NSDraggingInfo) {
        guard self.bounds.contains(sender.draggingLocation) else {return}
        guard let items = sender.draggingPasteboard.pasteboardItems else {return}
        let urls:[URL] = items.map({$0.string(forType: .fileURL)}).filter({$0 != nil}).map({URL(fileURLWithPath: $0!).standardized})
        self.dragClosure?(urls)
    }
    
}
