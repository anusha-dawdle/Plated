//
//  MealPlan.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation

struct MealPlan: Identifiable, Codable {
    let id: UUID
    var userId: String
    var date: Date
    var meals: [MealItem]
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), userId: String, date: Date, meals: [MealItem] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.date = date
        self.meals = meals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct MealItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var tags: [MealTag]
    var isCompleted: Bool
    var createdAt: Date

    init(id: UUID = UUID(), name: String, tags: [MealTag], isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.tags = tags
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
