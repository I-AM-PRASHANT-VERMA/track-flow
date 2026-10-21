## What and why
<!-- One paragraph. Link the audit finding or issue. Keep the PR small (aim for under 400 changed lines). -->

## Risk and rollout
- [ ] No change to the persisted data format, or a migration + new fixture test is included
- [ ] Backup JSON written by the previous release still imports (fixture test passes)
- [ ] New user-visible behaviour is behind a `--dart-define` flag whose default keeps today's behaviour, or it is a pure bug fix
- [ ] Release notes line added (user-facing wording)

## Verification
- [ ] `scripts/presubmit.ps1 -Strict` is green locally
- [ ] Tests added for the behaviour (failing before, passing after)
- [ ] Checked on a real device if the UI changed (screenshots attached)
