import Foundation
import UIKit

extension UIColor {

    public var isBlack: Bool {
        var red, green, blue, alpha: CGFloat
        red = 0; green = 0; blue = 0; alpha = 0;
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return red < 23 && green < 23 && blue < 23
    }

    public var isWhite: Bool {
        var red, green, blue, alpha: CGFloat
        red = 0; green = 0; blue = 0; alpha = 0;
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return red > 232 && green > 232 && blue > 232
    }

    public var isDark: Bool {
        var red, green, blue, alpha: CGFloat
        red = 0; green = 0; blue = 0; alpha = 0;
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // 0.2126, 0.7152 and 0.0722 are the standard luminance values for a UIColor object in the device colorspace.
        return (red*0.2126) + (green*0.7152) + (blue*0.0722) < 127.5
    }

    public var isLight: Bool {
        var red, green, blue, alpha: CGFloat
        red = 0; green = 0; blue = 0; alpha = 0;
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // 0.2126, 0.7152 and 0.0722 are the standard luminance values for a UIColor object in the device colorspace.
        return (red*0.2126) + (green*0.7152) + (blue*0.0722) > 128.0
    }

}

