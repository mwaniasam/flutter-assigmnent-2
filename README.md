# BookSwap - Student Book Exchange Platform

A Flutter application for students to exchange books with each other. Built with clean architecture and reusable components following the DRY (Don't Repeat Yourself) principle.

## Features

- **Browse Listings**: Discover books available for swap from other students
- **Post Books**: Share your books with the community
- **Chat System**: Communicate with other students to arrange swaps
- **My Listings**: Manage all your posted books
- **User Profile**: Customize settings and manage your account

## Technical Highlights

- Centralized theme configuration for consistent design
- Reusable widget components throughout the codebase
- Well-organized file structure with clear separation of concerns
- Responsive design that works across different screen sizes
- Smooth animations and transitions

## Project Structure

```
lib/
├── config/
│   ├── app_theme.dart          # Theme configuration
│   └── constants.dart          # App constants
├── models/
│   ├── book.dart               # Book data model
│   └── chat.dart               # Chat/message models
├── screens/
│   ├── splash_screen.dart      # Welcome screen
│   ├── main_navigation.dart    # Navigation controller
│   ├── home_screen.dart        # Browse books
│   ├── post_book_screen.dart   # Post new books
│   ├── my_listings_screen.dart # User's books
│   ├── chats_screen.dart       # Conversations list
│   ├── chat_detail_screen.dart # Chat view
│   └── profile_screen.dart     # Settings
├── widgets/
│   ├── book_card.dart          # Book display card
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

## Code Architecture

### DRY Principle
The codebase avoids repetition by:
- Centralizing theme colors and text styles in `app_theme.dart`
- Creating reusable widgets like `BookCard` and `CustomTextField`
- Using models for consistent data structures
- Extracting common UI patterns into separate widgets

### Best Practices
- State management with StatefulWidget
- Proper disposal of controllers
- Null-safety throughout
- Form validation and error handling

## Planned Features

- Backend integration (Firebase/REST API)
- User authentication
- Image upload for book covers
- Search and filters
- Push notifications
- Rating system
- Location-based matching

## Contributing

Contributions are welcome. Please submit a Pull Request.

## License

This project is licensed under the MIT License.

## Author

Samuel Mwania
