# CLAUDE.md

This file provides guidance for AI assistants working on this repository.

## Project Overview

**nopaystation-scripts-container** is a Docker packaging project that bundles
[sigmaboy/nopaystation_scripts](https://github.com/sigmaboy/nopaystation_scripts) and its
compiled dependencies into a single ready-to-use container image.

The repository contains **no original application code** — its sole purpose is Docker
packaging and distribution. The upstream scripts are cloned at image build time from
`https://github.com/sigmaboy/nopaystation_scripts` into `/scripts` inside the container.

The image is published to GitHub Container Registry:
`ghcr.io/ocost3000/nopaystation-scripts-container:latest`

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── docker-publish.yml   # CI: builds and pushes image to GHCR on push to main
├── Dockerfile                   # Multi-stage Docker build definition
├── LICENSE                      # GPLv3
└── README.md                    # User-facing documentation with usage examples
```

There is no `.gitignore`, no package manager manifest, no test suite, and no Makefile.
All dependency declarations live exclusively in the Dockerfile.

## Dockerfile Architecture

The image uses a **two-stage build** to keep the final image small:

### Builder stage (`debian:bookworm-slim`)

Compiles and downloads three binary tools:

| Tool | Source | Method |
|------|--------|--------|
| `pkg2zip` | `https://github.com/lusid1/pkg2zip` | Cloned and compiled with `make` |
| `mktorrent` v1.1 | `https://github.com/Rudde/mktorrent` | Cloned and compiled with `make install` |
| `t7z` (torrent7z) | `https://github.com/BubblesInTheTub/torrent7z/releases/download/1.3/t7z` | Pre-built binary, `curl` download |

### Final stage (`debian:bookworm-slim`)

- Installs runtime packages: `python3`, `python3-lxml`, `python3-requests`, `curl`, `wget`,
  `ca-certificates`, `git`, `file`
- Copies compiled binaries from builder stage
- Clones `nopaystation_scripts` into `/scripts`
- Sets `ENV PATH="/scripts:$PATH"` so all scripts are directly executable
- Sets `WORKDIR /scripts`

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/docker-publish.yml`) triggers on every push
to `main`. It:

1. Checks out the repository
2. Logs in to GHCR using `GITHUB_TOKEN`
3. Extracts metadata: applies `latest` tag on the default branch plus a commit-SHA tag
4. Builds and pushes with `docker/build-push-action@v6`

**There are no test or lint steps.** A push to `main` immediately triggers a live image build
and publish.

## Development Workflow

### Making changes

1. Edit `Dockerfile` or `README.md` as needed.
2. Commit on the current feature branch and push.
3. Open a pull request targeting `main`.
4. Merging to `main` automatically triggers the CI workflow and publishes a new image.

### Testing the Docker image locally

Build the image locally to verify changes before merging:

```bash
docker build -t nopaystation-scripts-container:local .
```

Run a quick smoke test:

```bash
docker run --rm nopaystation-scripts-container:local nps_game.sh --help
```

Mount a local directory to `/data` to capture output files:

```bash
docker run --rm -v /path/to/output:/data nopaystation-scripts-container:local <script> <args>
```

### Upgrading pinned versions

Three tools have version-sensitive references in the Dockerfile:

- **mktorrent**: tag `v1.1` is cloned implicitly (no explicit `--branch`); the clone pulls the
  default branch. To pin to a specific tag add `--branch v<TAG>` to the `git clone` call.
- **t7z**: version is hard-coded in the download URL (`/releases/download/1.3/t7z`). Update
  the URL when releasing a new version.
- **pkg2zip**: clones the tip of the default branch of the lusid1 fork with no version pin.

When changing any of these, rebuild locally and verify the binary executes before merging.

## Conventions and Guidelines

### Dockerfile style

- Use `debian:bookworm-slim` as the base for both stages; update the codename together if
  changing the Debian release.
- Group all `apt-get install` packages in a single `RUN` command per stage, followed
  immediately by `rm -rf /var/lib/apt/lists/*` to keep layers small.
- Keep build-time-only tools (gcc, make, etc.) in the builder stage; never install them in
  the final stage.
- Use `--no-install-recommends` on all `apt-get install` calls.

### Documentation

- `README.md` is user-facing. Keep usage examples up to date when scripts or flags change.
- `CLAUDE.md` (this file) is AI-assistant-facing. Update it whenever the Dockerfile
  structure, CI pipeline, or development workflow changes.

### What this repository does NOT contain

- No application code, tests, linters, or formatters
- No docker-compose file (end users run `docker run` directly)
- No environment variable configuration (all runtime config is passed as CLI arguments)
- No post-processing hooks (those are user-supplied, mounted via `/data`)

## Key Upstream References

- Upstream scripts: https://github.com/sigmaboy/nopaystation_scripts
- Game title ID lookup (PS Vita): http://renascene.com/psv/
- Game title ID lookup (PSP): http://renascene.com/psp/
- Published image: `ghcr.io/ocost3000/nopaystation-scripts-container:latest`
