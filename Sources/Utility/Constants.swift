//
//  Constant.swift
//  TweaKit
//
//  Created by cokile
//
// swiftlint:disable type_name

import UIKit

enum Constants {
    static let idSeparator = "§§"
}

extension Constants {
    enum Color {
        static let hexPrefix = "#"
        
        static var actionBlue: UIColor {
            UIColor(hexString: "3A87FD")!
        }
        
        static var backgroundPrimary: UIColor {
            UIColor(light: UIColor(hexString: "F2F2F7")!, dark: UIColor(hexString: "0F0F0F")!)
        }
        static var backgroundSecondary: UIColor {
            UIColor(light: UIColor(hexString: "#F1F1F1")!, dark: UIColor(hexString: "282828")!)
        }
        static var backgroundElevatedPrimary: UIColor {
            UIColor(light: UIColor(hexString: "F8F8FB")!, dark: UIColor(hexString: "202022")!)
        }
        static var backgroundElevatedSecondary: UIColor {
            UIColor(light: .white, dark: UIColor(hexString: "1A767680")!)
        }
        
        static var labelPrimary: UIColor {
            UIColor(light: UIColor(hexString: "201F42")!, dark: UIColor(hexString: "E1E1EF")!)
        }
        static var labelSecondary: UIColor {
            UIColor(light: UIColor(hexString: "80201F42")!, dark: UIColor(hexString: "80E1E1EF")!)
        }
        
        static var searchBachground: UIColor {
            UIColor(light: UIColor(hexString: "1E767680")!, dark: UIColor(hexString: "3C767680")!)
        }
        static var searchText: UIColor {
            UIColor(light: UIColor(hexString: "3C3C43")!, dark: UIColor(hexString: "EBEBF5")!)
        }
        static var searchPlaceholder: UIColor {
            UIColor(light: UIColor(hexString: "963C3C43")!, dark: UIColor(hexString: "96EBEBF5")!)
        }
        
        static var seperator: UIColor {
            UIColor(light: UIColor(hexString: "80E2E2E3")!, dark: UIColor(hexString: "803C3C3C")!)
        }
        
        static var disclosure: UIColor {
            UIColor(light: UIColor(hexString: "80201F42")!, dark: UIColor(hexString: "80E1E1EF")!)
        }
        
        static var panIndicator: UIColor {
            UIColor(light: UIColor(hexString: "DEDEDE")!, dark: UIColor(hexString: "1A767680")!)
        }
    }
}

extension Constants {
    enum Assets {
        static var naviBack: UIImage {
            UIImage(asset: "tweak_navi_back")!
        }
        static var naviSearch: UIImage {
            UIImage(asset: "tweak_navi_search")!
        }
        static var naviMore: UIImage {
            UIImage(asset: "tweak_navi_more")!
        }
        
        static var importTweaks: UIImage {
            UIImage(asset: "tweak_import")!
        }
        static var exportTweaks: UIImage {
            UIImage(asset: "tweak_export")!
        }
        static var resetTweaks: UIImage {
            UIImage(asset: "tweak_reset")!
        }
        
        static var floatButton: UIImage {
            UIImage(asset: "tweak_float_button")!
        }
        
        static var noTweaks: UIImage {
            UIImage(asset: "tweak_no_tweaks")!
        }
        static var noSearchResults: UIImage {
            UIImage(asset: "tweak_no_search_results")!
        }
        
        static var cross: UIImage {
            UIImage(asset: "tweak_cross")!
        }
        static var tick: UIImage {
            UIImage(asset: "tweak_tick")!
        }
        static var disclosure: UIImage {
            UIImage(asset: "tweak_disclosure")!
        }
        static var substract: UIImage {
            UIImage(asset: "tweak_strider_substract")!
        }
        static var add: UIImage {
            UIImage(asset: "tweak_strider_add")!
        }
        
        static var alphaBackground: UIImage {
            UIImage(asset: "tweak_alpha_background")!
        }
    }
}

extension Constants {
    enum Font {
        static var segmentTitle: UIFont {
            .systemFont(ofSize: 14, weight: .medium)
        }
    }
}

extension Constants {
    enum Date {
        static let iso8601Formatter: ISO8601DateFormatter = {
           let formatter = ISO8601DateFormatter()
            formatter.formatOptions.insert(.withFractionalSeconds)
            return formatter
        }()
    }
}

extension Constants {
    enum Trade {
        static let supportedVersion = 1
    }
}

extension Constants {
    enum UI {
        static var tweakEmptyView: TweakListEmptyView {
            .init(image: Constants.Assets.noTweaks)
        }
        static var tweakEmptyResultView: TweakListEmptyView {
            .init(image: Constants.Assets.noSearchResults)
        }
        
        private static let shapeColors = ["36CFC9", "3DB9FF", "48D14E", "FFCD4D", "FF473C", "FF60BF", "A70AAA", "9C0000", "FF9B64", "278B86", "234DE1", "5956FF"]
        private static let shapeCount = 12
        private static func _shapeColor(at index: Int) -> UIColor {
            UIColor(hexString: shapeColors[abs(index) % shapeCount])!
        }
        private static func _shapeImage(at index: Int) -> UIImage {
            UIImage(asset: "tweak_shape_\(abs(index) % shapeCount)")!
        }
        
        static func shapeColor(of tweak: AnyTweak) -> UIColor {
            _shapeColor(at: tweak.name.djb2hash)
        }
        
        static func shapeImage(of tweak: AnyTweak) -> UIImage {
            _shapeImage(at: tweak.id.djb2hash)
        }
    }
}

extension Constants {
    enum Debug {
        // https://stackoverflow.com/a/56836695/4155933
        static let isDebuggerAttached: Bool = {
            var isDebuggerAttached = false
            
            var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
            var info: kinfo_proc = kinfo_proc()
            var info_size = MemoryLayout<kinfo_proc>.size
            
            let success = name.withUnsafeMutableBytes { (nameBytePtr: UnsafeMutableRawBufferPointer) -> Bool in
                guard let nameBytesBlindMemory = nameBytePtr.bindMemory(to: Int32.self).baseAddress else { return false }
                return -1 != sysctl(nameBytesBlindMemory, 4, &info, &info_size, nil, 0)
            }
            
            if !success {
                isDebuggerAttached = false
            }
            
            if !isDebuggerAttached && (info.kp_proc.p_flag & P_TRACED) != 0 {
                isDebuggerAttached = true
            }
            
            return isDebuggerAttached
        }()
    }
}

extension Constants {
    enum Keys {
        static let searchHistories = "searchHistories"
    }
}
