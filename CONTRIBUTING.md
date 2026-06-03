# Contributing to Kreator Frame

Thank you for your interest in contributing to Kreator Frame! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

This project adheres to the Contributor Covenant [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Bugs

Before creating a bug report, check the [issue tracker](https://github.com/luisgamas/kreator_frame/issues) to avoid duplicates.

When filing a bug report, include:
- **Clear description**: What behavior did you expect? What actually happened?
- **Steps to reproduce**: Detailed steps to recreate the issue
- **Environment**: Device model, Android/Flutter version, app version
- **Screenshots/logs**: Visual evidence or error messages (if applicable)
- **Frequency**: Does it happen consistently or intermittently?

Use the [Bug Report template](https://github.com/luisgamas/kreator_frame/issues/new?template=bug_report.md) when creating an issue.

### Suggesting Features

Feature suggestions are welcome! Before proposing a feature:
- Check existing [issues](https://github.com/luisgamas/kreator_frame/issues) and [pull requests](https://github.com/luisgamas/kreator_frame/pulls)
- Provide clear use cases for the feature
- Consider scope: Does it align with Kreator Frame's goals (Kustom widget/wallpaper dashboard)?

Use the [Feature Request template](https://github.com/luisgamas/kreator_frame/issues/new?template=feature_request.md).

### Submitting Code Changes

#### Prerequisites

- **Flutter**: 3.10.4 or later
- **Dart**: 3.10.4 or later
- **Android SDK**: API 24+ (minimum), API 28+ (recommended)
- **Git**: Latest stable version

#### Setup Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/kreator_frame.git
   cd kreator_frame
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/luisgamas/kreator_frame.git
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Generate localization files (if modified):
   ```bash
   flutter gen-l10n
   ```

#### Development Workflow

1. **Sync with upstream**:
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/short-description
   ```
   Branch naming convention:
   - `feature/add-x` - New feature
   - `fix/resolve-x` - Bug fix
   - `refactor/improve-x` - Code refactoring
   - `docs/update-x` - Documentation
   - `chore/update-x` - Maintenance tasks

3. **Make your changes**:
   - Follow the [Code Style Guide](#code-style-guide)
   - Keep commits atomic and well-documented
   - Write clear commit messages (see [Commit Messages](#commit-messages))

4. **Test your changes**:
   ```bash
   flutter analyze
   flutter test
   ```
   Ensure no analysis errors and all tests pass.

5. **Push to your fork**:
   ```bash
   git push origin feature/short-description
   ```

6. **Create a Pull Request**:
   - Go to [Pull Requests](https://github.com/luisgamas/kreator_frame/pulls)
   - Click "New Pull Request"
   - Select `main` as base branch
   - Fill out the PR template with:
     - Clear description of changes
     - Related issue(s)
     - Testing performed
     - Screenshots/videos (if UI changes)

#### Code Style Guide

This project follows Flutter and Dart conventions with additional guidelines:

##### Architecture
- **Clean Architecture**: Strict separation of Domain/Infrastructure/Presentation layers
- **State Management**: Riverpod manual providers (NotifierProvider, AsyncNotifierProvider)
- **No Code Generation**: All providers and state management are manually defined (no .g.dart files)

##### Dart/Flutter Style
- **Formatting**: Use `dart format` (enforced via `flutter analyze`)
- **Linting**: Follow `flutter_lints` (6.0.0+)
- **Naming**:
  - Classes/enums: PascalCase
  - Variables/functions: camelCase
  - Constants: camelCase (not UPPER_CASE)
  - Private members: prefix with `_`
- **Type Safety**: Use explicit types, avoid `var` for public APIs
- **Imports**:
  ```dart
  // 🐦 Flutter imports
  import 'package:flutter/material.dart';

  // 📦 Package imports
  import 'package:flutter_riverpod/flutter_riverpod.dart';

  // 🌎 Project imports
  import 'package:kreator_frame/config/config.dart';
  ```

##### Documentation
- Public APIs require documentation comments (`///`)
- Complex logic requires inline comments (`//`)
- Keep comments concise and explain the "why", not the "what"

##### File Organization
```
lib/
├── config/          # Configuration, constants, theme
├── domain/          # Entities, repositories, datasources (business logic)
├── infrastructure/  # Implementation of repositories, datasources, services
├── presentation/    # Screens, widgets, providers
└── shared/          # Utilities, helpers, constants
```

#### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `perf`

**Scope**: Feature area (e.g., `wallpaper`, `theme`, `riverpod`)

**Subject**: Imperative, lowercase, no period. Max 50 chars.

**Body**: Explain what and why. Max 72 chars per line.

**Footer**: Reference issues: `Closes #123`, `Fixes #456`

**Example**:
```
feat(wallpaper): add app chooser intent for wallpaper selection

Implement Android ACTION_ATTACH_DATA system intent to allow users
to choose third-party apps for wallpaper application. Reduces bottom
sheet height by consolidating location buttons into icon row.

Closes #42
```

#### Testing

- Add tests for new features/bug fixes
- Run all tests before pushing:
  ```bash
  flutter test
  ```
- Ensure `flutter analyze` reports no issues:
  ```bash
  flutter analyze
  ```

### Pull Request Process

1. **Update CHANGELOG.md** with your changes (add under `## [Unreleased]` section if it exists, or create it)
2. **Ensure all checks pass**:
   - GitHub Actions (if configured)
   - `flutter analyze`
   - `flutter test`
3. **Respond to feedback** promptly and professionally
4. **Request re-review** after making changes
5. **Once approved**, maintainers will merge using **Merge Commit** strategy

## Development Tips

### Material Design 3
The project uses Material Design 3 with Material You support. Reference:
- [Material Design 3 Documentation](https://m3.material.io/)
- Existing implementations in `lib/presentation/widgets/`

### Riverpod Manual Providers
Examples of patterns used:
```dart
// State holder (no code generation)
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState();

  void updateState(String value) {
    state = state.copyWith(value: value);
  }
}

final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);
```

### Clean Architecture Layers
- **Domain**: Contains business logic, completely independent of Flutter/external packages
- **Infrastructure**: Implements domain repositories using external services (APIs, databases, native code)
- **Presentation**: UI layer, uses Riverpod providers to manage state

## Questions?

- Open a [Discussion](https://github.com/luisgamas/kreator_frame/discussions) for questions
- Check [Issues](https://github.com/luisgamas/kreator_frame/issues) for similar problems
- Review [CHANGELOG.md](CHANGELOG.md) for project history

## License

By contributing to Kreator Frame, you agree that your contributions will be licensed under the [Mozilla Public License 2.0](LICENSE).

---

Thank you for helping make Kreator Frame better! 🚀
