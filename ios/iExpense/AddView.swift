//
//  AddView.swift
//  iExpense
//
//  Created by Mac Van Anh on 5/9/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import SwiftUI

struct AddView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var expenses: Expenses
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    @State private var showingAlert = false
    
    static let types = ["Business", "Personal"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    ForEach(Self.types, id: \.self) {
                        Text($0)
                    }
                }
                
                TextField("Amount", text: $amount).keyboardType(.numberPad)
            }
            .navigationBarTitle("Add new expense")
            .navigationBarItems(trailing: Button("Save") {
                if let actualAmount = Int(self.amount) {
                    let item = ExpenseItem(name: self.name, type: self.type, amount: actualAmount)
                    self.expenses.items = self.expenses.items + [item]
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.showingAlert = true
                }
            })
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Wrong number"), message: Text("Please enter a valid number."), dismissButton: .default(Text("OK")))
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
