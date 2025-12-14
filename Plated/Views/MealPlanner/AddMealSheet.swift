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
    @State private var selectedTags: Set<MealTag> = [.breakfast]

    let onAdd: (MealItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal Details") {
                    TextField("Meal name", text: $mealName)
                }

                Section("Meal Tags (select one or more)") {
                    ForEach(MealTag.allCases, id: \.self) { tag in
                        Button {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        } label: {
                            HStack {
                                Image(systemName: tag.icon)
                                Text(tag.rawValue)
                                Spacer()
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
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
                        let meal = MealItem(name: mealName, tags: Array(selectedTags))
                        onAdd(meal)
                        dismiss()
                    }
                    .disabled(mealName.trimmingCharacters(in: .whitespaces).isEmpty || selectedTags.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMealSheet(selectedDate: .constant(Date())) { meal in
        print("Added meal: \(meal.name) with tags: \(meal.tags)")
    }
}
