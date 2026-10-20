# `.github`

The organization-level repository for [transummer2026](https://github.com/transummer2026).
It holds two unrelated things that GitHub happens to look for in the same place: the
**organization profile page**, and the **reusable CI workflows** every Pollpear repository
calls.

## Organization profile

[`profile/README.md`](profile/README.md) is what renders on
[github.com/transummer2026](https://github.com/transummer2026). GitHub only picks it up
from that exact path, and only while this repository is public — the README you are
reading now is the one for this repository alone and appears nowhere else.

## Reusable workflows

Each service repository keeps a thin caller in its own `.github/workflows/ci.yml` that
delegates here, so the pipeline is defined once and the services stay in step.

| Workflow | What it does | Called by |
| :--- | :--- | :--- |
| [`ci-service-branch.yml`](.github/workflows/ci-service-branch.yml) | CI1 — fast feedback on a push to a working branch | `Pollpear_shared` |
| [`ci-service.yml`](.github/workflows/ci-service.yml) | CI3 — full validation on a PR to `dev`: PR title, commitlint, lint, tests, Docker build (no push) | every service |
| [`ci-services-push.yml`](.github/workflows/ci-services-push.yml) | The "ship" path on a push to `dev` — builds and pushes the image to GHCR | the service callers |
| [`ci-shared-push.yml`](.github/workflows/ci-shared-push.yml) | Post-merge path for `Pollpear_shared`, which has no image to build | `Pollpear_shared` |
| [`ci-docs.yml`](.github/workflows/ci-docs.yml) | Documentation checks — naming conventions, link hygiene | `docs` |
| [`release-main.yml`](.github/workflows/release-main.yml) | release-please on a push to `main` | `Pollpear` |
| [`update-submodules.yml`](.github/workflows/update-submodules.yml) | Moves the superproject's submodule pointers forward | `Pollpear` |
| [`mirrror.yml`](.github/workflows/mirrror.yml) | Mirrors third-party images from Docker Hub to GHCR, on demand | manual |

`.github/workflows-archive/` holds a retired pipeline kept for reference. Files there are
outside `.github/workflows/`, so GitHub never runs them.

## Scripts

[`.github/scripts/`](.github/scripts) carries the shell steps the workflows shell out to,
rather than inlining them in YAML where they cannot be read or tested: CI status
aggregation (`global_status.sh`, `check_step_outcomes.sh`), PR hygiene (`normalize_pr.sh`,
`resolve_pr.sh`), security (`audit_severity.sh`, `secret_scan_base.sh`), documentation
naming (`check_docs_naming.sh`), language detection (`detect_language.sh`), the shared
submodule bump (`bump_shared_submodule.sh`) and image mirroring (`mirror-images.sh`).

## Other shared configuration

- [`.github/.releaserc.json`](.github/.releaserc.json) — semantic-release: `main` ships
  releases, `dev` ships `-dev` prereleases.
- [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE) — the issue template offered across
  the organization.
