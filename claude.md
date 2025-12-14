# Plated - Meal Planning & Social Sharing App

## Overview
Plated is an iOS app that combines meal planning with social features, allowing users to plan their meals and share their food experiences with friends and family.

## Main Features

### 1. Meal Planner
The core feature that helps users organize their meals throughout the week.

**Key Functionality:**
- View meals organized by date using a date picker
- Meals are grouped by tags (Breakfast, Lunch, Dinner, Snack)
- Add new meals with custom names and multiple tags
- Mark meals as completed
- Delete meals with swipe-to-delete
- Empty state guidance when no meals are planned

**Files:**
- `Views/MealPlanner/MealPlannerView.swift` - Main meal planning interface
- `Views/MealPlanner/AddMealSheet.swift` - Sheet for adding new meals
- `Views/MealPlanner/MealItemRow.swift` - Individual meal row display

### 2. Social Feed
A social platform for sharing meal photos and experiences.

**Key Functionality:**
- View feed of meal posts from friends/family
- Create posts with photos, captions, and meal tags
- React to posts with emojis (❤️, 😋, 🔥, 👍, 👏, 💪)
- Comment on posts
- Filter by meal type

**Files:**
- `Views/SocialFeed/SocialFeedView.swift` - Main feed interface
- `Views/SocialFeed/PostCard.swift` - Individual post display
- `Views/SocialFeed/CreatePostView.swift` - Create new posts
- `Views/SocialFeed/ReactionBar.swift` - Emoji reactions UI
- `Views/SocialFeed/CommentSheet.swift` - Comments interface

### 3. Tab Navigation
The app uses a tab-based navigation structure with two main tabs:
- **Calendar icon** - Meal Planner
- **Person icon** - Social Feed

**File:** `Views/MainTabView.swift`

## Data Models

### MealTag
Enum representing different meal types:
- `breakfast` 🌅 - Breakfast
- `lunch` ☀️ - Lunch
- `dinner` 🌙 - Dinner
- `snack` 🍃 - Snack

**Conformance:** `String, Codable, CaseIterable, Hashable`

**File:** `Models/MealTag.swift`

### MealItem
Represents a single meal with:
- `id: UUID` - Unique identifier
- `name: String` - Meal name
- `tags: [MealTag]` - Multiple tags (e.g., meal can be both breakfast and snack)
- `isCompleted: Bool` - Completion status

**File:** `Models/MealPlan.swift`

### MealPlan
Daily meal plan containing:
- `id: UUID` - Unique identifier
- `date: Date` - The date for this plan
- `meals: [MealItem]` - All meals for this date

**File:** `Models/MealPlan.swift`

### User
User profile information:
- `id: UUID` - Unique identifier
- `name: String` - Display name
- `profileImage: String` - SF Symbol name for avatar

**File:** `Models/User.swift`

### SocialPost
Social media post containing:
- `id: UUID` - Unique identifier
- `author: User` - Post creator
- `imageData: Data?` - Optional meal photo
- `caption: String` - Post description
- `mealTag: MealTag` - Associated meal type
- `reactions: [Reaction]` - Emoji reactions
- `comments: [Comment]` - User comments
- `createdAt: Date` - Post timestamp

**Supporting Types:**
- `Reaction` - User emoji reaction
- `Comment` - User text comment

**File:** `Models/SocialPost.swift`

## Services

### MockDataService
Central data management service using `@MainActor` and `ObservableObject`.

**Meal Planning Methods:**
- `getMealPlan(for: Date) -> MealPlan` - Get or create plan for date
- `addMeal(_:to:)` - Add meal to specific date
- `toggleMealCompletion(_:on:)` - Toggle meal completion status
- `deleteMeal(_:from:)` - Remove meal from date

**Social Feed Methods:**
- `addPost(_:)` - Create new post
- `addReaction(emoji:to:by:)` - Add emoji reaction
- `removeReaction(from:by:)` - Remove reaction
- `addComment(_:to:by:)` - Add comment to post

**Sample Data:**
- Pre-populated with sample meal plans for today/tomorrow
- Pre-populated with sample social posts from multiple users
- Sample users: You, Sarah, Mom, Alex, Jamie

**File:** `Services/MockDataService.swift`

### ImagePicker
UIKit wrapper for selecting photos from library.

**File:** `Services/ImagePicker.swift`

## Architecture

### App Entry Point
`PlatedApp.swift` - Main app struct with `@main` attribute

### State Management
- Uses SwiftUI's `@StateObject` and `@EnvironmentObject` for data flow
- `MockDataService` is the central source of truth
- Injected via `.environmentObject()` modifier

### UI Pattern
- SwiftUI native components
- List-based interfaces with sections
- Sheet presentations for modals
- NavigationStack for navigation hierarchy

## Recent Development History

### Known Issues (Resolved)
1. **Build Hangs** - Fixed by adding `Hashable` conformance to `MealTag`
   - Issue: Compiler hung during type inference for `Set<MealTag>`
   - Solution: Added `Hashable` protocol to `MealTag` enum

2. **Repeat Scheduling Feature** - Attempted but reverted
   - Initial attempt caused linker errors and build hangs
   - Reverted to simple single-date meal addition
   - Future consideration: Implement with simpler approach

3. **Type-Checking Timeouts** - Fixed by extracting complex views
   - Issue: Complex nested view hierarchies caused compiler timeouts
   - Solution: Extract helper functions for complex UI components

### Current State
- ✅ Builds successfully without errors
- ✅ Meal planning works for single dates
- ✅ Social feed fully functional
- ✅ All data models properly conform to protocols
- ⚠️ Preview may show "Cannot analyze built description" (Xcode cache issue)

## UI/UX Highlights

### Meal Planner
- Minimalistic date picker at top
- Chronologically sorted meal groups (Breakfast → Lunch → Dinner → Snack)
- Multiple tags per meal supported
- Clean empty state with helpful messaging

### Social Feed
- Card-based post layout
- Inline emoji reactions
- User avatars throughout
- Comment threading
- Photo upload support

### Add Meal Sheet
- Simple form-based input
- Multi-select for meal tags (can select multiple)
- Visual feedback with checkmarks
- Shows selected date context
- Disabled submit until required fields filled

## Technical Details

**Platform:** iOS (iPhone)
**Minimum Version:** iOS 18.5
**Language:** Swift
**Framework:** SwiftUI
**Architecture:** MVVM-like with ObservableObject
**Data Persistence:** In-memory only (MockDataService)

## Future Considerations

### Potential Features
- Repeat meal scheduling across multiple dates
- Calendar view for meal planning
- Meal templates/favorites
- Recipe storage and sharing
- Nutritional information tracking
- Grocery list generation from meal plans
- Real backend integration
- Persistent storage (Core Data or SwiftData)

### Known Limitations
- No data persistence (resets on app restart)
- No user authentication
- No real backend/networking
- Single user experience (no multi-user support)
- Photos not actually saved

---

*Last Updated: December 14, 2025*
*Created with Claude Code*
