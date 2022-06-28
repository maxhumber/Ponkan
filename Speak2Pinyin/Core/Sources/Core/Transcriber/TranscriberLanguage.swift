import Foundation

public enum TranscriberLanguage {
    case english(_ flavor: English = .unitedStates)
    case spanish(_ flavor: Spanish = .spain)
    case italian
    case portuguese(_ flavor: Portugese = .brazil)
    case russian
    case turkish
    case chinese(_ flavor: Chinese = .mandarin)
    
    public static let english = Self.english(.unitedStates)
    public static let mandarin = Self.chinese(.mandarin)
    public static let cantonese = Self.chinese(.cantonese)
    
    public enum English: String {
        case unitedStates = "en-US"
        case canada = "en-CA"
        case greatBritain = "en-GB"
        case india = "en-IN"
    }
    
    public enum Spanish: String {
        case unitedStates = "es-US"
        case mexico = "es-MX"
        case spain = "es-ES"
    }
    
    public enum Portugese: String {
        case brazil = "pt-BR"
    }
    
    public enum Chinese: String {
        case mandarin = "zh-CN"
        case cantonese = "zh-HK"
    }
    
    public var code: String {
        switch self {
        case .english(let flavor):
            return flavor.rawValue
        case .spanish(let flavor):
            return flavor.rawValue
        case .italian:
            return "it-IT"
        case .portuguese(let flavor):
            return flavor.rawValue
        case .russian:
            return "ru-RU"
        case .turkish:
            return "tr-TR"
        case .chinese(let flavor):
            return flavor.rawValue
        }
    }
}
