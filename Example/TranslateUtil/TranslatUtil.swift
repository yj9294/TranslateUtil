//
//  TranslatUtil.swift
//  TranslateUtil_Example
//
//  Created by yangjian on 2023/9/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import MLKitTranslate
import MLKitLanguageID
import MLKitTextRecognition
import MLKitTextRecognitionChinese
import MLKitTextRecognitionJapanese
import MLKitTextRecognitionKorean
import MLKitTextRecognitionDevanagari
import MLKitVision
import WebKit

public var AppEnterbackground = false
class TranslateUtil: NSObject {
    public static let share = TranslateUtil()
    public var duration = 15.0
    public var webTranslate: Bool {
        return isWebTranslate
    }
    private var isWebTranslate = false
    
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    
    var onWebSuccess: ((String)->Void)? = nil
    var onWebError: (()->Void)? = nil
        
    // 识别语言，只是source 为auto的时候去识别
    func requestSourceCode(text: String, completion: @escaping ((String)->Void)) {
        let languageId = LanguageIdentification.languageIdentification()
        languageId.identifyLanguage(for: text) { (languageTag, error) in
            if let _ = error {
                completion("und")
                return
            }
            let sourceCode = languageTag ?? "und"
            completion(sourceCode)
        }
    }
    
    // 下载离线包
    func requesTranslateModel(_ code: String) {
        let lan = TranslateLanguage(rawValue: code)
        let frenchModel = TranslateRemoteModel.translateRemoteModel(language: lan)
        debugPrint("[TR] 判定\(code)语言包是否下载。")
        if ModelManager.modelManager().isModelDownloaded(frenchModel) {
            debugPrint("[TR] 已经下载了\(code)语言包。")
            return
        }
        debugPrint("[TR] 没下载，开始下载\(code)语言包。")
        ModelManager.modelManager().download(
            frenchModel,
            conditions: ModelDownloadConditions(
                allowsCellularAccess: true,
                allowsBackgroundDownloading: true
            )
        )
    }
    
    // 预下载本机语言和英语
    func requestPrefrenceModel() {
        debugPrint("[TR] 预备下载english和本机语言")
        requesTranslateModel("en")
        if let local = Locale.current.languageCode {
            requesTranslateModel(local)
        }
    }
    
    public func translate(text: String, sourceCode: String, targetCode: String, completion: @escaping (Bool,String)->Void) {
        debugPrint("[TR] 开始翻译")
        var progress = 0.0
        var duration = duration
        var isSuccess = false
        var result = "Sorry, try to translate it again."
        // 最长15.4秒后返回结果
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            progress += 0.01 / duration
            if AppEnterbackground {
                timer.invalidate()
                completion(false, "")
                return
            }
            if progress >= 1.0 {
                timer.invalidate()
                completion(isSuccess, result)
            }
        }
        // 转换 code 为 ml 框架
        let sourceLan = TranslateLanguage(rawValue: sourceCode)
        let targetLan = TranslateLanguage(rawValue: targetCode)
        // 配置翻译参数
        let options = TranslatorOptions(sourceLanguage: sourceLan, targetLanguage: targetLan)
        let translator = Translator.translator(options: options)
        // 判定语言包是否下载
        let sourceModel = TranslateRemoteModel.translateRemoteModel(language: sourceLan)
        let targetModel = TranslateRemoteModel.translateRemoteModel(language: targetLan)
        let isSourceDownload = ModelManager.modelManager().isModelDownloaded(sourceModel)
        let isTargetDownload = ModelManager.modelManager().isModelDownloaded(targetModel)
        if isSourceDownload, isTargetDownload {
            debugPrint("[TR] 两个翻译包都已经下载,\(sourceCode), \(targetCode)")
            // 如果都下载了使用 sdk 翻译
            debugPrint("[TR] 开始离线翻译.")
            isWebTranslate = false
            translator.downloadModelIfNeeded { error in
                if AppEnterbackground {
                    isSuccess = false
                    result = ""
                    duration = 0.1
                    return
                }
                
                guard error == nil else {
                    print("[TR] Failed to ensure model downloaded with error \(error!)")
                    isSuccess = false
                    result = "Sorry, try to translate it again."
                    duration = 1.0
                    return
                }
                translator.translate(text, completion: { target, errorif in
                    if AppEnterbackground {
                        isSuccess = false
                        result = ""
                        duration = 0.1
                        return
                    }
                    
                    guard error == nil  else {
                        debugPrint("[TR] Translate with error \(error!)")
                        isSuccess = false
                        result = "Sorry, try to translate it again."
                        duration = 1.0
                        return
                    }
                    if let target = target {
                        debugPrint("[TR] 翻译完成.\(target)")
                        isSuccess = true
                        result = target
                        duration = 1.0
                    } else {
                        debugPrint("[TR] Translate text is nil")
                        isSuccess = false
                        result = "Sorry, try to translate it again."
                        duration = 1.0
                    }
                })
            }
        } else {
            if !NetworkUtil.shared.isConnected {
                isSuccess = false
                result = "No network."
                duration = 1.0
                return
            }
            // 没完全下载，则开启下载语言包，并使用网页翻译
            debugPrint("[TR] 两个翻译包没完全下载,\(sourceCode), \(targetCode)")
            isWebTranslate = true
            requesTranslateModel(sourceCode)
            requesTranslateModel(targetCode)
            var source = sourceCode
            var target = targetCode
            if sourceCode == "zh" {
                source = "zh-Hans"
            }
            if targetCode == "zh" {
                target = "zh-Hans"
            }
            debugPrint("[TR] 开始网页翻译.")
            
            let urlStr = "https://www.bing.com/translator/?ref=TThis&text=\(text)&from=\(source)&to=\(target)"
            if let urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlStr) {
                webView.load(URLRequest(url: url))
            }
            
            self.onWebSuccess = { re in
                if AppEnterbackground {
                    isSuccess = false
                    result = ""
                    duration = 0.1
                    return
                }
                isSuccess = true
                result = re
                duration = 1.0
            }
            self.onWebError = {
                if AppEnterbackground {
                    isSuccess = false
                    result = ""
                    duration = 0.1
                    return
                }
                isSuccess = false
                result = "Sorry, try to translate it again."
                duration = 1.0
            }
        }
    }
}

extension TranslateUtil: WKUIDelegate, WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("[TR] web加载开始")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("[TR] web加载失败.\(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("[TR] web加载完成")
        let js = "document.getElementById('tta_output_ta').value"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            webView.evaluateJavaScript(js) { result, error in
                print("[TR] result: \(String(describing: result))\n error: \(String(describing: error))")
                guard error == nil else {
                    debugPrint("[TR] 注入js失败, \(error!.localizedDescription)")
                    self.onWebError?()
                    return
                }
                
                if let resultStr = result as? String {
                    if resultStr != "" {
                        debugPrint("[TR] 注入js成功获取\(resultStr)")
                        if resultStr != " ..." {
                            self.onWebSuccess?(resultStr)
                        } else {
                            self.onWebError?()
                        }
                    }
                }
            }
        }
    }
}

extension TranslateUtil {
    public func ocrTranslate(source: String, image: UIImage, direction: UIImage.Orientation, completion: @escaping (Bool, String) -> Void) {
        
        var op: CommonTextRecognizerOptions
        let lan = TranslateLanguage(rawValue: source)
        switch lan{
        case .chinese:
            op = ChineseTextRecognizerOptions()
        case .japanese:
            op = JapaneseTextRecognizerOptions()
        case .korean:
            op = KoreanTextRecognizerOptions()
        default:
            op = TextRecognizerOptions()
        }
        debugPrint("[TR] 开始图片识别翻译")
        var progress = 0.0
        var duration = duration
        var isSuccess = false
        var result = "Sorry, try to translate it again."
        // 最长15.4秒后返回结果
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            progress += 0.01 / duration
            if progress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    completion(isSuccess, result)
                }
            }
            
            if AppEnterbackground {
                timer.invalidate()
                completion(false, "")
            }
        }
        
        let textRecognizer = TextRecognizer.textRecognizer(options: op)
        let visionImage = VisionImage(image: image)
        visionImage.orientation = direction
        textRecognizer.process(visionImage) { re, error in
            if AppEnterbackground {
                isSuccess = false
                result = ""
                duration = 0.1
                return
            }
            guard error == nil, let re = re else {
                debugPrint("[TR] 图片识别错误.")
                isSuccess = false
                result = "Sorry, try to translate it again."
                duration = 1.0
                return
            }
            let text = re.text
            if re.text.count == 0 {
                isSuccess = false
                result = "Sorry, try to translate it again."
                duration = 1.0
                return
            }
            debugPrint("[TR] 图片识别结果:\(text)")
            isSuccess = true
            result = text
            duration = 1.0
        }
    }
}

