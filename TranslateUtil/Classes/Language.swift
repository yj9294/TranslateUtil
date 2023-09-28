//
//  Language.swift
//  TranslateUtil
//
//  Created by yangjian on 2023/9/28.
//

import Foundation
public struct Language: Equatable, Codable {
    public var code: String
    public var country: String = ""
    public var language: String = ""
    
    public func prefixA() -> String {
        if language.count > 0 {
            return String(language.uppercased().prefix(1))
        }
        return ""
    }
    
    public static var Auto: Language {
        return Language(code: "und", country: "", language: "Auto")
    }
    
    public static var Af: Language {
        return Language(code: "af", country: "Afrikaans", language: "Afrikaans")
    }
    
    public static var English: Language {
        return Language(code: "en", country: "United States", language: "English")
    }
    
    public static func ==(lhs: Language, rhs: Language) -> Bool {
        return lhs.code == rhs.code
    }
}
