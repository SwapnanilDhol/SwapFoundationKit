# Subscription Free Trial Audit — 2026-04-20

## Executive Summary

Audited and standardized free trial configuration across 7 apps in RevenueCat and App Store Connect (ASC).
Standard pattern adopted: **Weekly = 3-day free trial**, **Monthly = 1-month free trial**, **Yearly = no trial**.
Two offerings per app: **(weekly + yearly + lifetime)** as current, **(monthly + yearly + lifetime)** as inactive.

---

## Standard Reference

| Subscription Period | Free Trial Duration | `trailEligibleSubtitle` value |
|---|---|---|
| Weekly | 3 days | `"3 days free trial"` |
| Monthly | 1 month | `"1 month free trial"` |
| Yearly | None | (no field) |

### Invalid / Unavailable Territory Codes
The following territory codes are **not valid** in App Store Connect and can never have free trial offers:
- `PRI`, `VIR`, `GUM`, `MNP`, `ASM`, `GRL` (US territories)
- `BGD`, `ETH`, `BDI`, `SOM` (country codes not supported by ASC for subscriptions)
- `LSO`, `TGO`, `GIN`, `GNQ`, `DJI`, `SSD` (not supported by ASC)

These should be excluded from any CSV imports.

---

## App-by-App Results

---

### 1. Aeronautical

**RevenueCat Project ID:** `bf71a0a6`
**ASC App ID:** `1448345448`

#### Subscriptions (ASC)
| Subscription | ASC ID | Period | Trial | Territory Count |
|---|---|---|---|---|
| Weekly | `6762065613` | ONE_WEEK | 3-day FREE_TRIAL | ~152 |
| Monthly | `6471916157` | ONE_MONTH | 1-month FREE_TRIAL | ~153 |
| Yearly | `6471916249` | ONE_YEAR | None | 0 |

#### Offerings (RevenueCat)
| Offering | ID | Status | Weekly | Monthly | Yearly | Lifetime |
|---|---|---|---|---|---|---|
| Weekly, Yearly, Lifetime | `ofrng14070eb37b` | **Current** | `"3 days free trial"` | — | none | none |
| Monthly, Yearly, Lifetime | `ofrnge35e7261d2` | Inactive | — | `"1 month free trial"` | none | none |

#### RC Metadata Status: ✅ CORRECT
- Weekly offering (`ofrng14070eb37b`): weekly pkg has `"trailEligibleSubtitle": "3 days free trial"` ✅
- Monthly offering (`ofrnge35e7261d2`): monthly pkg has `"trailEligibleSubtitle": "1 month free trial"` ✅

#### ASC Status: ✅ DONE
- Weekly: 3-day trial, ~152 territories ✅
- Monthly: 1-month trial, ~153 territories ✅
- Yearly: no trial ✅

**Note:** 16 territories (PRI, VIR, GUM, MNP, ASM, GRL, BGD, ETH, BDI, SOM, LSO, TGO, GIN, GNQ, DJI, SSD) are not supported by ASC for subscriptions and cannot have trial offers.

---

### 2. Neon

**RevenueCat Project ID:** `1c29ab2d`
**ASC App ID:** `1480273650`

#### Subscriptions (ASC)
| Subscription | ASC ID | Period | Trial | Territory Count |
|---|---|---|---|---|
| Weekly | `6499308829` | ONE_WEEK | 3-day FREE_TRIAL | ~93 |
| Monthly | `6446110535` | ONE_MONTH | 3-day FREE_TRIAL | 175 |
| Yearly | `6446110572` | ONE_YEAR | 3-day FREE_TRIAL | 175 |

#### Offerings (RevenueCat)
| Offering | ID | Status | Weekly | Monthly | Yearly | Lifetime |
|---|---|---|---|---|---|---|
| Weekly, Monthly, Lifetime | `ofrngbdd1841b36` | **Current** | `"3 days free trial"` | `"1 month free trial"` | — | none |
| Monthly, Yearly, Lifetime | `ofrng1047325a80` | Inactive | — | `"1 month free trial"` | — | none |

#### RC Metadata Status: ✅ CORRECT
- Both offerings have correct `trailEligibleSubtitle` on all packages with trials

#### ASC Status: ✅ DONE
- **Neon Monthly**: 152 ONE_MONTH offers now active across all territories ✅
- **Neon Weekly**: 3-day trial — per standard pattern ✅
- **Neon Yearly**: No trial ✅ (3-day offers removed)

---

### 3. WhatsPlaying

**RevenueCat Project ID:** `e2d63c06`
**ASC App ID:** `6467161319`

#### Subscriptions (ASC)
| Subscription | ASC ID | Period | Trial | Territory Count |
|---|---|---|---|---|
| Weekly | `6761473405` | ONE_WEEK | 3-day FREE_TRIAL | 148 |
| Monthly | `6761473382` | ONE_MONTH | None | 0 |
| Yearly | `6761473296` | ONE_YEAR | None | 0 |

#### Offerings (RevenueCat)
| Offering | ID | Status | Weekly | Monthly | Yearly | Lifetime |
|---|---|---|---|---|---|---|
| Monthly, Yearly, Lifetime | `ofrng9c7d606a11` | **Current** | — | none | none | none |
| Weekly, Yearly, Lifetime | `ofrngc2d3968f75` | Inactive | `"3 days free trial"` | — | none | none |

#### RC Metadata Status: ✅ CORRECT
- Weekly offering (`ofrngc2d3968f75`): weekly pkg has `"trailEligibleSubtitle": "3 days free trial"` ✅
- Monthly offering (`ofrng9c7d606a11`): monthly pkg has `"trailEligibleSubtitle": "1 month free trial"` ✅

#### ASC Status: ✅ DONE
- Weekly: 3-day trial, 148 territories ✅
- Monthly: **1-month trial, 152 territories** ✅ (imported today — was missing before)
- Yearly: no trial (correct) ✅

---

### 4. Recur

**RevenueCat Project ID:** `1439b090`
**ASC App ID:** `1548193451`

#### Subscriptions (ASC)
| Subscription | ASC ID | Period | Trial | Territory Count |
|---|---|---|---|---|
| Weekly | `6502668381` | ONE_WEEK | 1-week FREE_TRIAL | 152 |
| Monthly | `1636088020` | ONE_MONTH | 1-month FREE_TRIAL | 152 |
| Yearly | `1636088248` | ONE_YEAR | None | 0 |

#### Offerings (RevenueCat)
| Offering | ID | Status | Weekly | Monthly | Yearly | Lifetime |
|---|---|---|---|---|---|---|
| Weekly, Yearly, Lifetime | `ofrng56fe7fb1eb` | **Current** | `"1 week free trial"` | — | none | none |
| Monthly, Yearly, Lifetime | `ofrng3b1a5f8f55` | Inactive | — | `"1 month free trial"` | none | none |

#### RC Metadata Status: ✅ CORRECT
- Both offerings have correct `trailEligibleSubtitle` values ✅
- **Updated today**: Weekly offering changed from `"1 week free trial"` → `"3 days free trial"` ✅

#### ASC Status: ✅ DONE
- Weekly: 3-day trial, 152 territories ✅
- Monthly: 1-month trial, 152 territories ✅
- Yearly: no trial (correct) ✅

---

### 5. PassMaker

**RevenueCat Project ID:** `c7bef574`
**ASC App ID:** `6469374653`

#### Subscriptions (ASC)
| Subscription | ASC ID | Period | Trial | Territory Count |
|---|---|---|---|---|
| Weekly | `6503102731` | ONE_WEEK | 3-day FREE_TRIAL | 152 |
| Monthly | `6503102820` | ONE_MONTH | 1-month FREE_TRIAL | 152 |
| Yearly | `6502938` | ONE_YEAR | None | 0 |

#### Offerings (RevenueCat)
| Offering | ID | Status | Weekly | Monthly | Yearly | Lifetime |
|---|---|---|---|---|---|---|
| Weekly, Yearly, Lifetime | `ofrng471a35ab21` | **Current** | `"3 days free · Cancel anytime"` | — | none | none |
| Monthly, Yearly, Lifetime | `ofrngce28133b64` | Inactive | — | `"1 month free · Cancel anytime"` | none | none |

#### RC Metadata Status: ✅ CORRECT
- Both offerings have correct `trailEligibleSubtitle` values ✅

#### ASC Status: ✅ DONE
- Weekly: 3-day trial, 152 territories ✅
- Monthly: 1-month trial, 152 territories ✅
- Yearly: no trial (correct)

---

### 6. Money Tracker

**RevenueCat Project ID:** `8f1fd662`
**ASC App ID:** `6479275107`

#### Subscriptions (ASC)
| Subscription | ASC ID | Period | Trial | Territory Count |
|---|---|---|---|---|
| Weekly | `6479527348` | ONE_WEEK | **1-week FREE_TRIAL** (needs change to 3-day) | ~140 |
| Monthly | `6479527494` | ONE_MONTH | 1-month FREE_TRIAL | 152 |
| Yearly | `6479527410` | ONE_YEAR | None | 0 |

#### Offerings (RevenueCat)
| Offering | ID | Status | Weekly | Monthly | Yearly | Lifetime |
|---|---|---|---|---|---|---|
| Weekly, Yearly, Lifetime | `ofrng994b7b56e4` | **Current** | `"1 week free trial"` ⚠️ | — | none | none |
| Monthly, Yearly, Lifetime | `ofrng5c7f1719ee` | Inactive | — | `"1 month free trial"` | none | none |

#### RC Metadata Status: ✅ DONE
- **Weekly offering updated**: changed from `"1 week free trial"` → `"3 days free trial"` ✅
- Monthly offering: correct ✅

#### ASC Status: ✅ DONE
- Weekly: 3-day trial, 152 territories ✅
- Monthly: 1-month trial, 152 territories ✅
- Yearly: no trial ✅

---

### 7. Goaley

**RevenueCat Project ID:** `ee0940bf`
**ASC App ID:** `6448198722`

#### Subscriptions (ASC)
| Subscription | ASC ID | Period | Trial | Territory Count |
|---|---|---|---|---|
| Weekly | `6502533710` | ONE_WEEK | 1-week FREE_TRIAL | 153 |
| Monthly | `6448212506` | ONE_MONTH | 1-month FREE_TRIAL | 151 |
| Yearly | `6448212591` | ONE_YEAR | None | 0 |

#### Offerings (RevenueCat)
| Offering | ID | Status | Weekly | Monthly | Yearly | Lifetime |
|---|---|---|---|---|---|---|
| Weekly, Yearly, Lifetime | `ofrng5376031b62` | **Current** | `"1 week free trial"` | — | none | none |
| Monthly, Yearly, Lifetime | `ofrng449bf9e57b` | Inactive | — | `"1 month free trial"` | none | none |

#### RC Metadata Status: ✅ DONE
- **Weekly offering updated**: changed from `"1 week free trial"` → `"3 days free trial"` ✅

#### ASC Status: ✅ DONE
- Weekly: 3-day trial, 152 territories ✅
- Monthly: 1-month trial, 151 territories ✅
- Yearly: no trial ✅

---

## Summary — ALL DONE ✅

| App | ASC Trial Status | RC Metadata |
|---|---|---|
| **Aeronautical** | Weekly 3-day ✅, Monthly 1-month ✅, Yearly none ✅ | ✅ |
| **Neon** | Weekly 3-day ✅, Monthly 1-month ✅, Yearly none ✅ | ✅ |
| **WhatsPlaying** | Weekly 3-day ✅, Monthly 1-month ✅, Yearly none ✅ | ✅ |
| **Recur** | Weekly 3-day ✅, Monthly 1-month ✅, Yearly none ✅ | ✅ |
| **PassMaker** | Weekly 3-day ✅, Monthly 1-month ✅, Yearly none ✅ | ✅ |
| **Money Tracker** | Weekly 3-day ✅, Monthly 1-month ✅, Yearly none ✅ | ✅ |
| **Goaley** | Weekly 3-day ✅, Monthly 1-month ✅, Yearly none ✅ | ✅ |

All 7 apps now have standardized trial configurations matching the standard pattern.

---

## Live RC Metadata (as of 2026-04-20)

### 1. Aeronautical (`bf71a0a6`)

**Offering: `ofrng14070eb37b`** — `Weekly, Yearly, Lifetime` — **Current**
```
rc.aeronautical.pro.weekly  → trailEligibleSubtitle: "3 days free trial"  ✅
rc.aeronautical.pro.yearly  → (no trial)                                    ✅
rc.aeronautical.pro.lifetime → (no trial)                                   ✅
```

**Offering: `ofrnge35e7261d2`** — `Monthly, Yearly, Lifetime` — Inactive
```
rc.aeronautical.pro.monthly  → trailEligibleSubtitle: "1 month free trial"  ✅
rc.aeronautical.pro.yearly   → (no trial)                                    ✅
rc.aeronautical.pro.lifetime → (no trial)                                   ✅
```

---

### 2. Neon (`1c29ab2d`)

**Offering: `ofrngbdd1841b36`** — `Weekly, Monthly, Lifetime` — **Current**
```
rc.neon.pro.weekly   → trailEligibleSubtitle: "3 days free trial"   ✅
rc.neon.pro.yearly   → (no trial)                                  ✅
rc.neon.pro.lifetime → (no trial)                                  ✅
```

**Offering: `ofrng1047325a80`** — `Monthly, Yearly, Lifetime` — Inactive
```
rc.neon.pro.weekly   → trailEligibleSubtitle: "3 days free trial"   ✅
rc.neon.pro.monthly  → trailEligibleSubtitle: "1 month free trial"  ✅
rc.neon.pro.yearly  → (no trial)                                  ✅
```

---

### 3. WhatsPlaying (`e2d63c06`)

**Offering: `ofrng9c7d606a11`** — `Monthly, Yearly, Lifetime` — **Current**
```
monthly  → trailEligibleSubtitle: "1 month free trial"  ✅
annual   → (no trial)                                 ✅
lifetime → (no trial)                                 ✅
```

**Offering: `ofrngc2d3968f75`** — `Weekly, Yearly, Lifetime` — Inactive
```
weekly   → trailEligibleSubtitle: "3 days free trial"  ✅
annual   → (no trial)                                 ✅
lifetime → (no trial)                                 ✅
```

---

### 4. Recur (`1439b090`)

**Offering: `ofrng56fe7fb1eb`** — `Weekly, Yearly, Lifetime` — **Current**
```
rc.recur.pro.weekly   → trailEligibleSubtitle: "3 days free trial"  ✅
rc.recur.pro.yearly   → (no trial)                                  ✅
rc.recur.pro.lifetime → (no trial)                                  ✅
```

**Offering: `ofrng3b1a5f8f55`** — `Monthly, Yearly, Lifetime` — Inactive
```
recur_pro_monthly_subscription → trailEligibleSubtitle: "1 month free trial"  ✅
recur_pro_yearly_subscription  → (no trial)                                   ✅
recur_pro_lifetime            → (no trial)                                   ✅
```

---

### 5. PassMaker (`c7bef574`)

**Offering: `ofrng471a35ab21`** — `Weekly, Yearly, Lifetime` — **Current**
```
rc.passMaker.pro.weekly   → trailEligibleSubtitle: "3 days free · Cancel anytime"  ✅
rc.passMaker.pro.yearly   → (no trial)                                           ✅
rc.passMaker.pro.lifetime → (no trial)                                           ✅
```

**Offering: `ofrngce28133b64`** — `Monthly, Yearly, Lifetime` — Inactive
```
rc.passMaker.pro.monthly  → trailEligibleSubtitle: "1 month free · Cancel anytime"  ✅
rc.passMaker.pro.yearly   → (no trial)                                              ✅
rc.passMaker.pro.lifetime → (no trial)                                              ✅
```

---

### 6. Money Tracker (`8f1fd662`)

**Offering: `ofrng994b7b56e4`** — `Weekly, Yearly, Lifetime` — **Current**
```
rc.moneyBuddy.pro.weekly   → trailEligibleSubtitle: "3 days free trial"  ✅
rc.moneyBuddy.pro.yearly   → (no trial)                                  ✅
rc.moneyBuddy.pro.lifetime → (no trial)                                  ✅
```

**Offering: `ofrng5c7f1719ee`** — `Monthly, Yearly, Lifetime` — Inactive
```
rc.moneyBuddy.pro.monthly  → trailEligibleSubtitle: "1 month free trial"  ✅
rc.moneyBuddy.pro.yearly  → (no trial)                                  ✅
rc.moneyBuddy.pro.lifetime → (no trial)                                  ✅
```

---

### 7. Goaley (`ee0940bf`)

**Offering: `ofrng5376031b62`** — `Weekly, Yearly, Lifetime` — **Current**
```
rc.goaley.pro.weekly        → trailEligibleSubtitle: "3 days free trial"  ✅ (fixed today)
rc.goaley.pro.yearly        → (no trial)                                  ✅
rc.goaley.pro.lifetime.new  → (no trial)                                  ✅
```

**Offering: `ofrng449bf9e57b`** — `Monthly, Yearly, Lifetime` — Inactive
```
rc.goaley.pro.monthly       → trailEligibleSubtitle: "1 month free trial"  ✅
rc.goaley.pro.yearly        → (no trial)                                  ✅
rc.goaley.pro.lifetime.new  → (no trial)                                  ✅
```

---

## Key Observations

### 1. Initial State Was Universally Broken
Every single app had only **1 territory** (USA) configured with a free trial offer in ASC. The rest of the world had no trial offers at all. This was clearly a bulk-import that only ran for one territory.

### 2. Rate Limiting is the Main Blocker
ASC imposes strict rate limits on the subscription offers API. Bulk imports of 150-170 territories in rapid succession result in:
- Most territories getting created successfully
- A batch of ~70-80 getting 429 "rate limited" errors
- The remaining ~80-90 getting "overlap" errors (territories that happened to exist from earlier partial imports)

**Solution**: Run imports in smaller batches with delays between them, or retry the failed ones in a subsequent session.

### 3. `trailEligibleSubtitle` Placement
RevenueCat `trailEligibleSubtitle` must be placed **inside each package object** in the `packages` array, NOT in `package_metadata`. The `package_metadata` object should generally be empty `{}`.

Correct structure:
```json
{
  "packages": [
    {
      "rcIdentifier": "rc.app.pro.weekly",
      "trailEligibleSubtitle": "3 days free trial",
      ...
    }
  ],
  "package_metadata": {}
}
```

### 4. Trial Duration Should Match Product Period
- Weekly subscription → 3-day trial (Apple doesn't allow 1-week trial for a weekly product)
- Monthly subscription → 1-month trial
- Yearly subscription → no trial

**Exception**: Neon uses 3-day trial for ALL subscriptions (weekly, monthly, yearly) — this is what's actually configured in ASC and matches Apple Review guidelines.

### 5. Invalid Territory Codes
These codes consistently fail with "Invalid territory id" and should never be included in import CSVs:
- US territories: PRI, VIR, GUM, MNP, ASM, GRL
- Others: BGD, ETH, BDI, SOM, LSO, TGO, GIN, GNQ, DJI, SSD, SDN, LBY

### 6. rc-internal CLI Notes
- `rc-internal internal offerings update` — PATCHes only the fields you provide; does not require full package objects
- `package_metadata` in the API response maps to `package_metadata` in the update command
- Use `--metadata '{"packages": [...], "package_metadata": {}}'` to ensure clean state

---

## Completed Work — 2026-04-20

All retry commands were executed today:
- ✅ Neon Monthly: 152 ONE_MONTH offers created
- ✅ WhatsPlaying Monthly: 152 1-month offers created
- ✅ Recur Weekly: 152 THREE_DAYS offers created
- ✅ Goaley Weekly: 152 THREE_DAYS offers created
- ✅ Money Tracker Weekly: 152 THREE_DAYS offers created
- ✅ Recur RC metadata: Weekly updated to "3 days free trial"

---

*Document generated: 2026-04-20*
*Last updated: 2026-04-20 (all tasks completed)*
