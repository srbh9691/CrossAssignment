# Task List Flutter App with Back4App Integration
 
## Overview
This Flutter application is a simple task manager that allows users to create, update, delete, and view tasks using Back4App as the backend.
 
## Prerequisites
- Flutter SDK installed: [Flutter Install Guide](https://flutter.dev/docs/get-started/install)
- Back4App Account: [Back4App Sign Up](https://www.back4app.com/)
- Text Editor or IDE (e.g., Visual Studio Code, Android Studio)
 
## Getting Started
### 1. Create Classes in Back4App:
- **TaskList**
    - **Title:** Required field of type String
    - **Description:** Required field of type String
    - **Done:** Not a required field of type Boolean
- **VehicleManagement**
    - **OwnerName:** Required field of type String
    - **RegistrationNumber:** Required field of type String
    - **Make:** Required field of type String
    - **Model:** Not a required field of type String
 
### 2. Clone the Repository:
```bash
git clone https://github.com/srbh9691/CrossAssignment.git
cd CrossAssignment.
```
 
### 3. Install Dependencies:
```bash
flutter pub get
```
 
### 4. Configuration:
- Open `lib/main.dart`.
- Update the ApiConstants class with your Back4App details (backendBaseUrl, yourClassName, yourAppId, yourRestApiKey).
 
### 5. Run the Application:
- Launch your device or emulator.
- Run the app using Flutter CLI: `flutter run`
 
### 6. Usage:
- The app opens with a list of tasks retrieved from Back4App backend.
- Add tasks using the floating action button (+).
- Tap on a task to view details.
- Edit or delete tasks using the respective icons in each task.
- Long press on any task to edit it.
- Mark All task as done / pending using global checkbox.