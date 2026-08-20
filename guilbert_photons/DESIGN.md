# Guilbert Photons: Photon Observatory

## Product idea

Guilbert Photons is a document observatory: a query enters the optical field, the phase portrait shows the search state, and the result table becomes the readable evidence. Physics is used as a visual language for state and motion, not as decoration or a promise of a real quantum engine.

## Visual system

- **Surface:** graphite laboratory background with quiet cyan signal lines.
- **Cyan:** active signal, focus, trajectory, live connection.
- **Amber:** source, initial state, adjustable parameter.
- **Coral:** current state, warning, destructive action.
- **Typography:** expressive geometric sans for interface text; monospace only for IDs, latency, and API values.
- **Shape:** compact 8-12px controls, thin borders, dense panels, no nested glass cards.
- **Motion:** short, informative transitions. The trajectory draws when a search starts; points pulse only when state changes; results reveal in a short stagger. No blur, spinning papers, or motion that hides content.
- **Motion control:** animation is an interface setting, not a code-only feature. The user can switch it off and the choice is stored locally; `prefers-reduced-motion` is respected automatically.
- **Control rhythm:** every secondary control uses the same stack: action, one-line explanation, equal bottom spacing. Atmosphere and animation are presented as a matched pair.
- **Thermal field:** the phase viewport uses a satellite-style thermal wash instead of a grid. The pointer is a local heat source: movement places the warm spot, stillness increases its intensity, and leaving the field lets it cool down.
- **Field telemetry:** the viewport always names its current state (`waiting`, `observing`, `cooling`, or `paused`) so animation has an understandable cause and effect.
- **Thermal logo:** the logo orb mirrors field intensity and search state. It breathes at idle, accelerates during scanning, turns cyan on found, and coral on error.

## Developer color tokens

The palette is implemented as CSS custom properties in `guilbert.css`. Use semantic tokens in components instead of introducing one-off colors.

| Token | Value | Use |
| --- | --- | --- |
| `--photon-ink` | `#071014` | page background and primary dark text |
| `--photon-surface` | `#10252a` | observatory surface |
| `--photon-canvas` | `#061013` | phase field canvas |
| `--photon-heat-cold` | `#79e1d2` | cold signal, focus, trajectory |
| `--photon-heat-warm` | `#f6c267` | source, parameter, warming |
| `--photon-heat-hot` | `#f27f6d` | hot zone, warning, destructive action |
| `--photon-paper` | `#e9f1e8` | high-emphasis text and primary controls |
| `--photon-muted` | `#91a9a9` | secondary text and telemetry |
| `--photon-line` | `rgba(154, 224, 210, 0.16)` | borders and quiet separators |

Color is never the only state signal: active controls also use text, shape, focus rings, or `aria-pressed`. Thermal colors are reserved for the field and must not be reused for long blocks of body text.

## Control state matrix

| State | Visual treatment | UX meaning |
| --- | --- | --- |
| Rest | quiet surface, thin border, muted text | available but not competing with the query |
| Hover | brighter border and surface | target is discoverable before commitment |
| Focus | amber ring with offset | keyboard position is always visible |
| Pressed | one-pixel downward shift and semantic accent | action was physically received |
| Active | inset signal line and `aria-pressed` | mode remains selected after the click |
| Loading | spinner, hidden label, disabled duplicate clicks | work is in progress |
| Disabled | reduced opacity and `not-allowed` cursor | action is unavailable, never mysterious |
| Error | coral edge and explicit text | recovery is needed; color is not the only clue |

The primary action is the only full-width high-energy control. Export, mode, audio, motion, pagination, and destructive actions use quieter surfaces so the search command stays visually dominant. This follows the useful density of the local `search-service` interface while keeping the observatory's thermal language and focus treatment distinct.

## Screen structure

1. Header: product name, one-line purpose, API and CPU status.
2. Search command: labeled query field, primary search action, live status.
3. Observatory: phase portrait on the right and parameter controls below it.
4. Results: count, export actions, accessible document rows, pagination, empty and error states.
5. Audio: an independent ambient instrument. It can run while the user searches, reads, or changes the field.

## UX state strategy

The interface has three synchronized feedback channels: status text for clarity, the thermal field for spatial exploration, and the logo orb for peripheral awareness. Search phases are explicit: `idle` invites action, `scanning` confirms work is underway, `found` settles the result, and `error` uses a coral signal without hiding the cause in an animation. No state depends on color alone, and every animated state has a static equivalent.

## Video animation concept

A 8-10 second loop called **Photon Trace**:

1. A small amber source point appears at the left edge of the phase field.
2. A cyan pulse travels along a measured trajectory.
3. Three to five small nodes appear at intersections, representing matched documents.
4. The trajectory settles; the coral current-state marker pulses once.
5. The document count fades in beside the field.
6. The loop returns to idle without a flash or blur.

The UI preview should animate only the SVG field. JPEG is a still snapshot; GIF is a lightweight preview. The trace has four readable phases: source ignition, moving pulse, staggered detection nodes, and result settlement. A future WebM/MP4 export should record the visualization surface rather than the entire interface.

## Interaction rules

- Search is independent from audio and never waits for a music event.
- Changing the language reruns the current query immediately and keeps the table state coherent.
- `All languages` is the default search mode; language selection is an optional refinement, not a navigation requirement.
- Search normalizes case and diacritics, understands local aliases, and falls back across the supported language dictionaries.
- Empty input gets an inline message.
- Network failures remain visible in the interface and do not mark workflow steps as successful.
- Every interactive control has a keyboard focus state and an accessible name.
- Reduced-motion users receive the final field state without looping animation.
- The thermal field is scoped to the viewport and remains decorative; it never changes search data or interaction semantics.

## Implementation direction

Keep the current FastAPI boundary and local normalized JSON corpus; the current dataset contains 5,000 OpenAlex works plus curated multilingual annotations. Keep the phase portrait and thermal interaction local in the browser. Load export libraries lazily when their buttons are used. SQLite FTS5 remains a future indexing option when explainable ranking is needed.

## Scientific corpus

The current local corpus contains 5,000 normalized OpenAlex works plus 21 curated navigation annotations in Russian, French, and German, for 5,021 local records. Each record keeps a title, abstract, topic labels, language, publication date, journal, authors, DOI, source URL, and Open Access flag. The corpus is bibliographic discovery data: the interface presents abstracts and links, not copied full-text articles.

Run `make build-corpus` to refresh it. Use `make build-corpus CORPUS_TARGET=3000`, `5000`, or `8000` to choose the corpus size. The generator records its provider, query families, timestamp, and licensing note in `knowledge_base.meta.json`. Search currently uses normalized field matching; SQLite FTS5 is the next indexing step for ranking and larger imports.

## Design strategy review

The interface follows a three-layer hierarchy: command (query and language), observatory (phase state and controls), and evidence (document rows). This keeps the expressive field subordinate to the research task. Compared with a generic dashboard, the system uses motion as feedback for state transitions rather than decoration: one pulse means active computation, nodes mean discovered matches, and the table remains readable when motion is disabled. Compared with the neighboring `shadow_scene` screen, Guilbert uses denser operational controls and a stronger state vocabulary instead of relying on a single visual scene. The next safe improvement is ranked retrieval with explainable match reasons before adding more visual effects.

## Design QA checklist

- The search command is the first high-contrast action in the workflow.
- Every button has a visible label or an accessible name, a hover state, a focus state, a pressed/active state where relevant, and a disabled state where relevant.
- New control styling uses semantic color tokens consistently; legacy SVG artwork may keep local raw colors until it is migrated to the same token set.
- Motion explains a state change and has a static equivalent.
- A user can complete search, language selection, row expansion, pagination, and export with keyboard focus.
- Mobile controls wrap without changing their order or meaning.

## Supported search languages

The search interface supports an `all` mode plus Russian (`ru`), French (`fr`), and German (`de`). The corpus remains bibliographic and primarily English; a local terminology map translates common astronomy, astrophysics, cosmology, quantum, particle, and space terms into searchable corpus terms without duplicating source records.
