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

- 2026-09-03: When flagging a concern, weigh whether the affected data is
  actually user-touched before calling it impact. Peter pushed back on a
  "blast radius" finding because catalog/product data is server-managed and
  rarely changes — the real cost was concentrated in one heavy user-facing
  query, not the three listed. Narrow findings to where the cost actually lands.
- 2026-09-03: Anchor every review comment to a specific file and line; keep the
  summary comment short or empty so it does not restate the inline threads.
- 2026-09-03: Verify a finding against surrounding context before reporting it.
  Two findings this session were withdrawn for being artifacts of grepping added
  lines without context (an if/else pair read as a duplicated call; a "dropped
  refetch" that had moved to its only caller).

## Tracked PRs

One entry per PR ever reviewed or seen as a review request.

### getdreams/dreams-web-app#1516 — Feat: centralised cache invalidation
- Author: glowacki-dev
- Status: reviewed
- Last reviewed commit: 5126349fc0cf455cbc68da15ad32799ecd8e0901 (2026-09-03)
- Last seen commit: 5126349fc0cf455cbc68da15ad32799ecd8e0901 (2026-09-03)
- Summary: Replaces scattered query-key invalidation with tag-based
  invalidation — query factories declare tags in TanStack `meta`, mutations and
  SSE handlers call `invalidateCaches(tag, userId)`. Fixes SUP-343. ~95 files,
  substance in `utils/cacheInvalidation.ts` (new), `EventProvider` (+19/-130)
  and the deleted `utils/dreamsCache.ts`.
- Notes: Reviewed 2026-09-03, posted review 5099830037 (COMMENTED) with 9
  anchored inline comments + short summary. Context: this builds on the big
  loading/performance work, where the recurring problem is data going stale and
  needing per-site tweaks — so the review focused on under-invalidation and tag
  vocabulary gaps, not over-invalidation.
  Key findings: (1) `useSavehacks` tagged `products` while all 9 savehack
  mutations invalidate `subscriptions` — list refreshed only by accident via
  `useDreams`; (2) `useHomeBalance` no longer refreshed on savehack start;
  (3) `useInvites.rejectInvite` dropped the dreams refresh + unscoped userId.
  Root cause behind all three: `refreshDreamsDomain` was removed from inside
  the shared helpers (`updateCache`, `createDream`, `startSavehacks`) and pushed
  out to ~50 call sites, turning a guarantee into a convention. That structural
  point was deliberately left out of the posted comments (does not anchor to a
  line); raise it if the author's replies do not address the pattern.
  Withdrawn during review: a "duplicate invalidateCaches" in `Edit.tsx` (it is
  an if/else pair) and a "dropped refetch" in `useCashback.boost` (moved to its
  only caller, `NewPayout`). Mechanical tag audit came back clean — no declared
  tag unproduced, no invalidation matching nothing.

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
