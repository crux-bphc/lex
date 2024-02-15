# Setup

- You need flutter installed on your system. You can follow the [official guide](https://docs.flutter.dev/get-started/install).
- Java runtime v17
- Platform android-33
- The project uses:
    - [riverpod](https://pub.dev/packages/flutter_riverpod) for state management
    - [go_router](https://pub.dev/packages/go_router) for routing and navigation
    - [freezed](https://pub.dev/packages/freezed) for JSON modelling
    - [media_kit](https://pub.dev/packages/media_kit) for a cross-platform media player.

## Contribution workflow

1. Open an issue if required
2. Open a PR (Pull Request)
3. Make changes and make sure to follow the [conventional commit](https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional) style.
    - feat – a new feature is introduced with the changes
    - fix – a bug fix has occurred
    - chore – changes that do not relate to a fix or feature and don't modify src or test files (for example updating dependencies)
    - refactor – refactored code that neither fixes a bug nor adds a feature
    - docs – updates to documentation such as a the README or other markdown files
    - style – changes that do not affect the meaning of the code, likely related to code formatting such as white-space, missing semi-colons, and so on.
    - test – including new or correcting previous tests
    - perf – performance improvements
    - ci – continuous integration related
    - build – changes that affect the build system or external dependencies
    - revert – reverts a previous commit
4. Make sure to add tests if required.
5. Discuss
6. Approved and merged


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