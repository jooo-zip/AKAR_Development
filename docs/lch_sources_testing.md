# Limahong Sources overlay completion report

Completed: 2026-10-01. Scope: EXT-01/02/03, INT-01/02/03 and END-01.
Status: implemented and tested; researcher F6 visual review pending.

## Repository audit

AGENTS.md was read and the actual resources, Sources controllers, media metadata,
existing tests and Git state were inspected before editing. Starting state:
**0 staged, 51 unstaged, 35 untracked files**. This includes the previous uncommitted
Limahong header/narration work and unrelated modifications to AGENTS.md,
project.godot, other-landmark resources and the END-01 preview. All were preserved.
The audit snapshot, original file copies, index, HEAD and SHA-256 records are under
`%TEMP%/akar-lch-sources-20260930/` (audit began September 30; completion October 1).

No website was substituted for the researcher's approved references. Repository
metadata and documentation contained no stronger verified provenance for the exact
INT-02 Salcedo portrait, so the supplied Jardin Solei / The Crafty Historian credit
was used. END-01 uses generated graphics; no external photographic credit was added.

## Final Sources presentation

Each existing modal now shows:

```text
SOURCES

HISTORICAL REFERENCES
[approved hotspot-specific entries]

MEDIA CREDITS
[hotspot-specific provenance and project credits]
```

The same inherited overlay remains bounded inside the hotspot. Title and Close
stay fixed; only the text area scrolls. Font size is 22 px wide / 20 px compact;
Close remains at least 48 px high. Titles wrap and long URLs do not create
horizontal scrolling. The existing plain Label cannot open links, so canonical
URLs are stored in Resource metadata and recorded below instead of displayed inline.
`metadata/historical_source_urls` follows the visible historical-reference order.
INT-02's two webpage image sources have person-level `metadata/source_url` fields.
The book provenance has no invented URL.

The new small Limahong-only `lch_sources_overlay.gd` sets the two-section text and
uppercase modal title, adjusts only Sources typography and supports internal
keyboard/touch scrolling. It also places the modal at z_index 3 so EXT-02's
existing z_index 2 route ship cannot draw over source text. The route itself is
unchanged. The helper is attached by each controller. It does not own
historical or narration data and does not modify the shared component or header
helper. INT-02's Sources method now lists all three person Resources instead of
only the currently selected person's metadata. Known optional metadata remains
supported; unknown portrait ownership/permissions are omitted rather than invented.
INT-03 continues to append its existing `source_text()` output unchanged.

## Historical references by hotspot

| Hotspot | Approved references shown |
|---|---|
| EXT-01 | Lingayen (2020); Austria (2019); Pangasinan History (n.d.); Martindale (2024) |
| EXT-02 | Sande (1903; original 1576); Shutz (2019) |
| EXT-03 | Sande (1903; original 1576); Shutz (2019); Pangasinan History (n.d.); Martindale (2024) |
| INT-01 | Sande (1903; original 1576); Shutz (2019); Pangasinan History (n.d.); Martindale (2024) |
| INT-02 | Sande (1903; original 1576); Shutz (2019) |
| INT-03 | Austria (2018); Austria (2019); Lingayen (2020); Lingayen bidding document (2025); Pasiliao (2020) |
| END-01 | Sande (1903; original 1576); Shutz (2019); Martindale (2024); Pangasinan History (n.d.); Lingayen (2020); Austria (2018); Austria (2019); Pasiliao (2020) |

Existing historical qualifications within EXT-03, INT-02 and END-01 Sources were
retained. No internal Validation Sheet is presented as a historical source.
All normal hotspot content, dates, captions, qualifications, facility statuses,
reflection, takeaway and narration transcripts are unchanged.

## Media attribution

| Hotspot | Credits shown |
|---|---|
| EXT-01 | `lch_ext_01_channel_present`: Courtesy of the Lingayen Tourism Office; supplied directly for project use. Other locator/interface/map treatments/icons: AKAR Project / AKAR Research Team. |
| EXT-02 | Maps, route/marker/vessel/settlement and interface visuals: AKAR Project / AKAR Research Team. |
| EXT-03 | Tactical map, settlement, expedition markers, routes, vessel, diagrams/icons: AKAR Project / AKAR Research Team. |
| INT-01 | Statue photograph and interface graphics/icons: AKAR Project / AKAR Research Team. |
| INT-02 | Limahong: Lingayen in Time, p. 5, scanned book copy. Lavezaris: Kahimyang, supplied article title. Salcedo: Jardin Solei / The Crafty Historian, supplied article title and June 7, 2020 date. AKAR card framing/diagrams/interface separately credited. |
| INT-03 | Liwayway Yparraguirre / Philippine News Agency; Municipality of Lingayen; AKAR research team. All original detailed metadata and permission wording retained. |
| END-01 | Summary symbols, diagrams, icons, storyline/interface graphics: AKAR Project / AKAR Research Team. No external photo claimed. |

INT-03's Groundbreaking, Bataoil and PresentSite media resource blocks were
byte-compared against the pre-task copies and are unchanged. In particular:

2019 GROUNDBREAKING: Liwayway Yparraguirre / Philippine News Agency.
Photographer: Liwayway Yparraguirre. Article author: Hilda Austria.
Date: June 2019. Source: Philippine News Agency.

LEOPOLDO N. BATAOIL: Municipality of Lingayen.
Source: Municipality of Lingayen official website.
Page context: Official page identifying Hon. Leopoldo Bataoil.

PRESENT-SITE PHOTO: AKAR research team.
Source: AKAR research team.
Date: 2026-07-18 11:44:09 (embedded EXIF DateTimeOriginal; timezone unspecified).
Permission/reuse: Research-team captured / authorized for AKAR use.

All existing media fields and their source_text() output are preserved verbatim,
including known locations, event/type metadata and existing pending fields.
External reuse permissions are not inferred from citation. Individual project
photographer attribution remains unspecified as before.

Attribution/provenance is distinct from ownership or permission. The supplied
Tourism Office photograph and three sourced personality images are not described
as AKAR-owned. No author, artist, photographer, date, publisher, license or
permission beyond supplied/existing metadata was invented.

## Verification

| Suite | Result |
|---|---|
| `tests/lch_sources_test.gd` | 4599 checks, 0 failures |
| `tests/lch_header_test.gd` | 3461 checks, 0 failures |
| `tests/lch_ext_01_test.gd` | 0 failures, all three sizes |
| `tests/lch_ext_02_test.gd` | 0 failures, all three sizes |
| `tests/lch_ext_03_test.gd` | 0 failures, all three sizes |
| `tests/lch_int_01_test.gd` | 594 checks, 0 failures |
| `tests/lch_int_02_test.gd` | 2663 checks, 0 failures |
| `tests/lch_int_03_test.gd` | 1859 checks, 0 failures |
| `tests/lch_end_01_test.gd` | 4865 checks, 0 failures |

Godot 4.7.2 stable, Compatibility. All seven Sources overlays were exercised at
1280x720, 960x540 and 854x480 in their existing previews. The Sources-specific
suite checks exact inclusion/exclusion of reference sets, canonical URLs, special
media credits, no internal validation citation, no invented portrait license,
INT-03 complete original metadata, modal bounds, readable fonts, touch dimensions,
no horizontal scroll, mouse wheel, touchscreen swipe, keyboard Home/PageDown/End,
focus trap/return, fixed Close, Escape hierarchy, all historical state selections,
END-01 NONE, actual assigned audio continuity, and unchanged header geometry.

INT-01's old active-section-prefix assertion was updated to the approved standard
Sources heading while still asserting its selected section. INT-02's old pending
selected-image assertion now requires all three supplied provenances. Its optional
metadata fixture remains tested. All other regression assertions are retained.

Relevant headless import exits 0. No parser, missing resource, invalid UID, broken
audio-reference or duplicate-node errors. `git diff --check` and new-text-file
whitespace checks pass. Existing environment diagnostics remain: Windows root
certificate-store error, EXT-01/02 shutdown ObjectDB warnings (2/3 instances), and
INT-03's deliberate missing-image fixture warning. These do not fail assertions.

Rendered top and bottom snapshots cover all seven overlays at all three sizes:
`%TEMP%/lch-sources-<id>-<width>x<height>-top.png` and `-bottom.png`.
Logs: `%TEMP%/akar-sources-*.log`. Physical touchscreen and browser-export testing
were not performed; touch tests use native synthetic events. F6 approval is pending.

```text
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/lch_sources_test.gd
godot --path . --script res://tests/lch_sources_test.gd -- --capture
godot --headless --path . --script res://tests/lch_header_test.gd
godot --headless --path . --script res://tests/lch_<id>_test.gd
git diff --check
```

## Files changed for this Sources revision

The following 21 files were already modified when this task began. Only the
Sources data, Sources helper hookup, INT-02 Sources formatting, and appended
Sources documentation were changed on top of that existing work.

| Hotspot | Data resource | Controller | Testing documentation |
|---|---|---|---|
| EXT-01 | `data/landmarks/limahong_channel/lch_ext_01.tres` | `scripts/landmarks/limahong_channel/lch_ext_01.gd` | `docs/lch_ext_01_testing.md` |
| EXT-02 | `data/landmarks/limahong_channel/lch_ext_02.tres` | `scripts/landmarks/limahong_channel/lch_ext_02.gd` | `docs/lch_ext_02_testing.md` |
| EXT-03 | `data/landmarks/limahong_channel/lch_ext_03.tres` | `scripts/landmarks/limahong_channel/lch_ext_03.gd` | `docs/lch_ext_03_testing.md` |
| INT-01 | `data/landmarks/limahong_channel/lch_int_01.tres` | `scripts/landmarks/limahong_channel/lch_int_01.gd` | `docs/lch_int_01_testing.md` |
| INT-02 | `data/landmarks/limahong_channel/lch_int_02.tres` | `scripts/landmarks/limahong_channel/lch_int_02.gd` | `docs/lch_int_02_testing.md` |
| INT-03 | `data/landmarks/limahong_channel/lch_int_03.tres` | `scripts/landmarks/limahong_channel/lch_int_03.gd` | `docs/lch_int_03_testing.md` |
| END-01 | `data/landmarks/limahong_channel/lch_end_01.tres` | `scripts/landmarks/limahong_channel/lch_end_01.gd` | `docs/lch_end_01_testing.md` |

Additional existing tests updated:
- `tests/lch_int_01_test.gd`
- `tests/lch_int_02_test.gd`

New files:
- `scripts/landmarks/limahong_channel/lch_sources_overlay.gd`
- `scripts/landmarks/limahong_channel/lch_sources_overlay.gd.uid`
- `tests/lch_sources_test.gd`
- `tests/lch_sources_test.gd.uid`
- `docs/lch_sources_testing.md`

No scene, existing header helper, shared component, audio, image or project
configuration was changed by this revision. The Sources button placement and
SOURCES / LISTEN / CLOSE toolbar remain exactly as before. All seven authorized
narration assignments and OGG bytes are unchanged; Listen remains enabled.

## Canonical historical URLs

**Lingayen (2020)**

Municipality of Lingayen. (2020).
Limahong Channel Tourism Center Soon to Be Operational.

https://www.lingayen.gov.ph/limahong-channel-tourism-center-soon-to-be-operational/

**Austria (2018)**

Austria, H. (2018).
Limahong Channel Tourism Center to Be Built This Year.
Philippine News Agency.

https://www.pna.gov.ph/articles/1029395

**Austria (2019)**

Austria, H. (2019).
Limahong Channel Tourism Center in Pangasinan Groundbreaks.
Philippine News Agency.

https://www.pna.gov.ph/articles/1071673

**Pangasinan History (n.d.)**

Provincial Government of Pangasinan. (n.d.).
History.

https://www.pangasinan.gov.ph/the-province/history/

**Martindale (2024)**

Martindale, W. (2024).
The Many Names of Limahong: Remembering a Chinese Pirate in the Philippines.
BYU Asian Studies Student Journal, 9, Article 6.

https://scholarsarchive.byu.edu/asj/vol9/iss1/6

**Sande (1903; original 1576)**

Sande, F. de. (1903).
Relation of the Filipinas Islands.
In E. H. Blair & J. A. Robertson (Eds. & Trans.),
The Philippine Islands, 1493–1803, Vol. 4, pp. 21–97.
Original work dated 1576.

https://www.gutenberg.org/cache/epub/12635/pg12635-images.html

**Shutz (2019)**

Shutz, J. T. (2019).
Limahong's Pirates, Ming Mariners, and Early Sino-Spanish Relations: The Pangasinan Campaign of 1575 and Global History from Below.
Philippine Studies: Historical and Ethnographic Viewpoints, 67(3–4), 315–342.

https://doi.org/10.13185/2244-1638.1019

**Lingayen bidding document (2025)**

Municipality of Lingayen. (2025).
Bidding Documents for the Construction of a Multi-Purpose Building in the Limahong Tourism Center, Barangay Pangapisan North, Lingayen, Pangasinan.

https://www.lingayen.gov.ph/wp-content/uploads/INVITATION-TO-BID-_CONSTRUCTION-OF-MULTI-PURPOSE-BUILDING-SENIOR-CITIZEN-BUILDING-IN-LIMAHONG-TOURSIM-CENTER-BARANGAY-PANGAPISAN-NORTH.pdf

**Pasiliao (2020)**

Pasiliao, J. J. (2020).
Limahong Channel Hub to Boost Tourism, Jobs in Pangasinan Town.
Philippine News Agency.

https://www.pna.gov.ph/articles/1091355

## Canonical INT-02 image provenance

LAVEZARIS

Kahimyang.
"Slavery Among the Natives according Guido de Lavezaris."

https://kahimyang.com/kauswagan/articles/1705/slavery-among-the-natives-according-guido-de-lavezaris

SALCEDO

Jardin Solei / The Crafty Historian.
"The Love Story of Kandarapa and Juan de Salcedo: An Ill-Fated Romance."
June 7, 2020.

https://jardinsolei.wordpress.com/2020/06/07/the-love-story-of-kandarapa-and-juan-de-salcedo-an-ill-fated-romance/comment-page-1/

LIMAHONG

Lingayen in Time, p. 5.
Scanned book copy used by the AKAR Research Team.

## Git preservation

Final status: **0 staged, 51 unstaged, 40 untracked files**. This Sources revision
changed 23 existing already-dirty files and added five files. Every other baseline
file remains byte-identical, including project.godot, AGENTS.md, all other-landmark
resources, the existing END-01 preview, header helper, existing OGG/import files,
all photographs/maps and unrelated untracked files. Index entries and HEAD remain
identical to the starting snapshot. No reset, restore, stage, unstage, commit,
amend or push. No master scene or additional hotspot was created.

Starting status (exact file inventory):

```text
 M AGENTS.md
 M data/landmarks/casa_real/cr_end_01.tres
 M data/landmarks/casa_real/cr_ext_01.tres
 M data/landmarks/casa_real/cr_ext_02.tres
 M data/landmarks/casa_real/cr_ext_03.tres
 M data/landmarks/casa_real/cr_int_01.tres
 M data/landmarks/casa_real/cr_int_02.tres
 M data/landmarks/casa_real/cr_int_03.tres
 M data/landmarks/limahong_channel/lch_end_01.tres
 M data/landmarks/limahong_channel/lch_ext_01.tres
 M data/landmarks/limahong_channel/lch_ext_02.tres
 M data/landmarks/limahong_channel/lch_ext_03.tres
 M data/landmarks/limahong_channel/lch_int_01.tres
 M data/landmarks/limahong_channel/lch_int_02.tres
 M data/landmarks/limahong_channel/lch_int_03.tres
 M data/landmarks/lingayen_church/lc_end_01.tres
 M data/landmarks/lingayen_church/lc_ext_01.tres
 M data/landmarks/lingayen_church/lc_ext_02.tres
 M data/landmarks/lingayen_church/lc_ext_03.tres
 M data/landmarks/lingayen_church/lc_int_01.tres
 M data/landmarks/lingayen_church/lc_int_02.tres
 M data/landmarks/pangasinan_provincial_capitol/ppc_end_01.tres
 M data/landmarks/pangasinan_provincial_capitol/ppc_ext_01.tres
 M data/landmarks/pangasinan_provincial_capitol/ppc_int_01.tres
 M data/landmarks/pangasinan_provincial_capitol/ppc_int_02.tres
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M docs/lch_end_01_testing.md
 M docs/lch_ext_01_testing.md
 M docs/lch_ext_02_testing.md
 M docs/lch_ext_03_testing.md
 M docs/lch_int_01_testing.md
 M docs/lch_int_02_testing.md
 M docs/lch_int_03_testing.md
 M project.godot
 M scenes/landmarks/limahong_channel/summary/lch_end_01_preview.tscn
 M scripts/landmarks/limahong_channel/lch_end_01.gd
 M scripts/landmarks/limahong_channel/lch_ext_01.gd
 M scripts/landmarks/limahong_channel/lch_ext_02.gd
 M scripts/landmarks/limahong_channel/lch_ext_03.gd
 M scripts/landmarks/limahong_channel/lch_int_01.gd
 M scripts/landmarks/limahong_channel/lch_int_02.gd
 M scripts/landmarks/limahong_channel/lch_int_03.gd
 M tests/lch_end_01_test.gd
 M tests/lch_ext_01_test.gd
 M tests/lch_ext_02_test.gd
 M tests/lch_ext_03_test.gd
 M tests/lch_int_01_test.gd
 M tests/lch_int_02_test.gd
 M tests/lch_int_03_test.gd
?? assets/landmarks/limahong_channel/audio/lch_end_01_narration.ogg
?? assets/landmarks/limahong_channel/audio/lch_end_01_narration.ogg.import
?? assets/landmarks/limahong_channel/audio/lch_ext_01_narration.ogg
?? assets/landmarks/limahong_channel/audio/lch_ext_01_narration.ogg.import
?? assets/landmarks/limahong_channel/audio/lch_ext_02_narration.ogg
?? assets/landmarks/limahong_channel/audio/lch_ext_02_narration.ogg.import
?? assets/landmarks/limahong_channel/audio/lch_ext_03_narration.ogg
?? assets/landmarks/limahong_channel/audio/lch_ext_03_narration.ogg.import
?? assets/landmarks/limahong_channel/audio/lch_int_01_narration.ogg
?? assets/landmarks/limahong_channel/audio/lch_int_01_narration.ogg.import
?? assets/landmarks/limahong_channel/audio/lch_int_02_narration.ogg
?? assets/landmarks/limahong_channel/audio/lch_int_02_narration.ogg.import
?? assets/landmarks/limahong_channel/audio/lch_int_03_narration.ogg
?? assets/landmarks/limahong_channel/audio/lch_int_03_narration.ogg.import
?? assets/landmarks/lingayen_church/audio/lc_end_01_narration.ogg
?? assets/landmarks/lingayen_church/audio/lc_end_01_narration.ogg.import
?? assets/landmarks/lingayen_church/audio/lc_ext_01_narration.ogg
?? assets/landmarks/lingayen_church/audio/lc_ext_01_narration.ogg.import
?? assets/landmarks/lingayen_church/audio/lc_ext_02_narration.ogg
?? assets/landmarks/lingayen_church/audio/lc_ext_02_narration.ogg.import
?? assets/landmarks/lingayen_church/audio/lc_ext_03_narration.ogg
?? assets/landmarks/lingayen_church/audio/lc_ext_03_narration.ogg.import
?? assets/landmarks/lingayen_church/audio/lc_int_01_narration.ogg
?? assets/landmarks/lingayen_church/audio/lc_int_01_narration.ogg.import
?? assets/landmarks/lingayen_church/audio/lc_int_02_narration.ogg
?? assets/landmarks/lingayen_church/audio/lc_int_02_narration.ogg.import
?? docs/lch_header_testing.md
?? docs/references/lingayen_church/lingayen_memories_times_past_p20_source.jpeg
?? docs/references/lingayen_church/lingayen_memories_times_past_p20_source.jpeg.import
?? docs/references/lingayen_church/lingayen_memories_times_past_p30_source.jpeg
?? docs/references/lingayen_church/lingayen_memories_times_past_p30_source.jpeg.import
?? scripts/landmarks/limahong_channel/lch_header_utilities.gd
?? scripts/landmarks/limahong_channel/lch_header_utilities.gd.uid
?? tests/lch_header_test.gd
?? tests/lch_header_test.gd.uid
```

## Researcher F6 review

1. Open each existing Limahong preview and press F6 at 1280x720, 960x540 and 854x480.
2. Select a non-default locator/stage/person/section/topic, then start Listen.
3. Open Sources. Confirm its title, historical references and media credits.
   Check the Tourism Office credit and all three personality-image sources;
   compare INT-03's detailed credits with the supplied metadata.
4. Swipe within the text area, use the mouse wheel, then Tab to text and use
   Home/PageDown/End. Confirm fixed title/Close, wrapping and no horizontal scroll.
5. Escape closes Sources first and restores focus to Sources. Check that content
   selection, magnifier state and narration remain unchanged. Close the hotspot;
   narration stops. Reopen to verify the existing reset behavior.

Outstanding: researcher F6 visual review and optional physical-touch/browser review.
No additional historical/media metadata is invented to fill remaining unknowns.
Stop after this revision; no commit or push.
