//
//  MealPlannerView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct MealPlannerView: View {
    @EnvironmentObject var dataService: MockDataService
    @State private var selectedDate = Date()
    @State private var showingAddMeal = false

    private var mealsForSelectedDate: [MealItem] {
        dataService.getMealPlan(for: selectedDate).meals
    }

    private var groupedMeals: [(MealTag, [MealItem])] {
        // Create groups for each tag, including meals that have multiple tags
        var groups: [MealTag: [MealItem]] = [:]

        for meal in mealsForSelectedDate {
            for tag in meal.tags {
                if groups[tag] == nil {
                    groups[tag] = []
                }
                groups[tag]?.append(meal)
            }
        }

        // Return in the order of MealTag.allCases
        return MealTag.allCases.compactMap { tag in
            guard let meals = groups[tag], !meals.isEmpty else { return nil }
            return (tag, meals)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date picker - minimalistic
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGroupedBackground))

                // Meals list
                if mealsForSelectedDate.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(groupedMeals, id: \.0) { tag, meals in
                            Section {
                                ForEach(meals) { meal in
                                    MealItemRow(meal: meal) {
                                        dataService.toggleMealCompletion(meal, on: selectedDate)
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        dataService.deleteMeal(meals[index], from: selectedDate)
                                    }
                                }
                            } header: {
                                HStack(spacing: 6) {
                                    Image(systemName: tag.icon)
                                    Text(tag.rawValue)
                                }
                                .font(.subheadline.weight(.semibold))
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Meal Planner")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddMeal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealSheet(selectedDate: $selectedDate) { meal in
                    dataService.addMeal(meal, to: selectedDate)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No meals planned")
                .font(.title3.weight(.medium))

            Text("Tap the + button to add a meal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    MealPlannerView()
        .environmentObject(MockDataService())
}
