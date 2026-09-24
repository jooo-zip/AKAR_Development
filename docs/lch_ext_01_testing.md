# LCH-EXT-01 revision — Meet the Limahong Channel

## Audit

This revision extends the working inherited ConferenceRoomInteraction panel.
Shared Urduja implementation, navigation, input actions, and historical text are
unchanged. No other hotspot or Limahong master scene is implemented.

No suitable existing licensed pixel font found. Searches covered project font files,
Theme resources and font overrides. The project uses Godot's readable default font.
The inherited embedded Theme supplies dark heritage panels, gold selected buttons,
square borders and keyboard focus outlines. No reusable pixel-corner border or
Sources-specific icon was found.

Reused assets: assets/ui/icons/speaker.svg; all three supplied Limahong section
icons; assets/landmarks/urduja_house/icons/uh_information_hotspot.png for the
historical-note row. AtlasTexture regions remove transparent icon padding at display
time; original image bytes are unchanged. UI icons use nearest filtering.

Media audit: one site-detail locator, four documentary photographs (channel_present
and site_today_01/02/03), one illustrated marker, three section icons and one OGG.
All photographs are suitable for the requested supplied-media preview; publication
provenance/permissions still require researcher confirmation. The illustrated marker
is not a documentary photograph and is excluded from the photo sequence.
Three additional researcher-provided PNG locators now supply Lingayen, Pangapisan Norte and Limahong Channel views.

The supplied narration is still byte-identical to the Urduja UH-INT-04 recording:
SHA256 5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44.
It is not attached to the production component or played by the tests.

Pre-revision Git status:
- Four staged Urduja asset files: summary_visitor_marker.png and its .import;
  uh_end_01_cultural_architecture_icon.jpg and its .import.
- Modified project.godot.
- Untracked Limahong asset, data, scene and script directories; this document;
  tests/ containing the earlier implementation's tests and UID.
These are all pre-existing work, not newly introduced by this revision.

## Exact revision file inventory

Modified:
- scripts/landmarks/limahong_channel/lch_ext_01.gd
- scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn
- scenes/landmarks/limahong_channel/exterior/lch_ext_01_preview.tscn
- data/landmarks/limahong_channel/lch_ext_01_history.tres (photo caption only)
- data/landmarks/limahong_channel/lch_ext_01_today.tres (photo caption only)
- assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_site_today_02.JPG.import
- assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_site_today_03.jpg.import
- tests/lch_ext_01_test.gd
- docs/lch_ext_01_testing.md

Created (existing HistoricalHotspotContent resource type):
- data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
- data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
- data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
- data/landmarks/limahong_channel/lch_ext_01_today_02.tres
- data/landmarks/limahong_channel/lch_ext_01_today_03.tres

No new scripts, generic components, resource classes, font files or downloaded media.
Only the two newly used photographs' import settings enable mipmaps. No original
photo, icon, map or audio file is modified.

## Revised presentation and interaction

The component retains full-parent anchors, Containers, 5% inset F6 preview, roughly
57:43 visual/information allocation, and 180 ms cancellation-safe text fades.
A subdued square gold border extends the inherited heritage style. Section buttons
now carry their supplied pixel-art icons while keeping full labels and focus rings.

Typography: the optional exported display_font on the component applies only to
title, headings, short captions, section/locator/media buttons, note button, Sources
controls and REMEMBER. It is intentionally unassigned until a suitable licensed
font is supplied. Body paragraphs, expanded qualification, introductory description,
and source citations retain the current readable body font. REMEMBER is separated
from its paragraph for independent display-font styling; the original data is intact.
The lead uses smaller 18 px muted text; body remains 20 px compact / 22 px wide.
No antialiasing changes or fake pixel font transformations were applied.

Narration: shared speaker.svg plus LISTEN stays visible at 136 x 56 minimum, with
Narration pending on the subtitle row. With no assigned audio the button is disabled,
not in the Tab cycle, and cannot play anything. Assign approved narration_stream in
lch_ext_01.tres to enable the same button, including Play/Pause/Resume. There is no
autoplay, restart on section changes, or audio after hide/close/removal.

WHERE IS IT?: the three 56 px controls keep the exact labels LINGAYEN,
PANGAPISAN NORTE and LIMAHONG CHANNEL. Each existing locator resource now assigns
its own image through HistoricalHotspotContent.image. All three supplied PNG files
were present and are referenced without renaming, conversion or geographic edits.
Selection changes the image, active button and present-day caption immediately.
A stable 4:3 frame is centered inside the parent-sized visual area for all locator
levels. TextureRect aspect-fit preserves the complete supplied images, with
letterboxing where needed. Only the 3–6% transition zoom is clipped to the frame.
The photo viewer retains its previous full visual area and aspect-fit behavior.

A 300 ms sine-eased, two-phase Tween suggests geographic depth between separate
screenshots. Moving to a higher index fades/scales the outgoing image 1.00 to 1.06
in 140 ms, then reveals the target at scale 1.03 settling to 1.00 over 160 ms.
Moving to a lower index fades/scales the outgoing image 1.00 to 0.96, then reveals
the broader view at 1.01 settling to 1.00. Direct jumps use the same index-based
direction without stopping at an intermediate level. Selecting the current level
does not restart a transition. This is an exhibit transition, not a continuous map.

The active button, target image and caption update together. Captions are exactly:
- LINGAYEN • municipality locator
- PANGAPISAN NORTE • barangay locator
- LIMAHONG CHANNEL • landmark locator

Repeated input cancels the previous Tween and resets both image layers before
starting from the most recently selected level. Section changes, resize, close,
hide and removal restore scale 1.00 / opacity 1 and clear the outgoing layer.
The frame size is derived only from parent space, not the selected texture.
Missing per-state images retain the existing explicitly labeled site-detail fallback;
fully missing media retains the neutral placeholder. Mouse, touch, Enter/Space and
clamped Left/Right remain supported. Reopen restores LINGAYEN with no transition.
No breadcrumb was added because the smallest landscape layout takes priority.
WHY IS IT HISTORIC?: the full information-icon row is always visible above Sources.
It starts collapsed. Enter/Space or a tap reveals the exact approved qualification
inside the existing information scroll area; scroll reveals the note on expansion.
Collapsing returns the information scroll to the top. No nested modal or warning
styling. The row remains visible even at 854 x 480.

THE SITE TODAY: four supplied photographs, in order:
1. site_today_01.jpg — Visitor-center exterior and grounds
2. site_today_02.JPG — Visitor-center covered walkway
3. site_today_03.jpg — Visitor-center facade
4. channel_present.jpg — Visitor-center area beside the waterfront

Previous/Next are 56 px controls with a visible image count; endpoints do not wrap.
Focus transfers to the remaining enabled direction at endpoints. Photos keep their
aspect ratio and use linear mipmap filtering. There is no automatic slideshow.
Reopening resets to the first image. Null media keeps text and displays the existing
neutral development placeholder. Sources preserves locator, section and image state.

## Content, parent API and reset

Approved title, location, intro, all three historical paragraphs, qualification
label/text and takeaway remain unchanged. In particular, traditionally associated
and the lack of independently established archaeological identification remain.
Only neutral visible-photo captions and present-day locator UI data were added.
Historical citations and photo/media credit categories remain separate in Sources.

Existing API: open_interaction() -> bool, close_interaction(), select_concept(index),
get_selected_concept(), open_sources(), close_sources(), toggle_narration(),
stop_narration(). New local APIs: select_locator(index), change_media(direction).
Existing opened/closed, concept_changed, section_changed and source/audio signals
remain. Parent owns navigation and should suspend its background interaction while
open. Focus the parent trigger before opening for inherited focus restoration.

Fresh open restores WHERE IS IT?, LINGAYEN, first image, collapsed note, closed
Sources and stopped narration. Escape/Backspace closes Sources first, then the
hotspot, consuming input before emitting closed. There is no local enlarged view.
Tab focus includes only the visible enabled controls, and Sources confines focus
to its own scroll/close. Closing Sources returns focus to Sources; closing the panel
returns focus to the original parent trigger.

## Validation

Godot 4.7.2 headless/runtime validation and Compatibility/OpenGL renders:

| Logical canvas | Inset panel | Result |
| --- | --- | --- |
| 1280 x 720 | 1152 x 648 | Pass; all section layouts rendered |
| 960 x 540 | 864 x 486 | Pass; body readable, note row visible |
| 854 x 480 | 768.6 x 432 | Pass; header does not collide, local scrolling |

Original automated checks are preserved and extended. Checks cover:
- Visible disabled narration, silent open and 56 px header footprint.
- Parent bounds, body scroll space, full section labels, 56 px locator/media/note
  targets, and title/Listen/Close separation.
- Mouse section/locator/media changes; synthetic touch locator, Next and Sources.
- Tab/Shift+Tab, Enter/Space, section and locator arrows, locator endpoints.
- Gallery image/caption updates, endpoints, endpoint focus and no automatic advance.
- Inline note expansion/collapse; Sources selection preservation and return focus.
- Escape hierarchy, parent focus return, reopen reset and rapid selection/close.
- Missing locator/gallery image fallback.
- Optional audio lifecycle using a silent in-memory test signal, independent of
  any final recording: start, pause/resume, selection continuity, hidden-component
  stop, silent reopen. No Urduja recording or fabricated speech is used.

Run: godot --headless --path . --script res://tests/lch_ext_01_test.gd
For screenshots, omit --headless and append -- --capture. Images go to Windows TEMP.
The harness tests actual logical canvas sizes, not uniformly scaled screenshots.
Check the printed failure count with the Windows GUI executable. The environment
emits an OS certificate-store warning; no network feature is used by this component.

## Manual F6 researcher review

1. Open scenes/landmarks/limahong_channel/exterior/lch_ext_01_preview.tscn, press F6,
   and activate Meet the Limahong Channel. The same preview remains inset.
2. Check all three sections at 1280x720, 960x540 and 854x480. Confirm readable
   body text, visible LISTEN/pending state, no header collisions, crisp icons,
   photographic filtering, reachable Sources and no clipped essential controls.
3. Select all three locator steps with mouse/touch and keyboard. Confirm caption
   and gold selection change with the matching supplied image and short crossfade.
4. In WHY IS IT HISTORIC?, activate the visible information row. Read and scroll
   the qualification, then collapse it. Verify exact historical wording.
5. Browse all four site images using Previous/Next and Enter/Space. Verify captions,
   endpoints and no autoplay. Reopen and verify first-image/default-locator reset.
6. Open Sources, Escape back to Sources focus, then Escape to the parent trigger.
   Repeat rapid section changes and Close/Escape. Test Tab and Shift+Tab throughout.
7. Before enabling real narration, supply and verify a correct Limahong recording.
   Then audibly check playback/pause/resume, natural end, section continuity and close.
8. Check an actual touchscreen and landscape phone Web build. Project canvas
   scaling can differ from logical-size tests; physical touch comfort, browser
   audio policy and Web performance remain manual verification work.

Remaining assets/researcher work: suitable licensed pixel display font; correct
Limahong narration; bibliographic
citations, photo provenance and usage permissions. Existing photos are sufficient
for this manual gallery; the illustrated marker remains excluded.

## Git

The pre-existing project.godot is unchanged, including its existing modifications:
SHA256 48A9DA6DD9D125D6949AF523DC335ED4583C2D0DA874F2B4C65965A0AAFD5B32.
Final short status retains the initial staged files, modified project.godot and
untracked directories; revision files are within those existing untracked paths.
The pre/post file-hash audit identifies only the exact files listed above.
No commit or push. Stop here for researcher manual F6 review, not LCH-EXT-02.

## Earlier locator-image revision

Modified in this pass only:
- scripts/landmarks/limahong_channel/lch_ext_01.gd
- data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
- data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
- data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
- tests/lch_ext_01_test.gd
- docs/lch_ext_01_testing.md

Created: three Godot-generated .import sidecars alongside these existing supplied
images in assets/landmarks/limahong_channel/lch_ext_01/images/:
- lch_ext_01_lingayen.png
- lch_ext_01_pangapisan_norte.png
- lch_ext_01_limahong_channel.png
All three image slots are assigned; none is awaiting a final file. No new application
scene/script/resource class or original media file was created.

Speaker audit: scenes/components/conference_room_interaction.tscn assigns
res://assets/ui/icons/speaker.svg to Speaker. LCH inherits that exact resource and
the existing normal/pressed/focus styles; its visible disabled LISTEN treatment is
retained. No speaker substitution or new speaker artwork. Tests assert the exact
resource identity, visible disabled footprint, null narration resource/player stream.
No Urduja audio is attached.

Pre-pass status was the same as the previous revision's final status: four staged
Urduja asset files; modified project.godot; untracked Limahong assets/data/scenes/
scripts, docs/lch_ext_01_testing.md and tests/. The three supplied PNGs were already
within that untracked asset directory. Preserve all these pre-existing changes.
The earlier inventory above describes the prior revision; this section is the
complete file inventory for this targeted pass.

Additional checks cover every locator's assigned visual, intermediate fade opacity,
settled opacity/outgoing-layer cleanup, 50 rapid selections, section change during
transition, close/reopen during transition, per-state fallback and fully missing
media. Existing input, gallery, note, Sources and optional-audio checks are retained.
The interpolation test advances its Tween deterministically so a slow rendering
frame cannot skip the entire 180 ms interval and cause a false failure.

F6 review: use the unchanged lch_ext_01_preview.tscn. In WHERE IS IT?, select all
three states, inspect their full aspect-fit images at each target size, then switch
quickly and close/reopen mid-transition. Expect the final selection to settle at full
opacity and reopening to restore Lingayen. Confirm visible disabled LISTEN with the
same Urduja speaker icon. Historical text and other sections are unchanged.

No commit or push. Stop for researcher review; no other hotspot work.

## Fixed-frame geographic zoom revision (latest)

Baseline: local milestone commit c2110f5 already existed before this revision.
Pre-existing changes preserved: four staged Urduja icon/import files, modified
project.godot, untracked Limahong narration/import and marker/import files.

Files modified in this pass:
- scripts/landmarks/limahong_channel/lch_ext_01.gd
- scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn
- data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
- data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
- data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
- tests/lch_ext_01_test.gd
- docs/lch_ext_01_testing.md
Files created: none. Original media/imports and the preview scene are unchanged.

Uses the existing lch_ext_01_lingayen.png, lch_ext_01_pangapisan_norte.png and
lch_ext_01_limahong_channel.png. Their source proportions differ; the DISPLAY frame
is consistently 4:3. No conversion, permanent crop, distortion, map annotation or
new geography was introduced. Full geographic subjects remain visible at rest.
The new ImageArea expands within the inherited visual column. LocatorFrame is
centered and sized with width = min(parent width, parent height * 4/3), height =
width * 3/4. A subdued background makes letterboxing part of the stable frame.
Both image layers share its bounds and center pivot. Captions reserve one text line
at supported sizes to keep more room for the visual; tests check frame stability.

Tests preserve all earlier input, historical-note, gallery, Sources, speaker, audio,
missing-media and reset checks. Additional assertions cover fixed 4:3 bounds and
aspect-fit mode, equal frame rectangles across levels, exact captions, mouse and
synthetic touch on every locator, both adjacent/direct direction paths, settled
scale/opacity, rapid final image/caption/button consistency, neutral scale on section
change and no active animation after reopen. Tweens are advanced deterministically;
checks do not rely on frame-perfect timing.

Godot 4.7.2 headless and Compatibility rendered tests passed at 1280x720, 960x540
and 854x480, including the existing 5% inset parent. Rendered images were inspected
for fit, captions, touch controls and no locator layout jump. OS certificate-store
warning persists in this environment; no script/resource errors occurred.

Manual F6: open the unchanged lch_ext_01_preview.tscn. Compare 0→1→2 and 2→1→0,
then direct 0→2 and 2→0. Confirm outgoing scale direction, gently settling incoming
image, identical frame bounds and the exact matching caption. Rapidly choose
0→1→2→0→2, switch sections during animation, then close/reopen. Expect the final
selection to be consistent and fresh open to restore Lingayen, full opacity and
scale 1.00. Review all three landscape sizes; existing body scrolling is unchanged.

Approved historical text, historical note, gallery, Sources, Close, speaker and
shared Urduja code are unchanged. No commit or push during this revision. Stop for
researcher F6 review; no other hotspot work.
