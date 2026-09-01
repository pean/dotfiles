# PR Review Log

## Instructions

Accumulated guidance from Peter, most recent last. Each entry: what he said,
when, and why (if given). Read this section fully before every walkthrough —
it's the whole point of self-improvement.

- 2026-09-01: "Done for now until something new happens" means: keep the PR
  tracked, but only surface it again when the head SHA moves past the recorded
  last-seen commit. Peter's own comments on a PR do not make it actionable —
  new commits do.
- 2026-09-01: A PR Peter puts "on hold" stays tracked but is not surfaced in the
  status list at all until he asks about it or it changes state
  (draft -> ready, closed, merged).

## Tracked PRs

One entry per PR ever reviewed or seen as a review request.

### getdreams/dreams-sanity-studio#28 — fix(links): one href rule for nav, footer and body copy
- Author: giertzmathias
- Status: done-for-now
- Last reviewed commit: c4f507879883a96c8c3c8d633f7b58e2cb473d42 (2026-09-01, handled by Peter directly — no walkthrough in session)
- Last seen commit: c4f507879883a96c8c3c8d633f7b58e2cb473d42 (2026-09-01)
- Summary: Unifies href handling so nav, footer and body copy all resolve links
  through a single rule. Schema-side counterpart to getdreams-web#77.
- Notes: Peter commented 2026-09-01 11:24; no push since. Surface again only on
  a new commit.

### getdreams/getdreams-web#77 — feat(sections): same-page anchor links for any CTA or link
- Author: giertzmathias
- Status: done-for-now
- Last reviewed commit: 2504abd3fb58045b71aeb0e95fa5702871c6a386 (2026-09-01, handled by Peter directly — no walkthrough in session)
- Last seen commit: 2504abd3fb58045b71aeb0e95fa5702871c6a386 (2026-09-01)
- Summary: Lets any CTA or link target a same-page anchor. Renders the anchor
  model that dreams-sanity-studio#28 defines.
- Notes: Peter reviewed in comments; giertzmathias pushed 2504abd "address
  review — fetch anchorId, drop the scroll module" in response. Peter commented
  again 2026-09-01 11:19 after that push. Surface again only on a new commit.

### getdreams/dreams-ios-adapter#1658 — DRE-203 Prevent creating streaming client in master worker, keep it per worker
- Author: Camosk
- Status: on-hold
- Last reviewed commit: (none)
- Last seen commit: 64d7a9b57c5ccb200cf7cb0446e6b2522f230acc (2026-09-01)
- Summary: Moves streaming-client creation out of the master worker so each
  worker owns its own client.
- Notes: Draft, opened 2026-04-01, no activity since 2026-04-07. Put on hold by
  Peter 2026-09-01 — do not surface until he asks or the PR changes state.
