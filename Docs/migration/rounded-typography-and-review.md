# Adopting rounded typography and `requestReview(reason:)`

Two capabilities that host apps had each reimplemented now live in SFK. This is
the reference for replacing a host app's local copy.

## 1. Rounded typography that survives SwiftUI

### The problem this solves

`SFKAppearanceManager.configure()` sets `UIAppearance` proxies. SwiftUI
modifiers like `toolbarBackground` synthesize **fresh, per-instance**
`UINavigationBarAppearance` values that do not inherit those proxy fonts, so
navigation chrome silently reverts to the system font — sometimes only on
certain screens, sometimes only after a push or a scroll-edge transition.

Configuring appearance once at launch is therefore not sufficient on its own.
Fonts have to be re-applied to live navigation objects as SwiftUI resynthesizes
them.

### API

| Symbol | Use |
|---|---|
| `SFKAppearanceManager.configure()` | Call once at launch. Also reinforces the proxy values. |
| `SFKAppearanceManager.applyRoundedFonts(to: UINavigationBar)` | Re-patch a live navigation bar. |
| `SFKAppearanceManager.applyRoundedFonts(to: UINavigationItem)` | Re-patch appearances SwiftUI synthesized for a screen's toolbar. |
| `SFKRoundedHostingController` | Hosts a SwiftUI view and performs the re-application for you. |

Most apps need only `configure()` plus `SFKRoundedHostingController`. Reach for
`applyRoundedFonts(to:)` directly only when hosting SwiftUI through something
other than that controller.

### Migrating

Replace a local rounded hosting controller with a subclass:

```swift
// Before: a local UIHostingController<AnyView> subclass duplicating the
// font application and the appear/layout re-patching.
final class AppHostingController<Content: View>: UIHostingController<AnyView> { ... }

// After: inherit the re-application, keep only what is app-specific.
final class AppHostingController<Content: View>: SFKRoundedHostingController<Content> {
    override func viewDidDisappear(_ animated: Bool) { ... }
}
```

Then delete the app's own font constants and navigation-patch helpers. Keep any
deliberate visual divergence — for example, MoneyTracker keeps a translucent tab
bar where SFK configures an opaque one — and document it inline so it does not
read as an oversight.

`SFKRoundedHostingController` re-applies from `viewWillAppear`, `viewDidAppear`
(plus a deferred pass, because SwiftUI can synthesize appearances after
`viewDidAppear` returns) and `viewDidLayoutSubviews`. That looks redundant and
is not: the resynthesis happens more than once per screen and at points that
are not reliably observable.

## 2. `requestReview(reason:)`

### Migrating

```swift
// Before — per-app copy, often on the deprecated SKStoreReviewController,
// and with a `foregroundActiveScene` that took connectedScenes.first.
UIApplication.shared.requestReview(reason: "textTransactionEntry")

// After — identical call site, now backed by SFK.
UIApplication.shared.requestReview(reason: "textTransactionEntry")
```

Delete the app's local `requestReview` and `foregroundActiveScene`, and the
`StoreKit` import if nothing else in the file uses it.

### What changes behaviourally

- Uses `AppStore.requestReview(in:)`. Apps still on `SKStoreReviewController`
  move off a deprecated API.
- `foregroundActiveScene` filters on `activationState == .foregroundActive`
  rather than taking `connectedScenes.first`. The naive version can return a
  background scene under iPad multi-scene, Slide Over, and Split View.
- The scene is resolved **after** the ~1.5s delay, not before. An app
  backgrounded during the wait no longer spends one of the user's three annual
  prompts on a scene that cannot display it.

### `reason` is required

iOS caps review prompts at three per user per year and reports nothing back
about whether one was actually shown. `reason` is logged via `Logger` under the
`"Review"` context on both the request and the dropped-request paths, so it is
possible to tell after the fact which trigger consumed the quota, or that a
request was dropped for want of a foreground scene.

There is no unparameterised `requestReview()`. Pass a stable identifier for the
trigger, not a user-facing string.

## Host apps not yet migrated

At time of writing these still carry local copies: PassMaker, SubscriptionTracker,
Goaley, ColorPicker, METARBuddy, StickerTweet. PassMaker additionally has its own
`appRoundedTypography()` covering the same ground as the typography work above.
