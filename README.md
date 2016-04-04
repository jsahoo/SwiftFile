# SwiftFile

As we all know, NSUserDefaults isn't meant to store large files or complex pieces of data. This is unfortunate because of how incredibly easy it is to use for persisting data. Instead, we're supposed to use NSFileManager which can be real tedious to work with considering the many lines of boilerplate code required for the simplest of tasks. As if that wasn't enough, the iOS file system is complex with many guidelines for what files should be stored where and which files and folders can and will be included in iTunes/iCloud backups. Thankfully, there's a solution: SwiftFile.

## Overview
SwiftFile makes persistence as easy as NSUserDefaults. SwiftFile provides convenient, appropriately named functions to ensure that files are saved to the correct place within the file system according to Apple’s guidelines and are allowed to be backed up, if specified. SwiftFile utilizes key value pairs to make it incredibly simple to save and retrieve your data; all you need to know is the key. 

## Usage
### Save an Object
```swift
SwiftFile.storeObjectAsAppData("Test1", forKey: "Key1", backupsAllowed: true)
SwiftFile.storeObjectAsUserData("Test2", forKey: "Key2", backupsAllowed: true)
SwiftFile.storeObjectAsCache("Test3", forKey: "Key3")
```
### Retrieve an Object
```swift
SwiftFile.objectForKey("Key1")
SwiftFile.objectForKey("Key2")
SwiftFile.objectForKey("Key3")
```
