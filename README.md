# Skills

Manage and customize skills with a lightweight OpenClaw-style layout.

## Repository layout

```text
skills/
├── MANIFEST.json
└── open-claw-starter/
    ├── config.example.json
    └── SKILL.md
```

## Managing skills

- Register each skill in `skills/MANIFEST.json`.
- Set `"enabled": true` to turn a skill on.
- Add more skill folders under `skills/` and list them in the manifest.

## Customizing skills

1. Copy `skills/open-claw-starter` to a new skill folder.
2. Update the frontmatter in `SKILL.md` with the skill name, description, platform, and scope.
3. Adjust `config.example.json` with your preferred instructions, tools, and environment values.
4. Add the new skill to `skills/MANIFEST.json`.

This keeps skill discovery, enabling, and customization in one predictable place.
