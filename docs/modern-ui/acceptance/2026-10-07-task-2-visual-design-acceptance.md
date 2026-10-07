# DSM Helper Modern UI — Task 2 Acceptance

> Task: Task 2 — Visual Design Specification  
> Date: 2026-10-07  
> Integration target: `modern-ui`  
> Task branch: `feature/t2-visual-design`  
> Starting integration HEAD: `732fe97dd7ecad61892232aeebc61765f8aff2ed`

## 1. Accepted deliverable

### Visual Design Specification

`docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-visual-design.md`

Status: **Approved and authoritative for Task 3 and later New UI work.**

Task 2 creates one global visual authority. It does not create a competing second design-system document.

## 2. User-confirmed Design Decisions

The Task 2 brainstorming/design review explicitly resolved the cross-page visual choices that were not already fixed by Task 1.

Frozen decisions include:

1. New UI brand/accent primary: `#00A6FF`.
2. Daily Light/Dark surfaces use low-saturation grey-blue tones rather than a saturated blue canvas.
3. DSM Helper-owned ColorScheme is the default color source.
4. Dynamic Color is optional and off by default.
5. Top App Bar titles are left-aligned.
6. Information density is medium-high with flexible ~52dp single-line and ~64dp two-line row baselines.
7. Compact Chinese-first typography is frozen; system font scaling remains enabled.
8. Radius tokens are 6/10/14/20dp.
9. Spacing is 2/4/8/12/16/24/32dp with 16dp portrait-phone page content padding.
10. Tonal surfaces carry hierarchy; deep shadows do not.
11. All five NavigationBar destinations always show icon + label.
12. Semantic status color is restrained; normal/healthy state is not saturated.
13. Icons default to outlined, with filled forms for selection/emphasis.
14. Top App Bar exposes at most two direct actions; the second may demote to overflow.
15. Filled tonal TextField is the default form language.
16. Charts use thin-line, low-decoration monitoring language.
17. Dividers are density-dependent rather than universal.
18. Buttons use Material 3 Filled / Filled Tonal / Outlined / Text hierarchy.
19. New UI uses edge-to-edge while respecting only real Android unsafe system insets.
20. Large-font layouts preserve primary information and progressively demote tertiary metadata.
21. TabBar is used for peer content categories; SegmentedButton is for compact mode/view selection.
22. Current formal adaptive target is Android phone portrait; no premature NavigationRail/tablet shell work is required.
23. Dialog handles decisions/confirmation; Bottom Sheet handles contextual action collections.
24. Loading is progress-first; Skeleton is used only when final structure is stable and known.
25. NavigationBar body baseline is ~72dp with no artificial gesture-handle padding.
26. Snackbar is floating.
27. Top App Bar body baseline is 56dp.
28. Motion is fast and functional.
29. Material 3 defines semantics; DSM Helper tokens define density.

## 3. Color and accessibility validation

The final `#00A6FF` primary is intentionally paired with dark `onPrimary #001E2B` for direct foreground content.

Mechanical contrast review found:

- `#00A6FF` + `#001E2B`: approximately 6.47:1;
- `#00A6FF` + white: approximately 2.66:1 and therefore not the default foreground pairing;
- primary-container/on-container, core surface/on-surface, secondary, tertiary and semantic error/warning/success foreground pairings used by the specification were reviewed for readable contrast.

The specification also freezes non-color redundancy for status/error meaning and a minimum 48×48dp primary touch target.

## 4. Scope and isolation acceptance

Task 2 remains documentation/design work only.

It does not:

- implement ThemeData;
- implement Dynamic Color;
- add `lib/new_ui/**`;
- implement New Shell;
- implement LegacyPageHost;
- create a migrated feature page;
- modify legacy UI/theme/widgets;
- repair legacy Dark theme;
- alter Task 1 startup/session/navigation contracts;
- enter Task 3.

Legacy fallback remains intentionally visually legacy and isolated from the New UI Material 3 theme.

## 5. Design Gap status

**No unresolved Design Semantic Gap blocks Task 3.**

Task 1 product/global contracts were treated as immutable inputs. No conflict requiring a Task 1 contract change was found.

Feature-specific visual composition remains intentionally local only where the Visual Spec explicitly permits it. Features may not redefine global visual tokens.

## 6. Task 2 Exit Gate

| Gate | Result | Evidence |
|---|---|---|
| Single authoritative Visual Design Spec complete | PASS | Task 2 Visual Spec |
| ColorScheme frozen | PASS | Light/Dark role tables + semantic colors |
| Typography frozen | PASS | Typography token table |
| Spacing / radius / surface hierarchy frozen | PASS | Immutable visual rules |
| NavigationBar / Top App Bar baseline frozen | PASS | Core component rules |
| Lists / Cards / Buttons / Forms / controls frozen | PASS | Core component rules |
| Tabs / Dialog / Bottom Sheet / Menu / Snackbar frozen | PASS | Core component rules |
| Loading / Empty / Error / Offline / Stale / Reconnecting frozen | PASS | State presentation rules |
| Charts / metrics baseline frozen | PASS | Charts and metrics section |
| Light / Dark equal product requirement | PASS | Explicit Light/Dark ColorScheme |
| Android system bars / edge-to-edge / actual insets / IME frozen | PASS | Android system integration |
| Font scaling / touch / contrast rules frozen | PASS | Accessibility rules |
| Portrait-phone adaptive boundary frozen | PASS | Adaptive and portrait rules |
| Material 3 / legacy fallback visual isolation clear | PASS | Legacy isolation section |
| Feature freedom boundary explicit | PASS | Feature freedom boundary |
| No unresolved Task 3-blocking Design Gap | PASS | Design-gap status |
| No production code changed | PASS | Task branch compare is docs-only |
| Task 3 not started | PASS | No `lib/new_ui/**` production implementation |

**Task 2 Exit Gate result: PASS.**

## 7. Verification boundary

Because Task 2 is documentation-only:

- no real-device UI Gate is required to validate an implementation that does not yet exist;
- no production widget test is added by Task 2;
- repository PR CI remains required before merge to verify that the documentation-only branch does not break the existing build/test baseline;
- concrete ThemeData/component implementation and real-device visual verification belong to Task 3 and later feature replacement Gates.

## 8. Handoff

Task 2 formally unblocks:

`Task 3 — New UI Foundation / Shell`

Task 3 must consume this Visual Design Specification and Task 1 global contracts together.

Task 3 must not reinterpret visual tokens or begin feature-specific redesign while constructing the shell.
