# WizDesk

> **A modern productivity dashboard built with Flutter to help you organize tasks, manage your time, stay focused, and understand your productivity through analytics.**

WizDesk is a cross-platform productivity application designed to bring essential productivity tools together in one clean and intuitive workspace.

The application combines **task management, focus sessions, calendar planning and productivity analytics** into a unified dashboard experience.

---

## ✨ Features

### 📋 Task Management

* Create and manage tasks
* Organize tasks according to their status and priority
* Track task progress
* View upcoming and completed tasks
* Designed for quick day-to-day task management

### 🎯 Focus Mode

* Dedicated focus workspace
* Helps users concentrate on individual tasks
* Designed around focused work sessions
* Minimizes distractions while working

### 📅 Calendar

* Organize and view scheduled activities
* Keep tasks and plans aligned with your schedule
* Calendar-focused presentation for easier planning

### 📊 Productivity Analytics

* Visualize productivity data
* Track productivity trends
* Analytics dashboard with charts and statistics
* Uses interactive charts to make productivity data easier to understand

### ⚙️ Settings

* Centralized application settings
* Manage application preferences
* Dedicated settings architecture for future extensibility

### 🧭 Unified Navigation

* Central navigation system connecting the application's major features
* Consistent navigation experience across the application

---


## 🧠 State Management

WizDesk uses **BLoC (`flutter_bloc`)** for state management.

The application separates UI from application logic by managing state through BLoC-based components.

This provides:

* Predictable state transitions
* Separation of presentation and business logic
* Easier testing
* Better scalability as features grow

---

## 💉 Dependency Injection

The project uses **GetIt** for dependency injection.

Dependencies can be registered centrally and accessed where required instead of creating tightly coupled dependencies throughout the application.

This helps with:

* Loose coupling
* Testability
* Maintainability
* Managing shared services and repositories

---

## 💾 Local Storage

WizDesk uses local persistence technologies including:

* **Hive**
* **Hive Flutter**
* **SharedPreferences**

These provide support for storing application data and user preferences locally.

---

## 📱 Responsive UI

The application uses **Flutter ScreenUtil** for responsive sizing and layout adaptation.

This allows UI dimensions to scale more consistently across different screen sizes and resolutions.

---

## 🎨 UI & Design

The application uses:

* Flutter Material components
* Google Fonts
* Custom application theme
* Reusable widgets
* Responsive sizing

The application assets, including the WizDesk logo, are maintained under:


---

## 📈 Charts & Analytics

Productivity analytics are implemented using **FL Chart**.

Charts can be used to represent productivity-related information in a visual format, making trends and performance easier to understand.

---

## 🛠️ Tech Stack

| Technology             | Purpose                              |
| ---------------------- | ------------------------------------ |
| **Flutter**            | Cross-platform application framework |
| **Dart**               | Programming language                 |
| **flutter_bloc**       | State management                     |
| **Equatable**          | Value equality for states/models     |
| **GetIt**              | Dependency injection                 |
| **Hive**               | Local database/storage               |
| **SharedPreferences**  | Local preferences                    |
| **Flutter ScreenUtil** | Responsive UI                        |
| **Google Fonts**       | Typography                           |
| **FL Chart**           | Analytics and charts                 |
| **Intl**               | Internationalization/date formatting |
| **UUID**               | Unique identifier generation         |

The current project configuration targets Dart SDK `^3.12.0`.

---

## 🗺️ Roadmap

Potential future improvements include:

* [ ] Cloud synchronization
* [ ] Cross-device task synchronization
* [ ] Notifications and reminders
* [ ] Advanced productivity analytics
* [ ] More focus-session customization
* [ ] Dark/light theme customization
* [ ] Cloud backup and restore

---

## 👨‍💻 Author

**Ansh Lowanshi**

GitHub:
https://github.com/ansh-lowanshi

---

## ⭐ Support

If you find WizDesk useful or interesting, consider giving the repository a ⭐ on GitHub.

**Repository:**
https://github.com/ansh-lowanshi/WizDesk
