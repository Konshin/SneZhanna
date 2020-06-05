//
//  ContentView.swift
//  SneZhanna
//
//  Created by Aleksei Konshin on 05.06.2020.
//  Copyright © 2020 Aleksei Konshin. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var bill: Decimal = 100
    @State var tipPercent: Int = 10
    @State var numberOfPeople: Int = 1
    
    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    private let tipFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveSuffix = "%"
        formatter.negativeSuffix = "%"
        return formatter
    }()
    
    private let numberOfPeopleFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    var body: some View {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        let billBinding = Binding<String>(get: { return self.priceFormatter.string(from: self.bill.numberValue) ?? "" },
                                   set: { self.setBill($0) })
        let tipBinding = Binding<String>(get: { return self.tipFormatter.string(from: NSNumber(value: self.tipPercent)) ?? "" },
                                         set: {
                                            self.tipPercent = self.tipFormatter.number(from: $0)?.intValue ?? 0
        })
        let numberOfPeopleBinding = Binding<String>(get: { return "\(self.numberOfPeople)" },
                                                    set: {
                                                        self.numberOfPeople = Int($0) ?? 0
        })
        
        let tip = priceFormatter.string(from: (self.bill / 100 * Decimal(tipPercent) / Decimal(numberOfPeople)).numberValue) ?? ""
        let total = priceFormatter.string(from: (self.bill / 100 * (100 + Decimal(tipPercent)) / Decimal(numberOfPeople)).numberValue) ?? ""
        
        let padding: CGFloat = 20
        
        return NavigationView {
            GeometryReader { metrics in
                VStack(spacing: 10) {
                    self.titledText(title: self.numberOfPeople > 1 ? "Tip (per person)" : "Tip", text: tip)
                    self.titledText(title: self.numberOfPeople > 1 ? "Total (per person)" : "Total", text: total)
                    TitledContainer(title: "Bill") {
                        FormattingTextField(text: billBinding,
                                            formatter: self.priceFormatter,
                                            validator: self.validator(minLimit: 0, maxLimit: 999_999_999.99),
                                            isFirstResponder: true)
                            .frame(height: 30)
                    }
                    TitledContainer(title: "Tip %") {
                        Stepper(value: self.$tipPercent, in: 0...999_999, onEditingChanged: { _ in feedbackGenerator.selectionChanged() }) {
                            FormattingTextField(text: tipBinding,
                                                formatter: self.tipFormatter,
                                                validator: self.validator(minLimit: 0, maxLimit: 999_999),
                                                keyboardType: .numberPad,
                                                isFirstResponder: false)
                                .frame(height: 30)
                        }
                    }
                    TitledContainer(title: "Number of people") {
                        Stepper(value: self.$numberOfPeople, in: 1...999_999, onEditingChanged: { _ in feedbackGenerator.selectionChanged() }) {
                            FormattingTextField(text: numberOfPeopleBinding,
                                                formatter: self.numberOfPeopleFormatter,
                                                validator: self.validator(minLimit: 1, maxLimit: 999_999),
                                                keyboardType: .numberPad,
                                                isFirstResponder: false)
                                .frame(height: 30)
                        }
                    }
                }
                .padding(EdgeInsets(top: padding, leading: padding, bottom: 250, trailing: padding))
                .navigationBarTitle("Be a Gentleman with SneZhanna", displayMode: .inline)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - private functions
    
    private func validator(minLimit: Double, maxLimit: Double?) -> (NSNumber) -> NSNumber {
        return { value in
            if value.doubleValue < minLimit {
                return NSNumber(value: minLimit)
            }
            if let max = maxLimit, value.doubleValue > max {
                return NSNumber(value: max)
            }
            
            return value
        }
    }
    
    private func setBill(_ string: String) {
        bill = priceFormatter.number(from: string)?.decimalValue ?? 0
    }
    
    private func titledText(title: String, text: String) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.title)
            Text(text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(height: 40)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
