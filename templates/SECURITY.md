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
- **SSH commit signing** — Commits are cryptographically signed whenever an SSH agent is available
- **Dependency updates** — Dependabot opens PRs to keep dependencies current (enable GitHub's Dependabot alerts, a repository setting, for vulnerability monitoring)
- **SAST scanning** — Trivy scans the repository filesystem for CRITICAL/HIGH vulnerabilities on every PR into `main`
- **Pre-commit hooks** — Automated checks run before every commit
