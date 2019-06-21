//
//  UIColor+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-20.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

extension UIColor {
    
    public var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    public var rgbaInt: (red: Int, green: Int, blue: Int, alpha: Int) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Int((r * 255).rounded()), Int((g * 255).rounded()), Int((b * 255).rounded()), Int((a * 100).rounded()))
    }
    
    public var hsva: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }
    
    public var hsvaInt: (hue: Int, saturation: Int, brightness: Int, alpha: Int) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Int((h * 360).rounded()), Int((s * 100).rounded()), Int((b * 100).rounded()), Int((a * 100).rounded()))
    }
    
    public var grayscale: (white: CGFloat, alpha: CGFloat) {
        var w: CGFloat = 0
        var a: CGFloat = 0
        getWhite(&w, alpha: &a)
        return (w, a)
    }
    
    /**
     As stated in wikipedia, complementary colors are pairs of colors which, when combined, cancel each other out. This means that when combined, they produce a gray-scale color like white or black. When placed next to each other, they create the strongest contrast for those particular two colors. That's why life vests are often orange (0xFFA500), which is direct opposite of navy blue (0x005AFF). Due to this striking color clash, the term opposite colors is often considered more appropriate than "complementary colors".
     
     Complementary colors can create some striking optical effects. The shadow of an object appears to contain some of the complementary color of the object. For example, the shadow of a red apple will appear to contain a little blue-green. This effect is often copied by painters who want to create more luminous and realistic shadows. Also, if you stare at a square of color for a long period of time (thirty seconds to a minute), and then look at a white paper or wall, you will briefly see an afterimage of the square in its complementary color. Placed side by side as tiny dots, in partitive color mixing, complementary colors appear gray.
     
     Finding complementary color is very simple in RGB model. For any given color, for example, red (#FF0000) you need to find the color, which, after being added to red, creates white (0xFFFFFF). Naturally, all you need to do, is subtract red from white and get cyan (0xFFFFFF - 0xFF0000 = 0x00FFFF).
    */
    // See https://graphicdesign.stackexchange.com/questions/1316/what-are-the-true-complementary-colors-and-their-values
    public var complementaryRgb: UIColor {
        let rgba = self.rgba
        return UIColor(red: 1 - rgba.red, green: 1 - rgba.green, blue: 1 - rgba.blue, alpha: rgba.alpha)
    }
    
    public var complementaryHsv: UIColor {
        let hsva = self.hsva
        return UIColor(hue: hsva.hue > 0.5 ? hsva.hue - 0.5 : hsva.hue + 0.5, saturation: hsva.saturation, brightness: hsva.brightness, alpha: hsva.alpha)
    }
    
    /**
     The relative brightness of any point in a colorspace, normalized to 0 for darkest black and 1 for lightest white
     
     - Note: For more information, see the [relative luminance](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef) definition.
    */
    public var relativeLuminance : CGFloat {
        let rgba = self.rgba
        
        let RsRGB = rgba.red
        let GsRGB = rgba.green
        let BsRGB = rgba.blue
        
        let R = RsRGB <= 0.03928 ? RsRGB / 12.92 : pow((RsRGB + 0.055) / 1.055, 2.4)
        let G = GsRGB <= 0.03928 ? RsRGB / 12.92 : pow((RsRGB + 0.055) / 1.055, 2.4)
        let B = BsRGB <= 0.03928 ? RsRGB / 12.92 : pow((RsRGB + 0.055) / 1.055, 2.4)
        
        let L = 0.2126 * R + 0.7152 * G + 0.0722 * B
        
        return L
    }
    
    /**
     The contrast ratio.
     
     - Note: For more information, see the [contrast ratio](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef) definition.
     */
    public static func contrastRatio(_ left: UIColor, _ right: UIColor) -> CGFloat {
        // L1 is the relative luminance of the lighter of the colors
        let L1 = max(left.relativeLuminance, right.relativeLuminance)
        // L2 is the relative luminance of the darker of the colors.
        let L2 = min(left.relativeLuminance, right.relativeLuminance)
        
        let result = (L1 + 0.05) / (L2 + 0.05)
        
        // While contrast([255, 255, 255], [0, 0, 255]) returns 8.592, the same numbers reversed contrast([0, 0, 255], [255, 255, 255]) returns 0.116 – i.e., 1/8.592. To get a contrast ratio between 1 and 21, you will need to divide 1 by the output if the output is < 1
        return result < 1 ? 1 / result : result
    }
    
    /**
     - Note: For more information, see [1.4.3 and 1.4.6](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#visual-audio-contrast).
    */
    public static func isRecommendedContrastRatio(_ left: UIColor, _ right: UIColor) -> Bool {
        return contrastRatio(left, right) >= 4.5
    }
    
    public static func getBestContrastColor(color: UIColor) -> UIColor {
        var maxColor = UIColor()
        var maxRatio : CGFloat = 0
        let testColors : [UIColor] = [
            .black,
            .blue,
            .brown,
            .cyan,
            .darkGray,
            .gray,
            .green,
            .lightGray,
            .magenta,
            .orange,
            .purple,
            .red,
            .white,
            .yellow
        ]
        
        for testColor in testColors {
            let ratio = contrastRatio(color, testColor)
            if ratio > maxRatio {
                maxColor = testColor
                maxRatio = ratio
            }
        }
        return maxColor
    }
}
