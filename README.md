# Predictable Revenue Task Manager

A mobile application built with Flutter and Firebase to help sales and marketing teams manage recurring tasks, track pipeline activity, and streamline handoff processes.

## Features

### 🚀 Pipeline Activity Tracker
*   **Daily Metrics Logging**: Track key sales activities like Calls, Connects, and Meetings Booked.
*   **Performance Dashboard**: Visualize daily progress and historical conversion rates.
*   **Leaderboards**: Compete with team members on weekly activity metrics.

### 📋 Handoff Checklists
*   **Standardized Handover**: Ensure critical steps are followed when handing off leads (e.g., SDR to AE).
*   **Customizable Templates**: Create and edit checklist templates tailored to your team's process.
*   **History**: Review past handoffs for audit and training purposes.

### ✅ Recurring Task Management
*   **Team Tasks**: Create daily, weekly, or monthly recurring tasks for the entire team.
*   **Active/Inactive Toggle**: Managers can easily pause or activate tasks as priorities shift.
*   **Completion Tracking**: Mark tasks as complete, skipped, or partially done with notes.

## Tech Stack

*   **Frontend**: Flutter (Dart)
*   **Backend**: Firebase (Auth, Firestore)
*   **State Management**: Provider
*   **Charts**: fl_chart

## Getting Started

### Prerequisites
*   Flutter SDK
*   Firebase CLI (`flutterfire`)

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/onepiece92/predictable-todo.git
    cd predictable-todo
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase:**
    This project relies on Firebase. You must configure it with your own project:
    ```bash
    flutterfire configure
    ```
    Follow the prompts to select your project and platforms (iOS, Android). This will generate `lib/firebase_options.dart`.

4.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

```
lib/
├── core/            # Shared services (Firebase), themes, and utilities
├── features/        # Feature-based organization (Auth, Tasks, Stats, Handoffs)
├── models/          # Data models (User, Team, Task, PipelineMetric)
└── main.dart        # App entry point
```

## Contributing

1.  Fork the repository
2.  Create your feature branch (`git checkout -b feature/amazing-feature`)
3.  Commit your changes (`git commit -m 'Add some amazing feature'`)
4.  Push to the branch (`git push origin feature/amazing-feature`)
5.  Open a Pull Request
