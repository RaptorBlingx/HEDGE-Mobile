# Backend Integration

HEDGE ExpertAI Mobile is a separate Flutter project that consumes the HEDGE
backend over the gateway API.

## Repositories

- Mobile client: `/home/ubuntu/HEDGE-Mobile`
- Backend services and gateway: `/home/ubuntu/hedge`

This separation is intentional. The mobile app should remain a thin client with
its own release cycle, while the HEDGE repository continues to own search,
recommendation, ingestion, and gateway behavior.

## Integration boundary

The mobile app should call the HEDGE gateway, not the internal services
directly. That keeps the mobile client aligned with the same contract used by
the current frontend and widget.

Current client integration points:

- `GET /api/v1/catalog/apps`
- `POST /api/v1/chat`
- `POST /api/v1/feedback`

Planned next integration point:

- `POST /api/v1/chat/stream`

## Client responsibilities

- Present a mobile-first discovery experience
- Send user intent to the HEDGE chat endpoint
- Render recommended apps and metadata returned by the gateway
- Persist local mobile state such as saved apps and client preferences

## Backend responsibilities

- Maintain app catalog freshness and ranking logic
- Execute conversational recommendation flow
- Enforce security, routing, and API stability at the gateway
- Record user feedback and sessions

## Local development notes

- Preferred Android device workflow: `adb reverse tcp:8080 tcp:80`, then use `http://127.0.0.1:8080` in the app.
- Android emulator should use `http://10.0.2.2:8080` to reach a gateway running on the host.
- iOS Simulator and desktop Flutter runs can use `http://localhost` when the backend is exposed locally.
- Direct LAN access is possible, but the current Nginx setup redirects HTTP to a self-signed HTTPS endpoint, which is inconvenient for debug builds on real phones.

## Contract guidance

- Keep the mobile app dependent on gateway DTOs only.
- Avoid importing or copying backend business logic into the Flutter app.
- Prefer additive endpoint changes in the HEDGE gateway so the mobile client can
  evolve without coupling to internal service details.