//  Copyright 2016-2019 Skyscanner Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
//  with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
//  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
//  for the specific language governing permissions and limitations under the License.

/**
 A beautiful and flexible textfield implementation with support for title label, error message and placeholder.
 */
@IBDesignable
class SkyFloatingLabelTextField: UITextField { // swiftlint:disable:this type_body_length

    // MARK: Animation timing

    /// The value of the title appearing duration
    @objc dynamic var titleFadeInDuration: TimeInterval = 0.2
    /// The value of the title disappearing duration
    @objc dynamic var titleFadeOutDuration: TimeInterval = 0.3

    // MARK: Colors

    private var cachedTextColor: UIColor?

    /// A UIColor value that determines the text color of the editable text
    @IBInspectable override dynamic var textColor: UIColor? {
        set {
            cachedTextColor = newValue
            updateControl(false)
        }
        get {
            return cachedTextColor
        }
    }

    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable dynamic var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            updatePlaceholder()
        }
    }

    /// A UIFont value that determines text color of the placeholder label
    @objc dynamic var placeholderFont: UIFont? {
        didSet {
            updatePlaceholder()
        }
    }

    private func updatePlaceholder() {
        guard let placeholder = placeholder, let font = placeholderFont ?? font else {
            return
        }
        let color = isEnabled ? placeholderColor : disabledColor
        #if swift(>=4.2)
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font
            ]
        )
        #elseif swift(>=4.0)
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font
            ]
        )
        #else
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: font]
        )
        #endif
    }

    /// A UIFont value that determines the text font of the title label
    @objc dynamic var titleFont: UIFont = .systemFont(ofSize: 13) {
        didSet {
            updateTitleLabel()
        }
    }

    /// A UIColor value that determines the text color of the title label when in the normal state
    @IBInspectable dynamic var titleColor: UIColor = .gray {
        didSet {
            updateTitleColor()
        }
    }

    /// A UIColor value that determines the color of the bottom line when in the normal state
    @IBInspectable dynamic var lineColor: UIColor = .lightGray {
        didSet {
            updateLineView()
        }
    }

    /// A UIColor value that determines the color used for the title label and line when the error message is not `nil`
    @IBInspectable dynamic var errorColor: UIColor = .red {
        didSet {
            updateColors()
        }
    }

    /// A UIColor value that determines the color used for the line when error message is not `nil`
    @IBInspectable dynamic var lineErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }

    /// A UIColor value that determines the color used for the text when error message is not `nil`
    @IBInspectable dynamic var textErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }

    /// A UIColor value that determines the color used for the title label when error message is not `nil`
    @IBInspectable dynamic var titleErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }

    /// A UIColor value that determines the color used for the title label and line when text field is disabled
    @IBInspectable dynamic var disabledColor: UIColor = UIColor(white: 0.88, alpha: 1.0) {
        didSet {
            updateControl()
            updatePlaceholder()
        }
    }

    /// A UIColor value that determines the text color of the title label when editing
    @IBInspectable dynamic var selectedTitleColor: UIColor = .blue {
        didSet {
            updateTitleColor()
        }
    }

    /// A UIColor value that determines the color of the line in a selected state
    @IBInspectable dynamic var selectedLineColor: UIColor = .black {
        didSet {
            updateLineView()
        }
    }

    // MARK: Line height

    /// A CGFloat value that determines the height for the bottom line when the control is in the normal state
    @IBInspectable dynamic var lineHeight: CGFloat = 0.5 {
        didSet {
            updateLineView()
            setNeedsDisplay()
        }
    }

    /// A CGFloat value that determines the height for the bottom line when the control is in a selected state
    @IBInspectable dynamic var selectedLineHeight: CGFloat = 1.0 {
        didSet {
            updateLineView()
            setNeedsDisplay()
        }
    }

    // MARK: View components

    /// The internal `UIView` to display the line below the text input.
    var lineView: UIView!

    /// The internal `UILabel` that displays the selected, deselected title or error message based on the current state.
    var titleLabel: UILabel!

    // MARK: Properties

    /**
     The formatter used before displaying content in the title label.
     This can be the `title`, `selectedTitle` or the `errorMessage`.
     The default implementation converts the text to uppercase.
     */
    var titleFormatter: ((String) -> String) = { (text: String) -> String in
        if #available(iOS 9.0, *) {
            return text.localizedUppercase
        } else {
            return text.uppercased()
        }
    }

    /**
     Identifies whether the text object should hide the text being entered.
     */
    override var isSecureTextEntry: Bool {
        set {
            super.isSecureTextEntry = newValue
            fixCaretPosition()
        }
        get {
            return super.isSecureTextEntry
        }
    }

    /// A String value for the error message to display.
    @IBInspectable var errorMessage: String? {
        didSet {
            updateControl(true)
        }
    }

    /// The backing property for the highlighted property
    private var _highlighted: Bool = false

    /**
     A Boolean value that determines whether the receiver is highlighted.
     When changing this value, highlighting will be done with animation
     */
    override var isHighlighted: Bool {
        get {
            return _highlighted
        }
        set {
            _highlighted = newValue
            updateTitleColor()
            updateLineView()
        }
    }

    /// A Boolean value that determines whether the textfield is being edited or is selected.
    var editingOrSelected: Bool {
        return super.isEditing || isSelected
    }

    /// A Boolean value that determines whether the receiver has an error message.
    var hasErrorMessage: Bool {
        return errorMessage != nil && errorMessage != ""
    }

    private var _renderingInInterfaceBuilder: Bool = false

    /// The text content of the textfield
    @IBInspectable override var text: String? {
        didSet {
            updateControl(false)
        }
    }

    /**
     The String to display when the input field is empty.
     The placeholder can also appear in the title label when both `title` `selectedTitle` and are `nil`.
     */
    @IBInspectable override var placeholder: String? {
        didSet {
            setNeedsDisplay()
            updatePlaceholder()
            updateTitleLabel()
        }
    }

    /// The String to display when the textfield is editing and the input is not empty.
    @IBInspectable var selectedTitle: String? {
        didSet {
            updateControl()
        }
    }

    /// The String to display when the textfield is not editing and the input is not empty.
    @IBInspectable var title: String? {
        didSet {
            updateControl()
        }
    }

    // Determines whether the field is selected. When selected, the title floats above the textbox.
    override var isSelected: Bool {
        didSet {
            updateControl(true)
        }
    }

    // MARK: - Initializers

    /**
     Initializes the control
     - parameter frame the frame of the control
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        init_SkyFloatingLabelTextField()
    }

    /**
     Intialzies the control by deserializing it
     - parameter aDecoder the object to deserialize the control from
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_SkyFloatingLabelTextField()
    }

    private final func init_SkyFloatingLabelTextField() {
        borderStyle = .none
        createTitleLabel()
        createLineView()
        updateColors()
        addEditingChangedObserver()
    }

    private func addEditingChangedObserver() {
        self.addTarget(self, action: #selector(SkyFloatingLabelTextField.editingChanged), for: .editingChanged)
    }

    /**
     Invoked when the editing state of the textfield changes. Override to respond to this change.
     */
    @objc
    func editingChanged() {
        updateControl(true)
        updateTitleLabel(true)
    }

    // MARK: create components

    private func createTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = titleFont
        titleLabel.alpha = 0.0
        titleLabel.textColor = titleColor

        addSubview(titleLabel)
        self.titleLabel = titleLabel
    }

    private func createLineView() {

        if lineView == nil {
            let lineView = UIView()
            lineView.isUserInteractionEnabled = false
            self.lineView = lineView
            configureDefaultLineHeight()
        }

        lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(lineView)
    }

    private func configureDefaultLineHeight() {
        let onePixel: CGFloat = 1.0 / UIScreen.main.scale
        lineHeight = 2.0 * onePixel
        selectedLineHeight = 2.0 * self.lineHeight
    }

    // MARK: Responder handling

    /**
     Attempt the control to become the first responder
     - returns: True when successfull becoming the first responder
     */
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateControl(true)
        return result
    }

    /**
     Attempt the control to resign being the first responder
     - returns: True when successfull resigning being the first responder
     */
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateControl(true)
        return result
    }

    /// update colors when is enabled changed
    override var isEnabled: Bool {
        didSet {
            updateControl()
            updatePlaceholder()
        }
    }

    // MARK: - View updates

    internal func updateControl(_ animated: Bool = false) {
        updateColors()
        updateLineView()
        updateTitleLabel(animated)
    }

    private func updateLineView() {
        guard let lineView = lineView else {
            return
        }

        lineView.frame = lineViewRectForBounds(bounds, editing: editingOrSelected)
        updateLineColor()
    }

    // MARK: - Color updates

    /// Update the colors for the control. Override to customize colors.
    func updateColors() {
        updateLineColor()
        updateTitleColor()
        updateTextColor()
    }

    private func updateLineColor() {
        guard let lineView = lineView else {
            return
        }

        if !isEnabled {
            lineView.backgroundColor = disabledColor
        } else if hasErrorMessage {
            lineView.backgroundColor = lineErrorColor ?? errorColor
        } else {
            lineView.backgroundColor = editingOrSelected ? selectedLineColor : lineColor
        }
    }

    private func updateTitleColor() {
        guard let titleLabel = titleLabel else {
            return
        }

        if !isEnabled {
            titleLabel.textColor = disabledColor
        } else if hasErrorMessage {
            titleLabel.textColor = titleErrorColor ?? errorColor
        } else {
            if editingOrSelected || isHighlighted {
                titleLabel.textColor = selectedTitleColor
            } else {
                titleLabel.textColor = titleColor
            }
        }
    }

    private func updateTextColor() {
        if !isEnabled {
            super.textColor = disabledColor
        } else if hasErrorMessage {
            super.textColor = textErrorColor ?? errorColor
        } else {
            super.textColor = cachedTextColor
        }
    }

    // MARK: - Title handling

    private func updateTitleLabel(_ animated: Bool = false) {
        guard let titleLabel = titleLabel else {
            return
        }

        var titleText: String?
        if hasErrorMessage {
            titleText = titleFormatter(errorMessage!)
        } else {
            if editingOrSelected {
                titleText = selectedTitleOrTitlePlaceholder()
                if titleText == nil {
                    titleText = titleOrPlaceholder()
                }
            } else {
                titleText = titleOrPlaceholder()
            }
        }
        titleLabel.text = titleText
        titleLabel.font = titleFont

        updateTitleVisibility(animated)
    }

    private var _titleVisible: Bool = false

    /*
     *   Set this value to make the title visible
     */
    func setTitleVisible(
        _ titleVisible: Bool,
        animated: Bool = false,
        animationCompletion: ((_ completed: Bool) -> Void)? = nil
        ) {
        if _titleVisible == titleVisible {
            return
        }
        _titleVisible = titleVisible
        updateTitleColor()
        updateTitleVisibility(animated, completion: animationCompletion)
    }

    /**
     Returns whether the title is being displayed on the control.
     - returns: True if the title is displayed on the control, false otherwise.
     */
    func isTitleVisible() -> Bool {
        return hasText || hasErrorMessage || _titleVisible
    }

    private func updateTitleVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        let alpha: CGFloat = isTitleVisible() ? 1.0 : 0.0
        let frame: CGRect = titleLabelRectForBounds(bounds, editing: isTitleVisible())
        let updateBlock = { () -> Void in
            self.titleLabel.alpha = alpha
            self.titleLabel.frame = frame
        }
        if animated {
            #if swift(>=4.2)
            let animationOptions: UIView.AnimationOptions = .curveEaseOut
            #else
            let animationOptions: UIViewAnimationOptions = .curveEaseOut
            #endif
            let duration = isTitleVisible() ? titleFadeInDuration : titleFadeOutDuration
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: animationOptions,
                           animations: { () -> Void in updateBlock() },
                           completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }

    // MARK: - UITextField text/placeholder positioning overrides

    /**
     Calculate the rectangle for the textfield when it is not being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        let titleHeight = self.titleHeight()

        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight,
            width: superRect.size.width,
            height: superRect.size.height - titleHeight - selectedLineHeight
        )
        return rect
    }

    /**
     Calculate the rectangle for the textfield when it is being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        let titleHeight = self.titleHeight()

        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight,
            width: superRect.size.width,
            height: superRect.size.height - titleHeight - selectedLineHeight
        )
        return rect
    }

    /**
     Calculate the rectangle for the placeholder
     - parameter bounds: The current bounds of the placeholder
     - returns: The rectangle that the placeholder should render in
     */
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(
            x: 0,
            y: titleHeight(),
            width: bounds.size.width,
            height: bounds.size.height - titleHeight() - selectedLineHeight
        )
        return rect
    }

    // MARK: - Positioning Overrides

    /**
     Calculate the bounds for the title label. Override to create a custom size title field.
     - parameter bounds: The current bounds of the title
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the title label should render in
     */
    func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        if editing {
            return CGRect(x: 0, y: 0, width: bounds.size.width, height: titleHeight())
        }
        return CGRect(x: 0, y: titleHeight(), width: bounds.size.width, height: titleHeight())
    }

    /**
     Calculate the bounds for the bottom line of the control.
     Override to create a custom size bottom line in the textbox.
     - parameter bounds: The current bounds of the line
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the line bar should render in
     */
    func lineViewRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let height = editing ? selectedLineHeight : lineHeight
        return CGRect(x: 0, y: bounds.size.height - height, width: bounds.size.width, height: height)
    }

    /**
     Calculate the height of the title label.
     -returns: the calculated height of the title label. Override to size the title with a different height
     */
    func titleHeight() -> CGFloat {
        if let titleLabel = titleLabel,
            let font = titleLabel.font {
            return font.lineHeight
        }
        return 15.0
    }

    /**
     Calcualte the height of the textfield.
     -returns: the calculated height of the textfield. Override to size the textfield with a different height
     */
    func textHeight() -> CGFloat {
        guard let font = self.font else {
            return 0.0
        }

        return font.lineHeight + 7.0
    }

    // MARK: - Layout

    /// Invoked when the interface builder renders the control
    override func prepareForInterfaceBuilder() {
        if #available(iOS 8.0, *) {
            super.prepareForInterfaceBuilder()
        }

        borderStyle = .none

        isSelected = true
        _renderingInInterfaceBuilder = true
        updateControl(false)
        invalidateIntrinsicContentSize()
    }

    /// Invoked by layoutIfNeeded automatically
    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.frame = titleLabelRectForBounds(bounds, editing: isTitleVisible() || _renderingInInterfaceBuilder)
        lineView.frame = lineViewRectForBounds(bounds, editing: editingOrSelected || _renderingInInterfaceBuilder)
    }

    /**
     Calculate the content size for auto layout

     - returns: the content size to be used for auto layout
     */
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.size.width, height: titleHeight() + textHeight())
    }

    // MARK: - Helpers

    private func titleOrPlaceholder() -> String? {
        guard let title = title ?? placeholder else {
            return nil
        }
        return titleFormatter(title)
    }

    private func selectedTitleOrTitlePlaceholder() -> String? {
        guard let title = selectedTitle ?? title ?? placeholder else {
            return nil
        }
        return titleFormatter(title)
    }
} // swiftlint:disable:this file_length
