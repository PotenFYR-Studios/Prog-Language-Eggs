<!--
Conventional Commits title, please: feat: | fix: | docs: | ci: | chore:
One focused change per PR. Branch: master.
-->

## What does this PR change?

<!-- One or two sentences: the behavior change, not the diff. -->

## Motivation

<!-- Link the issue: Fixes #123 -->

## Checklist

- [ ] Behavior suite passes locally: `bash tests/panel-test.sh`
- [ ] Egg JSON changes keep PTDL_v2 shape (all 8 variable fields, `meta.update_url`, denylist, startup/stop intact)
- [ ] New languages include real runner resolution, real auto-detect triggers and a checksum-verified upstream
- [ ] No hardcoded language/variable/image values added to `docs/` page copy (content is generated from `egg-programming-multi.json` + README matrix via `docs/scripts/prebuild.ts`)
- [ ] README / docs updated where user-facing behavior changed
- [ ] Tokens/secrets never appear in code, logs or examples

## Docs build (if `docs/` touched)

```bash
cd docs && bun install && bun run build   # must succeed; serves from docs/dist
```
