# Security Policy

## Supported versions

Only the latest release of the `master` branch and the `:latest` /
sha-tagged images published from it receive security fixes. The egg's
`AUTO_UPDATE_EGG` self-update mechanism keeps deployed launchers in sync
with the fixed versions; we recommend leaving it enabled.

## Reporting a vulnerability

**Please do not open public issues for anything exploitable.**

1. Preferred: use GitHub **private vulnerability reporting** on this
   repository (Security tab → Report a vulnerability).
2. Or email **support@potenfyr.in** with `[PLE-SECURITY]` in the subject.

Include: affected component (egg JSON, `run.sh`, `entrypoint.sh`,
`install-runtime.sh`, `resolve-version.sh`, `install.sh`, `Dockerfile`),
panel family and version, reproduction steps, and any `.logs/` output.
Please give us a reasonable disclosure window; we aim to acknowledge
reports within 72 hours.

## Scope

In scope:

- The launcher scripts shipped in the container and refreshed via
  `EGG_UPDATE_URL` (injection, unsafe downloads, checksum bypass, path
  traversal, credential leaks in logs).
- The egg JSON (variable validation bypasses, denylist escapes).
- The container image and `Dockerfile` / `entrypoint.sh`.

Out of scope:

- The host panels themselves (Pterodactyl, Pelican, Feather, PufferPanel):
  report those upstream.
- Compromises requiring a malicious workspace the user deliberately
  uploaded (the egg executes your code by design; that is the product).

## Hardening posture already in place

- SHA256 checksum verification of on-demand runtime downloads against
  official vendor feeds.
- Git tokens (`GIT_AUTH_TOKEN`) and credentials in URLs are redacted from
  console output and log files.
- `file_denylist` blocks panel file-manager writes to launcher scripts and
  `.potenfyr` state.
- Non-root container user, `umask 022`, disabled core dumps, orphan
  process sweeps on boot and stop.
