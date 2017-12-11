//
//  StatusMenuController.swift
//  MountView
//
//  Benedikt Elser
//  Based on work by Brad Greenlee on 10/11/15.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate, MouseClickUp, NSMenuDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    var weatherMenuItem: NSMenuItem!
    var preferencesWindow: PreferencesWindow!
    var loved = Set<LovedItem>()
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    func menuWillOpen(_ menu: NSMenu) {
        refresh()
    }
    
    override func awakeFromNib() {
        statusItem.menu = statusMenu
        statusItem.button?.title = "⏏"
        statusMenu.delegate = self
        
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true // best for dark mode
        
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        if (UserDefaults.standard.object(forKey: "lovedPlaces") != nil) {
            let array: [[String:String]] = UserDefaults.standard.object(forKey: "lovedPlaces") as! [[String:String]]
            for i in array {
                loved.insert(LovedItem(absolutePath: i["absolutePath"]!, volumeName: i["volumeName"]!, volumeURLForRemounting: i["volumeURLForRemounting"]!))
            }
        }
        
        updateMountedVolumes()
    }
    
    // Displays a loved item in the MenuBar context menu
    fileprivate func addMenuItem(_ mountItem: LovedItem) {
        let view = MountView.instanceFromNib() as! MountView
        view.delegate = self
        view.loveButton.target = self
        view.loveButton.action = #selector(self.loveClicked)
        view.ejectButton.target = self
        view.ejectButton.action = #selector(self.ejectClicked)
        view.update(mountItem)
        
        let menuItem : NSMenuItem = NSMenuItem()
        menuItem.title = mountItem.absolutePath
        menuItem.view = view
        
        statusMenu.insertItem(menuItem, at: 0)
    }
    
    // Merges information from two sources
    // 1. Mounted Devices
    // 2. Loved Items (from preferences
    func updateMountedVolumes() {
        let mountedVolumes = Utils.getMountedVolumes()

        // Everything that is mounted and maybe loved
        for mountItem in mountedVolumes {
            if (loved.contains(mountItem)) {
                mountItem.loved = true
            }
            addMenuItem(mountItem)
        }

        // Everything that is not mounted but loved
        // This is because a freshly loved item is a mounted item,
        //that may be ejectable and not loved
        loved.subtracting(mountedVolumes).forEach {
            $0.isEjectable = false
            $0.loved = true
            addMenuItem($0)
        }
    }
    
    func refresh() {
        // remove all custom views
        statusMenu.items.filter({$0.view is MountView}).forEach({ statusMenu.removeItem($0)})

        updateMountedVolumes()
    }
    
    // The change of the title should be in MountView.swift
    @IBAction func loveClicked(_ sender: NSButton) {
        let mv = sender.superview as! MountView
        
        if (sender.title == "♡") {
            // Was Loved
            sender.title = "♥"
            loved.insert(mv.item!)
        } else {
            // Was unloved
            sender.title = "♡"
            loved.remove(mv.item!)
        }
        savePrefs()
        
    }
    
    func savePrefs() {
        UserDefaults.standard.set(loved.map({LovedItem.dump(that: $0)}), forKey: "lovedPlaces")
    }
    
    @IBAction func ejectClicked(_ sender: NSButton) {
        print("Eject clicked")
        
        guard let mv = sender.superview as? MountView else {
            print("This is no mount view")
            return
        }
        
        guard let item = mv.item else {
            print("No LovedItem attached to view")
            return
        }
        
        guard let url = URL(string: item.absolutePath) else {
            print("Can not construct url from: \(item.absolutePath)")
            return
        }
        
        do {
            try NSWorkspace.shared().unmountAndEjectDevice(at: url)
        } catch {
            print("ERROR unmounting")
            return
        }
        sender.isHidden = true
        self.statusMenu.cancelTracking()
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.loved = loved
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    func preferencesDidUpdate() {
        self.loved = preferencesWindow.loved
        savePrefs()
    }
    
    func mouseClickUp(view: MountView) {
        self.statusMenu.cancelTracking()
        print("Click up")
        
        guard let item = view.item else {
            return
        }
        guard var path = URL(string: item.absolutePath)?.path else {
            return
        }
        
        // Mount async, so the menu closes instead of BeachBall
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // This might fail, if a mountedItem is loved, ejected and then to be mounted again
            // Which is unlikely, because we recompute everything on each menu click
            if !(view.item is MountedItem?) {
                let mounted = Utils.mountShare(sharePath: item.volumeURLForRemounting)
                guard mounted != nil else {
                    Swift.print("ERROR mounting \(path)")
                    return
                }
                path = mounted!
            }
            print("Opening \(path)")
            NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: path)
        }
    }
}
