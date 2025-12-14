//
//  MealPlan.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation

struct MealPlan: Identifiable, Codable {
    let id: UUID
    var date: Date
    var meals: [MealItem]

    init(id: UUID = UUID(), date: Date, meals: [MealItem] = []) {
        self.id = id
        self.date = date
        self.meals = meals
    }
}

struct MealItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var tag: MealTag
    var isCompleted: Bool
    var createdAt: Date

    init(id: UUID = UUID(), name: String, tag: MealTag, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.tag = tag
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
