# UH-ENT-01 revision testing — 2 October 2026

This guide supersedes the previous milestone guide. The approved revision requirements
are summarized in `docs/specifications/urduja_house/revision_2026_10_02.md`.
Earlier specifications remain archival research context where wording conflicts.

## Exact F6 procedure

1. Open `scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn` in Godot 4.7.2.
2. Press **F6** (Run Current Scene). The actual production component opens automatically
   inside the preview's 5% inset frame; no master landmark scene is involved.
3. Test at **1280×720**, **960×540**, and **854×480**. The preview temporarily disables
   fixed canvas scaling so resizing exercises real parent-responsive layout.
4. For the full-parent comparison, set the Remote `Frame` anchors to 0, 0, 1, 1;
   restore 0.05, 0.05, 0.95, 0.95 for the inset comparison. Do not save Remote changes.
5. Close and use the preview OPEN button to repeat. F8 stops the preview.

## Interaction and states

Embedded historical video controls: Watch/Play, Replay, Mute, Transcript and Skip. Video is withheld pending verification; playback controls are disabled.

Open transcript status, Escape back, Skip, and Close/reopen. Confirm no video autoplay and no substitute video/audio. When a verified video/transcript is supplied, recheck playback, replay, mute, transcript pause/resume and skip.

## Shared header and reset contract

- SOURCES / LISTEN / CLOSE occupy the same header position as other Urduja components.
- SOURCES distinguishes historical references and media credits and includes the approved
  narration transcript. Unresolved provenance is explicitly labeled; no credits were invented.
- Opening/closing Sources preserves selection. Tab/Shift+Tab remain inside the active overlay.
- LISTEN remains visible but disabled with **Narration pending.** No separate ENT
  narration file exists; audio from another hotspot is never substituted.
- **RESEARCHER VIDEO/TRANSCRIPT VERIFICATION REQUIRED**. The supplied video remains
  unchanged and unassigned pending historical/transcript review. Transcript status,
  Skip, Sources and Close remain usable; no fabricated transcript is supplied.
- Escape/Backspace closes Sources first, then an internal inspection/transcript view, then
  the hotspot. CLOSE closes the entire hotspot. No points, rewards or completion tracking.
- Close/reopen restores initial state and stops media. Return-to-map remains a signal.

## Mouse, keyboard and touch

Test every displayed control with mouse and touch. No information depends on hover.
Tab/Shift+Tab traverse active controls; Enter/Space activate focused buttons. Selected gold
fill and keyboard-focus border must look distinct. Dragging always has direct-selection
and keyboard alternatives. Test rapid input and resize mid-transition; no stale text,
stacked Tweens, half-transparent content, duplicate UI or stuck focus may remain.

## Responsive visual review

Check at all three sizes: bounded inset frame, visible header controls, readable 20px body
text, local scrolling where needed, prominent aspect-preserved media, no overlapping targets,
no controls outside the parent, no accidental full-screen popup and no clipped Sources text.
Pixel art retains nearest filtering; documentary photos use aspect-fit/linear filtering.

## Removed or changed behavior

PopupWindow replaced with a parent-sized media component. Unverified playback assignment removed; media bytes preserved.

## Historical and media constraints

Use construction **began** in 1953. The removed original-name claim is not visitor-facing.
Princess Urduja remains a legendary cultural figure; Tawalisi is not conclusively identified
as Pangasinan. No lodging, first-resident or 2012 rehabilitation claim is introduced.
See `docs/urduja_house_media_credits.md` for per-file provenance and researcher actions.

## Automated validation

Run:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/uh_revision_test.gd
```

The revision test checks all nine real production components, all three sizes full/inset,
state transitions, rapid selection, reset, source focus, keyboard/mouse activation,
rail drag/touch routing and image-bound markers. Compatibility-rendered previews were
also inspected at 1280×720, 960×540 and 854×480. Physical touchscreen and complete researcher
F6 visual approval remain manual. Broader-suite caveats are recorded in the central report.
