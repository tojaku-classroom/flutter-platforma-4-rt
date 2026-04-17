# Firebase Repository Layer Implementation

## 📁 Structure

```
lib/
├── data/
│   └── repositories/
│       ├── firestore_poll_repository.dart    # Poll & options with subcollections
│       └── firestore_vote_repository.dart    # Votes with atomic counting
├── providers/
│   ├── repository_providers.dart             # Repository & Firebase providers
│   └── poll_providers.dart                   # Stream providers for UI
└── services/
    └── auth_service.dart                     # Anonymous auth helper
```

## ✨ Key Features

### 1. Subcollections Pattern
- **Polls**: `polls/{pollId}`
- **Options**: `polls/{pollId}/options/{optionId}` (subcollection)
- **Votes**: `votes/{voteId}` (flat for efficient querying)

### 2. Real-time Streams
All data providers use Firestore snapshots for live updates:
- `activePollsProvider` - Stream of active polls
- `pollProvider(pollId)` - Stream of specific poll
- `pollOptionsProvider(pollId)` - Stream of poll options
- `pollVotesProvider(pollId)` - Stream of votes

### 3. Atomic Vote Counting
Vote operations use Firestore transactions to ensure consistency:
- Casting vote: Create vote doc + increment option count
- Changing vote: Update vote doc + adjust both option counts
- Removing vote: Delete vote doc + decrement option count

### 4. Anonymous Authentication
Users are automatically signed in anonymously on app start.

## 🔧 Usage Examples

### Creating a Poll
```dart
final pollRepo = ref.read(pollRepositoryProvider);
final userId = ref.read(currentUserIdProvider)!;

final pollId = await pollRepo.createPoll(
  title: 'Favorite Programming Language?',
  creatorId: userId,
  optionTexts: ['Dart', 'Kotlin', 'Swift', 'JavaScript'],
);
```

### Watching Active Polls
```dart
final pollsAsync = ref.watch(activePollsProvider);

pollsAsync.when(
  data: (polls) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### Casting a Vote
```dart
final voteRepo = ref.read(voteRepositoryProvider);
final userId = ref.read(currentUserIdProvider)!;

await voteRepo.castVote(
  pollId: pollId,
  optionId: selectedOptionId,
  userId: userId,
);
```

### Watching Poll Results in Real-time
```dart
final optionsAsync = ref.watch(pollOptionsProvider(pollId));

optionsAsync.when(
  data: (options) {
    for (final option in options) {
      print('${option.text}: ${option.voteCount} votes');
    }
  },
  loading: () => ...,
  error: (err, _) => ...,
);
```

## 🔐 Firestore Security Rules (Required)

Add these to Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Polls collection
    match /polls/{pollId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.creatorId;
      
      // Options subcollection
      match /options/{optionId} {
        allow read: if true;
        allow write: if request.auth.uid == get(/databases/$(database)/documents/polls/$(pollId)).data.creatorId;
      }
    }
    
    // Votes collection
    match /votes/{voteId} {
      allow read: if true;
      allow create: if request.auth != null 
                    && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## 🎯 Next Steps for Demo

1. **Create Poll List UI** (15-20 min)
   - Display active polls with real-time vote counts
   - Add "Create Poll" button

2. **Create Poll Detail/Vote UI** (15-20 min)
   - Show poll options with current vote counts
   - Enable voting with visual feedback
   - Show real-time updates as others vote

3. **Add Push Notifications** (optional, if time)
   - Notify when new polls are created
   - Notify when poll results change significantly

## 🧪 Testing the Implementation

Run the app and use Firebase Console to:
1. Verify anonymous auth works
2. Manually add test polls in Firestore
3. Watch real-time updates in the app
4. Test vote counting with multiple devices/tabs
