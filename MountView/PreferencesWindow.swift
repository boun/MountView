//
//  PreferencesWindow.swift
//  MountView
//
//  Created by Benedikt Elser on 22.11.17.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    var delegate: PreferencesWindowDelegate?
    var loved = Set<LovedItem>()

    @IBOutlet weak var table: NSTableView!
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.table.noteNumberOfRowsChanged()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        table.delegate = self
        table.dataSource = self
    }
    
    @IBAction func removeClicked(_ sender: NSButton) {
        guard let mv = sender.superview as? MountView  else {
            return
        }
        guard let item = mv.item else {
            return
        }
        loved.remove(item)
        self.table.noteNumberOfRowsChanged()
    }
    
    func windowWillClose(_ notification: Notification) {
        delegate?.preferencesDidUpdate()
    }
}

extension PreferencesWindow: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return loved.count
    }
}

extension PreferencesWindow: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let item = loved[loved.index(loved.startIndex, offsetBy: row)]
        let view = MountView.instanceFromNib() as! MountView
        view.update(item)
        view.loveButton.target = self
        view.loveButton.action = #selector(removeClicked)
        // Call update before, otherwise it overwrites this :)
        view.loveButton.title = "X"

        return view
    }
    
}


