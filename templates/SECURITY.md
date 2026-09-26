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

- `.env` (gitignored) holds every sensitive value. None goes in code.
- Commits get SSH-signed once you give `make setup` a key and an SSH agent is reachable. If the agent wasn't reachable at setup time, unlock it and run `make doctor`.
- Dependabot opens PRs to keep dependencies current (turn on GitHub's Dependabot alerts, a repo setting, for vulnerability monitoring).
- Trivy scans the repo filesystem for CRITICAL/HIGH vulnerabilities on pushes and PRs to `main`.
- Pre-commit hooks scan for secrets and run lint before every commit.
