# SFK Catalog

`SwapFoundationKitHost` builds the **SFK Catalog** app: a searchable, installable reference for SwapFoundationKit components and APIs.

## Install on an iPhone

1. Open `SwapFoundationKitHost.xcodeproj` in Xcode.
2. Select the `SwapFoundationKitHost` scheme.
3. Choose a connected iPhone as the run destination.
4. Confirm the signing team under the app target's Signing & Capabilities settings.
5. Press Run.

The target links the repository's local `SwapFoundationKit` package, so rebuilding the catalog reflects local SFK changes immediately.

## Add a catalog entry

1. Add the destination and searchable API names to `CatalogDestination.swift`.
2. Add its destination mapping to `CatalogDestinationView.swift`.
3. Reuse an existing example screen or add a focused `*ExamplesView` with deterministic live states.
4. Build and inspect the app in Simulator before committing.

The registry is intentionally explicit. A missing catalog entry is visible in code review, and the on-device app never depends on repository documentation files being present at runtime.
