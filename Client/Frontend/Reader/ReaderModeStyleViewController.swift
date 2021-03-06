/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit
import Shared

private struct ReaderModeStyleViewControllerUX {
    static let RowHeight = 50

    static let Width = 270
    static let Height = 4 * RowHeight

    static let FontTypeRowBackground = UIColor(rgb: 0xfbfbfb)

    static let FontTypeTitleSelectedColor = UIColor(rgb: 0x333333)
    static let FontTypeTitleNormalColor = UIColor.lightGray // TODO THis needs to be 44% of 0x333333

    static let FontSizeRowBackground = UIColor(rgb: 0xf4f4f4)
    static let FontSizeLabelColor = UIColor(rgb: 0x333333)
    static let FontSizeButtonTextColorEnabled = UIColor(rgb: 0x333333)
    static let FontSizeButtonTextColorDisabled = UIColor.lightGray // TODO THis needs to be 44% of 0x333333

    static let ThemeRowBackgroundColor = UIColor.white
    static let ThemeTitleColorLight = UIColor(rgb: 0x333333)
    static let ThemeTitleColorDark = UIColor.white
    static let ThemeTitleColorSepia = UIColor(rgb: 0x333333)
    static let ThemeBackgroundColorLight = UIColor.white
    static let ThemeBackgroundColorDark = UIColor(rgb: 0x333333)
    static let ThemeBackgroundColorSepia = UIColor(rgb: 0xF0E6DC)

    static let BrightnessRowBackground = UIColor(rgb: 0xf4f4f4)
    static let BrightnessSliderTintColor = UIColor(rgb: 0xe66000)
    static let BrightnessSliderWidth = 140
    static let BrightnessIconOffset = 10
}

// MARK: -

protocol ReaderModeStyleViewControllerDelegate {
    func readerModeStyleViewController(_ readerModeStyleViewController: ReaderModeStyleViewController, didConfigureStyle style: ReaderModeStyle)
}

// MARK: -

class ReaderModeStyleViewController: UIViewController {
    var delegate: ReaderModeStyleViewControllerDelegate?
    var readerModeStyle: ReaderModeStyle = DefaultReaderModeStyle

    fileprivate var fontTypeButtons: [FontTypeButton]!
    fileprivate var fontSizeLabel: FontSizeLabel!
    fileprivate var fontSizeButtons: [FontSizeButton]!
    fileprivate var themeButtons: [ThemeButton]!

    override func viewDidLoad() {
        // Our preferred content size has a fixed width and height based on the rows + padding

        preferredContentSize = CGSize(width: ReaderModeStyleViewControllerUX.Width, height: ReaderModeStyleViewControllerUX.Height)

        popoverPresentationController?.backgroundColor = ReaderModeStyleViewControllerUX.FontTypeRowBackground

        // Font type row

        let fontTypeRow = UIView()
        view.addSubview(fontTypeRow)
        fontTypeRow.backgroundColor = ReaderModeStyleViewControllerUX.FontTypeRowBackground

        fontTypeRow.snp.makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.right.equalTo(self.view)
            make.height.equalTo(ReaderModeStyleViewControllerUX.RowHeight)
        }

        fontTypeButtons = [
            FontTypeButton(fontType: ReaderModeFontType.SansSerif),
            FontTypeButton(fontType: ReaderModeFontType.Serif)
        ]

        setupButtons(fontTypeButtons, inRow: fontTypeRow, action: #selector(ReaderModeStyleViewController.SELchangeFontType(_:)))

        // Font size row

        let fontSizeRow = UIView()
        view.addSubview(fontSizeRow)
        fontSizeRow.backgroundColor = ReaderModeStyleViewControllerUX.FontSizeRowBackground

        fontSizeRow.snp.makeConstraints { (make) -> () in
            make.top.equalTo(fontTypeRow.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(ReaderModeStyleViewControllerUX.RowHeight)
        }

        fontSizeLabel = FontSizeLabel()
        fontSizeRow.addSubview(fontSizeLabel)

        fontSizeLabel.snp.makeConstraints { (make) -> () in
            make.center.equalTo(fontSizeRow)
            return
        }

        fontSizeButtons = [
            FontSizeButton(fontSizeAction: FontSizeAction.smaller),
            FontSizeButton(fontSizeAction: FontSizeAction.bigger)
        ]

        setupButtons(fontSizeButtons, inRow: fontSizeRow, action: #selector(ReaderModeStyleViewController.SELchangeFontSize(_:)))

        // Theme row

        let themeRow = UIView()
        view.addSubview(themeRow)

        themeRow.snp.makeConstraints { (make) -> () in
            make.top.equalTo(fontSizeRow.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(ReaderModeStyleViewControllerUX.RowHeight)
        }

        themeButtons = [
            ThemeButton(theme: ReaderModeTheme.Light),
            ThemeButton(theme: ReaderModeTheme.Dark),
            ThemeButton(theme: ReaderModeTheme.Sepia)
        ]

        setupButtons(themeButtons, inRow: themeRow, action: #selector(ReaderModeStyleViewController.SELchangeTheme(_:)))

        // Brightness row

        let brightnessRow = UIView()
        view.addSubview(brightnessRow)
        brightnessRow.backgroundColor = ReaderModeStyleViewControllerUX.BrightnessRowBackground

        brightnessRow.snp.makeConstraints { (make) -> () in
            make.top.equalTo(themeRow.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(ReaderModeStyleViewControllerUX.RowHeight)
        }

        let slider = UISlider()
        brightnessRow.addSubview(slider)
        slider.accessibilityLabel = Strings.Brightness
        slider.tintColor = ReaderModeStyleViewControllerUX.BrightnessSliderTintColor
        slider.addTarget(self, action: #selector(ReaderModeStyleViewController.SELchangeBrightness(_:)), for: UIControlEvents.valueChanged)

        slider.snp.makeConstraints { make in
            make.center.equalTo(brightnessRow.center)
            make.width.equalTo(ReaderModeStyleViewControllerUX.BrightnessSliderWidth)
        }

        let brightnessMinImageView = UIImageView(image: UIImage(named: "brightnessMin"))
        brightnessRow.addSubview(brightnessMinImageView)

        brightnessMinImageView.snp.makeConstraints { (make) -> () in
            make.centerY.equalTo(slider)
            make.right.equalTo(slider.snp.left).offset(-ReaderModeStyleViewControllerUX.BrightnessIconOffset)
        }

        let brightnessMaxImageView = UIImageView(image: UIImage(named: "brightnessMax"))
        brightnessRow.addSubview(brightnessMaxImageView)

        brightnessMaxImageView.snp.makeConstraints { (make) -> () in
            make.centerY.equalTo(slider)
            make.left.equalTo(slider.snp.right).offset(ReaderModeStyleViewControllerUX.BrightnessIconOffset)
        }

        selectFontType(readerModeStyle.fontType)
        updateFontSizeButtons()
        selectTheme(readerModeStyle.theme)
        slider.value = Float(UIScreen.main.brightness)
    }

    /// Setup constraints for a row of buttons. Left to right. They are all given the same width.
    fileprivate func setupButtons(_ buttons: [UIButton], inRow row: UIView, action: Selector) {
        for (idx, button) in buttons.enumerated() {
            row.addSubview(button)
            button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
            button.snp.makeConstraints { make in
                make.top.equalTo(row.snp.top)
                if idx == 0 {
                    make.left.equalTo(row.snp.left)
                } else {
                    make.left.equalTo(buttons[idx - 1].snp.right)
                }
                make.bottom.equalTo(row.snp.bottom)
                make.width.equalTo(self.preferredContentSize.width / CGFloat(buttons.count))
            }
        }
    }

    @objc func SELchangeFontType(_ button: FontTypeButton) {
        selectFontType(button.fontType)
        delegate?.readerModeStyleViewController(self, didConfigureStyle: readerModeStyle)
    }

    fileprivate func selectFontType(_ fontType: ReaderModeFontType) {
        readerModeStyle.fontType = fontType
        for button in fontTypeButtons {
            button.isSelected = (button.fontType == fontType)
        }
        for button in themeButtons {
            button.fontType = fontType
        }
        fontSizeLabel.fontType = fontType
    }

    @objc func SELchangeFontSize(_ button: FontSizeButton) {
        switch button.fontSizeAction {
        case .smaller:
            readerModeStyle.fontSize = readerModeStyle.fontSize.smaller()
        case .bigger:
            readerModeStyle.fontSize = readerModeStyle.fontSize.bigger()
        }
        updateFontSizeButtons()
        delegate?.readerModeStyleViewController(self, didConfigureStyle: readerModeStyle)
    }

    fileprivate func updateFontSizeButtons() {
        for button in fontSizeButtons {
            switch button.fontSizeAction {
            case .bigger:
                button.isEnabled = !readerModeStyle.fontSize.isLargest()
                break
            case .smaller:
                button.isEnabled = !readerModeStyle.fontSize.isSmallest()
                break
            }
        }
    }

    @objc func SELchangeTheme(_ button: ThemeButton) {
        selectTheme(button.theme)
        delegate?.readerModeStyleViewController(self, didConfigureStyle: readerModeStyle)
    }

    fileprivate func selectTheme(_ theme: ReaderModeTheme) {
        readerModeStyle.theme = theme
    }

    @objc func SELchangeBrightness(_ slider: UISlider) {
        UIScreen.main.brightness = CGFloat(slider.value)
    }
}

// MARK: -

class FontTypeButton: UIButton {
    var fontType: ReaderModeFontType = .SansSerif

    convenience init(fontType: ReaderModeFontType) {
        self.init(frame: CGRect.zero)
        self.fontType = fontType
        setTitleColor(ReaderModeStyleViewControllerUX.FontTypeTitleSelectedColor, for: UIControlState.selected)
        setTitleColor(ReaderModeStyleViewControllerUX.FontTypeTitleNormalColor, for: .normal)
        backgroundColor = ReaderModeStyleViewControllerUX.FontTypeRowBackground
        accessibilityHint = Strings.Changes_font_type
        switch fontType {
        case .SansSerif:
            setTitle(Strings.SansSerif, for: UIControlState.normal)
            let f = UIFont(name: "FiraSans-Book", size: DynamicFontHelper.defaultHelper.ReaderStandardFontSize)
            titleLabel?.font = f
        case .Serif:
            setTitle(Strings.Serif, for: UIControlState.normal)
            let f = UIFont(name: "Charis SIL", size: DynamicFontHelper.defaultHelper.ReaderStandardFontSize)
            titleLabel?.font = f
        }
    }
}

// MARK: -

enum FontSizeAction {
    case smaller
    case bigger
}

class FontSizeButton: UIButton {
    var fontSizeAction: FontSizeAction = .bigger

    convenience init(fontSizeAction: FontSizeAction) {
        self.init(frame: CGRect.zero)
        self.fontSizeAction = fontSizeAction

        setTitleColor(ReaderModeStyleViewControllerUX.FontSizeButtonTextColorEnabled, for: UIControlState.normal)
        setTitleColor(ReaderModeStyleViewControllerUX.FontSizeButtonTextColorDisabled, for: UIControlState.disabled)

        switch fontSizeAction {
        case .smaller:
            let smallerFontLabel = Strings.Minus
            let smallerFontAccessibilityLabel = Strings.Decrease_text_size
            setTitle(smallerFontLabel, for: .normal)
            accessibilityLabel = smallerFontAccessibilityLabel
        case .bigger:
            let largerFontLabel = Strings.Plus
            let largerFontAccessibilityLabel = Strings.Increase_text_size
            setTitle(largerFontLabel, for: .normal)
            accessibilityLabel = largerFontAccessibilityLabel
        }

        // TODO Does this need to change with the selected font type? Not sure if makes sense for just +/-
        titleLabel?.font = UIFont(name: "FiraSans-Light", size: DynamicFontHelper.defaultHelper.ReaderBigFontSize)
    }
}

// MARK: -

class FontSizeLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let fontSizeLabel = Strings.FontSizeAa
        text = fontSizeLabel
        isAccessibilityElement = false
    }

    required init?(coder aDecoder: NSCoder) {
        // TODO
        fatalError("init(coder:) has not been implemented")
    }

    var fontType: ReaderModeFontType = .SansSerif {
        didSet {
            switch fontType {
            case .SansSerif:
                font = UIFont(name: "FiraSans-Book", size: DynamicFontHelper.defaultHelper.ReaderBigFontSize)
            case .Serif:
                font = UIFont(name: "Charis SIL", size: DynamicFontHelper.defaultHelper.ReaderBigFontSize)
            }
        }
    }
}

// MARK: -

class ThemeButton: UIButton {
    var theme: ReaderModeTheme!

    convenience init(theme: ReaderModeTheme) {
        self.init(frame: CGRect.zero)
        self.theme = theme

        setTitle(theme.rawValue, for: .normal)

        accessibilityHint = Strings.Changes_color_theme
        
        switch theme {
        case .Light:
            setTitle(Strings.Light, for: .normal)
            setTitleColor(ReaderModeStyleViewControllerUX.ThemeTitleColorLight, for: UIControlState.normal)
            backgroundColor = ReaderModeStyleViewControllerUX.ThemeBackgroundColorLight
        case .Dark:
            setTitle(Strings.Dark, for: .normal)
            setTitleColor(ReaderModeStyleViewControllerUX.ThemeTitleColorDark, for: UIControlState.normal)
            backgroundColor = ReaderModeStyleViewControllerUX.ThemeBackgroundColorDark
        case .Sepia:
            setTitle(Strings.Sepia, for: .normal)
            setTitleColor(ReaderModeStyleViewControllerUX.ThemeTitleColorSepia, for: UIControlState.normal)
            backgroundColor = ReaderModeStyleViewControllerUX.ThemeBackgroundColorSepia
        }
    }

    var fontType: ReaderModeFontType = .SansSerif {
        didSet {
            switch fontType {
            case .SansSerif:
                titleLabel?.font = UIFont(name: "FiraSans-Book", size: DynamicFontHelper.defaultHelper.ReaderStandardFontSize)
            case .Serif:
                titleLabel?.font = UIFont(name: "Charis SIL", size: DynamicFontHelper.defaultHelper.ReaderStandardFontSize)
            }
        }
    }
}
