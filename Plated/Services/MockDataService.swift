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
        self.currentUser = User(name: "You", profileImage: "person.circle.fill")
        self.users = [
            currentUser,
            User(name: "Sarah", profileImage: "person.circle.fill"),
            User(name: "Mom", profileImage: "person.circle.fill"),
            User(name: "Alex", profileImage: "person.circle.fill"),
            User(name: "Jamie", profileImage: "person.circle.fill")
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
        let newPlan = MealPlan(date: date, meals: [])
        mealPlans.append(newPlan)
        return newPlan
    }

    func addMeal(_ meal: MealItem, to date: Date) {
        if let index = mealPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            mealPlans[index].meals.append(meal)
        } else {
            let newPlan = MealPlan(date: date, meals: [meal])
            mealPlans.append(newPlan)
        }
    }

    func toggleMealCompletion(_ meal: MealItem, on date: Date) {
        if let planIndex = mealPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }),
           let mealIndex = mealPlans[planIndex].meals.firstIndex(where: { $0.id == meal.id }) {
            mealPlans[planIndex].meals[mealIndex].isCompleted.toggle()
        }
    }

    func deleteMeal(_ meal: MealItem, from date: Date) {
        if let planIndex = mealPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            mealPlans[planIndex].meals.removeAll { $0.id == meal.id }
        }
    }

    // MARK: - Social Feed Methods

    func addPost(_ post: SocialPost) {
        socialPosts.insert(post, at: 0)
    }

    func addReaction(emoji: String, to post: SocialPost, by user: User) {
        guard let index = socialPosts.firstIndex(where: { $0.id == post.id }) else { return }

        // Remove existing reaction from this user if any
        socialPosts[index].reactions.removeAll { $0.user.id == user.id }

        // Add new reaction
        let reaction = Reaction(user: user, emoji: emoji)
        socialPosts[index].reactions.append(reaction)
    }

    func removeReaction(from post: SocialPost, by user: User) {
        guard let index = socialPosts.firstIndex(where: { $0.id == post.id }) else { return }
        socialPosts[index].reactions.removeAll { $0.user.id == user.id }
    }

    func addComment(_ text: String, to post: SocialPost, by user: User) {
        guard let index = socialPosts.firstIndex(where: { $0.id == post.id }) else { return }
        let comment = Comment(user: user, text: text)
        socialPosts[index].comments.append(comment)
    }

    // MARK: - Sample Data Creation

    private func createSampleMealPlans() -> [MealPlan] {
        let calendar = Calendar.current
        let today = Date()
        var plans: [MealPlan] = []

        // Today's meals
        let todayMeals = [
            MealItem(name: "Oatmeal with berries", tag: .breakfast, isCompleted: true),
            MealItem(name: "Grilled chicken salad", tag: .lunch),
            MealItem(name: "Salmon with roasted vegetables", tag: .dinner),
            MealItem(name: "Apple slices with almond butter", tag: .snack)
        ]
        plans.append(MealPlan(date: today, meals: todayMeals))

        // Tomorrow's meals
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
            let tomorrowMeals = [
                MealItem(name: "Greek yogurt parfait", tag: .breakfast),
                MealItem(name: "Turkey wrap", tag: .lunch),
                MealItem(name: "Pasta primavera", tag: .dinner)
            ]
            plans.append(MealPlan(date: tomorrow, meals: tomorrowMeals))
        }

        return plans
    }

    private func createSamplePosts() -> [SocialPost] {
        var posts: [SocialPost] = []
        let calendar = Calendar.current

        // Post 1: Recent post from Sarah
        if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date()) {
            let post1 = SocialPost(
                author: users[1], // Sarah
                imageData: nil,
                caption: "Homemade pizza night!",
                mealTag: .dinner,
                reactions: [
                    Reaction(user: currentUser, emoji: "❤️"),
                    Reaction(user: users[2], emoji: "😋"),
                    Reaction(user: users[3], emoji: "🔥")
                ],
                comments: [
                    Comment(user: currentUser, text: "Looks delicious!"),
                    Comment(user: users[2], text: "Recipe please!")
                ],
                createdAt: twoDaysAgo
            )
            posts.append(post1)
        }

        // Post 2: Post from Mom
        if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date()) {
            let post2 = SocialPost(
                author: users[2], // Mom
                imageData: nil,
                caption: "Sunday brunch with the family",
                mealTag: .breakfast,
                reactions: [
                    Reaction(user: currentUser, emoji: "❤️"),
                    Reaction(user: users[1], emoji: "👍")
                ],
                comments: [
                    Comment(user: users[1], text: "Wish I was there!")
                ],
                createdAt: threeDaysAgo
            )
            posts.append(post2)
        }

        // Post 3: Post from Alex
        if let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: Date()) {
            let post3 = SocialPost(
                author: users[3], // Alex
                imageData: nil,
                caption: "Quick lunch before the meeting",
                mealTag: .lunch,
                reactions: [
                    Reaction(user: users[4], emoji: "👏")
                ],
                comments: [],
                createdAt: fourDaysAgo
            )
            posts.append(post3)
        }

        // Post 4: Post from Jamie
        if let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: Date()) {
            let post4 = SocialPost(
                author: users[4], // Jamie
                imageData: nil,
                caption: "Healthy snacking all day",
                mealTag: .snack,
                reactions: [
                    Reaction(user: currentUser, emoji: "💪"),
                    Reaction(user: users[1], emoji: "😋")
                ],
                comments: [
                    Comment(user: currentUser, text: "Love it!")
                ],
                createdAt: fiveDaysAgo
            )
            posts.append(post4)
        }

        return posts
    }
}
