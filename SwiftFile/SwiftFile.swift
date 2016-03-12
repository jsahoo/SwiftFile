//
//  SwiftFile.swift
//  SwiftFile
//
//  Created by Jonathan Sahoo on 3/11/16.
//  Copyright © 2016 Jonathan Sahoo. All rights reserved.
//

import Foundation

public class SwiftFile: NSObject {
    
    private static let SwiftFileStorageMap = "SwiftFileStorageMap"
    private static let SwiftFileStorageMapDirectory = NSSearchPathDirectory.ApplicationSupportDirectory
    
    /// Array of keys referencing objects that are currently stored.
    public static var keys: [String] { get { return Array(storedFilesMap.keys) } }
    
    /**
     Sets whether or not the item for a given key should be included in iCloud/iTunes backups.
     
     - parameter allowed: Whether or not the item should be included in iCloud/iTunes backups.
     - parameter key: The key for the item.
     - returns: `True` if successful, `False` otherwise.
    */
    public static func setBackupsAllowed(allowed: Bool, forItemWithKey key: String) -> Bool {
        guard let filepath = filepathForStoredObject(key) else {return false}
        let url = NSURL(fileURLWithPath: filepath)
        if let path = url.path where NSFileManager.defaultManager().fileExistsAtPath(path) {
            do {
                try url.setResourceValue(allowed, forKey: NSURLIsExcludedFromBackupKey)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    /**
     Checks whether or not the item for a given key will be included in iCloud/iTunes backups.
     
     - parameter key: The key for the object.
     - returns: `True` if object will be included in iCloud/iTunes backups, `False` otherwise.
     */
    public static func backupsAllowedForObjectWithKey(key: String) -> Bool? {
        guard let filepath = filepathForStoredObject(key) else {return nil}
        let url = NSURL(fileURLWithPath: filepath)
        if let path = url.path where NSFileManager.defaultManager().fileExistsAtPath(path) {
            do {
                let results = try url.resourceValuesForKeys([NSURLIsExcludedFromBackupKey])
                return results[NSURLIsExcludedFromBackupKey] as? Bool
            } catch {
                return nil
            }
        }
        return false
    }
    
    /**
     Stores an object classified as "App Data". Objects stored as "App Data" are included in iCloud/iTunes backups by default.
     
     - note: `key` must be unique to `SwiftFile`, not just this data type.
     - parameter object: The object to be stored.
     - parameter key: The key which will be used to reference the object.
     - parameter backupsAllowed: Whether or not the item should be included in iCloud/iTunes backups.
     - returns: `True` if stored successfully, `False` otherwise.
     */
    public static func storeObjectAsAppData(object: NSCoding, forKey key: String, backupsAllowed: Bool) -> Bool {
        return archiveObject(object, toDirectory: .ApplicationSupportDirectory, forKey: key, backupsAllowed: backupsAllowed)
    }
    
    /**
     Stores an object classified as "User Data". Objects stored as "User Data" are included in iCloud/iTunes backups by default.
     
     - note: `key` must be unique to `SwiftFile`, not just this data type.
     - parameter object: The object to be stored.
     - parameter key: The key which will be used to reference the object.
     - parameter backupsAllowed: Whether or not the item should be included in iCloud/iTunes backups.
     - returns: `True` if stored successfully, `False` otherwise.
     */
    public static func storeObjectAsUserData(object: NSCoding, forKey key: String, backupsAllowed: Bool) -> Bool {
        return archiveObject(object, toDirectory: .DocumentDirectory, forKey: key, backupsAllowed: backupsAllowed)
    }
    
    /**
     Stores an object classified as Cache. Objects stored as Cache are not included in iCloud/iTunes backups.
     
     - note: `key` must be unique to `SwiftFile`, not just this data type.
     - parameter object: The object to be stored.
     - parameter key: The key which will be used to reference the object.
     - returns: `True` if stored successfully, `False` otherwise.
     */
    public static func storeObjectAsCache(object: NSCoding, forKey key: String) -> Bool {
        return archiveObject(object, toDirectory: .CachesDirectory, forKey: key, backupsAllowed: false)
    }
    
    /**
     Checks whether or not the object for a given key exists.
     
     - parameter key: The key for the object.
     - returns: `True` if item exists, `False` otherwise.
     */
    public static func objectExistsForKey(key: String) -> Bool {
        guard let filepath = filepathForStoredObject(key) else {return false}
        if NSFileManager.defaultManager().fileExistsAtPath(filepath) {
            return true
        }
        return false
    }
    
    /**
     Retrieves the object for a given key.
     
     - parameter key: The key for the object.
     - returns: The object if it exists, `nil` otherwise.
     */
    public static func objectForKey(key: String) -> AnyObject? {
        guard let filepath = filepathForStoredObject(key) else {return nil}
        return NSKeyedUnarchiver.unarchiveObjectWithFile(filepath)
    }
    
    /**
     Removes the object for a given key from storage.
     
     - parameter key: The key for the object.
     - returns: `True` if object was removed successfully, `False` otherwise.
     */
    public static func removeObjectForKey(key: String) -> Bool {
        guard let filepath = filepathForStoredObject(key) else {return false}
        if NSFileManager.defaultManager().isDeletableFileAtPath(filepath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filepath)
                removeItemFromStoredFilesMap(key)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    // MARK: - Internal Helper Functions
    
    /// constructs a filepath from NSSearchPathDirectory and a key (filename) and creates the directory if it doesn't already exists
    private static func constructFilepathFrom(rootDirectorySearchPath: NSSearchPathDirectory, key: String) -> String? {
        guard let rootDirectory = NSSearchPathForDirectoriesInDomains(rootDirectorySearchPath, .UserDomainMask, true).first else {return nil}
        if !NSFileManager.defaultManager().fileExistsAtPath(rootDirectory) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(rootDirectory, withIntermediateDirectories: false, attributes: nil)
                return "\(rootDirectory)/\(key)"
            } catch {
                return nil
            }
        }
        return "\(rootDirectory)/\(key)"
    }
    
    /// saves the object to disk
    private static func archiveObject(object: NSCoding, toDirectory dir: NSSearchPathDirectory, forKey key: String, backupsAllowed: Bool) -> Bool {
        if key.isEmpty || key == SwiftFileStorageMap {return false}
        guard let filepath = constructFilepathFrom(dir, key: key) else {return false}
        
        // Check if an existing key is trying to be used with a different directory
        if let existingDirRawValue = storedFilesMap[key] where existingDirRawValue != dir.rawValue {
            if !removeObjectForKey(key) {return false}
        }
        
        if NSKeyedArchiver.archiveRootObject(object, toFile: filepath) {
            if addItemToStoredFilesMap(key, rootDirectory: dir) {
                if setBackupsAllowed(backupsAllowed, forItemWithKey: key) {
                    return true
                }
                else {
                    // remove from stored file map, remove from storage
                    removeObjectForKey(key)
                }
            }
            else {
                // remove from storage
                removeObjectForKey(key)
            }
        }
        return false
    }
    
    /// get filepath for an object previously saved to disk
    private static func filepathForStoredObject(key: String) -> String? {
        guard let dirRawValue = storedFilesMap[key], let dir = NSSearchPathDirectory(rawValue: dirRawValue) else {return nil}
        return constructFilepathFrom(dir, key: key)
    }
    
    // MARK: - SwiftFile Internal Map
    
    /// internal map of keys to object locations
    private static var storedFilesMap: [String : UInt] {
        get {
            if let filepath = constructFilepathFrom(SwiftFileStorageMapDirectory, key: SwiftFileStorageMap), let map = NSKeyedUnarchiver.unarchiveObjectWithFile(filepath) as? [String : UInt] {
                return map
            }
            return [String : UInt]()
        }
    }
    
    /// add an item to the internal map
    private static func addItemToStoredFilesMap(key: String, rootDirectory: NSSearchPathDirectory?) -> Bool {
        guard let filepath = constructFilepathFrom(SwiftFileStorageMapDirectory, key: SwiftFileStorageMap) else {return false}
        var map = storedFilesMap
        map[key] = rootDirectory?.rawValue
        return NSKeyedArchiver.archiveRootObject(map, toFile: filepath)
    }
    
    /// remove an item from the internal map
    private static func removeItemFromStoredFilesMap(key: String) {
        addItemToStoredFilesMap(key, rootDirectory: nil)
    }
}
