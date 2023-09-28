//
//  Language.swift
//  TranslateUtil
//
//  Created by yangjian on 2023/9/28.
//

import Foundation
public struct Language: Equatable, Codable {
    var code: String
    var country: String = ""
    var language: String = ""
    
    func prefixA() -> String {
        if language.count > 0 {
            return String(language.uppercased().prefix(1))
        }
        return ""
    }
    
    static var Auto: Language {
        return Language(code: "und", country: "", language: "Auto")
    }
    
    static var Af: Language {
        return Language(code: "af", country: "Afrikaans", language: "Afrikaans")
    }
    
    static var English: Language {
        return Language(code: "en", country: "United States", language: "English")
    }
    
    public static func ==(lhs: Language, rhs: Language) -> Bool {
        return lhs.code == rhs.code
    }
}
