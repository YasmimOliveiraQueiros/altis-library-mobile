# altis_library_mobile

A new Flutter project.

## API configuration

Copy `.env.example` to `.env` and set `API_BASE_URL` to an address reachable
from the device. The example uses `http://10.0.2.2:8080`, which reaches the host
machine from the default Android emulator. On a physical device, use the
development machine's reachable network address instead. Build-time defines
are included in the application, so do not put passwords, tokens, private keys,
or other secrets in this file.

Run the app with:

```sh
flutter run --dart-define-from-file=.env
```

The included VS Code launch configuration passes the same define automatically.

## Account registration

The mobile registration form is available, but account creation is disabled
until the API provides a confirmed public registration endpoint. The current
OpenAPI contract documents `POST /users` as requiring Bearer authentication;
the app does not send registration data to that protected endpoint or attempt
to create an account.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
