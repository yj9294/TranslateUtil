//
//  CacheUtil.swift
//  TranslateUtil
//
//  Created by yangjian on 2023/9/28.
//

import UIKit
import MLKitTranslate

public class CacheUtil: NSObject {
    public static let share = CacheUtil()
    public var textSourceLanguage: Language {
        set{
            UserDefaults.standard.setObject(newValue, forKey: .textSourceKey)
        }
        get{
            UserDefaults.standard.getObject(Language.self, forKey: .textSourceKey) ?? .Auto
        }
    }
    public var textTargetLanguage: Language {
        set{
            UserDefaults.standard.setObject(newValue, forKey: .textTargetKey)
        }
        get{
            UserDefaults.standard.getObject(Language.self, forKey: .textTargetKey) ?? .English
        }
    }
    
    public var targetDatasource: [Language] {
        return datasource
    }
    
    public var sourceDatasource: [Language] {
        return [[.Auto], datasource].flatMap({ array in
            return array
        })
    }
    
    public var translateText: String {
        set {
            UserDefaults.standard.setObject(newValue, forKey: .translateText)
        }
        get {
            UserDefaults.standard.getObject(String.self, forKey: .translateText) ?? ""
        }
    }
    
    public var datasource: [Language] {
        if let source = UserDefaults.standard.getObject([Language].self, forKey: .targetSource) {
            return source
        } else {
            let array: [Language] = TranslateLanguage.allLanguages().compactMap {
                let country = Locale.current.localizedString(forRegionCode: $0.rawValue) ?? ""
                let code = $0.rawValue
                let language = Locale.current.localizedString(forLanguageCode: $0.rawValue) ?? ""
                return Language(code: code, country: country, language: language)
            }.sorted { l1, l2 in
                l1.language < l2.language
            }
            UserDefaults.standard.setObject(array, forKey: .targetSource)
            return array
        }
    }
}

extension UserDefaults {
    func setObject<T: Encodable> (_ object: T?, forKey key: String) {
        let encoder =  JSONEncoder()
        guard let object = object else {
            self.removeObject(forKey: key)
            return
        }
        guard let encoded = try? encoder.encode(object) else {
            return
        }
        
        self.setValue(encoded, forKey: key)
    }
    
    func getObject<T: Decodable> (_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        guard let object = try? decoder.decode(type, from: data) else {
            print("Could'n find key")
            return nil
        }
        
        return object
    }
}

extension String {
    static let textSourceKey = "textSourceKey"
    static let textTargetKey = "textTargetKey"
    static let targetSource = "targetSource"
    static let translateText = "translateText"
}
