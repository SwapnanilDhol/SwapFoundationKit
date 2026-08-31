# Currency

Add the `SwapFoundationKitCurrency` product and `import SwapFoundationKitCurrency` for `Currency` and `ExchangeRateManager`.

This optional boundary keeps exchange-rate networking out of the default UI product. It preserves the currency data and routes XML fetching through the canonical injected HTTP transport.

See the [currency reference](Currency/README.md). Moving the import does not change exchange-rate freshness, rounding, currency identities, or persisted host preferences. Post-extraction verification remains pending.
