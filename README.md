# Cinema UI — Flutter

This project recreates the mobile cinema UI shown in the supplied reference video.

## Included
- Now Playing home screen
- Animated movie poster carousel
- Movie details screen
- Cast cards
- Cinema seat-selection screen
- Interactive seat selection
- Date/session selector
- Dynamic ticket total
- Dark cinematic styling
- Bottom navigation
- Page transitions
- Local reference assets cropped from the supplied video

## Run

```bash
flutter pub get
flutter run
```

For Chrome:

```bash
flutter run -d chrome
```

For Android:

```bash
flutter run -d android
```

No third-party Flutter packages are required.


## Added authentication flow

Startup is now:

Splash Screen → 3-screen Onboarding → Auth Choice → Login / Sign Up → Mock OTP → Home

The OTP is intentionally mock-only. Any 4-digit code is accepted and no Firebase/SMS service is used.


## New mock sections and notifications

Added:
- Coming Soon page with mock movies
- Tomorrow page with mock movies
- Notifications page with an in-app real-time stream
- Buying a ticket instantly creates a booking notification
- Profile page with mock name, phone number, ticket count, and Sign Out
- Sign Out returns to the authentication screen

### Important: phone notifications
The current implementation is intentionally **mock/in-app only**. It updates the Notifications screen immediately while the app is running.

It does **not** yet display an Android/iOS system push notification on the phone. Real phone notifications require a notification plugin (for example Firebase Cloud Messaging + local notifications) and platform configuration. This can be connected later without changing the UI flow.
