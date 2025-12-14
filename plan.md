# Firebase Integration Plan for Plated

## Overview
Convert Plated from a mock-data app to a production app with Firebase backend, supporting real users with Google Sign-In authentication, private meal plans, and real-time social features.

## User Requirements
- **Authentication:** Google Sign-In
- **Data Privacy:** Private meal plans per user, social feed for friends/followers
- **Real-time Sync:** Yes, using Firestore listeners

## Implementation Phases

### Phase 1: Firebase SDK Setup & Configuration

**1.1 Install Firebase SDK**
- Add Firebase iOS SDK via Swift Package Manager
- Packages needed:
  - FirebaseAuth (authentication)
  - FirebaseFirestore (database)
  - FirebaseStorage (image uploads)

**1.2 Configure Firebase**
- Download `GoogleService-Info.plist` from Firebase Console
- Add to Xcode project (root level, included in target)
- Initialize Firebase in `PlatedApp.swift`

**Files to modify:**
- `PlatedApp.swift` - Add Firebase initialization

---

### Phase 2: Authentication System

**2.1 Create AuthenticationService**
Create new file: `Services/AuthenticationService.swift`

**Responsibilities:**
- Google Sign-In authentication
- Sign out
- Track authentication state
- Create user profile in Firestore on sign up

**Published Properties:**
```swift
@Published var currentUser: User?
@Published var isAuthenticated: Bool
@Published var authError: String?
```

**Methods:**
```swift
func signInWithGoogle() async throws
func signOut() throws
```

**2.2 Create Authentication Views**
Create new files in `Views/Authentication/`:
- `SignInView.swift` - Google Sign-In button and branding

**2.3 Update App Entry Point**
Modify `PlatedApp.swift`:
- Check authentication state
- Show `AuthenticationView` if not authenticated
- Show `MainTabView` if authenticated

---

### Phase 3: Firestore Database Structure

**3.1 Collections Design**

```
users/ (collection)
  └── {userId}/ (document)
      ├── id: String
      ├── name: String
      ├── email: String
      ├── profileImageUrl: String? (Firebase Storage URL)
      ├── createdAt: Timestamp
      └── followers: [String] (array of user IDs)
      └── following: [String] (array of user IDs)

mealPlans/ (collection)
  └── {mealPlanId}/ (document)
      ├── id: String
      ├── userId: String (owner)
      ├── date: Timestamp
      ├── meals: [MealItem] (subcollection would be better, but array is simpler)
      ├── createdAt: Timestamp
      └── updatedAt: Timestamp

socialPosts/ (collection)
  └── {postId}/ (document)
      ├── id: String
      ├── authorId: String (reference to users collection)
      ├── imageUrl: String? (Firebase Storage URL)
      ├── caption: String
      ├── mealTag: String
      ├── reactions: [{userId: String, emoji: String}]
      ├── createdAt: Timestamp
      └── isPublic: Boolean (for privacy settings)

comments/ (subcollection of socialPosts)
  └── {postId}/comments/{commentId}
      ├── id: String
      ├── userId: String
      ├── text: String
      ├── createdAt: Timestamp
```

**3.2 Security Rules Strategy**
- Users can only read/write their own meal plans
- Users can read posts from users they follow
- Users can write their own posts
- All users can add reactions/comments to visible posts

---

### Phase 4: Firebase Storage for Images

**4.1 Storage Structure**
```
profileImages/
  └── {userId}.jpg

postImages/
  └── {postId}.jpg
```

**4.2 Create StorageService**
Create new file: `Services/StorageService.swift`

**Methods:**
```swift
func uploadProfileImage(_ imageData: Data, userId: String) async throws -> String
func uploadPostImage(_ imageData: Data, postId: String) async throws -> String
func deleteImage(at path: String) async throws
```

---

### Phase 5: FirebaseDataService Implementation

**5.1 Create FirebaseDataService**
Create new file: `Services/FirebaseDataService.swift`

**Purpose:** Replace `MockDataService` with real Firebase backend

**Published Properties:**
```swift
@Published var mealPlans: [MealPlan] = []
@Published var socialPosts: [SocialPost] = []
@Published var currentUser: User?
@Published var users: [User] = [] // Following/followers
@Published var isLoading: Bool = false
@Published var error: String?
```

**Dependencies:**
- FirebaseFirestore instance
- StorageService instance
- AuthenticationService instance (to get current user ID)

**5.2 Meal Planning Methods** (async versions)
```swift
func fetchMealPlans() async throws // Fetch user's meal plans
func getMealPlan(for date: Date) -> MealPlan? // Local lookup, auto-fetch if missing
func addMeal(_ meal: MealItem, to date: Date) async throws
func toggleMealCompletion(_ meal: MealItem, on date: Date) async throws
func deleteMeal(_ meal: MealItem, from date: Date) async throws
```

**5.3 Social Feed Methods** (async versions)
```swift
func fetchSocialFeed() async throws // Fetch posts from following
func addPost(_ post: SocialPost, image: Data?) async throws
func addReaction(emoji: String, to post: SocialPost) async throws
func removeReaction(from post: SocialPost) async throws
func addComment(_ text: String, to post: SocialPost) async throws
func fetchComments(for post: SocialPost) async throws -> [Comment]
```

**5.4 Real-time Listeners**
```swift
private var mealPlansListener: ListenerRegistration?
private var socialFeedListener: ListenerRegistration?

func startListening() // Set up Firestore listeners
func stopListening() // Clean up listeners
```

**5.5 User Management**
```swift
func fetchFollowing() async throws // Get users I follow
func followUser(_ userId: String) async throws
func unfollowUser(_ userId: String) async throws
func searchUsers(query: String) async throws -> [User]
```

---

### Phase 6: Model Updates

**6.1 Update Models for Firebase**

Modify existing models to work with Firestore:

**User.swift:**
- Add `email: String`
- Add `profileImageUrl: String?`
- Add `followers: [String]` (user IDs)
- Add `following: [String]` (user IDs)
- Add `createdAt: Date`

**MealPlan.swift:**
- Add `userId: String` (owner ID)
- Add `updatedAt: Date`

**MealItem.swift:**
- Keep existing properties (already compatible)

**SocialPost.swift:**
- Change `author: User` to `authorId: String`
- Change `imageData: Data?` to `imageUrl: String?`
- Add `isPublic: Bool`
- Add `authorName: String` (denormalized for performance)
- Add `authorProfileImageUrl: String?` (denormalized)

**Reaction.swift:**
- Change `user: User` to `userId: String`

**Comment.swift:**
- Change `user: User` to `userId: String`
- Add `userName: String` (denormalized)

**6.2 Add Firestore Extensions**
Create `Extensions/Firestore+Extensions.swift`:
- Extension methods to convert between model objects and Firestore documents
- `DocumentSnapshot` to model conversions
- Model to dictionary conversions

---

### Phase 7: View Updates

**7.1 Update View Instantiation**

Modify views to handle async data loading:

**MealPlannerView.swift:**
- Add `.task { }` modifier to fetch meal plans on appear
- Add loading state UI
- Handle errors gracefully
- Convert method calls from sync to async using `Task { }`

**SocialFeedView.swift:**
- Add `.task { }` modifier to fetch social feed
- Add loading state UI
- Add pull-to-refresh
- Handle errors gracefully

**CreatePostView.swift:**
- Update to use `StorageService` for image upload
- Show upload progress
- Handle upload errors

**7.2 Add Loading States**
Create `Views/Components/LoadingView.swift`:
- Reusable loading spinner component
- Error state display
- Empty state display

**7.3 Add User Discovery**
Create new files:
- `Views/SocialFeed/UserSearchView.swift` - Search and follow users
- `Views/SocialFeed/UserProfileView.swift` - View user profiles
- `Views/SocialFeed/FollowersListView.swift` - View followers/following

---

### Phase 8: Error Handling & Loading States

**8.1 Create Error Types**
Create `Models/AppError.swift`:
```swift
enum AppError: LocalizedError {
    case authenticationFailed(String)
    case firestoreError(String)
    case storageError(String)
    case networkError
    // etc.
}
```

**8.2 Add Error Handling UI**
- Toast/alert for errors
- Retry mechanisms
- Offline state detection

---

### Phase 9: Testing & Migration

**9.1 Keep MockDataService**
- Rename to `MockDataService.swift` (keep for previews)
- Create protocol `DataServiceProtocol`
- Both `MockDataService` and `FirebaseDataService` conform
- Use mock for SwiftUI previews
- Use Firebase for production

**9.2 Environment Switching**
Update `PlatedApp.swift`:
```swift
#if DEBUG
@StateObject private var dataService = MockDataService() // For previews
#else
@StateObject private var dataService = FirebaseDataService()
#endif
```

---

### Phase 10: Security Rules & Deployment

**10.1 Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Meal plans are private
    match /mealPlans/{planId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }

    // Social posts visible to followers
    match /socialPosts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == request.resource.data.authorId;
      allow update, delete: if request.auth.uid == resource.data.authorId;
    }
  }
}
```

**10.2 Storage Security Rules**
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

---

## Critical Files to Create

**New Files:**
1. `Services/AuthenticationService.swift` - Auth management
2. `Services/FirebaseDataService.swift` - Firebase data operations
3. `Services/StorageService.swift` - Image upload/download
4. `Views/Authentication/AuthenticationView.swift` - Auth container
5. `Views/Authentication/SignInView.swift` - Sign in form
6. `Views/Authentication/SignUpView.swift` - Sign up form
7. `Views/Authentication/ForgotPasswordView.swift` - Password reset
8. `Views/Components/LoadingView.swift` - Loading states
9. `Views/SocialFeed/UserSearchView.swift` - Find users
10. `Models/AppError.swift` - Error types
11. `Extensions/Firestore+Extensions.swift` - Firestore helpers

**Files to Modify:**
1. `PlatedApp.swift` - Firebase init, auth state check
2. `Models/User.swift` - Add email, followers, following
3. `Models/SocialPost.swift` - Change to use IDs instead of objects
4. `Models/MealPlan.swift` - Add userId, updatedAt
5. `Views/MealPlanner/MealPlannerView.swift` - Async data loading
6. `Views/SocialFeed/SocialFeedView.swift` - Async data loading
7. `Views/SocialFeed/CreatePostView.swift` - Image upload

**Files to Keep (for previews):**
1. `Services/MockDataService.swift` - Rename if needed

---

## Implementation Order

1. **Phase 1:** Firebase SDK setup (15 min)
2. **Phase 2:** Authentication system (2 hours)
3. **Phase 3:** Update models for Firebase (30 min)
4. **Phase 4:** Storage service for images (1 hour)
5. **Phase 5:** FirebaseDataService implementation (3 hours)
6. **Phase 6:** Update existing views for async (2 hours)
7. **Phase 7:** Add loading/error states (1 hour)
8. **Phase 8:** User discovery features (2 hours)
9. **Phase 9:** Security rules (30 min)
10. **Phase 10:** Testing & refinement (ongoing)

**Total estimated time:** ~12-15 hours

---

## Key Architectural Decisions

### Why Not Use Protocol for DataService?
**Decision:** Create protocol `DataServiceProtocol` that both Mock and Firebase services conform to
**Reason:** Allows SwiftUI previews to use mock data while production uses Firebase

### Why Denormalize Author Data in Posts?
**Decision:** Store `authorName` and `authorProfileImageUrl` directly in posts
**Reason:** Reduces Firestore reads, improves feed performance (trade-off: data duplication)

### Why Use Listeners Instead of One-Time Fetches?
**Decision:** Implement real-time listeners for meal plans and social feed
**Reason:** User requested real-time sync, provides better UX

### Why Keep Comments as Subcollection?
**Decision:** Store comments in subcollection instead of array
**Reason:** Scalability - posts can have unlimited comments without document size limits

---

## Potential Challenges

1. **Async/Await Conversion:** Views currently expect synchronous data
   - **Solution:** Use `.task { }` modifiers and `@State` for loading

2. **Image Upload Performance:** Large images slow down post creation
   - **Solution:** Compress images before upload, show progress indicator

3. **Query Performance:** Fetching posts from all followed users
   - **Solution:** Denormalize data, use Firestore query limits, implement pagination

4. **Offline Support:** App should work offline
   - **Solution:** Firebase provides automatic offline persistence

5. **Cost Management:** Firestore charges per read/write
   - **Solution:** Use listeners instead of polling, implement query limits

---

## Success Criteria

- ✅ Users can sign in with Google
- ✅ Users stay authenticated across app restarts
- ✅ Meal plans sync across devices in real-time
- ✅ Social posts appear in feed from followed users
- ✅ Images upload to Firebase Storage
- ✅ App works offline (reads cached data)
- ✅ Security rules prevent unauthorized access
- ✅ No data loss during migration
