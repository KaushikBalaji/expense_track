# Flutter Expense Tracker App

## Overview
The **Flutter Expense Tracker App** is a mobile application built using Flutter to help users track and manage their expenses. The app allows users to enter expense details, view them grouped by month, and delete entries as needed. The app features expandable sections for each month, dynamic entry cards, and a clean, responsive design.

This project is aimed at providing an easy way for users to track their daily or monthly expenses and gain insights into their spending habits.

## Features
- **Group Expenses by Month**: Expenses are grouped and displayed by month, providing a clear overview of the user's spending habits over time.
- **Expandable Month Sections**: Users can expand or collapse the list of expenses by month to easily navigate through their entries.
- **Dynamic Entry Cards**: Each expense is displayed in a dynamic card with details such as date, amount, category, and description.
- **Delete Entries**: Users can delete individual expense entries from the list.

## Tech Stack
- **Flutter**: Framework used to build cross-platform mobile apps.
- **Dart**: Programming language used for Flutter development.
- **Stateful Widgets**: Used for managing dynamic content, such as the expanding/collapsing sections and entry deletion.

## Screenshots
Below are some screenshots of the app in action:

### Main Screen
![Main Screen](https://github.com/user-attachments/assets/d3a6f360-4fdb-44b2-a4c8-489d59242361)

### Expense Grouping by Month
![Grouped by Month](https://github.com/user-attachments/assets/4ab24343-243e-42f2-9d7b-baf3bfea5954)

### Expanding/Collapsing Month Sections
![Expanding Month Section](https://github.com/user-attachments/assets/7e79fa8e-c192-4a2d-b848-82680389f949)

### Entry Card Example
![Entry Card](https://github.com/user-attachments/assets/443be332-6d0e-4b45-8424-f1199b7fa515)

## Setup Instructions

### Prerequisites
Before running the app, make sure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) on your system.
- [Dart](https://dart.dev/get-dart) (installed automatically with Flutter).
- An editor such as [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
- [Android emulator](https://developer.android.com/studio/run/emulator) or a physical device for testing the app.

### Steps to Run the App
1. **Clone the Repository**  
   Clone this repository to your local machine:
   ```bash
   git clone https://github.com/your-username/flutter-expense-tracker.git
   
2. **Navigate to the Project Directory**  
   Once the repository is cloned, navigate into the project directory:
   ```bash
   cd flutter-expense-tracker
   
3. **Install Dependencies**  
   Run the following command to install all the required dependencies:
   ```bash
   flutter pub get
   
4. **Navigate to the Project Directory**  
   To run the app, use the following command:
   ```bash
   cd flutter-expense-tracker
   
5. **Test the App**  
   After running the app, test its functionality by entering expenses, expanding/collapsing month sections, and deleting entries.


## Features to Implement
- Search Functionality: Allow users to search for specific entries by amount or description.
- Category Filter: Users can filter entries by categories like "Food", "Transport", etc.
- User Authentication: Add user authentication with Firebase to store and sync entries across devices.
- Charts/Analytics: Visualize spending patterns using charts for better insights.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements
- [Flutter](https://flutter.dev/docs/get-started/install) - The open-source UI toolkit for building natively compiled applications.
- [Dart](https://dart.dev/get-dart) - Programming language for Flutter.
