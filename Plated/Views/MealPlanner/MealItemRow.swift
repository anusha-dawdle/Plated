//
//  MealItemRow.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct MealItemRow: View {
    let meal: MealItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: meal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(meal.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.body)
                    .strikethrough(meal.isCompleted)
                    .foregroundStyle(meal.isCompleted ? .secondary : .primary)

                HStack(spacing: 4) {
                    Image(systemName: meal.tag.icon)
                        .font(.caption)
                    Text(meal.tag.rawValue)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        MealItemRow(meal: MealItem(name: "Oatmeal with berries", tag: .breakfast, isCompleted: false)) {}
        MealItemRow(meal: MealItem(name: "Grilled chicken salad", tag: .lunch, isCompleted: true)) {}
    }
}
