# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please send details to: **[SECURITY_EMAIL]**

Include as much of the following information as possible:

- A description of the vulnerability
- Steps to reproduce or proof of concept
- The potential impact
- Any suggested fixes (optional)

## Response Timeline

- **Acknowledgment:** Within 48 hours of receiving the report
- **Initial assessment:** Within 5 business days
- **Fix or mitigation:** Aimed for within 30 days, depending on complexity

## Supported Versions

| Version | Supported |
| ------- | --------- |
| Latest  | ✅ Yes    |

## Security Measures in This Project

This project includes several security-by-default features:

- **No secrets in code** — All sensitive values are managed via `.env` (gitignored)
- **SSH commit signing** — All commits must be cryptographically signed
- **Dependency scanning** — Dependabot monitors dependencies for known vulnerabilities
- **SAST scanning** — Trivy scans code and containers for security issues on every PR
- **Pre-commit hooks** — Automated checks run before every commit
