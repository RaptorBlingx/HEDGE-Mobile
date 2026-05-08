# HEDGE ExpertAI Mobile

HEDGE ExpertAI Mobile is a standalone Flutter client for the HEDGE-ExpertAI
backend. It is intentionally split from the main HEDGE repository so the mobile
app can evolve as its own product and release cycle while still consuming the
existing backend APIs.

The app talks to the HEDGE backend over HTTP through the gateway service in the
main project. The mobile client does not embed backend code; it reads the app
catalog, sends chat requests, and submits recommendation feedback to the HEDGE
gateway.

## Repository split

- Mobile project repo: this repository
- Backend repo: `/home/ubuntu/hedge`
- Communication boundary: HEDGE gateway REST endpoints

The current mobile implementation already uses that boundary in
`lib/src/services/hedge_api_client.dart` and the app-level state controller in
`lib/src/state/app_controller.dart`.

## Backend communication

The mobile client currently depends on these gateway endpoints:

- `GET /api/v1/catalog/apps`
- `POST /api/v1/chat`
- `POST /api/v1/feedback`

Next step in the app: add `POST /api/v1/chat/stream` support so the mobile app
can consume the same streaming experience as the web client.

The Android platform files are now generated in this repository. iOS can be
added later with:

```bash
cd /home/ubuntu/HEDGE-Mobile
flutter create . --platforms=ios
flutter pub get
```

Flutter-generated platform folders belong in this repository and should be
committed. They are not ignored here.

## Running against HEDGE backend

For Android development on a wireless-debugged physical device, use ADB reverse
so the app can reach the HEDGE backend through the debug connection:

```bash
adb reverse tcp:8080 tcp:80
adb reverse --list
```

With that in place, the app's default Android development URL is
`http://127.0.0.1:8080`, which is forwarded to the server's port `80`.

You can still override the backend URL explicitly when needed:

```bash
flutter run --dart-define=HEDGE_API_BASE_URL=http://127.0.0.1:8080
```

For an Android emulator, use `http://10.0.2.2:8080`. For iOS Simulator or
desktop Flutter runs, use `http://localhost` if the backend is exposed locally.

If you prefer direct LAN access instead of ADB reverse, point the app to the
reachable gateway base URL in the in-app Settings screen or via
`--dart-define`. In the current server setup, plain HTTP on port `80` redirects
to a self-signed HTTPS endpoint, so ADB reverse is the smoother development
path.

## Current status

- Discover screen with chat-first recommendation flow
- Browse screen with local filtering over the HEDGE catalog
- App detail screen with metadata and "Ask AI" handoff
- Saved screen for shortlisting apps
- Settings screen with configurable gateway base URL
- Android wireless debugging workflow validated with `adb reverse`

See `docs/backend-integration.md` for the current integration contract.

