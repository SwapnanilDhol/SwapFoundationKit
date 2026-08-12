# SwapFoundationKitFeedback

`SwapFoundationKitFeedback` owns the reusable feedback contract, client,
attachment processing, form state, SwiftUI screen, and UIKit coordinator.
Host apps inject their endpoint, accent, verified privacy/retention copy,
installation identity, RevenueCat-derived context, and analytics mapping.

Do not put RevenueCat or product analytics dependencies in this target.
Those remain host-app composition concerns.
