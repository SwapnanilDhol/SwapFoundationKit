# SwapFoundationKitPulse

Opt-in Pulse integration for network logging and the debug console. Add the
`SwapFoundationKitPulse` product and `import SwapFoundationKitPulse` when the
host app needs `SFKPulseService` or `SFKPulseConsoleView`.

Configure `SFKPulseService` before constructing `HTTPClient` instances or
touching `SwapFoundationKit.shared` so the instrumentation seam is registered
before clients are created. See [the extraction guide](../Docs/migration/v4-phase-1-product-extraction.md).
