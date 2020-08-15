//
//  ExpandableTextView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 27/06/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

protocol ExpandableTextViewPlaceholderDelegate: class {
    func expandableTextViewDidShowPlaceholder(_ textView: ExpandableTextView)
    func expandableTextViewDidHidePlaceholder(_ textView: ExpandableTextView)
}

class ExpandableTextView: UITextView {

    // MARK: - Properties

    weak var placeholderDelegate: ExpandableTextViewPlaceholderDelegate?

    var placeholderText: String {
        get {
            return self.placeholder.text
        }
        set {
            self.placeholder.text = newValue
        }
    }

    var textHeightDidChangeAction: Action?
    var textDidEndEditingAction: Action?

    // MARK: - Overrided Properties

    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }

    override var text: String! {
        didSet {
            self.textDidChange()
        }
    }

    override var textContainerInset: UIEdgeInsets {
        didSet {
            self.configurePlaceholder()
        }
    }

    override var textAlignment: NSTextAlignment {
        didSet {
            self.configurePlaceholder()
        }
    }

    // MARK: - Private Properties

    private let placeholder: UITextView = UITextView()
    private var documentHeight: CGFloat = .leastNormalMagnitude

    // MARK: - Life Cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.commonInit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ExpandableTextView.textDidEndEditing),
                                               name: UITextView.textDidEndEditingNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ExpandableTextView.textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: self)
        self.configurePlaceholder()
        self.updatePlaceholderVisibility()
    }

    // MARK: - Override

    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeholder.frame = self.bounds
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if self.isPlaceholderViewAttached {
            self.placeholderDelegate?.expandableTextViewDidShowPlaceholder(self)
        } else {
            self.placeholderDelegate?.expandableTextViewDidHidePlaceholder(self)
        }
    }

    // MARK: - Public

    func setTextPlaceholderColor(_ color: UIColor) {
        self.placeholder.textColor = color
    }

    func setTextPlaceholderFont(_ font: UIFont) {
        self.placeholder.font = font
    }

    func setTextPlaceholderAccessibilityIdentifier(_ accessibilityIdentifier: String) {
        self.placeholder.accessibilityIdentifier = accessibilityIdentifier
    }

    @objc
    func textDidChange() {
        self.updatePlaceholderVisibility()
        self.scrollToCaret()

        let endOfDocumentRect = caretRect(for: endOfDocument)
        let endOfDocumentHeight = endOfDocumentRect.origin.y + endOfDocumentRect.size.height

        let beginOfDocumentRect = caretRect(for: beginningOfDocument)
        let beginOfDocumentHeight = beginOfDocumentRect.origin.y + beginOfDocumentRect.size.height

        let documentHeight = endOfDocumentHeight + beginOfDocumentHeight

        if documentHeight != self.documentHeight || endOfDocumentRect.origin.y <= 0 {
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.textHeightDidChangeAction?.perform()
        }
        self.documentHeight = documentHeight
    }

    @objc
    func textDidEndEditing() {
        textDidEndEditingAction?.perform()
    }

    // MARK: - Private

    private func scrollToCaret() {
        if let textRange = self.selectedTextRange {
            var rect = caretRect(for: textRange.end)
            rect = CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: rect.height + textContainerInset.bottom))

            self.scrollRectToVisible(rect, animated: false)
        }
    }

    private func updatePlaceholderVisibility() {
        if self.text == "" {
            self.showPlaceholder()
        } else {
            self.hidePlaceholder()
        }
    }

    private func showPlaceholder() {
        let wasAttachedBeforeShowing = self.isPlaceholderViewAttached
        self.addSubview(self.placeholder)

        if !wasAttachedBeforeShowing {
            self.placeholderDelegate?.expandableTextViewDidShowPlaceholder(self)
        }
    }

    private func hidePlaceholder() {
        let wasAttachedBeforeHiding = self.isPlaceholderViewAttached
        self.placeholder.removeFromSuperview()

        if wasAttachedBeforeHiding {
            self.placeholderDelegate?.expandableTextViewDidHidePlaceholder(self)
        }
    }

    private var isPlaceholderViewAttached: Bool {
        return self.placeholder.superview != nil
    }

    private func configurePlaceholder() {
        self.placeholder.translatesAutoresizingMaskIntoConstraints = false
        self.placeholder.isEditable = false
        self.placeholder.isSelectable = false
        self.placeholder.isUserInteractionEnabled = false
        self.placeholder.textAlignment = self.textAlignment
        self.placeholder.textContainerInset = self.textContainerInset
        self.placeholder.backgroundColor = UIColor.clear
    }
}
