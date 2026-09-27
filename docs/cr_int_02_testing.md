# CR-INT-02 — Discover the Banáan Galleries

## Purpose and scope

Educational question: “What can visitors explore inside Banáan Museum?”

Learning takeaway: “Banáan Museum brings different aspects of Pangasinan’s environment, history, people, and cultural identity together within the restored Casa Real.”

This is a museum orientation and preview directory, not a full virtual exhibition. Only researcher-approved gallery titles, photographs, gallery-space recordings, overall narration and invitation copy are included. There are no artifact descriptions, gallery-specific historical interpretations, floor-plan positions, individual artifact interactions, completion tracking, or game mechanics. Acceptability remains the evaluation scope; no learning-effectiveness claim is made.

## Interaction and states

The Banáan Gallery Trail has three states: DIRECTORY, PREVIEW and IMAGE_FOCUS, with separate PHOTO/VIDEO preview modes. Directory opens with G01 centered and no Gallery Window open. Thirteen museum plaques represent **11 principal gallery groupings**: Gallery 5 contains 5A + 5B, and Gallery 6 contains 6A + 6B. Both subdivisions remain selectable and carry explicit grouping labels.

All selections pass through select_gallery(index, open_preview=false). A horizontal swipe or mouse drag of at least 44 px selects one bounded adjacent entry without opening it. Mostly vertical gestures do not change selection. A direct plaque tap/click selects, centers and opens that gallery. Arrow controls are also available. The focused trail accepts Left/Right, Home/End and Enter/Space. Gold indicates selection; the separate yellow outline indicates keyboard focus.

A restrained 380 ms framing/photo/action reveal opens the Gallery Window. Every preview starts with its real approved photograph; photos use aspect-preserving containment. WATCH GLIMPSE deliberately starts that entry's real VideoStreamPlayer; it is muted at runtime, non-looping and never automatic. Natural finish or SKIP GLIMPSE clears the player stream, restores the photograph and offers REPLAY GLIMPSE. Media transitions last 180 ms. Changing gallery, opening Sources, returning to Directory, closing/hiding, or entering Image Focus stops the old video. Narration continues independently.

VIEW PHOTO opens the same image within the existing inset overlay (200 ms fade), with CLOSE VIEW returning to Preview. No browser fullscreen or added artifact hotspots. RETURN TO DIRECTORY closes Preview and returns to the Gallery Trail with the current gallery selected and centered, allowing free choice. CONTINUE EXPLORING stays in Preview and directly opens the next official directory entry; G11 loops to G01. No Directory view appears between previews.

**Continue Exploring uses digital directory order, not validated physical adjacency.**

### Final Gallery Preview navigation revision

The forward sequence is G01 → G02 → G03 → G04 → G05A → G05B → G06A → G06B → G07 → G08 → G09 → G10 → G11 → G01, repeating. This is DIGITAL DIRECTORY browsing order, not a claim that consecutive entries occupy physically adjacent museum rooms.

CONTINUE EXPLORING computes the next index, wraps at the end, and calls the existing authoritative select_gallery(next_index, true). That existing path cancels old transitions, stops/clears video, restores PHOTO mode, resets the Watch Glimpse helper, selects the correct photograph/video mapping, preserves narration and reuses the Gallery Window transition. It does not create another scene or a competing selection method. Rapid requests replace prior transitions safely.

RETURN TO DIRECTORY retains its existing behavior: cancel video, restore PHOTO mode, return to DIRECTORY and center the same selected gallery. In particular, returning from G11 keeps G11 selected; wrapping happens only when Continue is deliberately activated.

There is intentionally **no Previous Gallery button** in Preview. To revisit an earlier or different gallery, use RETURN TO DIRECTORY and choose it freely. The existing Gallery Trail left/right browsing and generic overlay BACK controls are unchanged. Sources, the visit invitation and Image Focus block Continue. ENTER GALLERY and its visit modal, all links/contact details, media, source mappings, appearance and responsive layout are unchanged.

Navigation revision validation (2026-09-28): 1,246 targeted rendered checks, 5,232 full headless checks and 5,328 full rendered checks passed with zero failures. All three requested viewport sizes passed; G11-to-G01 captures were visually reviewed. Godot 4.7.2 import, parse/reload and standalone preview launch passed with zero GDScript errors. Casa Real regressions passed: CR-EXT-01 1,983; CR-EXT-02 1,897; CR-EXT-03 5,431; CR-INT-01 2,287 checks. The first CR-EXT-02 run emitted shutdown resource-cleanup diagnostics after passing; a verbose rerun passed without those diagnostics. No earlier hotspot files were changed. The existing environment certificate-store diagnostic remains separate from GDScript validation. git diff --check and changed-untracked-file whitespace checks passed. SHA-256 audit of 594 pre-existing files identified only the controller, this navigation documentation and the test as changed; the controller diff is confined to continue_exploring(). No new files, staging, commit or push. Targeted tests cover two complete forward cycles per viewport, every subdivision boundary, G11 wrapping, rapid G04 → G05A → G05B → G06A and G10 → G11 → G01 → G02, real video playing/skip/replay/natural completion before Continue, playing/paused narration, overlay guards, return-selection preservation, absence of a Previous control, and mouse/touch/Enter/Space access to both controls. A Directory visibility observer catches even transient Directory reveals during forward browsing.

ENTER GALLERY remains the visitor-facing CTA and opens an in-AKAR visit-information modal inviting visitors to experience the complete gallery physically at Banáan Pangasinan Provincial Museum. It does not represent digital entry or navigate to another scene. This supports AKAR's design as a complement to the physical museum. The obsolete navigation-request signal and preview-only entry-status display have been removed. The preview harness still opens the real component and supports close/reopen. The production close_requested and established closed lifecycle signals remain.

### ENTER GALLERY visit invitation revision

Title: **ENTER THE FULL EXPERIENCE AT BANÁAN**

Body:

> You’ve seen a glimpse of this gallery in AKAR.
>
> Visit the Banáan Pangasinan Provincial Museum to experience the complete exhibits, artifacts, and curatorial narratives in person.

Online Reservation: https://banaan.seepangasinan.com/online-reservation/

Visitor Information: https://banaan.seepangasinan.com/visitor-guidelines/

Museum inquiries:

- (075) 511-9821
- banaanppm@gmail.com

The two URLs are underlined LinkButton text links with 48 px hit areas, not additional CTA buttons. Visible link text omits the https:// prefix exactly as supplied. The only conventional modal button is BACK (56 px). Links call Godot OS.shell_open only after deliberate activation; no embedded website, browser automation, new scene or booking form is added. Automated tests replace that callable with a request recorder, validating the exact targets and input paths without opening an external browser.

Opening the modal stops/resets a playing gallery glimpse and restores its photograph; selection, trail position, replay state and overall narration remain intact. The dimmed Gallery Preview stays recognizable and cannot be operated through the modal. Tab / Shift+Tab cycle Online Reservation → Visitor Information → BACK; Enter and Space activate the focused control. BACK and Escape return to the exact same Gallery Preview and restore focus to ENTER GALLERY, without advancing, resetting or returning to Directory.

Escape order: Sources → Visit invitation → Image Focus → Preview → Directory → closed. Sources retains priority, including when opened by the host over the invitation. Closing/reopening or resetting the hotspot clears the visit modal. At 1280×720 and 960×540 all modal text fits without scrolling. At 854×480 only the modal text area scrolls; BACK stays fixed and reachable. Existing Directory/Preview responsive layouts are unchanged.

No additional media assets were required for this revision. All new visitor text, section labels, contacts and URLs are fields in the existing content Resource; gallery mappings and source-credit fields remain unchanged.

Revision validation: the targeted rendered modal suite passes 141 checks across all three viewports. It covers pointer/keyboard activation, exact copy/targets, blocked underlying actions, focus order, video cleanup, playing/paused narration preservation, BACK/Escape, Sources priority and close/reopen. The full revised CR-INT-02 suite passes 3,990 headless checks and 4,083 rendered checks, with zero failures. CR-EXT-01 (1,983), CR-EXT-02 (1,897), CR-EXT-03 (5,431) and CR-INT-01 (2,287) were rerun and passed. Godot 4.7.2 editor import/reload and scene checks reported no GDScript errors or warnings. Modal captures and a 30-frame geometry check confirmed stable centered bounds at every requested size; local scrolling is needed only at 854×480. External browser/network navigation was intentionally not launched by automated tests.

## Official directory and media audit

Canonical root: assets/landmarks/casa_real/interior/galleries/. The folder already had the correct spelling; no gallaries folder existed, and no rename, duplication, transcoding or asset change was performed.

All 13 photographs loaded as Texture2D and all 13 clips as Godot VideoStream resources. Durations below are read directly from VideoStreamPlayer.get_stream_length(), rounded to 3 decimals. G01 video is 1024×576; the other clips are 1280×720. These are short gallery glimpse previews. Actual supplied durations range from 2.800 to 5.300 seconds, consistent with approximately 3–5 seconds; no padding, speed adjustment, duplicate frames or looping was added. Retaining real duration supports rapid, self-paced museum browsing.

| ID | Display | Official title | Photo path | Video path | Seconds | Photo source |
|---|---|---|---|---|---:|---|
| G01 | Gallery 1 | Where Asin and Bolo Embraced | assets/landmarks/casa_real/interior/galleries/cr_int_02_g01.JPG | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g01_preview.ogv | 2.800 | AKAR Research Team |
| G02 | Gallery 2 | The Shape of Our Homeland | assets/landmarks/casa_real/interior/galleries/cr_int_02_g02.png | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g02_preview.ogv | 3.040 | Daily Tribune |
| G03 | Gallery 3 | Asin Gallery & Dayat Exhibit | assets/landmarks/casa_real/interior/galleries/cr_int_02_g03.jpg | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g03_preview.ogv | 3.319 | AKAR Research Team |
| G04 | Gallery 4 | Watered by the Hands of Ama-Gaolay | assets/landmarks/casa_real/interior/galleries/cr_int_02_g04.png | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g04_preview.ogv | 4.968 | Daily Tribune |
| G05A | Gallery 5A | The Descendants of Apolaqui | assets/landmarks/casa_real/interior/galleries/cr_int_02_g05a.jpg | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g05a_preview.ogv | 3.633 | AKAR Research Team |
| G05B | Gallery 5B | Desired by the Sea Merchants | assets/landmarks/casa_real/interior/galleries/cr_int_02_g05b.jpg | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g05b_preview.ogv | 4.767 | Tom Ora / TikTok |
| G06A | Gallery 6A | Patriots and Nation Builders | assets/landmarks/casa_real/interior/galleries/cr_int_02_g06a.png | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g06a_preview.ogv | 4.471 | Daily Tribune |
| G06B | Gallery 6B | Frontrunner of Modernization | assets/landmarks/casa_real/interior/galleries/cr_int_02_g06b.jpg | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g06b_preview.ogv | 4.767 | Tom Ora / TikTok |
| G07 | Gallery 7 | Festivals by the Sea and the Fields | assets/landmarks/casa_real/interior/galleries/cr_int_02_g07.png | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g07_preview.ogv | 4.633 | Daily Tribune |
| G08 | Gallery 8 | Beachhead of Valor | assets/landmarks/casa_real/interior/galleries/cr_int_02_g08.jpg | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g08_preview.ogv | 4.667 | Tom Ora / TikTok |
| G09 | Gallery 9 | The Pilgrims Who Responded to the Call | assets/landmarks/casa_real/interior/galleries/cr_int_02_g09.png | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g09_preview.ogv | 3.737 | Getaway.PH |
| G10 | Gallery 10 | Sung Romances under the Guava Tree | assets/landmarks/casa_real/interior/galleries/cr_int_02_g10.png | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g10_preview.ogv | 5.300 | Daily Tribune |
| G11 | Gallery 11 | Luminaries of Anacbanuas | assets/landmarks/casa_real/interior/galleries/cr_int_02_g11.png | assets/landmarks/casa_real/interior/galleries/previews/cr_int_02_g11_preview.ogv | 5.133 | Daily Tribune |

## Narration and sources

Narration: assets/landmarks/casa_real/audio/cr_int_02_narration.ogg (16.0 seconds).

Speaker: assets/ui/icons/speaker.svg.

Approved transcript:

> The Banáan Pangasinan Provincial Museum presents the many stories that shape Pangasinan’s identity. Explore the gallery spaces at your own pace, then visit Banáan Museum to experience the complete exhibits, artifacts, and curatorial narratives.

One overall track only, no autoplay. LISTEN / PAUSE / RESUME remains immediately left of CLOSE. Gallery selection, video, Image Focus and Sources preserve narration position/state. Close and reopen stop/reset it. No music or narrator identity is invented.

The existing Casa Real Sources overlay is reused. It groups the directory, photos, videos and narration; each gallery Resource separately retains media_credit, media_source, video_credit and video_source for traceability. Sources preserves selection and current view, safely restores PHOTO mode, and never resumes video automatically. Modal focus is trapped; native touch scrolling and keyboard navigation are supported.

Researcher-approved source mapping:

- Daily Tribune, Galleries 2, 4, 6A, 7, 10, 11: “Cultural encounter, historic gathering: Pangasinan opens its first provincial museum,” 27 November 2023. Roel Hoang Manipon is the **article author**; photographer not identified. Project-use approval confirmed by researcher; license/copyright unspecified.
- Tom Ora | Akar ng Pangasinense / TikTok, Galleries 5B, 6B, 8: source account, not an assumed photographer. Exact post URL not found in project documentation. Project-use approval confirmed by researcher; license/copyright unspecified.
- Getaway.PH, Gallery 9: “BANÁAN: Pangasinan’s first-ever provincial museum opens to the public,” 25 September 2023. Kenneth M. del Rosario is the supplied author and photographer. Project-use approval confirmed by researcher; license/copyright unspecified.
- AKAR Research Team, photographs G01/G03/G05A, all 13 gallery videos and the overall narration: project-use approval confirmed in the supplied specification. Individual videographer/narrator names and copyright licenses are unspecified.
- Official gallery directory: researcher-supplied and approved Phase 5 specification. A separate supporting publication URL was not supplied; the implementation does not invent one.

Project-use approval is not presented as public-domain or Creative Commons permission.

## Layout and accessibility

1280×720: 90% centered inset; approximately 67% media / 33% identity and actions. The bounded trail shows several plaques when browsing its middle; at the endpoints no fabricated wrapping neighbors are shown.

960×540: 96% inset, tighter margins, active plaque and neighbors. Preview keeps the media large and allows local action-column scrolling.

854×480: 96% inset with compact trail spacing and partial neighboring plaques. Header controls stay visible; primary touch controls remain at least 56 px high. Only the preview action area or Sources text scrolls vertically. Photos and videos remain proportional; there is no page-level scrolling.

Touch and mouse support every primary control, plaque selection, swipe/drag, local scrolling, media playback/skip/replay, photo focus, Sources, narration and close/reopen. Tab / Shift+Tab cycle visible controls. Enter / Space activate controls. Sources has its own focus cycle. Escape closes Sources first, then the visit invitation when open, then Image Focus, then Preview back to Directory, then the hotspot. Navigation input is marked handled before a close can remove the component.

## Reset and interruption contract

reset_hotspot() restores DIRECTORY, PHOTO, index 0, dragging false, video_has_played false, G01 centered, Sources and visit invitation closed, narration stopped/unpaused, stream cleared, full opacity and no active tweens. Reopen calls this reset. Close/host hide stops both media players, ends gestures, kills transitions, restores transient visuals, and emits lifecycle signals. Rapid replacement cancels earlier transitions; no deferred callback swaps obsolete content into the current view.

## Validation

Validation performed with Godot 4.7.2, Compatibility rendering. The automated test instantiates the real cr_int_02_preview.tscn and its production child, injects actual mouse/touch/key events, validates every media mapping, waits for every clip's natural finish at 1280×720, and checks playback/skip/replay across all three sizes. It also checks selection, gallery entry, all directory transitions, focus, narration, modal behavior, rapid replacement and cleanup.

Initial Phase 5 test results (2026-09-27; revised visit-modal results above):

- Godot editor import, scene load and GDScript reload: passed; zero script/parse/compile errors.
- Headless CR-INT-02: 3,846 checks, zero failures.
- Rendered CR-INT-02: 3,936 checks, zero failures; 87 distinct screenshots (90 capture assertions, Sources captures reused per pointer mode).
- 1280×720, 960×540 and 854×480: passed. Directory, gallery photographs/videos, Image Focus and Sources were captured; representative captures at each size were visually inspected.
- Every one of the 13 clips decoded, played muted without looping, completed naturally and returned to its own photograph. All mappings, replay/skip, gallery changes and close during playback passed.
- Mouse/touch trail gestures and controls, keyboard navigation/focus, Continue Exploring through all 13 entries, Enter Gallery, narration, Sources, rapid switching and reset/reopen: passed.
- The standalone F6 scene was also launched directly via the Godot CLI in Compatibility mode at 854×480 and exited cleanly. Researcher pressing F6 in their own editor remains the approval step.
- The initial rendered run caught a directory minimum-height overflow at 854×480. Compact plaque padding/spacing was reduced within CR-INT-02; the subsequent full rendered and headless runs passed. The headless narration test waits for the audio mixer to acknowledge pause before sampling its position, matching the earlier hotspot test convention.
- git diff --check and whitespace checks including new untracked files: passed.

Regression results:

- CR-EXT-01: 1,983 checks, zero failures.
- CR-EXT-02: 1,897 checks, zero failures.
- CR-EXT-03: 5,431 checks, zero failures.
- CR-INT-01: 2,287 checks, zero failures.

Run from the repository root with the installed Godot console executable:

```text
Godot --headless --editor --path . --import --quit
Godot --headless --path . --script res://tests/cr_int_02_test.gd
Godot --path . --rendering-method gl_compatibility --script res://tests/cr_int_02_test.gd -- --capture
```

On this restricted Windows host, validation uses a temporary APPDATA/LOCALAPPDATA profile. An existing root-certificate-store diagnostic is environmental and separate from GDScript parsing. Screenshots are saved to %TEMP%/akar_cr_int_02_*.png. Godot's native video API is documented at https://docs.godotengine.org/en/stable/classes/class_videostreamplayer.html. Native import/playback validation does not substitute for browser/device performance review.

## Researcher F6 review

1. Open scenes/landmarks/casa_real/interior/cr_int_02_preview.tscn and press F6. Check the G01-centered Directory without autoplay.
2. Swipe/drag both ways; tap visible neighbors; check all 13 exact titles and the 5A/5B and 6A/6B grouping labels. Use Left/Right, Home/End, Enter/Space and Tab/Shift+Tab.
3. Open every Gallery Window. Watch each real clip to completion, replay, skip, then change gallery during playback. Verify muted video and proportional photo/video display.
4. Use VIEW PHOTO and CLOSE VIEW. RETURN TO DIRECTORY keeps the same selection for free-choice browsing. CONTINUE EXPLORING directly opens the next preview and loops G11 → G01 without showing Directory. Check both subdivision boundaries, rapid Continue presses and Continue during video playback; no Previous Gallery button is provided. ENTER GALLERY opens the unchanged visit invitation. Check both ordinary web links, phone/email, Tab order and BACK/Escape returning to the same gallery. At 854×480 scroll the modal text to see the inquiries while BACK remains fixed.
5. Start/pause/resume narration, then browse, play a muted clip and open Sources. Check audio continuity and modal focus. Scroll the local action column and Sources with touch and keyboard.
6. Exercise Escape through Sources → Visit invitation (when open) → Image Focus (when open) → Preview → Directory → closed. Reopen and verify full reset. Repeat rapid changes and close during video.
7. Repeat at 1280×720, 960×540 and 854×480; check readability, scrolling, actions and photographic framing. Review actual audio/video on the intended touchscreen and landscape phone/browser before approval.

## Outstanding review and repository safety

Researcher F6 visual/audio/video review remains required before milestone approval. Browser export/device performance and physical touchscreen feel remain manual review items. No master layout, gallery free-roam, CR-INT-03 or CR-END-01 is implemented. Missing publication/post URLs and unspecified licenses remain honestly documented metadata gaps, not invented credits.

Initial repository state: CR-INT-01 committed at 3e9caf4. Existing modified project.godot, docs/references and researcher-supplied CR-INT-02 media/import files were recorded before editing. SHA-256 audit confirmed all 578 pre-existing tracked/untracked files unchanged, including every earlier hotspot and media file. Only 16 new CR-INT-02 implementation files were added: two scenes, five production/preview scripts, one content Resource, one test, this document and six script UID sidecars. git diff --check passed; new files were separately checked because ordinary git diff omits untracked files. No staged files, commit or push.

Visit-invitation revision safety audit: 594 files were recorded before editing. Only seven CR-INT-02 files changed: controller, content class, content Resource, preview script, preview scene, test, and this document. All other files, including media, earlier hotspots, project.godot and docs/references, remain unchanged. Removing only the newly added visit fields reproduces the original content Resource hash, confirming all pre-existing gallery content and source mappings are byte-for-byte preserved. No new files or assets were needed. git diff --check and separate untracked-file whitespace checks passed; nothing staged, committed or pushed.
