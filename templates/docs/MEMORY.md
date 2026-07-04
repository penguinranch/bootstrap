# Agent Memory

> **Living document** — long-lived context that helps AI agents support the developer better across sessions. Add to it whenever the developer corrects you, states a preference, or you discover something non-obvious the codebase can't tell you.
>
> **Never store secrets, API keys, tokens, or credentials here.** Those belong in `.env` (gitignored). This file is committed and readable by anyone with repo access.

## Developer Preferences

<!-- Coding style, communication style, tools they like/dislike, review preferences. -->

- [e.g., Prefers small commits with detailed messages; explain reasoning before large refactors]

## Environment Notes & Gotchas

<!-- Non-obvious facts about the dev environment, services, or tooling that would trip up a fresh session. -->

- [e.g., The staging database is shared — never run destructive migrations against it]

## Lessons Learned

<!-- Approaches that were tried and rejected, and why. Prevents re-litigating settled questions. -->

- [e.g., Tried library X for auth (2026-07) — abandoned because Y; don't suggest it again]

## Glossary

<!-- Domain terms, abbreviations, and project-specific vocabulary. -->

- **[Term]** — [what it means in this project]
