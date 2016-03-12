Pod::Spec.new do |s|

    s.name         = "SwiftFile"
    s.platform     = :ios, "9.0"
    s.version      = "1.0"
    s.summary      = "Incredibly simple persistence and file management tool written in Swift."
    s.homepage     = "https://github.com/jsahoo/SwiftFile"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author       = "Jonathan Sahoo"
    s.source       = { :git => "https://github.com/jsahoo/SwiftFile.git", :tag => s.version }
    s.source_files  = "SwiftFile/SwiftFile.swift"
    s.requires_arc = true

end