//
//  LovedItem.swift
//  MountView
//
//  Created by Bendedikt Elser on 22.11.17.
//
import Foundation
import Cocoa

class LovedItem: NSObject {
    var absolutePath: String
    var volumeName: String
    var volumeURLForRemounting: String
    var isEjectable: Bool
    var icon: NSImage
    var loved: Bool
    
    init(absolutePath: String, volumeName: String, volumeURLForRemounting: String) {
        self.absolutePath = absolutePath
        self.volumeName = volumeName
        self.volumeURLForRemounting = volumeURLForRemounting
        self.isEjectable = false
        self.icon = NSImage(byReferencingFile: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericAirDiskIcon.icns")!
        self.loved = true
    }
    
    // Functions to Serialize this Object to a configuration
    
    static func dump(that item:LovedItem) -> [String:String] {
        var ret: [String:String] = [:]
        ret["absolutePath"] = item.absolutePath
        ret["volumeName"] = item.volumeName
        ret["volumeURLForRemounting"] = item.volumeURLForRemounting
        return ret
    }
    
    override var description: String {
        get {
            return "{ "
                + "\n absolutePath: \(self.absolutePath)"
                + "\n volumeName: \(self.volumeName)"
                + "\n volumeURLForRemounting: \(self.volumeURLForRemounting)"
                + "\n isEjectable: \(self.isEjectable)"
                + "\n loved: \(self.loved)"
                + "\n}"

        }
    }
    
    // Intentionally contains only one attribute
    override var hashValue: Int {
        get {
            return self.volumeURLForRemounting.hashValue
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        print("Equal")

        guard let rhs = object as? LovedItem else {
            return false
        }
        return self.volumeURLForRemounting == rhs.volumeURLForRemounting
    }
    
    override func isEqual(to object: Any?) -> Bool {
        guard let rhs = object as? LovedItem else {
            return false
        }
        return self.volumeURLForRemounting == rhs.volumeURLForRemounting
        
    }
    
}
