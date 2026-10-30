# My Little Tower

## About

My Little Tower is a productivity app designed to help users build healthier screen-time habits through a simple tower-building system.

The idea is straightforward: every day, users work toward a screen-time goal. When they meet their goal, they earn a new floor for their tower. Over time, the tower becomes a visual record of their consistency and progress.

Rather than relying on statistics alone, My Little Tower gives users something they can build and maintain through their daily habits.

## Features

- **Daily Screen-Time Tracking:** Tracks interactive screen-on time using Android screen-on and screen-off events.
- **Personalized Goals:** Allows users to set a daily screen-time goal.
- **Tower Building:** Earn a new floor by meeting your daily goal.
- **Tower Collapse:** If the daily goal is exceeded, the tower collapses, giving users an opportunity to start rebuilding.
- **Daily Journal:** Record your feelings and write a short reflection for each day.
- **Tower Reconstruction:** Provides an option to restore a fallen tower through an in-app purchase flow.

## Getting Started

### Installation

1. Download the provided Android APK.
2. Install the APK on an Android device.
3. Open My Little Tower.
4. Follow the initial setup instructions.

### Required Permission

My Little Tower requires Android's Usage Access permission to retrieve screen-time information.

To enable it:

1. Open the app and follow the permission prompt.
2. Find My Little Tower in the Usage Access settings.
3. Enable Usage Access.
4. Return to the app.

Without this permission, the app cannot retrieve the device's screen-time information.

## How to Use

1. **Set Your Goal:** Choose a daily screen-time goal during the initial setup.
2. **Track Your Progress:** Check your screen time and see how close you are to your daily goal.
3. **Build Your Tower:** Meet your daily goal to preserve your progress and earn another floor.
4. **Write in Your Journal:** Tap the corresponding floor to record your feelings and thoughts for the day.
5. **Rebuild:** If your tower falls, use the reconstruction feature to restore it.

## Technology

My Little Tower was developed using:

- Flutter and Dart for the application interface and functionality.
- Kotlin for Android-specific screen-time tracking.
- SharedPreferences for local data storage.
- RevenueCat for the tower reconstruction purchase flow.

## Notes

- Screen-time tracking requires an Android device with Usage Access enabled.
- Screen-time calculations use Android's screen-interactive and screen-non-interactive events.
- The app's reporting day begins at 6:00 AM.
- The reconstruction purchase flow uses the RevenueCat Test Store during testing. No real payment is required in the test environment.

## Submitted to

Developed as a project for the Congressional App Challenge.