//
//  ViewController.swift
//  SwiftFile
//
//  Created by Jonathan Sahoo on 3/11/16.
//  Copyright © 2016 Jonathan Sahoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Storing Data")
        print(SwiftFile.storeObjectAsAppData("Test1", forKey: "Key1", backupsAllowed: true))
        print(SwiftFile.storeObjectAsUserData("Test2", forKey: "Key2", backupsAllowed: true))
        print(SwiftFile.storeObjectAsCache("Test3", forKey: "Key3"))
        
        print("\nRetrieving Data")
        print(SwiftFile.objectForKey("Key1"))
        print(SwiftFile.objectForKey("Key2"))
        print(SwiftFile.objectForKey("Key3"))
        
        print("\nRemoving Data")
        print(SwiftFile.removeObjectForKey("Key3"))
        
        print("\nStore With Same Key, Different Data Type")
        print(SwiftFile.storeObjectAsAppData("Test4", forKey: "Key2", backupsAllowed: false))
        
        print("\nRetrieving Data")
        print(SwiftFile.objectForKey("Key1"))
        print(SwiftFile.objectForKey("Key2"))
        print(SwiftFile.objectForKey("Key3"))
        
        print("\nAll Keys")
        print(SwiftFile.keys)
        
        print("\nBackups Allowed")
        print(SwiftFile.backupsAllowedForObjectWithKey("Key1"))
        print(SwiftFile.backupsAllowedForObjectWithKey("Key2"))
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

