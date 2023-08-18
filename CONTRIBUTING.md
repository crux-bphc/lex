# Setup

- You need flutter installed on your system. You can follow the [official guide](https://docs.flutter.dev/get-started/install).
- The project uses:
    - [riverpod](https://pub.dev/packages/flutter_riverpod) for state management
    - [go_router](https://pub.dev/packages/go_router) for routing and navigation
    - [freezed](https://pub.dev/packages/freezed) for JSON modelling
    - [media_kit](https://pub.dev/packages/media_kit) for a cross-platform media player.

# Project Structure

- The main dart codebase is located in the `lib` directory.
- The `utils` directory contains helpful tools like a logger, http client, etc.
- The `router` directory contains the routing config for the app and scaffolds for how it looks on different platforms
- The `providers` directory contains [riverpod](https://pub.dev/packages/flutter_riverpod) providers that are globally helpful eg the preference handler, the theme toggle etc.
- The `modules` directory has folders which contain the logic for their respective sections eg. CMS, Impartus, Settings. Each module is somewhat isolated so logic for a specific section is the app is in a single place.
- A module folder has different directories
    - `models` are a collection of [freezed](https://pub.dev/packages/freezed) and immutable classes that are used for modelling the JSON api responses.
    - `screens` are different pages inside the same section.
    - `services` includes tools like an api client or download manager.
    - `widgets` are wigets that are used in pages, it is structured this way so they can be easily changed/customized.

## Build freezed models

```sh
dart run build_runner build --delete-conflicting-outputs
```