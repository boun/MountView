//
//  Utils.swift
//  MountView
//
//  Created by Bendedikt Elser on 22.11.17.
//

import Foundation
import NetFS

class Utils {
    
    static func mountShare(sharePath: String) -> String? {
        let res = UnsafeMutablePointer<Unmanaged<CFArray>?>(mutating: [])
        
        let mounted : Int32 = NetFSMountURLSync(URL(string: sharePath)! as CFURL, nil, nil, nil, nil, nil, res)
        if mounted > 0 {
            print("Error: sharePath: \(sharePath) Not Valid \(mounted)")
            return nil
        } else {
            let b = res.pointee?.takeRetainedValue()
            let mountPath = unsafeBitCast(CFArrayGetValueAtIndex(b, 0), to: CFString.self)
            print("Mounted: \(sharePath) at \(mountPath)")
            return mountPath as String
        }
    }
    
    static func getMountedVolumes() -> Set<MountedItem> {
        let filemanager = FileManager()
        let paths = filemanager.mountedVolumeURLs(includingResourceValuesForKeys: MountedItem.keys, options: [.skipHiddenVolumes])
        var ret = Set<MountedItem>()
        
        if let urls = paths {
            for url in urls {
                
                let mountItem = MountedItem.fromMountedFilesystems(theurl: url)
                print(LovedItem.dump(that: mountItem))
                ret.insert(mountItem)
            }
        }
        return ret
    }

    
}
