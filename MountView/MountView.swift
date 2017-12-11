//
//  MountView.swift
//  MountView
//
//  Created by Bendedikt Elser on 21.11.17.
//

import Cocoa

protocol MouseClickUp {
    func mouseClickUp(view: MountView)
}


class MountView: NSView {
    var delegate: MouseClickUp?
    
    @IBOutlet weak var devImage: NSImageView!
    @IBOutlet weak var devField: NSTextField!
    @IBOutlet weak var URLField: NSTextField!
    @IBOutlet weak var ejectButton: NSButton!
    @IBOutlet weak var loveButton: NSButton!
    
    var url = URL(string:"")
    var item: LovedItem?
    
    class func instanceFromNib() -> NSView {
        var objs = NSArray()
        if Bundle.main.loadNibNamed("MountView", owner: nil, topLevelObjects: &objs) {
            for obj in objs {
                if obj is MountView {
                    let view = obj as! NSView
                    let trackingArea:NSTrackingArea = NSTrackingArea(rect: view.frame as CGRect, options: [NSTrackingAreaOptions.activeAlways, NSTrackingAreaOptions.mouseEnteredAndExited], owner: view, userInfo: nil)
                    view.addTrackingArea(trackingArea)
                    return view
                }
            }
        }
        
        return NSView()
    }
    
    func update(_ data: LovedItem) {
        self.item = data
        self.devField.stringValue = data.volumeName
        self.URLField.stringValue = data.volumeURLForRemounting
        self.devImage.image = data.icon
        self.ejectButton.isHidden = !data.isEjectable
        if (data.loved) {
            self.loveButton.title = "♥"
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        delegate?.mouseClickUp(view: self)
    }
    
    //https://stackoverflow.com/questions/43265671/osx-nsmenuitem-with-custom-nsview-does-not-highlight-swift
    var highlighted : Bool = false {
        didSet {
            if oldValue != highlighted {
                needsDisplay = true
            }
        }
    }
    
    override func mouseEntered(with theEvent: NSEvent) { highlighted = true }
    override func mouseExited(with theEvent: NSEvent) { highlighted = false }

    // Why are the colors so strange in all views, except the image view???
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        if highlighted  {
            NSColor.selectedMenuItemColor.set()
        } else {
            NSColor.clear.set()
        }
        NSBezierPath.fill(dirtyRect)
    }

    
}
