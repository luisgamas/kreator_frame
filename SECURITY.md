# Security Policy

## Supported Versions

| Version | Supported          | Status      |
|---------|:------------------:|-------------|
| 1.5.2   | ✅                 | Latest      |
| 1.5.1   | ✅                 | Maintained  |
| 1.5.0   | ✅                 | Maintained  |
| < 1.5.0 | ❌                 | Unsupported |

## Reporting Security Vulnerabilities

**Please do not report security vulnerabilities through public GitHub issues.**

### How to Report

If you discover a security vulnerability in Kreator Frame, please report it by:

1. **Email**: Send details to the repository maintainer (check [CONTRIBUTING.md](CONTRIBUTING.md) for contact info or use GitHub's private security advisory feature)

2. **GitHub Security Advisory** (Recommended):
   - Go to the repository's **Security** tab
   - Click **Report a vulnerability**
   - Fill out the form with vulnerability details
   - This creates a private advisory visible only to maintainers and reporters

### What to Include

When reporting a vulnerability, please provide:

- **Description**: Clear explanation of the vulnerability
- **Impact**: Potential harm or data exposure
- **Affected Versions**: Which app/library versions are affected
- **Reproduction Steps**: How to reproduce the vulnerability (if possible)
- **Suggested Fix**: Proposed solution (optional but helpful)
- **Your Contact Info**: For follow-up communication

### Timeline

We commit to:
- **Acknowledge** receipt within 48 hours
- **Provide initial assessment** within 1 week
- **Release patch** within 2 weeks (if critical) or following next release cycle
- **Public disclosure** after patch is released

## Security Considerations

### Native Code (Android/Kotlin)

This project includes native Android components for wallpaper operations:

- **File Access**: Uses `FileProvider` for secure content URI sharing
- **Permissions**: Minimal permissions required:
  - `INTERNET` - API data fetching
  - `SET_WALLPAPER` - Wallpaper application
  - `WRITE_EXTERNAL_STORAGE` - Image downloads (API 28 and below)
- **MethodChannel Security**: Communication with native code is local, no external network exposure

### Flutter Dependencies

All dependencies are publicly available on pub.dev. We regularly:
- Monitor pub.dev security advisories
- Update dependencies to latest compatible versions
- Review CHANGELOG and security notes for critical packages

### User Data

Kreator Frame:
- Does **not** collect personal data
- Does **not** track user behavior
- Does **not** send data to external services (except wallpaper/widget API fetch)
- Stores only user preferences locally (SharedPreferences, no cloud sync)

### API Security

- Wallpaper/widget data fetched from `WALLPAPERS_URL` (defined in `.env`)
- All API calls use HTTPS
- No authentication/API keys stored in source code (`.env` is gitignored)

## Best Practices for Users

If you're using Kreator Frame:

1. **Keep the app updated** to receive security patches
2. **Review permissions** before installing (listed in Security Considerations)
3. **Report issues** using this security policy if you discover something suspicious

## Security Disclosure

Once a vulnerability is patched and released, we will:
- Credit the reporter (with permission)
- Publish a security advisory on GitHub
- Update documentation if needed
- Close the private advisory

## Questions?

For security-related questions (not vulnerability reports):
- Review this document
- Check [CONTRIBUTING.md](CONTRIBUTING.md)
- Open a [Discussion](https://github.com/luisgamas/kreator_frame/discussions) (for non-sensitive topics)

---

Thank you for helping keep Kreator Frame secure! 🔒
