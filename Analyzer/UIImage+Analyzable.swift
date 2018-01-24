import Foundation
import UIKit

public extension UIImage {

    /// This is a dummy object to hold our shared comparator.
    struct Comparators {
        static var sortedColorComparator: Comparator = { (lhs, rhs) -> ComparisonResult in
            guard let left = lhs as? Color, let right = rhs as? Color else { fatalError() }

            if left.count < right.count {
                return .orderedDescending
            } else if left.count == right.count {
                return .orderedSame
            } else {
                return .orderedAscending
            }
        }
    }

    /// This is a dummy object to hold information on the representation of a color.
    struct Color {
        let color: Double
        let count: Int

        /// Create a Color object
        ///
        /// - Parameters:
        ///   - color: the double value, representing a color
        ///   - count: the count of the color
        init(_ color: Double, _ count: Int) {
            self.color = color
            self.count = count
        }
    }

    enum Downsampling: CGFloat {
        case high = 50 // 50px
        case mid = 100 // 100px
        case low = 250 // 250px
        case none = 0
    }

    // MARK: - Internal

    private func computeEdgeColor(fromImageColors imageColors: NSCountedSet, height: Int) -> Double {
        let threshold = Int(CGFloat(height)*0.01)
        let enumerator = imageColors.objectEnumerator()
        let sortedColors = NSMutableArray(capacity: imageColors.count)
        while let color = enumerator.nextObject() as? Double {
            let colorCount = imageColors.count(for: color)
            if threshold < colorCount {
                sortedColors.add(Color(color, colorCount))
            }
        }
        sortedColors.sort(comparator: Comparators.sortedColorComparator)

        var proposedEdgeColor: Color
        if 0 < sortedColors.count {
            proposedEdgeColor = sortedColors.object(at: 0) as! Color
        } else {
            proposedEdgeColor = Color(0, 1)
        }

        if proposedEdgeColor.color.isBlackOrWhite && 0 < sortedColors.count {
            for i in 1..<sortedColors.count {
                let nextProposedEdgeColor = sortedColors.object(at: i) as! Color
                if Double(nextProposedEdgeColor.count)/Double(proposedEdgeColor.count) > 0.3 {
                    if !nextProposedEdgeColor.color.isBlackOrWhite {
                        proposedEdgeColor = nextProposedEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }

        return proposedEdgeColor.color
    }

    private func computePrimaryColor(fromImageColors imageColors: NSCountedSet, height: Int) -> Double {
        let cgImage = drawInContext().cgImage
        let width: Int = cgImage.width
        let height: Int = cgImage.height

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("Could not get cgImage data.")
        }

        let imageColors = allocateImageColors(forWidth: width, height: height, data: data)
        let existingBackgroundColor = computeEdgeColor(fromImageColors: imageColors, height: height)

        var result: Double = 0
        for color in sortedColors {
            let color = (color as! Color).color

            if color.contrasts(existingBackgroundColor) && color.distinct(existingBackgroundColor) {
                result = color
            }

            break
        }

        return result
    }

    private func computeSecondaryColor(fromImageColors imageColors: NSCountedSet, height: Int) -> Double {
        let cgImage = drawInContext().cgImage
        let width: Int = cgImage.width
        let height: Int = cgImage.height

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("Could not get cgImage data.")
        }

        let imageColors = allocateImageColors(forWidth: width, height: height, data: data)
        let existingBackgroundColor = computeEdgeColor(fromImageColors: imageColors, height: height)
        let existingPrimaryColor = computePrimaryColor(fromImageColors: imageColors, height: height)

        var result: Double = 0
        for color in sortedColors {
            guard let color = (color as? Color)?.color else { continue }

            if color.contrasts(existingBackgroundColor) == false || existingPrimaryColor.distinct(color) == false {
                continue
            }

            result = color

            break
        }

        return result
    }

    private func computeDetailColor(fromImageColors imageColors: NSCountedSet, height: Int) -> Double {
        let cgImage = drawInContext().cgImage
        let width: Int = cgImage.width
        let height: Int = cgImage.height

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("Could not get cgImage data.")
        }

        let imageColors = allocateImageColors(forWidth: width, height: height, data: data)
        let existingBackgroundColor = computeEdgeColor(fromImageColors: imageColors, height: height)
        let existingPrimaryColor = computePrimaryColor(fromImageColors: imageColors, height: height)
        let existingSecondaryColor = computeSecondaryColor(fromImageColors: imageColors, height: height)

        var result: Double = 0
        for color in sortedColors {
            guard let color = (color as? Color)?.color else { continue }

            if color.contrasts(existingBackgroundColor) == false || existingSecondaryColor.distinct(color) == false || existingPrimaryColor.distinct(color) == false {
                continue
            }

            result = color

            break
        }

        return result
    }

    private var sortedColors: NSMutableArray {
        let cgImage = drawInContext().cgImage
        let width: Int = cgImage.width
        let height: Int = cgImage.height

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("Could not get cgImage data.")
        }

        let imageColors = allocateImageColors(forWidth: width, height: height, data: data)
        let enumerator = imageColors.objectEnumerator()
        let sortedColors = NSMutableArray(capacity: imageColors.count)
        let existingBackgroundColor = computeEdgeColor(fromImageColors: imageColors, height: height)
        let findDarkTextColor = existingBackgroundColor.isDarkColor == false

        while var color = enumerator.nextObject() as? Double {
            color = color.withMinimumSaturation(0.15)
            if color.isDarkColor == findDarkTextColor {
                let count = imageColors.count(for: color)
                sortedColors.add(Color(color, count))
            }
        }

        sortedColors.sort(comparator: Comparators.sortedColorComparator)

        return sortedColors
    }

    private func allocateImageColors(forWidth width: Int, height: Int, data: UnsafePointer<UInt8>!) -> NSCountedSet {
        let imageColors = NSCountedSet(capacity: width*height)
        for x in 0..<width {
            for y in 0..<height {
                let pixel: Int = ((width * y) + x) * 4
                if 127 <= data[pixel+3] {
                    imageColors.add((Double(data[pixel+2])*1000000)+(Double(data[pixel+1])*1000)+(Double(data[pixel])))
                }
            }
        }

        return imageColors
    }

    private func resizeTo(_ size: CGSize) -> CGImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        defer {
            UIGraphicsEndImageContext()
        }

        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let result = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = result.cgImage else {
            fatalError("UIGraphicsGetImageFromCurrentImageContext returned nil.")
        }

        return cgImage
    }

    private func drawInContext(withDownsampling downsampling: Downsampling = .low) -> (cgImage: CGImage, width: Int, height: Int) {
        var scaleDownSize: CGSize = size

        if downsampling != .none {
            if size.width < size.height {
                let ratio = size.height/size.width
                scaleDownSize = CGSize(width: downsampling.rawValue/ratio, height: downsampling.rawValue)
            } else {
                let ratio = size.width/size.height
                scaleDownSize = CGSize(width: downsampling.rawValue, height: downsampling.rawValue/ratio)
            }
        }

        let result = resizeTo(scaleDownSize)

        return (
            cgImage: result,
            width: result.width,
            height: result.height
        )
    }

    // MARK: - Public Variables

    var backgroundColor: UIColor {
        let cgImage = drawInContext().cgImage
        let width: Int = cgImage.width
        let height: Int = cgImage.height

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("Could not get cgImage data.")
        }

        let imageColors = allocateImageColors(forWidth: width, height: height, data: data)

        return computeEdgeColor(fromImageColors: imageColors, height: height).uiColor
    }

    var primaryColor: UIColor {
        let cgImage = drawInContext().cgImage
        let width: Int = cgImage.width
        let height: Int = cgImage.height

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("Could not get cgImage data.")
        }

        let imageColors = allocateImageColors(forWidth: width, height: height, data: data)

        return computePrimaryColor(fromImageColors: imageColors, height: height).uiColor
    }

    var secondaryColor: UIColor {
        let cgImage = drawInContext().cgImage
        let width: Int = cgImage.width
        let height: Int = cgImage.height

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("Could not get cgImage data.")
        }

        let imageColors = allocateImageColors(forWidth: width, height: height, data: data)

        return computeSecondaryColor(fromImageColors: imageColors, height: height).uiColor
    }

    var detailColor: UIColor {
        let cgImage = drawInContext().cgImage
        let width: Int = cgImage.width
        let height: Int = cgImage.height

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("Could not get cgImage data.")
        }

        let imageColors = allocateImageColors(forWidth: width, height: height, data: data)

        return computeDetailColor(fromImageColors: imageColors, height: height).uiColor
    }

}

