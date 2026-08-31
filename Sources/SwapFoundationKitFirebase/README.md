# Firebase analytics adapter

Add the `SwapFoundationKitFirebase` product and `import SwapFoundationKitFirebase` when adopting the SFK analytics adapter.

The host owns Firebase installation and initialization. This product does not add the Firebase SDK to every SFK consumer. Supply event, user-property, screen, and identity handlers that forward to the host's Firebase installation; a host-level Firebase import does not automatically link the SDK into this SwiftPM target.

The initializer requires forwarding handlers; there is no zero-argument logger. Preserve event names and payload schemas in those handlers and verify delivery in the host before release. Compilation and handler-forwarding tests pass in the consolidated package suite; Firebase SDK delivery remains host-owned validation.
