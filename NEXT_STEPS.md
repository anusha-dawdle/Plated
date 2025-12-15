# Next Steps for Plated

## 🔴 CURRENT SESSION STATUS (December 15, 2025)

### ✅ Completed This Session
1. **Fixed User ID Type Mismatch**
   - Changed `User.id` from `UUID` to `String` to match Firebase Auth UID
   - Updated all code references (`user.id.uuidString` → `user.id`)
   - Fixed AuthenticationService to use Firebase UID directly
   - Fixed profile username loading issue

2. **Updated Firebase Storage Structure**
   - Changed from flat structure to subdirectories:
     - Profile images: `profileImages/{userId}/avatar.jpg`
     - Post images: `postImages/{postId}/image.jpg`
   - Updated StorageService.swift accordingly
   - Published correct Storage security rules

3. **Created Required Firestore Indexes**
   - ✅ `followRequests`: Compound index (status, toUserId, createdAt) - **Enabled**
   - ✅ `socialPosts`: Compound index (authorId, createdAt) - **Enabled**

4. **Updated Firestore Security Rules**
   - Published rules with `onlyUpdating()` helper function
   - Added support for followers/following updates across users
   - Added support for reactions/comments updates on posts
   - Fixed mealPlans create vs read/update/delete rules

5. **Manual Data Fixes**
   - Manually updated following/followers arrays for both test accounts in Firestore

### ❌ Still Broken (Stopping Point)
1. **Firestore Permission Errors** - All queries failing with "Missing or insufficient permissions":
   - `mealPlans` listener failing
   - `followRequests` listener failing
   - `socialPosts` listener failing

2. **Reactions Not Working**
   - Clicking emoji reactions does nothing
   - No updates written to Firestore
   - Console shows: `Write at socialPosts/{id} failed: Missing or insufficient permissions`

3. **Comments Not Working**
   - Adding comments doesn't work
   - Same permission errors as reactions

### 🔍 Next Steps to Debug (When Resuming)
1. **Verify Authentication State**
   - Check if user is actually signed in (Settings tab should show profile)
   - Sign out and sign back in to refresh auth token
   - Force-quit and relaunch app

2. **Test Firestore Rules in Simulator**
   - Firebase Console → Firestore → Rules → Simulator tab
   - Test read operation on `socialPosts` collection
   - Verify if rules allow authenticated reads
   - Check for runtime errors in `onlyUpdating()` function

3. **Compare Published vs Draft Rules**
   - Ensure "Published" version matches what was intended
   - Check for any discrepancies between tabs

4. **Potential Root Causes to Investigate**
   - Auth token might be expired/invalid
   - Rules might have runtime errors (check Firebase Console logs)
   - Mismatch between query structure and security rules
   - Caching issue with rules propagation

### 📝 Current Firestore Rules (What Should Be Published)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function onlyUpdating(fields) {
      return request.resource.data
        .diff(resource.data)
        .affectedKeys()
        .hasOnly(fields);
    }

    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null
        && (request.auth.uid == userId
            || onlyUpdating(['followers', 'following']));
      allow delete: if request.auth != null && request.auth.uid == userId;
    }

    match /mealPlans/{planId} {
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.userId;
      allow read, update, delete: if request.auth != null
        && request.auth.uid == resource.data.userId;
    }

    match /socialPosts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.authorId;
      allow update: if request.auth != null
        && (request.auth.uid == resource.data.authorId
            || onlyUpdating(['reactions', 'comments']));
      allow delete: if request.auth != null
        && request.auth.uid == resource.data.authorId;
    }

    match /followRequests/{requestId} {
      allow read: if request.auth != null
        && (request.auth.uid == resource.data.fromUserId
            || request.auth.uid == resource.data.toUserId);
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.fromUserId;
      allow update: if request.auth != null
        && request.auth.uid == resource.data.toUserId
        && onlyUpdating(['status']);
    }
  }
}
```

### 🧪 Test Accounts Created
- **Account 1**: anushagarg@ucsb.edu (username: "anusha")
  - Firebase UID: `3SAVDYw4Zad9tUi7FRYF8gfGh7t2`
  - Has 2 posts in Firestore
  - Manually set followers: `["sOB5sXBmoCTIwXwfK2LgJD9bNEE2"]`
  - Manually set following: `["sOB5sXBmoCTIwXwfK2LgJD9bNEE2"]`

- **Account 2**: anusha.modern@gmail.com (username: "agtest")
  - Firebase UID: `sOB5sXBmoCTIwXwfK2LgJD9bNEE2`
  - Has 1 post in Firestore
  - Manually set followers: `["3SAVDYw4Zad9tUi7FRYF8gfGh7t2"]`
  - Manually set following: `["3SAVDYw4Zad9tUi7FRYF8gfGh7t2"]`

---

## Previous Status (Before This Session)
✅ Firebase integration complete
✅ User management system implemented
✅ Follow system with requests working
✅ Private meal planning functional
✅ Followers-only social feed operational
✅ Documentation updated

---

## Immediate Testing (Priority 1)

### 1. Firebase Console Setup ⚠️
**Required before testing:**

Go to [Firebase Console](https://console.firebase.google.com) and verify:

**Storage:**
- Navigate to: Build → Storage
- Verify: Firebase Storage is enabled
- Should see: `profileImages/` and `postImages/` folders will appear after first upload

**Indexes:**
- These will be auto-created when you first use features
- When you see Firestore errors, click the link in the error to create the index
- Required indexes:
  - `followRequests`: Compound on `toUserId` (Asc), `status` (Asc), `createdAt` (Desc)
  - `users`: Single field on `username` (Asc)
  - `mealPlans`: Single field on `userId` (Asc)
  - `socialPosts`: Single field on `authorId` (Asc)

**Security Rules:**
- Firestore Rules: Should be deployed (check Firestore → Rules tab)
- Storage Rules: Should be deployed (check Storage → Rules tab)

---

### 2. Build & Test on Device 🧪

#### Test Plan: Complete User Journey

**Setup: Create Two Test Accounts**
- Use two different Google accounts
- Test account 1: Your primary account
- Test account 2: Friend/family member or secondary Google account

#### Test Account 1 - First User Experience

**Authentication & Onboarding:**
1. ✅ Launch app → Sign in with Google
2. ✅ Profile setup appears
3. ✅ Enter display name (e.g., "Alice")
4. ✅ Enter username (e.g., "alice_eats")
5. ✅ Upload profile picture from camera/library
6. ✅ Tap "Continue" → Should go to main app

**Initial App State (No Followers):**
1. ✅ Feed tab → Should only show your posts (empty if no posts yet)
2. ✅ Planner tab → Should be empty
3. ✅ Profile tab → Should show your name, username, 0 followers, 0 following
4. ✅ Settings tab → Should show your profile info

**Create First Post:**
1. ✅ Feed tab → Tap "+" button
2. ✅ Choose photo source (Camera or Library)
3. ✅ Select a photo
4. ✅ Enter caption (e.g., "My first meal!")
5. ✅ Select meal tag (Breakfast/Lunch/Dinner/Snack)
6. ✅ Tap "Post"
7. ✅ Wait for upload (progress indicator should appear)
8. ✅ Post should appear in feed

**Search for User (Will Create Later):**
1. ✅ Profile tab → Tap search icon (magnifying glass)
2. ✅ Enter username "bob_eats" (or whatever username you'll use for test account 2)
3. ✅ Should show "No users found" (account doesn't exist yet)

#### Test Account 2 - Second User Experience

**Sign Out & Switch Accounts:**
1. ✅ Settings tab → Sign Out
2. ✅ Sign in with different Google account

**Onboarding:**
1. ✅ Enter display name (e.g., "Bob")
2. ✅ Enter username (e.g., "bob_eats")
3. ✅ Upload different profile picture
4. ✅ Tap "Continue"

**Create Post:**
1. ✅ Feed tab → Create a post with photo and caption
2. ✅ Post appears in your feed
3. ✅ Note: Alice (test account 1) should NOT see this post yet

**Search & Follow Alice:**
1. ✅ Profile tab → Search icon
2. ✅ Search for "alice_eats"
3. ✅ Tap on Alice's profile
4. ✅ Should see Alice's profile with her post
5. ✅ Tap "Follow" button
6. ✅ Button should change to "Pending"
7. ✅ Should NOT be able to tap "Pending" (disabled)

#### Back to Test Account 1 - Accept Follow Request

**Sign Out & Switch Back:**
1. ✅ Sign out from Bob's account
2. ✅ Sign in with Alice's account

**Check Follow Request:**
1. ✅ Settings tab → Should show red badge on "Follow Requests"
2. ✅ Tap "Follow Requests"
3. ✅ Should see Bob's request with:
   - Bob's profile picture
   - Bob's name ("Bob")
   - Bob's username ("@bob_eats")
   - Accept (✓) and Reject (✗) buttons

**Accept Request:**
1. ✅ Tap Accept (✓)
2. ✅ Request should disappear from list
3. ✅ Badge on Settings should disappear

**Verify Feed:**
1. ✅ Feed tab → Should now see:
   - Your own posts (Alice's posts)
   - Bob's posts (because you accepted his request)
2. ✅ Posts should be in chronological order

**Interact with Bob's Post:**
1. ✅ Tap heart emoji → Should add reaction
2. ✅ Tap heart again → Should remove reaction
3. ✅ Try different emoji → Should replace previous reaction
4. ✅ Tap comment icon → Comment sheet opens
5. ✅ Your profile picture should appear in input area
6. ✅ Type a comment (e.g., "Looks delicious!")
7. ✅ Tap "Post"
8. ✅ Comment should appear with your profile picture

**Check Profile Stats:**
1. ✅ Profile tab → Should show:
   - 1 Follower (Bob)
   - 0 Following (you haven't followed anyone)

#### Test Account 2 - Verify Everything

**Switch to Bob Again:**
1. ✅ Sign out, sign in as Bob

**Check Follow Status:**
1. ✅ Profile tab → Search for Alice
2. ✅ Tap Alice's profile
3. ✅ Button should now say "Following" (not "Pending")
4. ✅ Tap "Following" → Should unfollow (optional test)
5. ✅ Button changes back to "Follow"

**Check Feed:**
1. ✅ Feed tab → Should show:
   - Your own posts (Bob's posts)
   - Alice's posts (because she accepted your follow request)

**Check Notifications on Alice's Post:**
1. ✅ Find Alice's post in feed
2. ✅ Should see Alice's comment on your post
3. ✅ Should see Alice's reaction

**Test Reactions & Comments:**
1. ✅ React to Alice's post
2. ✅ Comment on Alice's post
3. ✅ Your profile picture should appear in comment

---

### 3. Test Meal Planner 📅

**Basic Functionality:**
1. ✅ Planner tab → Select today's date
2. ✅ Tap "+" to add meal
3. ✅ Enter meal name (e.g., "Scrambled eggs")
4. ✅ Select multiple tags (e.g., Breakfast + Snack)
5. ✅ Tap "Add"
6. ✅ Meal should appear under both Breakfast and Snack sections

**Meal Completion:**
1. ✅ Tap checkbox next to meal
2. ✅ Should toggle instantly (NO flicker or reload)
3. ✅ Meal text should have strikethrough
4. ✅ Tap checkbox again to uncheck

**Meal Deletion:**
1. ✅ Swipe left on a meal
2. ✅ Tap "Delete"
3. ✅ Meal should disappear

**Date Switching:**
1. ✅ Change date to tomorrow
2. ✅ Add different meals
3. ✅ Switch back to today
4. ✅ Should see today's meals (not tomorrow's)

**Real-time Sync (if testing on multiple devices):**
1. ✅ Sign in on second device with same account
2. ✅ Add meal on device 1
3. ✅ Should appear on device 2 within 1-2 seconds

---

### 4. Known Issues to Watch For 🐛

#### Expected Limitations:
1. **10 User Follow Limit**
   - Feed only shows posts from first 10 users you follow
   - Reason: Firestore 'in' query limitation
   - Workaround: Unfollow users to see others' posts
   - Future fix: Implement fan-out feed architecture

2. **Username Uniqueness**
   - If username is taken, you'll see error: "This username is already taken"
   - Must choose a different username
   - Username cannot be changed after setup

3. **Image Loading Delay**
   - Profile pictures may take 1-2 seconds to load first time
   - Cached after first load
   - This is normal for Firebase Storage

4. **No Notifications**
   - Won't get notified of follow requests
   - Must manually check Settings tab
   - Future fix: Push notifications via FCM

#### Potential Bugs:
- ❌ If app crashes on sign in → Check GoogleService-Info.plist is in project
- ❌ If images don't upload → Check Firebase Storage is enabled in console
- ❌ If search doesn't work → Check Firestore index for `username` field exists
- ❌ If follow requests don't appear → Check Firestore compound index exists
- ❌ If feed is empty after accepting request → Check feed query in FirebaseDataService

---

## Future Enhancements (Priority 2)

### Quick Wins (1-2 hours each)

#### 1. Loading Indicators
**Where:** UserSearchView, ProfileView, UserProfileView
**Why:** Users don't know if search is running or profile is loading
**Implementation:**
- Add `@State private var isLoading = false`
- Show `ProgressView()` while fetching data
- Hide results until loaded

#### 2. Error Toasts
**Where:** All async operations (follow, post, comment, etc.)
**Why:** Errors fail silently, users don't know what went wrong
**Implementation:**
- Create `ToastView` component
- Show toast on error with message
- Auto-dismiss after 3 seconds

#### 3. Empty State Messages
**Where:** Feed when not following anyone, Profile when no posts
**Why:** Empty screens are confusing
**Implementation:**
- Already have empty states, but could improve messaging
- Add "Search for users to follow" button in feed empty state
- Add "Create your first post" button in profile empty state

#### 4. Confirmation Dialogs
**Where:** Unfollow action, delete meal, delete post
**Why:** Easy to accidentally tap
**Implementation:**
- Add `.confirmationDialog` modifier
- "Are you sure you want to unfollow [user]?"
- Cancel and Confirm buttons

#### 5. Pull to Refresh
**Where:** Social feed
**Why:** Users want to manually refresh feed
**Implementation:**
- Add `.refreshable { }` modifier to feed ScrollView
- Already using real-time listeners, but good UX

---

### Bigger Features (4+ hours each)

#### 1. Push Notifications 🔔
**Notify users when:**
- Someone sends follow request
- Someone accepts your follow request
- Someone comments on your post
- Someone reacts to your post

**Implementation:**
- Set up Firebase Cloud Messaging (FCM)
- Request notification permissions
- Store device tokens in Firestore
- Send notifications via Cloud Functions
- Handle notification taps

**Impact:** High - users will engage more with notifications

---

#### 2. Profile Editing ✏️
**Allow users to change:**
- Display name
- Profile picture
- Add bio field
- Add website/social links

**Implementation:**
- Create EditProfileView
- Add bio field to User model
- Update Firestore and all denormalized data
- Show edit button in Settings

**Impact:** Medium - nice to have but not critical

---

#### 3. User Blocking 🚫
**Allow users to:**
- Block users from following them
- Hide blocked users from search
- Remove blocked users from followers

**Implementation:**
- Add `blockedUsers: [String]` to User model
- Filter search results to exclude blocked users
- Reject follow requests from blocked users automatically
- Add "Block" button in UserProfileView

**Impact:** High - important for user safety

---

#### 4. Direct Messaging 💬
**Allow followers to:**
- Send private messages
- Real-time message updates
- Message threads
- Image sharing in messages

**Implementation:**
- Create `messages` collection in Firestore
- Create `conversations` collection for threads
- Create MessagesView, ConversationView, MessageInputView
- Add real-time listener for messages
- Add Messages tab or inbox icon

**Impact:** High - major feature addition

---

#### 5. Story-Style Posts 📸
**24-hour ephemeral posts:**
- Upload photo/video
- Visible for 24 hours only
- Shown in circular avatars at top of feed
- Tap to view full screen

**Implementation:**
- Create `stories` collection with `expiresAt` field
- Cloud Function to delete expired stories
- Create StoryView, StoryCreatorView
- Add story ring to profile pictures in feed

**Impact:** Medium - nice feature but complex

---

#### 6. Meal Templates & Favorites ⭐
**Allow users to:**
- Save meals as templates
- Quickly add favorite meals
- Copy meals to other dates
- Create weekly meal plans

**Implementation:**
- Create `mealTemplates` collection
- Add "Save as Template" button when adding meal
- Add "Templates" section in AddMealSheet
- Add "Copy to..." button in meal planner

**Impact:** High - very useful for meal planning

---

## Development Priorities

### Phase 1: Stability (Do First)
1. ✅ Test everything on device
2. ✅ Fix any critical bugs
3. ✅ Add basic error handling
4. ✅ Add loading indicators

### Phase 2: Safety (Do Second)
1. Push notifications for follow requests
2. User blocking feature
3. Report inappropriate content
4. Better error messages

### Phase 3: Engagement (Do Third)
1. Direct messaging
2. Story-style posts
3. Meal templates
4. Profile editing

### Phase 4: Polish (Do Fourth)
1. Dark mode
2. iPad optimization
3. Animations and transitions
4. Onboarding tutorial
5. Analytics

---

## Questions to Consider

### Product Direction:
1. **Primary use case:** Is this more of a meal planner or social network?
   - If meal planner: Focus on templates, recipes, grocery lists
   - If social network: Focus on messaging, stories, discovery

2. **Target audience:** Friends/family or public social network?
   - If friends/family: Focus on private groups, family meal planning
   - If public: Focus on discovery, trending meals, influencers

3. **Monetization:** Free or premium features?
   - Free tier: Basic meal planning + social features
   - Premium: Advanced recipes, nutritional tracking, ad-free

### Technical Decisions:
1. **Scalability:** How many users are you expecting?
   - Current architecture good for 1,000s of users
   - For 10,000+ users: Need fan-out feed, better caching
   - For 100,000+ users: Need CDN, database sharding

2. **Platform:** iOS only or expand to Android/Web?
   - iOS only: Keep current SwiftUI approach
   - Cross-platform: Consider React Native or Flutter

---

## Resources

### Firebase Documentation:
- [Cloud Messaging (Push Notifications)](https://firebase.google.com/docs/cloud-messaging)
- [Security Rules Best Practices](https://firebase.google.com/docs/rules/best-practices)
- [Firestore Query Optimization](https://firebase.google.com/docs/firestore/query-data/queries)
- [Storage Best Practices](https://firebase.google.com/docs/storage/best-practices)

### SwiftUI Resources:
- [AsyncImage Best Practices](https://developer.apple.com/documentation/swiftui/asyncimage)
- [Concurrency with Swift](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [App Architecture](https://developer.apple.com/documentation/swiftui/app-organization)

---

## Contact & Support

### Getting Help:
- **Firebase Issues:** Check Firebase Console → Support
- **Build Errors:** Clean build folder (Cmd+Shift+K), rebuild
- **SwiftUI Issues:** Check console logs for detailed errors
- **Firestore Queries:** Check Firebase Console → Firestore → Usage tab

### Useful Commands:
```bash
# Clean build
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset simulators
xcrun simctl erase all

# Check Firebase config
cat GoogleService-Info.plist

# View Firestore data
# Go to: Firebase Console → Firestore Database → Data tab
```

---

*Last Updated: December 14, 2025*
*Next Review: After device testing complete*
