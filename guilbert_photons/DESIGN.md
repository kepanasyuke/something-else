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

## Screen structure

1. Header: product name, one-line purpose, API and CPU status.
2. Search command: labeled query field, primary search action, live status.
3. Observatory: phase portrait on the right and parameter controls below it.
4. Results: count, export actions, accessible document rows, pagination, empty and error states.
5. Audio: an independent ambient instrument. It can run while the user searches, reads, or changes the field.

## Video animation concept

A 8-10 second loop called **Photon Trace**:

1. A small amber source point appears at the left edge of the phase field.
2. A cyan pulse travels along a measured trajectory.
3. Three to five small nodes appear at intersections, representing matched documents.
4. The trajectory settles; the coral current-state marker pulses once.
5. The document count fades in beside the field.
6. The loop returns to idle without a flash or blur.

The UI preview should animate only the SVG field. JPEG is a still snapshot; GIF is a lightweight preview. A future WebM/MP4 export should record the visualization surface rather than the entire interface.

## Interaction rules

- Search is independent from audio and never waits for a music event.
- Empty input gets an inline message.
- Network failures remain visible in the interface and do not mark workflow steps as successful.
- Every interactive control has a keyboard focus state and an accessible name.
- Reduced-motion users receive the final field state without looping animation.

## Implementation direction

Keep the current FastAPI boundary, replace the demo document list with a small SQLite-backed corpus, and keep the phase portrait local in the browser. Load export libraries lazily when their buttons are used. This keeps the first screen fast and makes the search path independent from optional media features.
