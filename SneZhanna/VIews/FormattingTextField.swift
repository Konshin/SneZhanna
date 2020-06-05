//
//  FormattingTextField.swift
//  SneZhanna
//
//  Created by Aleksei Konshin on 05.06.2020.
//  Copyright © 2020 Aleksei Konshin. All rights reserved.
//

import SwiftUI

struct FormattingTextField: UIViewRepresentable {
    
    typealias Validator = (NSNumber) -> NSNumber
    
    @Binding var text: String
    let formatter: NumberFormatter
    let validator: Validator?
    var keyboardType: UIKeyboardType = .decimalPad
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<FormattingTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange), for: .editingChanged)
        return textField
    }

    func makeCoordinator() -> FormattingTextField.Coordinator {
        return Coordinator(text: $text, formatter: formatter, validator: validator)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<FormattingTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}

extension FormattingTextField {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        let formatter: NumberFormatter
        let validator: Validator?
        var didBecomeFirstResponder = false
        
        /// Valid digits symbols
        private let digitsSet = CharacterSet.decimalDigits
        /// Valid symbols
        private let allowedSet = CharacterSet(charactersIn: (Locale.current.decimalSeparator ?? ",")).union(.decimalDigits)
        
        init(text: Binding<String>, formatter: NumberFormatter, validator: Validator?) {
            _text = text
            self.validator = validator
            self.formatter = formatter
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.selectAll(nil)
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let originalText = textField.text ?? ""
            let info = replaceTextInfo(original: originalText,
                                       range: range,
                                       replacingString: string)
            textField.applyReplacing(info)
            let isTryToDeleteFirstSymbol = originalText == info.text && string.isEmpty
            if isTryToDeleteFirstSymbol {
                textField.selectAll(nil)
            }
            
            return false
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // MARK: - private
        
        private func updateCoursorPosition(_ textField: UITextField) {
            let position = cursorBeginPosition(for: textField.text ?? "")
            textField.setCursorPosition(at: position)
        }
        
        private func digits(from number: String) -> String {
            return number.filter { $0.unicodeScalars.contains(where: digitsSet.contains) }
        }
        
        /// Formatting a number with formatter
        ///
        /// - Parameter stringNumber: Original number
        /// - Returns: Formatted number
        private func formattedNumber(from stringNumber: String) -> String {
            let number = self.number(from: stringNumber)
            return formatter.string(from: number) ?? ""
        }
        
        private func cursorBeginPosition(for text: String) -> Int {
            var position = 0
            var foundDigit = false
            for char in text {
                var isDigit: Bool {
                    return char.unicodeScalars.contains(where: digitsSet.contains)
                }
                var isGroupingSeparator: Bool {
                    return String(char) == formatter.groupingSeparator
                }
                var isSkippableChar: Bool {
                    return isDigit || isGroupingSeparator
                }
                if foundDigit {
                    if !isSkippableChar {
                        return position
                    }
                } else {
                    if !foundDigit, isSkippableChar {
                        foundDigit = true
                    }
                }
                position += 1
            }
            
            return position
        }
        
        private func cursorMinPosition(for text: String) -> Int {
            var position = 0
            var foundDigit = false
            for char in text {
                var isDigit: Bool {
                    return char.unicodeScalars.contains(where: digitsSet.contains)
                }
                if foundDigit {
                    if !isDigit {
                        return position
                    }
                } else {
                    if !foundDigit, isDigit {
                        foundDigit = true
                    }
                }
                position += 1
            }
            
            return position
        }
        
        private func cursorMaxPosition(for text: String) -> Int {
            var position = text.count
            while position > 0 {
                let char = text[text.index(text.startIndex, offsetBy: position - 1)]
                var isDigit: Bool {
                    return char.unicodeScalars.contains(where: digitsSet.contains)
                }
                if isDigit {
                    return position
                } else {
                    position -= 1
                }
            }
            
            return position
        }
        
        /// Parse number from string
        /// - Parameter string: Original number string
        private func number(from string: String) -> NSNumber {
            var allowed = self.cleanNumber(number: string)
            let decimalSymbol = "."
            if allowed.contains(",") {
                allowed = allowed.replacingOccurrences(of: ",", with: decimalSymbol)
            }
            
            var separatedByDecimalSymbol = allowed.components(separatedBy: decimalSymbol)
            if separatedByDecimalSymbol.count > 2 {
                // Remove dupplicates
                let firstPart = separatedByDecimalSymbol.removeFirst()
                let secondPart = separatedByDecimalSymbol.joined()
                allowed = firstPart + decimalSymbol + secondPart
            }

            let number = NSNumber(value: Double(allowed) ?? 0)
            if let validator = validator {
                return validator(number)
            }
            
            return number
        }
        
        /// Removes any symbols excluding allowed
        ///
        /// - Parameter number: Any number string
        /// - Returns: String including only valid for number symbols
        private func cleanNumber(number: String) -> String {
            return number.filter { $0.unicodeScalars.contains(where: allowedSet.contains) }
        }
        
        private func replaceTextInfo(original: String, range: NSRange, replacingString: String) -> TextInputReplacingInfo {
            if replacingString.isEmpty {
                // Erasing
                let originalString = original as NSString
                let cuttedSubstrings = originalString.substring(with: range)
                let cuttedDigits = digits(from: cuttedSubstrings)
                let modifiedString: String
                // Some extra offset for cursor
                var extraLocationOffset = 0
                
                if cuttedDigits.isEmpty {
                    // No one digit was erased - search for the nearest
                    var prefix = originalString.substring(to: range.upperBound)
                    var suffix = originalString.substring(from: range.upperBound)
                    while !prefix.isEmpty {
                        let removedCharacter = prefix.removeLast()
                        if removedCharacter == formatter.decimalSeparator?.first {
                            suffix.insert(removedCharacter, at: suffix.startIndex)
                            // We moved decimal separator - we need to make offset for the coursor
                            extraLocationOffset -= 1
                            continue
                        }
                        if removedCharacter.unicodeScalars.contains(where: digitsSet.contains) {
                            break
                        }
                    }
                    modifiedString = prefix + suffix
                } else {
                    // Some digit was erased - just replace the range in the string
                    modifiedString = (original as NSString).replacingCharacters(in: range, with: replacingString)
                }
                let text: String = formattedNumber(from: modifiedString)
                let lengthDiff = original.count - text.count
                // The new location is the old plus diff
                let location = range.location - max(0, lengthDiff - 1) + extraLocationOffset
                let limitedLocation = max(cursorMinPosition(for: text), location)
                return TextInputReplacingInfo(text: text, coursorPosition: limitedLocation)
            } else {
                let originalRange = range
                var range = originalRange
                if range.length == 0, range.location <= 1, number(from: original).intValue == 0 {
                    // Replace first 0 with value
                    range.length = 1
                    range.location = 0
                }
                let modified = (original as NSString).replacingCharacters(in: range, with: replacingString)
                let text: String = formattedNumber(from: modified)
                var extraLocationOffset = 0
                if replacingString == formatter.decimalSeparator {
                    extraLocationOffset = 1
                }
                
                let minCursorPosition = cursorMinPosition(for: original)
                let isMinOffsetDisabled = minCursorPosition == originalRange.location || replacingString == formatter.decimalSeparator
                let minLocationOffset = isMinOffsetDisabled ? 0 : 1
                let lengthDiff = max(text.count - original.count, minLocationOffset)
                let location = originalRange.location + lengthDiff + extraLocationOffset
                var limitedLocation = min(cursorMaxPosition(for: text), location)
                
                let replacedText = (original as NSString).substring(with: range)
                if replacedText.contains(formatter.decimalSeparator), !replacingString.contains(formatter.decimalSeparator) {
                    let maxIndex = cursorBeginPosition(for: text)
                    if maxIndex > 0 {
                        limitedLocation = min(maxIndex, limitedLocation)
                    }
                }
                return TextInputReplacingInfo(text: text, coursorPosition: limitedLocation)
            }
        }
        
    }
    
}

/// Info about replacing by TextInputFormatter
struct TextInputReplacingInfo {
    // The result text
    let text: String
    // The result coursor position
    let coursorPosition: Int
}

private extension UITextField {
    
    func applyReplacing(_ info: TextInputReplacingInfo) {
        text = info.text
        let newPosition = position(from: beginningOfDocument, offset: info.coursorPosition) ?? endOfDocument
        selectedTextRange = textRange(from: newPosition, to: newPosition)
        sendActions(for: .editingChanged)
    }
    
    func setCursorPosition(at index: Int) {
        let newPosition = position(from: beginningOfDocument, offset: index) ?? endOfDocument
        selectedTextRange = textRange(from: newPosition, to: newPosition)
    }
    
}

struct FormattingTextField_Previews: PreviewProvider {
    @State static var text = "123"
    
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter
    }()
    
    static var previews: some View {
        return FormattingTextField(text: $text,
                                   formatter: priceFormatter,
                                   validator: { $0 })
    }
}

