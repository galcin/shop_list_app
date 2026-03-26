# GitHub Copilot Instructions

These are the developer's personal preferences. Always follow them unless explicitly told otherwise.

---

## Code Style

- Always check `mounted` before using `context` after any async operation.
- Keep files small and well-organized; split large widgets into smaller ones.
- Write comments for complex or non-obvious logic.
- Prefer concise code over verbose/explicit code.
- Always handle errors — show snackbars for failures and provide fallback UI where appropriate.
- Make widgets reusable and generic; extract them into separate files in the `lib/shared/` folder.

---

## Project-Specific Rules

- Use `AppColors` for all colors — never hardcode color values.
- Use the `Poppins` font family for all text styles.
- Use Riverpod for all state management — no other state solutions.
- Follow the existing file and folder structure at all times.
- No `print()` statements in production code.

---

## Copilot Response Style

- Keep answers short and direct.
- Always explain the reasoning behind changes.
- Always show the full relevant code, not partial snippets with `// ...existing code...`.
- Implement changes immediately rather than just suggesting them.
- Do not create summary or changelog markdown files unless explicitly asked.
