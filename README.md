# Kreator Frame Dashboard

<p align="center">
  <img src="assets/dashboard/dashboard_icon.png" width="128" alt="Kreator Frame Logo" />
</p>

<p align="center">
  <a href="https://github.com/luisgamas/kreator_frame/releases">
    <img src="https://img.shields.io/github/v/release/luisgamas/kreator_frame?style=for-the-badge&color=02569B" alt="Release" />
  </a>
  <a href="https://github.com/luisgamas/kreator_frame/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/luisgamas/kreator_frame?style=for-the-badge&color=0175C2" alt="License" />
  </a>
  <!-- <a href="https://github.com/luisgamas/kreator_frame/stargazers">
    <img src="https://img.shields.io/github/stars/luisgamas/kreator_frame?style=for-the-badge&color=02569B" alt="Stars" />
  </a> -->
  <!-- <a href="https://github.com/luisgamas/kreator_frame/releases">
    <img src="https://img.shields.io/github/downloads/luisgamas/kreator_frame/total?style=for-the-badge&color=0175C2" alt="Downloads" />
  </a> -->
</p>

<p align="center">
  <img src="https://img.shields.io/badge/FLUTTER-FRAMEWORK-gray?labelColor=02569B&style=for-the-badge&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/DART-LANGUAGE-gray?labelColor=0175C2&style=for-the-badge&logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/PLATFORM-ANDROID-gray?labelColor=3DDC84&style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/STATUS-BETA-gray?labelColor=FFA000&style=for-the-badge" alt="Beta" />
</p>

<p align="center">
  <i>Your Kustom creations. One template. The Play Store.</i>
</p>

---

**Kreator Frame Dashboard** is a production-ready Flutter template for creators who want to publish their Kustom widget and wallpaper packs (**KWGT** & **KLWP**) on the **Google Play Store** — without writing a single line of code.

> [!IMPORTANT]
> This project is in **Beta**. Fully functional for distribution, but contributions and bug reports are always welcome.

---

## ✨ What Makes It Great

*   **Plug & Play** — Drop your `.kwgt` and `.klwp` files into the assets folder, configure one JSON, and you're ready to build.
*   **Make It Yours** — Change the app name, icon, package ID, and splash screen. Every pixel is customizable.
*   **Wallpaper Showcase** — A dedicated dashboard that automatically pulls and displays your wallpapers from any JSON endpoint.
*   **Material You** — Dynamic theming that adapts to the user's device color palette, light and dark.
*   **CI/CD Ready** — GitHub Actions workflow to sign, build, and deploy your AAB straight to Google Play.

---

## 🧱 Under the Hood

| Layer | Stack |
|---|---|
| **State Management** | [Riverpod 3.x](https://riverpod.dev) — manual providers, zero code generation |
| **Navigation** | [GoRouter 17](https://pub.dev/packages/go_router) — declarative, type-safe routing |
| **Architecture** | Clean Architecture — `domain`, `infrastructure`, `presentation` layers |
| **HTTP** | [Dio 5](https://pub.dev/packages/dio) — robust networking with timeouts & error handling |
| **Theming** | Material Design 3 + [dynamic_color](https://pub.dev/packages/dynamic_color) for Material You |
| **Localization** | English & Spanish via ARB files (Flutter `flutter_localizations`) |

---

## 📖 Documentation

Every step — from zero to the Play Store — is covered in the **[Wiki](https://github.com/luisgamas/kreator_frame/wiki)** (also available locally under `docs/`).

|     |     |
|---|---|
| [Installation & Setup](https://github.com/luisgamas/kreator_frame/wiki/Installation-and-Setup) | Get your environment ready |
| [Editing the Project](https://github.com/luisgamas/kreator_frame/wiki/Editing-the-Project) | Configure `.env` and your wallpaper data |
| [Adding Widgets & Wallpapers](https://github.com/luisgamas/kreator_frame/wiki/Adding-widgets) | Import your Kustom files |
| [Customization](https://github.com/luisgamas/kreator_frame/wiki/Home#2-customization) | Rename, rebrand, change icons & splash |
| [Build & Release](https://github.com/luisgamas/kreator_frame/wiki/Build-and-release-an-Android-app) | Sign your APK/AAB and ship it |

---

## 📱 Try It First

See the dashboard live before building your own:

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=io.github.luisgamas.kreator_frame">
    <img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="250" />
  </a>
</p>

---

## 🤝 Contributing

Pull requests, bug reports, and feature ideas are all welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) for code style, architecture conventions, and the PR workflow.

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).

---

## ❤️ Support

Kreator Frame is built with love for the Kustom community. If it helps you, consider fueling its future:

<p align="center">
  <a href="https://sink.gamas.workers.dev/buymeacoffee">
    <img src="https://raw.githubusercontent.com/luisgamas/buttons-design/main/buy_me_a_coffe/buy_me_a_coffe_fill.png" width="200" alt="Buy Me a Coffee" />
  </a>
  <a href="https://sink.gamas.workers.dev/paypal-donations">
    <img src="https://raw.githubusercontent.com/luisgamas/buttons-design/main/paypal/paypal_fill.png" width="200" alt="Donate via PayPal" />
  </a>
  <a href="https://sink.gamas.workers.dev/github-sponsor">
    <img src="https://raw.githubusercontent.com/luisgamas/buttons-design/main/github_sponsor/github_sponsor_fill.png" width="200" alt="Sponsor on GitHub" />
  </a>
</p>

---

## ⚖️ License

Licensed under **Mozilla Public License 2.0 (MPL 2.0)**. See [LICENSE](LICENSE) for the full legal text.

```
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/
```
