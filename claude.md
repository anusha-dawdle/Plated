# Plated - Meal Planning & Social Sharing App

## Overview
Plated is a fully-featured iOS social meal planning app with Firebase backend. Users can privately plan their meals, share food experiences with followers, and discover what others are eating. Think Instagram meets meal planning.

## Core Features

### 1. Authentication & User Profiles
Firebase-powered authentication with Google Sign-In.

**Key Functionality:**
- Google Sign-In authentication
- Profile setup with name, unique username, and profile picture
- Username-based user discovery
- Profile pictures stored in Firebase Storage
- Automatic session persistence

**Files:**
- `Services/AuthenticationService.swift` - Authentication management, user profile creation
- `Views/Authentication/SignInView.swift` - Google Sign-In interface
- `Views/Authentication/ProfileSetupView.swift` - Initial profile setup (name, username, photo)

**User Flow:**
1. Sign in with Google
2. First-time users: Set display name, choose unique username, upload profile picture
3. Returning users: Direct access to app

### 2. Meal Planner (Private)
Personal meal planning with real-time Firebase sync. **All meal plans are private.**

**Key Functionality:**
- Date-based meal organization with minimalistic date picker
- Meals grouped by type (Breakfast, Lunch, Dinner, Snack)
- Add meals with custom names and multiple tags
- Mark meals as completed (with optimistic updates for smooth UX)
- Delete meals with swipe-to-delete
- Real-time sync across devices
- Empty state guidance

**Files:**
- `Views/MealPlanner/MealPlannerView.swift` - Main meal planning interface
- `Views/MealPlanner/AddMealSheet.swift` - Sheet for adding new meals
- `Views/MealPlanner/MealItemRow.swift` - Individual meal row with checkbox

**Technical Notes:**
- Uses Firestore real-time listeners for instant updates
- Implements optimistic updates with 300ms debounce to prevent UI flickering
- Meals stored per-user in `mealPlans` collection

### 3. Social Feed (Followers-Only)
Share meal photos with followers. **Feed shows only your posts + posts from people you follow.**

**Key Functionality:**
- Photo-based posts with captions and meal tags
- Camera or photo library support
- React to posts with 6 emoji reactions (❤️, 😋, 🔥, 👍, 👏, 💪)
- Comment on posts with profile pictures
- Real-time updates for reactions and comments
- Filter by meal type
- Image upload to Firebase Storage

**Files:**
- `Views/SocialFeed/SocialFeedView.swift` - Main feed interface
- `Views/SocialFeed/PostCard.swift` - Individual post display with reactions/comments
- `Views/SocialFeed/CreatePostView.swift` - Create new posts with photo picker
- `Views/SocialFeed/ReactionBar.swift` - Emoji reactions UI
- `Views/SocialFeed/CommentSheet.swift` - Comments interface with input

**Privacy:**
- Posts are followers-only (no public posts)
- Feed filtered by following list + own posts
- Firestore query limited to 10 followed users (Firestore 'in' query limitation)

### 4. User Profile System
Dedicated profile tab for viewing your own posts and stats.

**Key Functionality:**
- View your own posts in chronological order
- Display followers/following counts
- Access user search
- Fixed header with profile picture, name, username, and stats
- Scrollable feed of your posts

**Files:**
- `Views/Profile/ProfileView.swift` - Current user's profile (tab 3)
- `Views/Profile/ProfileHeader.swift` - Reusable profile header component

### 5. Follow System
Request-based follow system (like Instagram private accounts).

**Key Functionality:**
- Send follow requests to users
- Accept/reject incoming follow requests
- Unfollow users
- View pending requests
- Follow status indicator (Following/Pending/Not Following)
- Badge count on Settings tab for pending requests

**Files:**
- `Views/Profile/UserProfileView.swift` - View other users' profiles with follow button
- `Views/Profile/UserSearchView.swift` - Search users by username
- `Views/Settings/FollowRequestsView.swift` - Manage incoming follow requests
- `Models/FollowRequest.swift` - Follow request data model

**User Flow:**
1. Search for user by username
2. View their profile
3. Tap "Follow" → Request sent (status changes to "Pending")
4. Recipient sees request in Settings → Follow Requests
5. Recipient accepts → Status changes to "Following", posts appear in feed
6. Can tap "Following" to unfollow

### 6. Tab Navigation
Four-tab structure for main navigation.

**Tabs:**
1. **Feed** (photo.on.rectangle.angled) - Social feed showing posts from you + followers
2. **Planner** (checklist) - Private meal planning calendar
3. **Profile** (person.circle) - Your profile, posts, and user search
4. **Settings** (gearshape) - Follow requests, account settings, sign out

**File:** `Views/MainTabView.swift`

## Data Models

### User
Complete user profile with social features.

**Properties:**
- `id: UUID` - Unique identifier (matches Firebase Auth UID)
- `name: String` - Display name
- `username: String` - Unique username (lowercase, alphanumeric + underscores)
- `email: String` - Email from Google Sign-In
- `profileImageUrl: String?` - Firebase Storage URL
- `followers: [String]` - Array of follower user IDs
- `following: [String]` - Array of following user IDs
- `createdAt: Date` - Account creation date

**File:** `Models/User.swift`

**Username Rules:**
- Unique across all users
- Lowercase only
- Letters, numbers, and underscores allowed
- Minimum 3 characters
- Validated during profile setup and search

### FollowRequest
Tracks follow request status between users.

**Properties:**
- `id: UUID` - Request identifier
- `fromUserId: String` - Requester's user ID
- `fromUserName: String` - Denormalized for display
- `fromUserUsername: String` - Denormalized for display
- `fromUserProfileImageUrl: String?` - Denormalized for display
- `toUserId: String` - Recipient's user ID
- `status: FollowRequestStatus` - pending/accepted/rejected
- `createdAt: Date` - Request timestamp

**File:** `Models/FollowRequest.swift`

**Firestore Collection:** `followRequests`
- Indexed by: `toUserId`, `status`, `createdAt`

### MealTag
Enum for meal categorization.

**Cases:**
- `breakfast` 🌅
- `lunch` ☀️
- `dinner` 🌙
- `snack` 🍃

**Conformance:** `String, Codable, CaseIterable, Hashable`

**File:** `Models/MealTag.swift`

### MealItem
Individual meal entry.

**Properties:**
- `id: UUID` - Unique identifier
- `name: String` - Meal name
- `tags: [MealTag]` - Multiple tags supported
- `isCompleted: Bool` - Completion status

**File:** `Models/MealPlan.swift`

### MealPlan
Daily meal plan container.

**Properties:**
- `id: UUID` - Plan identifier
- `userId: String` - Owner's user ID
- `date: Date` - Plan date
- `meals: [MealItem]` - All meals for this date
- `createdAt: Date` - Creation timestamp
- `updatedAt: Date` - Last modification

**File:** `Models/MealPlan.swift`

**Firestore Collection:** `mealPlans`
- Indexed by: `userId`, `date`
- Security: Users can only read/write their own plans

### SocialPost
Social media post with reactions and comments.

**Properties:**
- `id: UUID` - Post identifier
- `authorId: String` - Author's user ID
- `authorName: String` - Denormalized for performance
- `authorUsername: String` - Denormalized for performance
- `authorProfileImageUrl: String?` - Denormalized for performance
- `imageUrl: String?` - Firebase Storage URL
- `caption: String` - Post description
- `mealTag: MealTag` - Meal type
- `reactions: [Reaction]` - Emoji reactions
- `comments: [Comment]` - User comments
- `isPublic: Bool` - Always false (followers-only)
- `createdAt: Date` - Post timestamp

**File:** `Models/SocialPost.swift`

**Firestore Collection:** `socialPosts`
- Indexed by: `authorId`, `createdAt`
- Query filtered by following list

### Reaction
Emoji reaction on a post.

**Properties:**
- `id: UUID` - Reaction identifier
- `userId: String` - User who reacted
- `emoji: String` - Emoji character

**File:** `Models/SocialPost.swift`

### Comment
Text comment on a post.

**Properties:**
- `id: UUID` - Comment identifier
- `userId: String` - Comment author's user ID
- `userName: String` - Denormalized for display
- `userProfileImageUrl: String?` - Denormalized for display
- `text: String` - Comment text
- `createdAt: Date` - Comment timestamp

**File:** `Models/SocialPost.swift`

## Services

### FirebaseDataService
Central data management service with Firebase backend.

**Responsibilities:**
- Meal plan CRUD operations
- Social post CRUD operations
- Follow system management
- User search and discovery
- Real-time Firestore listeners
- Optimistic updates

**Published Properties:**
```swift
@Published var mealPlans: [MealPlan] = []
@Published var socialPosts: [SocialPost] = []
@Published var followRequests: [FollowRequest] = []
@Published var isLoading = false
@Published var error: String?
```

**Meal Planning Methods:**
- `getMealPlan(for: Date) -> MealPlan?` - Get plan for specific date
- `addMeal(_:to:) async throws` - Add meal to date
- `toggleMealCompletion(_:on:) async throws` - Toggle completion (optimistic)
- `deleteMeal(_:from:) async throws` - Remove meal from date

**Social Feed Methods:**
- `addPost(_:image:) async throws` - Create post with image upload
- `addReaction(emoji:to:by:) async throws` - Add emoji reaction
- `removeReaction(from:by:) async throws` - Remove reaction
- `addComment(_:to:userName:userProfileImageUrl:) async throws` - Add comment

**Follow System Methods:**
- `sendFollowRequest(to:) async throws` - Send follow request
- `acceptFollowRequest(_:) async throws` - Accept request, update followers/following
- `rejectFollowRequest(_:) async throws` - Reject request
- `unfollowUser(_:) async throws` - Unfollow user, update arrays
- `getFollowStatus(for:) async throws -> FollowStatus` - Check relationship status
- `searchUsers(query:) async throws -> [User]` - Search by username
- `getUser(userId:) async throws -> User` - Fetch user profile

**Real-time Listeners:**
- `startMealPlansListener(userId:)` - Listen to user's meal plans
- `startSocialFeedListener()` - Listen to posts from following list
- `startFollowRequestsListener(userId:)` - Listen to pending follow requests

**File:** `Services/FirebaseDataService.swift`

**Technical Notes:**
- Uses `@MainActor` for thread safety
- Implements 300ms debounce for optimistic updates
- Firestore listeners auto-update published properties
- Feed query limited to 10 users (Firestore 'in' query limit)

### AuthenticationService
Manages user authentication and profile creation.

**Responsibilities:**
- Google Sign-In authentication
- User profile creation in Firestore
- Profile updates (name, username, photo)
- Session management
- Sign out

**Published Properties:**
```swift
@Published var currentUser: User?
@Published var isAuthenticated = false
@Published var needsProfileSetup = false
@Published var authError: String?
```

**Methods:**
- `signInWithGoogle() async throws` - Google Sign-In flow
- `updateProfile(name:username:profileImage:) async throws` - Update user profile
- `signOut() throws` - Sign out and clear state
- `checkUsernameUniqueness(username:) async throws` - Validate username

**File:** `Services/AuthenticationService.swift`

**Technical Notes:**
- Stores users in Firestore `users` collection
- Document ID matches Firebase Auth UID
- Validates username uniqueness before saving
- Handles profile image upload via StorageService

### StorageService
Firebase Storage management for images.

**Responsibilities:**
- Upload profile images
- Upload post images
- Delete images
- Generate download URLs

**Methods:**
- `uploadProfileImage(_:userId:) async throws -> String` - Upload to `profileImages/{userId}.jpg`
- `uploadPostImage(_:postId:) async throws -> String` - Upload to `postImages/{postId}.jpg`
- `deleteImage(at:) async throws` - Delete from storage

**File:** `Services/StorageService.swift`

**Storage Structure:**
```
profileImages/
  └── {userId}.jpg
postImages/
  └── {postId}.jpg
```

**Technical Notes:**
- Images compressed to 70% quality before upload
- Returns Firebase Storage download URL
- Security rules allow authenticated users to read, owners to write

## Architecture

### App Entry Point
`PlatedApp.swift` - Firebase initialization and authentication state management

**Flow:**
1. Initialize Firebase on app launch
2. Check authentication state via AuthenticationService
3. If authenticated: Show `MainTabView`
4. If not authenticated: Show `SignInView`
5. If needs profile setup: Show `ProfileSetupView`

### State Management
- SwiftUI `@StateObject` and `@EnvironmentObject` for dependency injection
- `FirebaseDataService` injected globally as environment object
- `AuthenticationService` injected globally as environment object
- Real-time updates via Firestore listeners trigger view re-renders

### Database Structure

**Firestore Collections:**
```
users/
  └── {userId}/ (document)
      ├── name: String
      ├── username: String (indexed)
      ├── email: String
      ├── profileImageUrl: String
      ├── followers: [String]
      ├── following: [String]
      └── createdAt: Timestamp

mealPlans/
  └── {planId}/ (document)
      ├── userId: String (indexed)
      ├── date: Timestamp
      ├── meals: [MealItem]
      ├── createdAt: Timestamp
      └── updatedAt: Timestamp

socialPosts/
  └── {postId}/ (document)
      ├── authorId: String (indexed)
      ├── authorName: String (denormalized)
      ├── authorUsername: String (denormalized)
      ├── authorProfileImageUrl: String (denormalized)
      ├── imageUrl: String
      ├── caption: String
      ├── mealTag: String
      ├── reactions: [Reaction]
      ├── comments: [Comment]
      ├── isPublic: Boolean (always false)
      └── createdAt: Timestamp (indexed)

followRequests/
  └── {requestId}/ (document)
      ├── fromUserId: String
      ├── fromUserName: String (denormalized)
      ├── fromUserUsername: String (denormalized)
      ├── fromUserProfileImageUrl: String (denormalized)
      ├── toUserId: String (indexed)
      ├── status: String (indexed: "pending"/"accepted"/"rejected")
      └── createdAt: Timestamp (indexed)
```

**Required Firestore Indexes:**
1. `followRequests`: Compound index on `toUserId` (Asc), `status` (Asc), `createdAt` (Desc)
2. `users`: Single field index on `username` (Asc)
3. `mealPlans`: Single field index on `userId` (Asc)
4. `socialPosts`: Single field index on `authorId` (Asc)

### UI Pattern
- SwiftUI native components throughout
- List-based interfaces with sections
- Sheet presentations for modals (add meal, create post, comments)
- NavigationStack for hierarchical navigation
- AsyncImage for loading images from Firebase Storage
- Task modifiers for async data loading
- Optimistic updates for instant UI feedback

## Technical Details

**Platform:** iOS (iPhone)
**Minimum Version:** iOS 18.5
**Language:** Swift
**Framework:** SwiftUI
**Backend:** Firebase (Auth, Firestore, Storage)
**Authentication:** Google Sign-In
**Architecture:** MVVM with ObservableObject
**Data Sync:** Real-time Firestore listeners
**Image Storage:** Firebase Storage
**Offline Support:** Firestore automatic persistence

## Privacy & Security

### Data Privacy
- **Meal plans:** Completely private, never visible to other users
- **Posts:** Visible only to users who follow you (and accepted your request)
- **Profiles:** Searchable by username, visible to all authenticated users
- **Follow requests:** Only visible to sender and recipient

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    match /mealPlans/{planId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }

    match /socialPosts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == request.resource.data.authorId;
      allow update, delete: if request.auth.uid == resource.data.authorId;
    }

    match /followRequests/{requestId} {
      allow read: if request.auth.uid == resource.data.fromUserId ||
                     request.auth.uid == resource.data.toUserId;
      allow create: if request.auth.uid == request.resource.data.fromUserId;
      allow update: if request.auth.uid == resource.data.toUserId;
    }
  }
}
```

### Firebase Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profileImages/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    match /postImages/{postId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Known Issues & Solutions

### Resolved Issues
1. **Build Timeouts** - Fixed by removing complex nested closures
2. **Meal Planner Flickering** - Fixed with optimistic updates + 300ms debounce
3. **Comment Profile Pictures** - Fixed by denormalizing user data in Comment model
4. **Label Initializer Error** - Fixed by using `systemImage:` instead of `systemName:`

### Current Limitations
- Feed limited to 10 followed users due to Firestore 'in' query limit
  - Solution for future: Implement fan-out feed architecture or pagination
- Username changes not supported after initial setup
  - Would require updating all denormalized data (posts, comments, etc.)
- No blocking users feature
- No direct messaging feature
- No notification system

## Future Enhancements

### Potential Features
- Push notifications for follow requests, comments, reactions
- Story-style ephemeral posts (24-hour expiration)
- Meal templates and favorites
- Recipe storage with ingredients
- Grocery list generation from meal plans
- Nutritional information tracking
- Meal planning suggestions based on past meals
- Group meal planning for families
- Export meal plans to calendar
- Dark mode support
- iPad optimization
- Direct messaging between followers
- User blocking
- Report inappropriate content
- Profile editing (bio, website links)
- Multiple photo uploads per post
- Video posts

### Technical Improvements
- Implement pagination for feed (infinite scroll)
- Fan-out feed architecture for 10+ following limit
- Image caching and optimization
- Offline queue for post creation
- Analytics and crash reporting
- A/B testing framework
- Performance monitoring
- Unit and UI tests

---

*Last Updated: December 14, 2025*
*Created with Claude Code*
*Backend: Firebase (Auth, Firestore, Storage)*
