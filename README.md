# Plated

SwiftUI meal planning and social sharing app with two tabs: daily meal planner with checkable items and Instagram-style food photo feed with reactions/comments.

## Architecture

**Pattern**: MVVM with centralized data service
**State Management**: `@StateObject` in app root, `@EnvironmentObject` injected into views
**Data Layer**: `MockDataService` - swappable interface for future backend integration

## File Structure

### App Entry
**`PlatedApp.swift`**
- `@main` app entry point
- Initializes `MockDataService` as `@StateObject`
- Injects data service into `MainTabView` via `.environmentObject()`

**`Views/MainTabView.swift`**
- Root `TabView` with two tabs: Planner and Feed
- Tab icons: `checklist` and `photo.on.rectangle.angled`

---

### Models

**`Models/MealTag.swift`**
- `enum MealTag`: `.breakfast`, `.lunch`, `.dinner`, `.snack`
- `icon` computed property returns SF Symbol names for each tag

**`Models/User.swift`**
- `struct User`: `Identifiable`, `Codable`, `Equatable`
- Properties: `id` (UUID), `name`, `profileImage` (optional String for SF Symbol or URL)

**`Models/MealPlan.swift`**
- `struct MealPlan`: Container for a day's meals with `id`, `date`, `meals: [MealItem]`
- `struct MealItem`: Individual meal with `id`, `name`, `tag: MealTag`, `isCompleted: Bool`, `createdAt`

**`Models/SocialPost.swift`**
- `struct SocialPost`: Feed post with `author: User`, `imageData: Data?`, `caption`, `mealTag`, `reactions`, `comments`, `createdAt`
- `struct Reaction`: User emoji reaction with `user`, `emoji` (String)
- `struct Comment`: User comment with `user`, `text`, `createdAt`

---

### Services

**`Services/MockDataService.swift`**
- `@MainActor class MockDataService: ObservableObject`
- **Published properties**: `mealPlans`, `socialPosts`, `currentUser`, `users`
- **Meal methods**: `getMealPlan(for:)`, `addMeal(_:to:)`, `toggleMealCompletion(_:on:)`, `deleteMeal(_:from:)`
- **Social methods**: `addPost(_)`, `addReaction(emoji:to:by:)`, `removeReaction(from:by:)`, `addComment(_:to:by:)`
- **Sample data**: Generates 5 users, 2 days of meal plans, 4 social posts with reactions/comments

**`Services/ImagePicker.swift`**
- `UIViewControllerRepresentable` wrapper for `UIImagePickerController`
- Supports `.camera` and `.photoLibrary` source types
- Binds selected `UIImage?` to SwiftUI state
- Coordinator pattern for delegate callbacks

---

### Views - Meal Planner

**`Views/MealPlanner/MealPlannerView.swift`**
- Graphical `DatePicker` for day selection
- Groups meals by `MealTag` in sectioned `List`
- **Actions**: Toggle completion, swipe-to-delete, add meal via sheet
- Empty state when no meals planned

**`Views/MealPlanner/MealItemRow.swift`**
- Displays meal name, tag icon/label, completion checkbox
- Strikethrough styling when completed
- `onToggle` callback for completion toggle

**`Views/MealPlanner/AddMealSheet.swift`**
- Form with `TextField` for meal name, `Picker` for `MealTag`
- Shows selected date in read-only section
- Validation: disables "Add" button if name is empty

---

### Views - Social Feed

**`Views/SocialFeed/SocialFeedView.swift`**
- Scrollable `LazyVStack` of `PostCard` views
- **Actions**: Create post (sheet), show comments (sheet for selected post)
- Empty state with "Create Post" CTA

**`Views/SocialFeed/PostCard.swift`**
- Post header: author name, profile icon, timestamp (relative), meal tag badge
- Image display (300pt height) or placeholder if `imageData` is nil
- Caption text
- `ReactionBar` (horizontal scroll)
- Comments button showing count or "Add a comment"

**`Views/SocialFeed/ReactionBar.swift`**
- Displays grouped reactions (emoji + count) as `Capsule` buttons
- Highlights current user's reaction with blue background
- `Menu` for adding reactions (❤️ 👍 😋 🔥 👏)
- Tapping existing reaction toggles it off

**`Views/SocialFeed/CommentSheet.swift`**
- `NavigationStack` with comments list (`CommentRow`) or empty state
- Bottom input: `TextField` with "Post" button
- `@FocusState` for keyboard management
- Calls `onAddComment` callback, clears text after posting

**`Views/SocialFeed/CreatePostView.swift`**
- `Form` with image selection (camera/photo library via `ImagePicker`)
- Caption `TextField` (1-5 lines), `MealTag` picker
- `confirmationDialog` for choosing photo source
- Compresses image to JPEG (0.7 quality) before creating `SocialPost`
- Validates: requires both image and non-empty caption

---

## Key Dependencies

- **SwiftUI**: All UI declarative
- **PhotosUI**: For `ImagePicker` functionality
- **Foundation**: Date handling, Codable, UUID

## Privacy Permissions Required

- `NSCameraUsageDescription`: Camera access for food photos
- `NSPhotoLibraryUsageDescription`: Photo library access

## Data Flow

1. `PlatedApp` creates `MockDataService` → 2. Service injected as `@EnvironmentObject` → 3. Views read/write via `@EnvironmentObject var dataService` → 4. `@Published` properties trigger UI updates → 5. All mutations happen through service methods (single source of truth)

## Backend Integration Points

Replace `MockDataService` with real service implementing same interface:
- Meal CRUD → API calls or SwiftData for local persistence
- Social posts → Cloud storage (Firebase/Supabase) with image upload (S3/Firebase Storage)
- Reactions/comments → Real-time listeners (Firestore/Supabase Realtime)
- Authentication → Add user auth before social features
- Offline support → Cache social feed, sync on reconnect
