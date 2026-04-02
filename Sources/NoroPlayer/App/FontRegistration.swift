import CoreText
import Foundation

public func registerCustomFont() {
    guard let url = Bundle.module.url(forResource: "CozetteVector", withExtension: "ttf") else {
        print("[Font] CozetteVector.ttf not found in bundle")
        return
    }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
}
