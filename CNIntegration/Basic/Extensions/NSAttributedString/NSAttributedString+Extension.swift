//
//  NSAttributedString+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 27/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

extension NSAttributedString {

    static func string(with text: String,
                       font: UIFont? = nil,
                       color: UIColor? = nil,
                       underlineStyle: NSUnderlineStyle? = nil,
                       underlineColor: UIColor? = nil) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let font = font {
            attributes[.font] = font
        }
        if let color = color {
            attributes[.foregroundColor] = color
        }
        if let underlineStyle = underlineStyle {
            attributes[.underlineStyle] = underlineStyle.rawValue
        }
        if let underlineColor = underlineColor ?? color {
            attributes[.underlineColor] = underlineColor
        }
        return NSAttributedString(string: text, attributes: attributes)
    }

    func size(withConstrainedWidth width: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.size
    }

    func size(withConstrainedHeight height: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.size
    }
}

extension NSMutableAttributedString {
    func append(attachment: NSTextAttachment) {
        let attributedStringWithAttachments = NSAttributedString(attachment: attachment)
        append(attributedStringWithAttachments)
    }
}

@available(iOS 11.0, *)
extension NSAttributedString {

    func image(insets: UIEdgeInsets, cornerRadius: CGFloat, color: UIColor) -> UIImage? {
        let size = self.size(withConstrainedWidth: .greatestFiniteMagnitude)
        let extendedSize = CGSize(width: size.width + insets.left + insets.right,
                                  height: size.height + insets.top + insets.bottom)
        let rect = CGRect(origin: .zero, size: extendedSize)
        let render = UIGraphicsImageRenderer(size: extendedSize, format: .init(for: .init(displayScale: UIScreen.main.scale)))
        let image = render.image { _ in
            let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            color.setFill()
            rectanglePath.fill()
            draw(in: CGRect(origin: .init(x: insets.left, y: insets.top), size: size))
        }
        return image
    }
}
