# Same brief, different burden

_Claude Opus 4.8 and Codex gpt-5.6-sol implement player-drawn asteroid boards in Driftfire. Evidence snapshot: 2026-08-19._

## Verdict

**Codex won this run.** That is the developer's judgment after using both implementations, and the raw sessions support it. Codex carried more of the feature from requirement to working integration without turning the developer into its test harness. Its architecture was cleaner, its visual verification caught real failures, its tests were stronger on the riskiest network behavior, and its written work was easier to scan.

Claude often understood the problem correctly. Its design identified most of the hard requirements, its initial codebase investigation was excellent, and it recovered thoughtfully when failures were reported. The problem was execution across subsystem boundaries. The developer repeatedly became the integration test: a black drawing screen, untextured rock, the wrong background, omitted local multitouch, a Uplink path that skipped drawing, overlapping controls, an unrotated joiner view, concurrent drawing crashes, and—at the latest observed Claude build—dots that worked on iOS while dragged lines did not.

Codex was not flawless. Its first board-library UI was also poor. Its first Uplink co-editor did not rotate the joiner's board, and its first native iOS bridge introduced a Web parse failure. Reviewers found meaningful persistence, lifecycle, geometry, compatibility, and native-input edge cases. The distinction is not "Codex made no mistakes." It is that fewer correctness failures reached the developer, the remaining problems were fixed and pinned with stronger tests, and the resulting structure was easier to extend.

> "After this experience, Codex is clearly the winner, and it's going to become my primary model going forward." — the developer

## What was actually compared

Both agents received the same opening prompt: the developer's complete feature request plus a 12 KB Claude-authored engineering brief. They worked in separate Git worktrees and opened separate pull requests.

The opening request required:

- a selectable custom-drawn asteroid style, excluded from Random;
- a finger-drawing canvas before the match;
- stable texture identity for connected, extended, and separate shapes;
- erase mode;
- one global Draw/Erase state;
- two controls in local two-player mode; and
- simultaneous local multitouch.

The engineering brief added correctness traps and asked each agent to stop for four product decisions: bridge texture, rematch behavior, persistence, and Uplink support.

The runs ceased to be identical after that checkpoint. The agents asked different forms of the questions and the developer's later requests differed. Live Uplink co-editing and variable-width/native-iOS brushes therefore belong to a later phase, not the original-brief score.

This was also not a blind benchmark:

- Claude Opus 4.8 and Codex gpt-5.6-sol at medium effort are not matched tiers.
- The environments differed, including Codex sandbox friction and a harness change between starts.
- Both implementations used mandatory Claude and Codex reviewers, so final code is not purely the implementing model's unaided work.
- Claude started first. Its code could be influenced by Codex review, and the branches accumulated different follow-up scope.
- One feature, one developer, and one run cannot rank the models in general.

## Three phases, not one flat score

### Phase 1: the identical opening brief

| Outcome | Claude | Codex |
|---|---|---|
| Style, exclusions, component rules | Correct, with tests | Correct, with tests |
| Stable textures through extend/bridge/split | Correct | Correct |
| Local two-player multitouch | Implemented only after the developer reminded it that this was required | Designed into the pure draft model from the start |
| Global Draw/Erase state | Correct after an early toggle-count correction | Correct from the first implementation |
| First working render | Black screen, then gray rock and the wrong background until device reports | Real starfield and real rock textures in the first verified render |
| Safe-area/chamfer/spawn geometry | Reviewer-hardened | Reviewer-hardened |
| Visual verification | Reported success despite missing the black-screen failure | Framebuffer matrix caught an invalid mapping test and exercised production transforms |

**Phase 1 result: Codex.** Both solved the core data problem. Codex did a much better job of carrying it through the actual game.

### Phase 2: chosen product scope

Both agents added persistence and Uplink support after the developer answered their questions. The exact answers and implementations differed.

Claude built a richer two-tier persistence model: four recent boards plus an unlimited saved library. Codex built a simpler named library with automatic `Custom Board N` names. Both stores needed reviewer hardening. Codex's final persistence tests go deeper on atomic replacement, backup recovery, corrupt-entry isolation, and transactional mutation.

For Uplink, "support" did not initially mean the same thing. Claude moved toward live co-editing. Codex initially treated the host as the author and transported the committed board through snapshot zero. The later request for both remote players to draw live should therefore be compared separately.

### Phase 3: later additions

**Live Uplink co-editing.** Both agents initially missed the joiner's 180-degree authoring view. Codex fixed the board presentation and inverse input transform after one device report, added a focused mapping test, and framebuffer-verified the result. Claude's joiner view remains wrong. The developer also reports that simultaneous remote drawing crashes Claude's build; Codex orders edits through the host and tests byte-identical convergence.

**Variable-width iOS drawing.** Claude mapped Godot drag pressure to width. On the latest observed iOS build, taps produce dots but drags do not produce lines. This is an observed regression; the exact root cause was not established in this comparison. Codex later investigated Apple's input surface, added a native `UITouch.majorRadius` bridge, fixed a Web-only class-loading regression, and then iterated with the developer on feel: thinner light strokes, preserved drag width, and a much wider flat-thumb gesture. Those later turns were primarily product calibration, not repeated rejection of the native approach.

**First UI quality.** Neither agent gets this point. Claude's initial drawing experience was rough and partly nonfunctional. Codex's first library screen was, in the developer's words, "pretty terrible" until it was redirected toward the existing settings screen. The useful difference is how the designs evolved, not who made a beautiful first mockup.

## The developer became the integration test

This is the clearest pattern in the raw sessions.

Claude's design said:

- resolve components at stroke end;
- implement local multitouch;
- reuse exact board geometry;
- verify the canvas visually; and
- make Uplink host-authoritative.

Yet its implementation initially resolved while drawing, omitted local multitouch, mismatched real board geometry until review, passed a visual check while the screen was black on-device, and left the network integration broken. The reasoning was often strong; the last mile repeatedly was not.

Codex showed the opposite pattern more often. It began with the engine-independent draft model and red-first tests, then persistence, style wiring, the editor, the app flow, and finally network coordination. Its framebuffer run exposed that an input-mapping test exercised an unused helper and could pass while production was wrong. It replaced the test before handoff. Reviewers still found defects, but the agent used them as part of its delivery loop rather than relying as heavily on the developer's device testing to discover the basic integration.

> Evaluator summary, explicitly endorsed by the developer: "The user repeatedly became the integration test." This is sharp, but accurate: Claude's design usually named the right requirements; a human playing the build had to reveal where they had not survived integration.

## Engineering craft

### Plan and pull request

Claude's stage-two plan is 658 lines and embeds Rust, GDScript, exact test bodies, and shell commands. It is precise but effectively replaces the design with an implementation script. Codex's complete plan is 193 lines: staged checklists, file ownership, and a conflict/parallelization map designed to be read alongside the specification.

The same difference appears in the pull requests. Codex uses short, named sections and bullets. Claude uses longer subsystem prose. The developer found the Codex PR materially easier to scan.

> "Codex's PR description is better organized. I like the bullet points and the structure and the succinctness."

### Architecture

Both editors receive raw touch events through a procedural `_input` branch. The distinction is what happens next.

Claude's 844-line `BoardDrawScreen` owns touch tracking, terrain mutation, preview rendering, control layout, persistence UI, and network mirroring. Its pure `BoardDrawModel` is a compact 127-line texture-identity helper, but most drawing behavior stays in the engine screen. `app.gd` gains 58 lines that probe geometry, run the draw-screen lifecycle, and write settings internals.

Codex's 571-line `CustomBoardEditor` converts touches into a uniform operation vocabulary and delegates coverage, components, textures, and serialization to a 516-line pure `CustomBoardDraft`. A 95-line network coordinator owns host/joiner ordering, and a 203-line flow object owns editor/library/match transitions. `app.gd` gains 24 lines of delegation.

That is the context behind the developer's judgment that **Codex is using cleaner patterns**. It is not merely that Codex calls `emit`. Local input, host echoes, and joiner proposals share one operation model; the editor does not know the network session; and the app does not know drawing geometry.

Claude has a defensible tradeoff: it paints through the match's existing `DestructibleField`, which gives exact terrain semantics and antialiased coverage. Codex implements an authoring-time rasterizer in GDScript and must keep it faithful to the match. Claude's small texture model is also easier to understand in isolation. For a feature that grew into persistence and live network co-editing, however, Codex's additional boundaries paid for themselves.

### Comments

Claude's main feature files contain roughly 23 comments per 100 lines; Codex's contain roughly 2–5. Claude's comments are usually substantive, not filler, but the volume competes with the code. Codex more closely matches the project's preference to explain only the non-obvious, although a few draft invariants could use more explanation.

> "Codex uses a lot fewer comments, which I like because its code speaks for itself."

## Tests: overlap and meaningful differences

Both suites cover the feature's core:

- connected, extended, separate, bridged, and split shapes;
- Random/gallery exclusions;
- snapshot round-trips;
- protected spawn areas;
- global Draw/Erase state; and
- persistence basics.

Codex is materially stronger on the hardest integration surface:

- `test_joiner_sees_and_touches_the_canonical_board_rotated_180_degrees` tests both presentation and inverse input mapping.
- `test_host_orders_joiner_strokes_and_shared_mode_into_authoritative_echoes` asserts byte-identical drafts and separate remote touch IDs.
- It covers both letterbox and pillarbox mapping.
- It tests that snapshot zero does not clobber the joiner's local field choice.
- It tests transport loss during authoring and persistence corruption/recovery.

Claude's remote co-draw test injects strokes already expressed in board coordinates, so it cannot catch the joiner's screen-to-board bug. Its convergence assertion compares only the number of solid cells; two different boards can contain the same number of cells.

Claude has two important unique tests:

- fractional rim cells inherit the component's rock texture, preserving smooth edges; and
- the rotated local-two-player toggle is hit-tested in its transformed position rather than painting through the control.

The conclusion is not that Claude's tests are weak. Both suites are substantial. Codex's uniquely strong tests align better with the failures most likely to break remote co-editing.

## Objective context

Current branch heads inspected:

| | Claude | Codex |
|---|---:|---:|
| Commit | `797c7f9a` | `d1166ded` |
| Commits beyond the shared base | 33 | 34 |
| Files changed | 57 | 96 |
| Insertions / deletions | 4,488 / 70 | 5,284 / 80 |
| Main plan | 658 lines | 193 lines |
| Added to `app.gd` | 58 lines | 24 lines |
| Last reported coverage | 88.2% | 88.1% on the last full verified head; later iOS feel-tuning commits had focused checks with final gates still in progress at inspection |

These numbers describe scope, not quality. Codex's current diff is larger because it includes live co-editing hardening and a native iOS bridge. Claude's includes a richer recents/saved-board system and Rust drawing primitives.

The earlier session-log estimate put comparable attended work at approximately 8.7 hours for Claude and 4.1 hours for Codex after subtracting waits for user input. Treat that as directional. Logs can estimate elapsed working spans, not measure focused human-equivalent labor, and the later iOS calibration falls outside that cutoff.

## Final judgment

Codex won because it reduced the developer's burden. It did not merely finish with fewer visible defects; it organized the work so that the pure model, screen, network ordering, and app lifecycle could be tested independently. Its tests matched the riskiest real behavior. Its plan and PR communicated intent without requiring a close reading of implementation prose.

Claude produced strong design work, richer persistence behavior, smooth terrain edges, and several valuable tests. But too many requirements were understood in the abstract and lost at integration time. On a mobile, two-player drawing feature, that gap is the feature.

The result does not establish a universal model ranking. It does establish the outcome of this run: **Codex was faster to a dependable implementation, easier to review, and required substantially less human integration testing.**

## Evidence

- Claude implementation: PR #596, branch `feat/custom-drawn-boards`, head `797c7f9a`.
- Codex implementation: PR #598, branch `feat/custom-drawn-boards-codex`, head `d1166ded`.
- Comparison sources: both raw CLI session logs, both diffs, plans, PR descriptions/comments, reviewer findings, and the developer's on-device reports.
- This narrative is the authoritative comparison. `data.json` is its structured companion; `index.html` is its public presentation.
