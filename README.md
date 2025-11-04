# BookSwap - Student Book Exchange Platform

A Flutter application for students to exchange books with each other. Features real book data integration with Google Books API, making it easy to find and share books with accurate information and official cover images.

## Key Features

### Google Books API Integration
- Search for real books by title, author, or ISBN
- Automatic population of book details:
  - Official book covers
  - Accurate author names
  - Publisher information
  - Publication dates
  - ISBN numbers
- No manual data entry needed
- Professional appearance with verified book data

### Core Functionality
- **Browse Listings**: Discover books available for swap with real covers and details
- **Smart Book Search**: Search Google's book database when posting
- **Post Books**: Select from real books and add condition/swap preferences
- **Chat System**: Communicate with other students to arrange swaps
- **My Listings**: Manage all your posted books with swipe-to-delete
- **User Profile**: Customize settings and manage your account

## Technical Implementation

### Book Search Flow
1. Tap "Post" or "+" button
2. Search for a book by title, author, or ISBN
3. Select from real Google Books results
4. Book details auto-fill (title, author, cover, publisher, ISBN)
5. Choose condition (New, Like New, Good, Used)
6. Optional: Add swap preferences
7. Post to the marketplace

### Architecture
- Clean, organized code structure following DRY principles
- Centralized theme configuration
- Reusable widget components
- Google Books API service layer
- Image caching for smooth performance
- Material Design 3 with custom color scheme (Navy #1E1E3F + Gold #FFB800)

## Project Structure

```
lib/
├── config/
│   ├── app_theme.dart          # Theme configuration
│   └── constants.dart          # App constants
├── models/
│   ├── book.dart               # Book data model (with ISBN, publisher, etc.)
│   └── chat.dart               # Chat/message models
├── screens/
│   ├── splash_screen.dart      # Welcome screen
│   ├── main_navigation.dart    # Navigation controller
│   ├── home_screen.dart        # Browse books
│   ├── book_search_screen.dart # Google Books search
│   ├── post_book_screen.dart   # Post new books
│   ├── my_listings_screen.dart # User's books
│   ├── chats_screen.dart       # Conversations list
│   ├── chat_detail_screen.dart # Chat view
│   └── profile_screen.dart     # Settings
├── services/
│   └── google_books_service.dart # Google Books API integration
├── widgets/
│   ├── book_card.dart          # Book display card with cached images
│   ├── custom_bottom_nav_bar.dart  # Navigation bar
│   └── custom_text_field.dart  # Form inputs
└── main.dart                   # Entry point
```

## Getting Started

Clone the repository:
```bash
git clone <your-repo-url>
cd bookswap_app
```

Install dependencies:
```bash
flutter pub get
```

Run the app:
```bash
flutter run
```

## Built With

- Flutter - UI framework
- Dart - Programming language  
- Material Design 3 - Design system
- Google Books API - Real book data
- http package - API requests
- cached_network_image - Image caching and performance

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  cached_network_image: ^3.3.0
```

## Code Quality

### DRY Principle
The codebase avoids repetition by:
- Centralizing theme colors and text styles in `app_theme.dart`
- Creating reusable widgets like `BookCard` and `CustomTextField`
- Using models for consistent data structures
- Extracting common UI patterns into separate widgets
- Single source of truth for book data via Google Books API

### Best Practices
- State management with StatefulWidget
- Proper disposal of controllers
- Null-safety throughout
- Form validation and error handling
- Image caching for performance
- Graceful error handling for API calls
- Clean separation of concerns (services, models, UI)

## Google Books API

The app uses the Google Books API v1 for:
- Searching books by title, author, or ISBN
- Fetching book metadata (publisher, publish date, descriptions)
- Loading official book cover images
- Getting ISBN numbers for verification

**Endpoint**: `https://www.googleapis.com/books/v1/volumes`

**No API key required** for basic read-only access (up to 1,000 requests/day)

## Sample Books

The app includes sample listings to demonstrate the Google Books integration:
- The Great Gatsby by F. Scott Fitzgerald
- 1984 by George Orwell
- To Kill a Mockingbird by Harper Lee
- Harry Potter and the Philosopher's Stone by J.K. Rowling
- The Catcher in the Rye by J.D. Salinger

All with real covers, ISBNs, and publisher information from Google Books.

## Future Enhancements

- Backend integration (Firebase/REST API)
- User authentication and profiles
- Real-time chat functionality
- Image upload for book condition photos
- Advanced search filters (genre, year, condition)
- Push notifications for messages
- Rating and review system
- Location-based matching
- ISBN barcode scanner
- Book recommendations

## What Makes This Different

Unlike typical student projects that use placeholder data, this app integrates with a real API to provide:
- Verified book information
- Professional book covers
- Accurate metadata (ISBN, publisher, dates)
- Better user experience
- Production-ready architecture

This demonstrates understanding of:
- RESTful API consumption
- Asynchronous programming
- JSON parsing
- Error handling
- Image caching strategies
- Clean code architecture

## Contributing

Contributions are welcome. Please submit a Pull Request.

## License

This project is licensed under the MIT License.

## Author

Samuel Mwania
