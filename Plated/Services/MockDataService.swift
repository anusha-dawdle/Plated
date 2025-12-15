//
//  MockDataService.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation
import SwiftUI

@MainActor
class MockDataService: ObservableObject {
    @Published var mealPlans: [MealPlan] = []
    @Published var socialPosts: [SocialPost] = []
    @Published var currentUser: User
    @Published var users: [User] = []

    init() {
        // Create sample users
        self.currentUser = User(name: "You", email: "you@example.com", profileImageUrl: "person.circle.fill")
        self.users = [
            currentUser,
            User(name: "Sarah", email: "sarah@example.com", profileImageUrl: "person.circle.fill"),
            User(name: "Mom", email: "mom@example.com", profileImageUrl: "person.circle.fill"),
            User(name: "Alex", email: "alex@example.com", profileImageUrl: "person.circle.fill"),
            User(name: "Jamie", email: "jamie@example.com", profileImageUrl: "person.circle.fill")
        ]

        // Create sample meal plans
        self.mealPlans = createSampleMealPlans()

        // Create sample social posts
        self.socialPosts = createSamplePosts()
    }

    // MARK: - Meal Planning Methods

    func getMealPlan(for date: Date) -> MealPlan {
        let calendar = Calendar.current
        if let existingPlan = mealPlans.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return existingPlan
        }
        let newPlan = MealPlan(userId: currentUser.id.uuidString, date: date, meals: [])
        mealPlans.append(newPlan)
        return newPlan
    }

    func addMeal(_ meal: MealItem, to date: Date) {
        if let index = mealPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            mealPlans[index].meals.append(meal)
            mealPlans[index].updatedAt = Date()
        } else {
            let newPlan = MealPlan(userId: currentUser.id.uuidString, date: date, meals: [meal])
            mealPlans.append(newPlan)
        }
    }

    func toggleMealCompletion(_ meal: MealItem, on date: Date) {
        if let planIndex = mealPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }),
           let mealIndex = mealPlans[planIndex].meals.firstIndex(where: { $0.id == meal.id }) {
            mealPlans[planIndex].meals[mealIndex].isCompleted.toggle()
            mealPlans[planIndex].updatedAt = Date()
        }
    }

    func deleteMeal(_ meal: MealItem, from date: Date) {
        if let planIndex = mealPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            mealPlans[planIndex].meals.removeAll { $0.id == meal.id }
            mealPlans[planIndex].updatedAt = Date()
        }
    }

    // MARK: - Social Feed Methods

    func addPost(_ post: SocialPost) {
        socialPosts.insert(post, at: 0)
    }

    func addReaction(emoji: String, to post: SocialPost, by user: User) {
        guard let index = socialPosts.firstIndex(where: { $0.id == post.id }) else { return }

        // Remove existing reaction from this user if any
        socialPosts[index].reactions.removeAll { $0.userId == user.id.uuidString }

        // Add new reaction
        let reaction = Reaction(userId: user.id.uuidString, emoji: emoji)
        socialPosts[index].reactions.append(reaction)
    }

    func removeReaction(from post: SocialPost, by user: User) {
        guard let index = socialPosts.firstIndex(where: { $0.id == post.id }) else { return }
        socialPosts[index].reactions.removeAll { $0.userId == user.id.uuidString }
    }

    func addComment(_ text: String, to post: SocialPost, by user: User) {
        guard let index = socialPosts.firstIndex(where: { $0.id == post.id }) else { return }
        let comment = Comment(userId: user.id.uuidString, userName: user.name, text: text)
        socialPosts[index].comments.append(comment)
    }

    // MARK: - Sample Data Creation

    private func createSampleMealPlans() -> [MealPlan] {
        let calendar = Calendar.current
        let today = Date()
        var plans: [MealPlan] = []

        // Today's meals
        let todayMeals = [
            MealItem(name: "Oatmeal with berries", tags: [.breakfast], isCompleted: true),
            MealItem(name: "Grilled chicken salad", tags: [.lunch]),
            MealItem(name: "Salmon with roasted vegetables", tags: [.dinner]),
            MealItem(name: "Apple slices with almond butter", tags: [.snack])
        ]
        plans.append(MealPlan(userId: currentUser.id.uuidString, date: today, meals: todayMeals))

        // Tomorrow's meals
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
            let tomorrowMeals = [
                MealItem(name: "Greek yogurt parfait", tags: [.breakfast]),
                MealItem(name: "Turkey wrap", tags: [.lunch]),
                MealItem(name: "Pasta primavera", tags: [.dinner])
            ]
            plans.append(MealPlan(userId: currentUser.id.uuidString, date: tomorrow, meals: tomorrowMeals))
        }

        return plans
    }

    private func createSamplePosts() -> [SocialPost] {
        var posts: [SocialPost] = []
        let calendar = Calendar.current

        // Post 1: Recent post from Sarah
        if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date()) {
            let post1 = SocialPost(
                authorId: users[1].id.uuidString, // Sarah
                authorName: users[1].name,
                authorProfileImageUrl: users[1].profileImageUrl,
                imageUrl: nil,
                caption: "Homemade pizza night!",
                mealTag: .dinner,
                reactions: [
                    Reaction(userId: currentUser.id.uuidString, emoji: "❤️"),
                    Reaction(userId: users[2].id.uuidString, emoji: "😋"),
                    Reaction(userId: users[3].id.uuidString, emoji: "🔥")
                ],
                comments: [
                    Comment(userId: currentUser.id.uuidString, userName: currentUser.name, text: "Looks delicious!"),
                    Comment(userId: users[2].id.uuidString, userName: users[2].name, text: "Recipe please!")
                ],
                createdAt: twoDaysAgo
            )
            posts.append(post1)
        }

        // Post 2: Post from Mom
        if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date()) {
            let post2 = SocialPost(
                authorId: users[2].id.uuidString, // Mom
                authorName: users[2].name,
                authorProfileImageUrl: users[2].profileImageUrl,
                imageUrl: nil,
                caption: "Sunday brunch with the family",
                mealTag: .breakfast,
                reactions: [
                    Reaction(userId: currentUser.id.uuidString, emoji: "❤️"),
                    Reaction(userId: users[1].id.uuidString, emoji: "👍")
                ],
                comments: [
                    Comment(userId: users[1].id.uuidString, userName: users[1].name, text: "Wish I was there!")
                ],
                createdAt: threeDaysAgo
            )
            posts.append(post2)
        }

        // Post 3: Post from Alex
        if let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: Date()) {
            let post3 = SocialPost(
                authorId: users[3].id.uuidString, // Alex
                authorName: users[3].name,
                authorProfileImageUrl: users[3].profileImageUrl,
                imageUrl: nil,
                caption: "Quick lunch before the meeting",
                mealTag: .lunch,
                reactions: [
                    Reaction(userId: users[4].id.uuidString, emoji: "👏")
                ],
                comments: [],
                createdAt: fourDaysAgo
            )
            posts.append(post3)
        }

        // Post 4: Post from Jamie
        if let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: Date()) {
            let post4 = SocialPost(
                authorId: users[4].id.uuidString, // Jamie
                authorName: users[4].name,
                authorProfileImageUrl: users[4].profileImageUrl,
                imageUrl: nil,
                caption: "Healthy snacking all day",
                mealTag: .snack,
                reactions: [
                    Reaction(userId: currentUser.id.uuidString, emoji: "💪"),
                    Reaction(userId: users[1].id.uuidString, emoji: "😋")
                ],
                comments: [
                    Comment(userId: currentUser.id.uuidString, userName: currentUser.name, text: "Love it!")
                ],
                createdAt: fiveDaysAgo
            )
            posts.append(post4)
        }

        return posts
    }
}
