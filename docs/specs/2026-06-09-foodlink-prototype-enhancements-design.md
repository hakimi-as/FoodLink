# FoodLink Prototype Enhancements — Design Spec
**Date:** 2026-06-09
**Scope:** HTML prototype (`index.html`) only — Flutter app not in scope
**Goal:** Elevate FoodLink to a 5/5 score on Creativity, Innovation, and Feasibility for the Technopreneurship MVP/Prototype Demonstration rubric (30 marks)

---

## Rubric Alignment

| Criterion | Target | How These Features Address It |
|-----------|--------|-------------------------------|
| Creativity (5) | Highly creative and novel solution | Map with radius UX, WhatsApp alerts, carbon credit economy |
| Innovation (5) | Truly innovative or disruptive concept | Carbon credit marketplace, FoodLink Pro B2B SaaS, Halal-first ASEAN expansion |
| Feasibility (5) | Polished demo that proves the concept | All flows interactive, no broken states, convincing real-world data |

---

## Section 1: Map Screen (`sc-map`)

### Purpose
Show food locations spatially on a campus map, with a radius circle matching the user's notification settings. The biggest visual "wow" moment in the demo.

### Navigation
- Accessed via a new **map icon button** (🗺️) added to the Feed screen header row, between the notification bell and the avatar button
- Back button returns to Feed
- Food pins open the existing claim sheet overlay

### Layout
```
[ ← ]  Food Near You                    [ ≡ List ]
─────────────────────────────────────────────────
  [ CSS campus map ]
    - Building blocks (grey rectangles with labels)
    - Road/path lines
    - 🔵 User location (blue pulsing dot)
    - 🟠 Orange translucent radius circle (500m default)
    - 📍 Food pins (3–4 pins, each with emoji + qty badge)
─────────────────────────────────────────────────
  [ All ]  [ ⚡ Urgent ]  [ 🟢 Halal ]   ← filter chips
```

### Map Details
- Campus landmarks: "Kulliyyah A", "Main Cafeteria", "Library", "Sports Centre", "Gate 1"
- Food pins positioned at realistic spots:
  - 🍛 Pin at Main Cafeteria — "Nasi Lemak · 3 left"
  - 🍞 Pin at Kulliyyah A — "Roti Canai · 1 left · ⚡ Urgent"
  - 🧃 Pin at Library — "Packed Lunch · 5 left"
- Tapping a pin: highlights it (scale up) and opens the existing claim sheet with that food's data
- Radius circle updates in real-time when notification radius changes in settings (stored in a JS variable)
- Filter chips hide/show pins by category

### Implementation Notes
- Pure CSS/SVG — no map API required
- Campus map drawn with `position:absolute` divs inside a relative container
- Radius circle: CSS `border-radius:50%` div with `background:rgba(240,90,40,0.12)` and `border:2px dashed var(--p)`
- Pulsing user dot: CSS `@keyframes pulse` animation

---

## Section 2: Notification Settings Screen (`sc-notif-settings`)

### Purpose
Replace the existing Notifications toggle in Profile with a full settings screen covering radius picker, WhatsApp alerts, and food type preferences.

### Navigation
- Profile > Notifications menu item now calls `go('sc-notif-settings')` instead of toggling
- Back button returns to Profile

### Layout
```
[ ← ]  Notification Settings
────────────────────────────────────
  ALERT RADIUS
  [ 100m ] [ 250m ] [●500m●] [ 1km ] [ 2km ]
  "Alerts when food appears within 500m"
  [ mini map preview with radius circle ]

  WHATSAPP ALERTS
  WhatsApp Notifications  [ toggle ON ]
  Phone Number: [ +60 1X-XXXX XXXX        ]

  📱 Preview:
  ┌─────────────────────────────────┐
  │ 🌱 FoodLink Alert               │
  │ 🍛 Nasi Lemak Ayam Berempah     │
  │    is available 250m from you!  │
  │ 📍 Main Cafeteria · 3 left      │
  │    Expires in 45 min            │
  │ 👉 fl.my/claim/FL-4821          │
  └─────────────────────────────────┘

  IN-APP ALERTS
  Push Notifications      [ toggle ON ]
  Urgent food only        [ toggle OFF ]
  Halal only              [ toggle OFF ]

  [ Save Settings ]
────────────────────────────────────
```

### Behaviour
- Radius pills: tapping one sets the active state (orange fill) and updates the mini map circle size
- WhatsApp toggle: animates the phone field into view (CSS `max-height` transition)
- WhatsApp preview card: always visible when toggle is on — shows a static realistic WhatsApp-style green bubble
- Save button: shows toast "✅ Settings saved" and calls `back('sc-profile')`
- Radius value stored in JS `window.notifRadius` — read by map screen to draw radius circle

### Styling
- WhatsApp preview card: `background:#DCF8C6` (WhatsApp green), `border-radius:12px 12px 12px 0`, monospace sender name in dark green
- Radius mini map: 120×120px simplified version of the campus map CSS, radius circle scales with selection

---

## Section 3: Carbon Credits Economy

### Purpose
Show FoodLink's business model: food saved = CO₂ offset = carbon credits with real monetary value. Woven into 4 existing screens — no new screens.

### 3a. Impact Strip (Feed screen)
- Add 4th column: `🌿` value `21` label `CARBON CREDITS`
- Strip becomes 4-column flex layout (slightly reduced font sizes to fit)
- Tapping the CR stat: toast — *"1 CR = 1kg CO₂ offset. Sell credits to corporate partners via FoodLink Pro."*

### 3b. Profile Stats Card
- Add 4th stat: icon `🌿` · value in `#7C3AED` (purple) · label "Credits"
- Card becomes 4-column; dividers between each; reduce `.prof-stat-val` font-size from 22px to 18px and `.prof-stat-ico` from 18px to 15px to prevent cramping
- Tapping stat: toast — *"Your 21 credits ≈ RM 63. Redeem via FoodLink Pro."*

### 3c. History Screen
- Each history item: small green badge on right edge — `+2 CR` (donations) or `+0.5 CR` (claims)
- Top banner (full width, green gradient): *"🌳 You've earned 21 carbon credits — like planting 3 trees"*

### 3d. Admin Dashboard
- Existing 2×2 stat grid: add a 5th card spanning full width at the bottom
- Content: `🌿 Carbon Credits Issued` · value `847 CR` · subtext *"847kg CO₂ offset · Est. market value RM 2,541"*
- Background: `linear-gradient(135deg, #F0FDF4, #DCFCE7)` with green border

---

## Section 4: FoodLink Pro Admin Tab + Partner Cafeterias

### Purpose
Demonstrate the B2B SaaS revenue model to judges — the institution-facing analytics product that monetises the data collected by the student app.

### Navigation
- Admin Dashboard tab bar: add `📊 Pro` as a 4th tab (after existing Users/Food/Claims tabs)

### Pro Tab Layout
```
  BAR CHART — "Food Saved This Week"
  Mon  Tue  Wed  Thu  Fri  Sat  Sun
  [▓]  [▓▓] [▓▓▓][▓▓] [▓▓▓▓][▓] [▓▓]
   8    14   22   16   31    9   18  meals

  DONUT CHART — "Food Type Breakdown"
  [🍚 42%] [🍞 28%] [🧃 18%] [Other 12%]
  (CSS conic-gradient circle, 120px)

  CAMPUS IMPACT SUMMARY
  ┌──────────┬──────────┬──────────┬──────────┐
  │ 312      │ 48       │ 12 min   │ ↓ 23%    │
  │ Users    │ Donors   │ Avg Claim│ Waste vs │
  │          │          │ Time     │ Last Mo  │
  └──────────┴──────────┴──────────┴──────────┘

  PARTNER CAFETERIAS
  [🏪 Pak Ali's Café · Kulliyyah A · 48 meals · ● Active]
  [🍽️ Main Cafeteria IIUM · Central · 124 meals · ● Active]
  [☕ Annexe Café · Library Block · 12 meals · ○ Pending]
  [ + Add Partner ]  (shows toast)

  UPGRADE BANNER
  ┌────────────────────────────────────────────┐
  │ 🚀 FoodLink Pro — Institution License      │
  │ RM 299/month · Full analytics ·            │
  │ Carbon credit marketplace access           │
  │              [ Contact Us ]                │
  └────────────────────────────────────────────┘
```

### Implementation Notes
- Bar chart: flex row of divs with `height` set as inline style (percentage of max value), orange gradient fill
- Donut chart: single div with `background: conic-gradient(...)`, `border-radius:50%`, centre cut with inner white circle
- Campus Impact Summary: 4-column grid, same style as admin stat cards
- Partner Cafeteria cards: same `.admin-row` style as existing user/food rows, with status pill
- Upgrade banner: dark gradient card (`#0F172A` bg), orange CTA button → toast *"Our team will contact you within 24 hours."*

---

## Section 5: SDG Badges + Onboarding Enhancement

### Purpose
Signal to judges immediately that FoodLink is SDG-aligned and has ASEAN scale ambition. Two additions to existing onboarding slide 3 and one addition to the login screen.

### 5a. Onboarding Slide 3 — SDG Badges
Below the existing green quote card, add:
```
  "FoodLink actively contributes to 3 UN Sustainable Development Goals"

  ┌──────┐  ┌──────┐  ┌──────┐
  │  2   │  │  12  │  │  13  │
  │ Zero │  │Resp. │  │Climate│
  │Hunger│  │Cons. │  │Action│
  └──────┘  └──────┘  └──────┘
  (yellow)  (amber)   (green)
```
- Each badge: 60×60px square, `border-radius:12px`, white text, bold number in large font, small label below

### 5b. Onboarding Slide 3 — ASEAN Expansion
Below SDG badges:
```
  "Where we're going"
  🇲🇾 Malaysia  🇮🇩 Indonesia  🇧🇳 Brunei  🇸🇬 Singapore
  [● Active]   [Coming Soon] [Coming Soon] [Coming Soon]
```
- Malaysia label in orange, rest in `var(--mu)` grey
- Subtext: *"Halal-first food rescue — built for 300M Muslims across Southeast Asia"*

### 5c. Login Screen — SDG Pill Row
Below tagline "Connecting Surplus. Feeding Communities." add:
```
  [ 🌱 SDG 2 ]  [ ♻️ SDG 12 ]  [ 🌍 SDG 13 ]
```
- Small pill chips, `background:var(--pl)`, `color:var(--p)`, `border-radius:20px`
- Gives judges an immediate signal before demo starts

---

## Data & State

All new state is managed via plain JS variables (no new Firebase calls needed for prototype):
- `window.notifRadius = 500` — shared between notif settings and map screen
- `window.whatsappEnabled = false` — controls WhatsApp preview visibility
- `window.carbonCredits = 21` — displayed across impact strip, profile, history
- Existing `window.currentUser` — used to conditionally show Pro tab (admin only)

---

## Screen List (additions only)

| Screen ID | Title | Entry Point |
|-----------|-------|-------------|
| `sc-map` | Food Near You | Feed header map icon |
| `sc-notif-settings` | Notification Settings | Profile > Notifications |

All other features are additions to existing screens.

---

## Out of Scope
- Flutter app changes
- Real WhatsApp API integration
- Real carbon credit marketplace backend
- Google Maps API (CSS map only)
- Real chart library (CSS charts only)
