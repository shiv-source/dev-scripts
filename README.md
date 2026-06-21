# dev-scripts

A curated collection of essential development and automation scripts. Any utility, setup, or helper script can be added here — the goal is a single home for scripts you'd otherwise lose to random directories or scratch files.

## Structure

```
dev-scripts/
├── setup-graphify.sh       # Bootstrap the Graphify knowledge-graph skill
├── uninstall-graphify.sh   # Remove Graphify and associated artifacts
└── README.md
```

## Conventions

- Scripts should be **self-contained** — a single file that's readable on its own.
- Prefer **shell scripts** for portability; use other languages when shell gets unwieldy.
- Add a **comment header** at the top of each script explaining what it does and how to use it.
- **Make executable**: `chmod +x <script>.sh`.
- Keep the root flat unless a collection naturally groups into its own subdirectory.

## Usage

```bash
./setup-graphify.sh   # install Graphify
./some-other-tool.sh  # run whatever you've added
```

## Adding a script

1. Create your script in the repo root (or a subdirectory if it's a multi-file tool).
2. `chmod +x` it.
3. Commit with a descriptive message — `feat: add <script-name>`.
