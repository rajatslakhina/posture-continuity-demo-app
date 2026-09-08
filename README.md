# PostureContinuity Demo

**Scroll to item 30, put the caret in the e-mail field, tap Unfold. Then do it again with the switch off.**

This is the companion app for [`posture-continuity-kit`](https://github.com/rajatslakhina/posture-continuity-kit), consumed as a **remote Swift Package pinned to a release tag** — not a local path, not a branch. It renders one checkout flow in one or two columns and drives it through fold / unfold / book / laptop postures with the real `ContinuityCoordinator` underneath. A **Restore** toggle switches the continuity machinery off so you can watch what an app that never heard of it does: the layout changes, and the scroll position, focus, sheet and navigation all evaporate.

[![CI](https://github.com/rajatslakhina/posture-continuity-demo-app/actions/workflows/ci.yml/badge.svg)](https://github.com/rajatslakhina/posture-continuity-demo-app/actions/workflows/ci.yml)

---

## Why this matters

Rebuilding for the iOS 27 SDK makes your app resizable; the new hardware makes it fold. Every screen now has a question it never had to answer: *when the geometry changes underneath a user mid-task, what happens to their work?* The library's README makes the architectural case. This app exists so the answer is something you can see:

- **Unfold with Restore on:** the list re-flows into two columns, the sidebar boundary sits where the policy put it, item 30 is still at the top and the caret is still in the e-mail field. The outcome strip names the generation, the provenance (`capture g1` vs `checkpoint`) and any degradations.
- **Unfold with Restore off:** two columns, item 0, no focus.
- **Navigation, separately:** in one column a pushed order covers the list (and its e-mail row), so this is its own run: open an order, tap **Unfold**, and the pushed detail becomes the sidebar selection in two columns; **Fold** again and it is a pushed detail once more. Restore off: nothing selected.
- **Sheet, separately:** presenting a sheet takes first responder away from the list, so this is not combinable with the focus claim either. Tap *Choose address…*, then tap **Unfold** through the sheet (the controls stay tappable behind it); with Restore on the sheet is re-presented over the two-column layout, with Restore off it is gone.
- **Fold from the two-column detail with the promo-code field focused:** focus is dropped — and *reported* dropped — because that field does not exist in one column. The plan says `focusDropped(promo-code)`.
- **Storm:** three transitioning observations in one gesture, ending where it began. One generation, no restore, the checkpoint untouched; the journal counts it.
- **Jump:** a settled posture with no transitioning observation first (what a resizable-simulator drag looks like from inside). The plan is marked `noCaptureWindow`, not `captureMissed`.
- **Laptop:** expanded width, horizontal hinge. The hinge-aware policy refuses to stack two panels across the crease and stays single-column.

The **Journal** tab shows the coordinator's metrics (transitions, storms absorbed, captures accepted/rejected, degraded restores, invariant violations — which should read `0`) and a script box. `transitioning@100,expanded@600,transitioning@800,book@1200` is the same language `-posture-script` accepts on launch, so an agent driving the simulator can put the app into any posture sequence and read the journal back.

---

## What the app owns vs. what the library owns

`Demo/DemoApp.swift` is small on purpose, and it imports **both** products for a reason:

- From `PostureContinuity` (core) it builds the `LayoutPolicyRegistry` — a `HingeAvoidingPolicy` over a 600 pt `WidthThresholdPolicy` for the checkout flow — and parses `-posture-script` from `CommandLine.arguments` with `PostureScript.fromLaunchArguments`. Which flows split, at what width, and whether the boundary follows the hinge is a product decision, so it lives in the app.
- From `PostureContinuityUI` it takes `PostureContinuityDemoView`, handing it the registry and the optional launch script.

## Screenshots

**There are none, and this section says so rather than describing an image that does not exist.**

This repository was produced by an unattended scheduled run. Opening `Demo.xcodeproj` in Xcode and running it on a Simulator requires computer-use access to Xcode and the Simulator, and that access was refused three times during the run (`Computer-use access to "Xcode 26.3", "Simulator" can't be approved during a scheduled run`). There is deliberately no `Demo/Screenshots/` directory. The CI job below proves the project resolves the remote package and compiles for the Simulator; it does not prove the app launched.

## How to run it

```sh
git clone https://github.com/rajatslakhina/posture-continuity-demo-app.git
cd posture-continuity-demo-app
open Demo.xcodeproj
```

1. Let Xcode resolve the remote package (`posture-continuity-kit`, pinned `upToNextMajorVersion` from `1.0.1`).
2. Select the shared **Demo** scheme and any iOS 17+ Simulator (an iPad or the resizable iPhone shows the two-column layouts best).
3. Build & Run.
4. Scroll and focus the e-mail field, then tap **Unfold** / **Book** / **Fold** / **Storm** / **Jump**. Try opening an order, and the address sheet, as separate runs. Flip **Restore** off and repeat.

To drive it from a launch argument (Edit Scheme → Run → Arguments), add:

```
-posture-script "transitioning@100,expanded@600,transitioning@800,book@1200,transitioning@1400,compact@1900"
```

Requirements: Xcode 16+, iOS 17+ deployment target.

## Verification

Two separate facts, stated separately:

- **Builds for a Simulator by CI:** pending — this line is rewritten from the real result once the first run on `main` has reported.
- **Ran on a Simulator:** **no.** See *Screenshots* above for the verbatim refusal. Nothing in this repository has been observed running.

Structural checks that did happen on this tree: `project.pbxproj` brace/paren balance (33/33, 24/24) and every referenced object id defined (22/22, no dangling refs); the shared scheme's blueprint id matches the `Demo` target; the package reference is an `XCRemoteSwiftPackageReference` at `https://github.com/rajatslakhina/posture-continuity-kit.git` with `upToNextMajorVersion` from `1.0.1` — no local path, no branch. `DemoApp.swift` and the demo view were traced by hand and by three independent review rounds against the library's `ContinuityCoordinator`; the round-3 finding (a doc claim that focus and a presented sheet could be restored simultaneously) was fixed and is documented above, but that final fix was not independently re-reviewed.

## Library

[`rajatslakhina/posture-continuity-kit`](https://github.com/rajatslakhina/posture-continuity-kit) — problem statement, design decisions with rejected alternatives, and the test suite (including the negative controls and the racing-writer concurrency tests).

## License

MIT — see [LICENSE](LICENSE).
