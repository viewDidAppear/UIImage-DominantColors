import Foundation
import UIKit

public extension Double {
    private var red: Double {
        return fmod(floor(self/1000000),1000000)
    }

    private var green: Double {
        return fmod(floor(self/1000),1000)
    }

    private var blue: Double {
        return fmod(self,1000)
    }

    public var isDarkColor: Bool {
        return (red*0.2126) + (green*0.7152) + (blue*0.0722) < 127.5
    }

    public var isLightColor: Bool {
        return (red*0.2126) + (green*0.7152) + (blue*0.0722) > 128.0
    }

    public var isBlackOrWhite: Bool {
        return (red > 232 && green > 232 && blue > 232) || (red < 23 && green < 23 && blue < 23)
    }

    public func distinct(_ other: Double) -> Bool {
        let otherRed = other.red
        let otherGreen = other.green
        let otherBlue = other.blue

        return (fabs(red-otherRed) > 63.75 || fabs(green-otherGreen) > 63.75 || fabs(blue-otherBlue) > 63.75)
            && !(fabs(red-green) < 7.65 && fabs(red-blue) < 7.65 && fabs(otherRed-otherGreen) < 7.65 && fabs(otherRed-otherBlue) < 7.65)
    }

    /// Get color for a given minimum saturation value
    ///
    /// Reference: https://en.wikipedia.org/wiki/HSL_and_HSV
    ///
    /// - Parameter saturation: the absolute minimum saturation value to look for.
    /// - Returns: a double representation of a color in "RGB" with given minimum saturation
    public func withMinimumSaturation(_ saturation: Double) -> Double {

        // RGB to HSV
        var hue, sat, val: Double
        let maximum = fmax(red,fmax(green, blue))
        var chroma = maximum-fmin(red,fmin(green, blue))

        val = maximum
        sat = val == 0 ? 0:chroma/val

        if saturation <= sat {
            return self
        }

        if chroma == 0 {
            hue = 0
        } else if red == maximum {
            hue = fmod((green-blue)/chroma, 6)
        } else if green == maximum {
            hue = 2+((blue-red)/chroma)
        } else {
            hue = 4+((red-green)/chroma)
        }

        if hue < 0 {
            hue += 6
        }

        // HSV to RGB

        chroma = val*saturation
        let X = chroma*(1-fabs(fmod(hue,2)-1))
        var R, G, B: Double

        switch hue {
        case 0...1:
            R = chroma
            G = X
            B = 0
        case 1...2:
            R = X
            G = chroma
            B = 0
        case 2...3:
            R = 0
            G = chroma
            B = X
        case 3...4:
            R = 0
            G = X
            B = chroma
        case 4...5:
            R = X
            G = 0
            B = chroma
        case 5..<6:
            R = chroma
            G = 0
            B = X
        default:
            R = 0
            G = 0
            B = 0
        }

        let minimum = val-chroma

        return (floor((R + minimum)*255)*1000000)+(floor((G + minimum)*255)*1000)+floor((B + minimum)*255)
    }

    public func contrasts(_ color: Double) -> Bool {
        let backgroundLum = (0.2126*red)+(0.7152*green)+(0.0722*blue)+12.75
        let foregroundLum = (0.2126*color.red)+(0.7152*color.green)+(0.0722*color.blue)+12.75

        if backgroundLum > foregroundLum {
            return 1.6 < backgroundLum/foregroundLum
        } else {
            return 1.6 < foregroundLum/backgroundLum
        }
    }

    public var uiColor: UIColor {
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }

}

