//
//  AddMealSheet.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct AddMealSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date

    @State private var mealName: String = ""
    @State private var selectedTag: MealTag = .breakfast

    let onAdd: (MealItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal Details") {
                    TextField("Meal name", text: $mealName)

                    Picker("Meal type", selection: $selectedTag) {
                        ForEach(MealTag.allCases, id: \.self) { tag in
                            HStack {
                                Image(systemName: tag.icon)
                                Text(tag.rawValue)
                            }
                            .tag(tag)
                        }
                    }
                }

                Section {
                    Text("Planning for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let meal = MealItem(name: mealName, tag: selectedTag)
                        onAdd(meal)
                        dismiss()
                    }
                    .disabled(mealName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMealSheet(selectedDate: .constant(Date())) { _ in }
}
