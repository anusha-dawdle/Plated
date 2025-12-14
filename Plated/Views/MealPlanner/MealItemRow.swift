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

                // Show all tags
                HStack(spacing: 6) {
                    ForEach(meal.tags, id: \.self) { tag in
                        HStack(spacing: 3) {
                            Image(systemName: tag.icon)
                                .font(.caption2)
                            Text(tag.rawValue)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        MealItemRow(meal: MealItem(name: "Oatmeal with berries", tags: [.breakfast], isCompleted: false)) {}
        MealItemRow(meal: MealItem(name: "Grilled chicken salad", tags: [.lunch], isCompleted: true)) {}
        MealItemRow(meal: MealItem(name: "Brunch special", tags: [.breakfast, .lunch], isCompleted: false)) {}
    }
}
