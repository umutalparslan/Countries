//
//  SavedCountries.swift
//  Countries
//
//  Created by Umut Can Alparslan on 5.01.2022.
//

import Foundation

class SCArray: NSObject {
    public static var name = [String]()
    public static var code = [String]()
    
    public static func userDefaultsSettings() {
        UserDefaults.standard.removeObject(forKey: "savedCountriesName")
        UserDefaults.standard.removeObject(forKey: "savedCountriesCode")
        UserDefaults.standard.set(SCArray.name, forKey: "savedCountriesName")
        UserDefaults.standard.set(SCArray.code, forKey: "savedCountriesCode")
        UserDefaults.standard.synchronize()
    }
}
