//
//  TextViewWithPlaceholder.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 03/02/17.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

class TextViewWithPlaceholder: UITextView {

    override var text: String! {
        didSet { updatePlaceholder() }
    }

    override var attributedText: NSAttributedString! {
        didSet { updatePlaceholder() }
    }

    // MARK: Placeholder

    var placeholder: String? {
        didSet { updatePlaceholder() }
    }

    var placeholderColor = UIColor.lightGray {
        didSet { updatePlaceholder() }
    }

    /// This flag determines whether placeholder should be drawn in `drawRect:`.
    private var shouldDrawPlaceholder = true {
        didSet {
            if oldValue != shouldDrawPlaceholder {
                setNeedsDisplay()
            }
        }
    }

    private func updatePlaceholder() {
        shouldDrawPlaceholder = text.isEmpty
    }

    // MARK: Lifecycle

    private func initialize() {
        textContainer.lineFragmentPadding = 0 // removes text inset witin a container
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(TextViewWithPlaceholder.handleTextViewTextDidChangeNotification(_:)),
                                                         name: UITextView.textDidChangeNotification,
                                                         object: self)
        autocorrectionType = .no
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = layoutMargins
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Notification Handling

    @objc
    private dynamic func handleTextViewTextDidChangeNotification(_ notification: Notification) {
        if (notification.object as AnyObject) === self {
            updatePlaceholder()
        }
    }

    // MARK: Drawing

    override func draw(_ rect: CGRect) {

        func drawPlaceholder(_ placeholder: NSString, inRect rect: CGRect) {
            placeholder.draw(in: rect,
                                   withAttributes: [
                                    NSAttributedString.Key.font: font!,
                                    NSAttributedString.Key.foregroundColor: placeholderColor
                ]
            )
        }

        /* Implementation */

        super.draw(rect)

        if let placeholder = placeholder, shouldDrawPlaceholder {
            drawPlaceholder(placeholder as NSString, inRect: bounds.inset(by: layoutMargins))
        }
    }
}
