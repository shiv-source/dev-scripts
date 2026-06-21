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

Run any script directly from the raw URL — no clone needed:

```bash
curl -fsSL https://raw.githubusercontent.com/shiv-source/dev-scripts/refs/heads/main/setup-graphify.sh | bash
```

Or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/shiv-source/dev-scripts/refs/heads/main/setup-graphify.sh | bash
```

To play it safe, download first then execute:

```bash
curl -fsSLo /tmp/setup-graphify.sh https://raw.githubusercontent.com/shiv-source/dev-scripts/refs/heads/main/setup-graphify.sh && bash /tmp/setup-graphify.sh
```

## Adding a script

1. Create your script in the repo root (or a subdirectory if it's a multi-file tool).
2. `chmod +x` it.
3. Commit with a descriptive message — `feat: add <script-name>`.
