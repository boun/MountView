//
//  MountedItem.swift
//  MountView
//
//  Created by Bendedikt Elser on 23.11.17.
//

import Foundation
import Cocoa

class MountedItem: LovedItem {

    static let keys: [URLResourceKey] = [.volumeNameKey, .volumeURLForRemountingKey, .volumeIsEjectableKey, .effectiveIconKey]
    

    static func fromMountedFilesystems(theurl: URL) -> MountedItem {
        
        let se = Set<URLResourceKey>(MountedItem.keys)
        var vals = URLResourceValues()
        do {
            vals = try theurl.resourceValues(forKeys: se)
        } catch {
            Swift.print("Conversion")
        }

        var remountingURL = ""
        if let url = vals.volumeURLForRemounting {
            remountingURL = url.absoluteString as String
        } else {
            remountingURL = theurl.absoluteString
        }
        
        let item = MountedItem(absolutePath: theurl.absoluteString, volumeName: vals.volumeName as String!, volumeURLForRemounting: remountingURL)
        
        item.isEjectable = vals.volumeIsEjectable! || (vals.volumeURLForRemounting != nil)
        item.icon = vals.effectiveIcon as! NSImage
        item.loved = false

        return item
    }
}
