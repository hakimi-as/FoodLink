# FoodLink Prototype Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add map screen, WhatsApp radius notifications, carbon credits economy, FoodLink Pro admin analytics, and SDG/ASEAN onboarding enhancements to `index.html` to score 5/5 on the technopreneurship rubric.

**Architecture:** All changes are in a single file (`index.html`). CSS additions go inside the existing `<style>` block before its closing tag. New HTML screens are inserted before the `</div><!-- /.app-wrapper -->` comment at line 1129. JS additions go inside the `<script>` block. Existing functions are updated in-place.

**Tech Stack:** Vanilla HTML/CSS/JavaScript. No external libraries. No API keys required — map is CSS-drawn, WhatsApp preview is static.

---

## File Map

| File | Changes |
|------|---------|
| `index.html:8–299` | Add CSS for map, notif settings, carbon, pro tab, SDG |
| `index.html:533–576` | Add 🗺️ map icon to feed header; add 4th carbon credit to impact strip |
| `index.html:805–824` | Add 4th stat (carbon credits) to profile stats card |
| `index.html:906–916` | Add CR badges to history items; add top banner |
| `index.html:1061–1066` | Add carbon credits stat card to admin stats grid |
| `index.html:1101–1106` | Add 📊 Pro tab to admin tab bar |
| `index.html:1107–1127` | Add admin-panel-pro div |
| `index.html:1129` | Insert sc-map and sc-notif-settings screens before this line |
| `index.html:331` | Add SDG badges + ASEAN expansion to onboarding slide 3 |
| `index.html:392–396` | Add SDG pill row to login screen |
| `index.html:847–851` | Update Notifications menu item to open sc-notif-settings |
| `index.html:1131+` | Add JS: map state, map functions, notif settings functions |
| `index.html:1478–1485` | Update switchAdminTab to handle 'pro' panel |

---

## Task 1: Map Screen CSS

**Files:**
- Modify: `index.html` — add CSS inside `<style>` block before `</style>` (line 299)

- [ ] **Step 1: Add map CSS**

Find the line `</style>` (line 299) and insert the following CSS immediately before it:

```css
/* ── Map screen ─────────────────────────────────────────────────────────── */
.campus-map{position:relative;width:100%;height:370px;background:#E8F4E0;overflow:hidden;flex-shrink:0}
.map-road-h{position:absolute;background:#D4C9A8;left:0;right:0}
.map-road-v{position:absolute;background:#D4C9A8;top:0;bottom:0}
.map-building{position:absolute;background:#C4D4BE;border-radius:6px;display:flex;align-items:center;justify-content:center;border:1px solid #B0C4AA}
.map-building-label{font-size:8px;font-weight:700;color:#4A6045;text-align:center;line-height:1.3;padding:3px}
.map-user-dot{position:absolute;width:16px;height:16px;background:#3B82F6;border-radius:50%;border:3px solid #fff;box-shadow:0 0 0 0 rgba(59,130,246,.4);animation:map-pulse 2s infinite;z-index:10;transform:translate(-50%,-50%)}
@keyframes map-pulse{0%{box-shadow:0 0 0 0 rgba(59,130,246,.4)}70%{box-shadow:0 0 0 14px rgba(59,130,246,0)}100%{box-shadow:0 0 0 0 rgba(59,130,246,0)}}
.map-radius{position:absolute;border:2px dashed rgba(240,90,40,.55);background:rgba(240,90,40,.08);border-radius:50%;transform:translate(-50%,-50%);z-index:5;pointer-events:none;transition:width .35s,height .35s}
.map-pin{position:absolute;transform:translate(-50%,-100%);z-index:20;cursor:pointer;display:flex;flex-direction:column;align-items:center;transition:transform .15s}
.map-pin:active{transform:translate(-50%,-100%) scale(.94)}
.map-pin-bubble{background:#fff;border-radius:20px;padding:5px 10px;box-shadow:0 3px 12px rgba(0,0,0,.18);display:flex;align-items:center;gap:5px;font-size:12px;font-weight:700;white-space:nowrap;border:1.5px solid var(--br);color:var(--tx)}
.map-pin-bubble.urgent{border-color:#DC2626;background:#FEF2F2;color:#DC2626}
.map-pin-tail{width:0;height:0;border-left:6px solid transparent;border-right:6px solid transparent;border-top:8px solid #fff;margin-top:-1px;filter:drop-shadow(0 2px 2px rgba(0,0,0,.1))}
.map-pin-tail.urgent{border-top-color:#FEF2F2}
.map-label{position:absolute;font-size:7.5px;font-weight:700;color:#7A9070;letter-spacing:.3px;white-space:nowrap;pointer-events:none}
/* ── Notif settings ──────────────────────────────────────────────────────── */
.radius-pills{display:flex;gap:8px;margin-bottom:16px}
.radius-pill{flex:1;height:38px;border:1.5px solid var(--br);border-radius:20px;background:var(--card);font-family:'DM Sans',sans-serif;font-size:12.5px;font-weight:600;color:var(--mu);cursor:pointer;transition:all .18s}
.radius-pill.active{background:var(--p);border-color:var(--p);color:#fff}
.wa-preview{background:#DCF8C6;border-radius:12px 12px 12px 0;padding:12px 14px;font-size:12.5px;line-height:1.6;color:#0F172A;box-shadow:0 2px 8px rgba(0,0,0,.08)}
.wa-sender{font-size:11px;font-weight:800;color:#128C7E;margin-bottom:4px}
.wa-time{font-size:10px;color:#64748B;text-align:right;margin-top:4px}
.mini-map{position:relative;width:100%;height:90px;background:#E8F4E0;border-radius:12px;overflow:hidden;border:1.5px solid var(--br)}
.mini-map-radius{position:absolute;border:2px dashed rgba(240,90,40,.55);background:rgba(240,90,40,.08);border-radius:50%;transform:translate(-50%,-50%);left:50%;top:50%;transition:width .35s,height .35s}
.mini-map-dot{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:10px;height:10px;background:#3B82F6;border-radius:50%;border:2px solid #fff;z-index:2}
/* ── FoodLink Pro charts ──────────────────────────────────────────────────── */
.pro-bar-chart{display:flex;align-items:flex-end;gap:5px;height:100px;padding:0 2px;margin-top:8px}
.pro-bar-col{flex:1;display:flex;flex-direction:column;align-items:center;gap:3px;height:100%;justify-content:flex-end}
.pro-bar{width:100%;background:linear-gradient(180deg,var(--p),var(--p2));border-radius:4px 4px 0 0;min-height:4px}
.pro-bar-day{font-size:9px;color:var(--mu);font-weight:600}
.pro-bar-val{font-size:9px;font-weight:700;color:var(--p)}
.pro-donut{width:100px;height:100px;border-radius:50%;position:relative;margin:0 auto}
.pro-donut::after{content:'';position:absolute;inset:22px;background:var(--card);border-radius:50%}
.pro-legend-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0}
/* ── SDG badges ──────────────────────────────────────────────────────────── */
.sdg-badge{width:58px;height:58px;border-radius:12px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;flex-shrink:0}
.sdg-num{font-family:'Sora',sans-serif;font-size:20px;font-weight:800;color:#fff;line-height:1}
.sdg-lbl{font-size:7px;font-weight:700;color:rgba(255,255,255,.9);text-align:center;line-height:1.2;letter-spacing:.2px}
```

- [ ] **Step 2: Verify**

Open `index.html` in a browser. No visible changes expected yet — confirm no console errors.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "style: add CSS for map, notif settings, pro charts, SDG badges"
```

---

## Task 2: Map Screen HTML + JS

**Files:**
- Modify: `index.html` — insert screen before `</div><!-- /.app-wrapper -->` (line 1129), add JS to `<script>` block

- [ ] **Step 1: Add map screen HTML**

Find `</div><!-- /.app-wrapper -->` and insert the following immediately before it:

```html
<!-- ===================== MAP ===================== -->
<div class="screen" id="sc-map" style="background:var(--bg)">
  <div class="back-row" style="padding:16px 22px 12px;flex-shrink:0">
    <div class="back-btn" onclick="back('sc-feed')">←</div>
    <div style="font-family:'Sora',sans-serif;font-size:17px;font-weight:700;color:var(--tx);flex:1">Food Near You</div>
    <div class="icon-btn" onclick="back('sc-feed')" title="List view">☰</div>
  </div>
  <!-- Campus map -->
  <div class="campus-map" id="campus-map">
    <!-- Roads -->
    <div class="map-road-h" style="top:49%;height:18px"></div>
    <div class="map-road-h" style="top:22%;height:12px;opacity:.6"></div>
    <div class="map-road-v" style="left:27%;width:14px"></div>
    <div class="map-road-v" style="left:62%;width:10px;opacity:.6"></div>
    <!-- Buildings -->
    <div class="map-building" style="left:3%;top:8%;width:21%;height:13%"><div class="map-building-label">Kulliyyah A</div></div>
    <div class="map-building" style="left:3%;top:27%;width:21%;height:13%"><div class="map-building-label">Kulliyyah B</div></div>
    <div class="map-building" style="left:65%;top:8%;width:22%;height:13%"><div class="map-building-label">Library</div></div>
    <div class="map-building" style="left:33%;top:8%;width:22%;height:12%"><div class="map-building-label">Masjid</div></div>
    <div class="map-building" style="left:38%;top:58%;width:22%;height:13%"><div class="map-building-label">Main Cafeteria</div></div>
    <div class="map-building" style="left:65%;top:60%;width:21%;height:13%"><div class="map-building-label">Sports Centre</div></div>
    <div class="map-building" style="left:2%;top:48%;width:12%;height:8%"><div class="map-building-label">Gate 1</div></div>
    <!-- User location (center) -->
    <div class="map-user-dot" style="left:50%;top:46%"></div>
    <!-- Radius circle -->
    <div class="map-radius" id="map-radius" style="left:50%;top:46%;width:190px;height:190px"></div>
    <!-- Food pins -->
    <div class="map-pin" id="map-pin-0" style="left:49%;top:58%" onclick="showClaimFromMap(0)">
      <div class="map-pin-bubble">🍛 3 left</div>
      <div class="map-pin-tail"></div>
    </div>
    <div class="map-pin" id="map-pin-1" style="left:14%;top:27%" onclick="showClaimFromMap(1)">
      <div class="map-pin-bubble urgent">🍞 1 left ⚡</div>
      <div class="map-pin-tail urgent"></div>
    </div>
    <div class="map-pin" id="map-pin-2" style="left:76%;top:8%" onclick="showClaimFromMap(2)">
      <div class="map-pin-bubble">🧃 5 left</div>
      <div class="map-pin-tail"></div>
    </div>
  </div>
  <!-- Filter chips -->
  <div class="chips" id="map-chips" style="padding:12px 22px;flex-shrink:0">
    <div class="chip active" onclick="filterMapPins('All',this)">All</div>
    <div class="chip" onclick="filterMapPins('Urgent',this)">⚡ Urgent</div>
    <div class="chip" onclick="filterMapPins('Halal',this)">🟢 Halal</div>
  </div>
  <div style="padding:0 22px 12px;font-size:12px;color:var(--mu);flex-shrink:0">
    🔵 You · 🟠 Notification radius · Tap a pin to claim
  </div>
</div>
```

- [ ] **Step 2: Add map icon to feed header**

Find this in the feed header (around line 533):
```html
      <div class="icon-btn" onclick="go('sc-notifications')" style="margin-left:0">🔔<div class="notif-dot"></div></div>
```

Replace it with:
```html
      <div class="icon-btn" onclick="updateMapRadius();go('sc-map')" title="Map view">🗺️</div>
      <div class="icon-btn" onclick="go('sc-notifications')" style="margin-left:0">🔔<div class="notif-dot"></div></div>
```

- [ ] **Step 3: Add map JavaScript**

Find `// ── State ──` (line 1132) and add these lines after `let activeLbTab = 'donors';`:

```javascript
// Map
window.notifRadius = 500;
const MAP_RADIUS_PX = {100:55,250:100,500:190,1000:300,2000:380};
const MAP_FOODS = [
  {emoji:'🍛',title:'Nasi Lemak Ayam Berempah',donor:'Pak Ali\'s Café',loc:'Main Cafeteria',qty:3,halal:true,urgent:false},
  {emoji:'🍞',title:'Roti Canai Special',donor:'Kulliyyah A Canteen',loc:'Kulliyyah A',qty:1,halal:true,urgent:true},
  {emoji:'🧃',title:'Packed Lunch Set',donor:'Library Café',loc:'Library',qty:5,halal:true,urgent:false}
];
```

Then, find `// ── Bottom nav ──` and add the following functions immediately before it:

```javascript
// ── Map ───────────────────────────────────────────────────────────────────────
function updateMapRadius() {
  const px = MAP_RADIUS_PX[window.notifRadius] || 190;
  const el = document.getElementById('map-radius');
  if (el) { el.style.width = px+'px'; el.style.height = px+'px'; }
  const mini = document.getElementById('mini-map-radius');
  if (mini) {
    const scale = px / 190;
    const miniPx = Math.min(70, Math.round(40 * scale));
    mini.style.width = miniPx+'px'; mini.style.height = miniPx+'px';
  }
}
function showClaimFromMap(idx) {
  if (currentUser && currentUser.role === 'donor') { toast('Donors cannot claim food'); return; }
  const item = MAP_FOODS[idx];
  claimFood = {id: 900+idx, title: item.title, donor: item.donor, loc: item.loc, emoji: item.emoji, qty: item.qty};
  claimQty = 1;
  document.getElementById('cl-emoji').textContent = item.emoji;
  document.getElementById('cl-title').textContent = item.title;
  document.getElementById('cl-donor').textContent = item.donor + ' · 📍 ' + item.loc;
  document.getElementById('cl-qty').textContent = 1;
  document.getElementById('claim-overlay').style.display = 'flex';
}
function filterMapPins(type, el) {
  document.querySelectorAll('#map-chips .chip').forEach(c => c.classList.remove('active'));
  el.classList.add('active');
  MAP_FOODS.forEach((item, i) => {
    const pin = document.getElementById('map-pin-'+i);
    if (!pin) return;
    if (type === 'All') pin.style.display = 'flex';
    else if (type === 'Urgent') pin.style.display = item.urgent ? 'flex' : 'none';
    else if (type === 'Halal') pin.style.display = item.halal ? 'flex' : 'none';
  });
}
```

- [ ] **Step 4: Verify**

Open `index.html`. Log in as Receiver. On the feed, tap the 🗺️ icon. The map screen should appear with the campus layout, a blue pulsing dot, an orange dashed radius circle, and 3 food pins. Tap a pin — the claim sheet should open with correct food data. Tap filter chips to show/hide pins.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: add campus map screen with food pins, radius circle, and filter chips"
```

---

## Task 3: Notification Settings Screen HTML + JS

**Files:**
- Modify: `index.html` — insert screen + update profile menu item + add JS

- [ ] **Step 1: Add sc-notif-settings screen**

Find `</div><!-- /.app-wrapper -->` and insert the following immediately before it (after the map screen you just added):

```html
<!-- ===================== NOTIF SETTINGS ===================== -->
<div class="screen" id="sc-notif-settings" style="background:var(--bg)">
  <div style="background:var(--card);padding:16px 22px 16px;border-bottom:1px solid var(--br);flex-shrink:0">
    <div style="display:flex;align-items:center;gap:14px">
      <div class="back-btn" onclick="back('sc-profile')">←</div>
      <div style="font-family:'Sora',sans-serif;font-size:17px;font-weight:700;color:var(--tx)">Notification Settings</div>
    </div>
  </div>
  <div class="sa" style="padding:20px 22px 40px">
    <!-- Radius -->
    <span class="section-label">Alert Radius</span>
    <div class="radius-pills" id="radius-pills">
      <button class="radius-pill" data-r="100" onclick="setRadius(100,this)">100m</button>
      <button class="radius-pill" data-r="250" onclick="setRadius(250,this)">250m</button>
      <button class="radius-pill active" data-r="500" onclick="setRadius(500,this)">500m</button>
      <button class="radius-pill" data-r="1000" onclick="setRadius(1000,this)">1km</button>
      <button class="radius-pill" data-r="2000" onclick="setRadius(2000,this)">2km</button>
    </div>
    <div style="font-size:12px;color:var(--mu);margin-bottom:14px" id="radius-desc">You'll be alerted when food appears within 500m of you</div>
    <!-- Mini map preview -->
    <div class="mini-map" style="margin-bottom:20px">
      <div class="mini-map-radius" id="mini-map-radius" style="width:40px;height:40px"></div>
      <div class="mini-map-dot"></div>
      <div style="position:absolute;bottom:8px;right:10px;font-size:9px;font-weight:600;color:#7A9070">IIUM Campus</div>
    </div>
    <!-- WhatsApp -->
    <span class="section-label">WhatsApp Alerts</span>
    <div class="menu-item" style="margin-bottom:10px;cursor:default">
      <div class="menu-icon" style="background:#DCFCE7;font-size:20px">💬</div>
      <div class="menu-info"><div class="menu-title">WhatsApp Notifications</div><div class="menu-sub">Instant alerts to your phone</div></div>
      <div class="menu-toggle"><div class="toggle" id="wa-toggle" onclick="toggleWhatsapp()"><div class="toggle-knob"></div></div></div>
    </div>
    <div id="wa-section" style="max-height:0;overflow:hidden;transition:max-height .35s ease">
      <div class="field" style="margin-bottom:12px">
        <label>WhatsApp Number</label>
        <div class="field-wrap"><span class="icon">📱</span><input type="tel" id="wa-phone" placeholder="+60 1X-XXXX XXXX"></div>
      </div>
      <!-- Preview bubble -->
      <div style="background:var(--card);border-radius:16px;padding:14px;margin-bottom:16px;border:1.5px solid var(--br)">
        <div style="font-size:11px;font-weight:700;color:var(--mu);margin-bottom:10px;text-transform:uppercase;letter-spacing:.5px">📱 Message Preview</div>
        <div class="wa-preview">
          <div class="wa-sender">🌱 FoodLink Alert</div>
          🍛 <strong>Nasi Lemak Ayam Berempah</strong> is available <span id="wa-radius-txt">500m</span> from you!<br>
          📍 Main Cafeteria · 3 portions left · Expires in 45 min<br>
          👉 <span style="color:#128C7E;font-weight:600">fl.my/claim/FL-4821</span>
          <div class="wa-time">10:32 AM ✓✓</div>
        </div>
      </div>
    </div>
    <!-- In-app -->
    <span class="section-label">In-App Alerts</span>
    <div class="menu-item" style="margin-bottom:10px;cursor:default">
      <div class="menu-icon" style="background:#EFF6FF">🔔</div>
      <div class="menu-info"><div class="menu-title">Push Notifications</div><div class="menu-sub">Alerts inside the app</div></div>
      <div class="menu-toggle"><div class="toggle on" id="push-toggle" onclick="togglePush()"><div class="toggle-knob"></div></div></div>
    </div>
    <div class="menu-item" style="margin-bottom:10px;cursor:default">
      <div class="menu-icon" style="background:#FEF2F2">⚡</div>
      <div class="menu-info"><div class="menu-title">Urgent Food Only</div><div class="menu-sub">Only items expiring in &lt;30 min</div></div>
      <div class="menu-toggle"><div class="toggle" id="urgent-toggle" onclick="toggleUrgentOnly()"><div class="toggle-knob"></div></div></div>
    </div>
    <div class="menu-item" style="margin-bottom:24px;cursor:default">
      <div class="menu-icon" style="background:#F0FDF4">🟢</div>
      <div class="menu-info"><div class="menu-title">Halal Only</div><div class="menu-sub">Only show halal-certified food</div></div>
      <div class="menu-toggle"><div class="toggle" id="halal-filter-toggle" onclick="toggleHalalFilter()"><div class="toggle-knob"></div></div></div>
    </div>
    <button class="btn-primary" onclick="saveNotifSettings()">Save Settings</button>
  </div>
</div>
```

- [ ] **Step 2: Update Profile Notifications menu item**

Find this block (around line 847):
```html
      <div class="menu-item">
        <div class="menu-icon" style="background:#FAF5FF">🔔</div>
        <div class="menu-info"><div class="menu-title">Notifications</div><div class="menu-sub">Claims, pickups, alerts</div></div>
        <div class="menu-toggle"><div class="toggle on" id="notif-toggle" onclick="toggleNotif()"><div class="toggle-knob"></div></div></div>
      </div>
```

Replace it with:
```html
      <div class="menu-item" onclick="go('sc-notif-settings')">
        <div class="menu-icon" style="background:#FAF5FF">🔔</div>
        <div class="menu-info"><div class="menu-title">Notifications</div><div class="menu-sub">Radius alerts · WhatsApp · Claims</div></div>
        <div class="menu-chevron">›</div>
      </div>
```

- [ ] **Step 3: Add notification settings JavaScript**

Find `// ── Map ──` (the functions you added in Task 2) and add the following immediately after the `filterMapPins` function:

```javascript
// ── Notif Settings ────────────────────────────────────────────────────────────
let waOn = false;
let pushOn = true;
let urgentOnly = false;
let halalFilter = false;
const RADIUS_LABELS = {100:'100m',250:'250m',500:'500m',1000:'1km',2000:'2km'};

function setRadius(r, el) {
  window.notifRadius = r;
  document.querySelectorAll('.radius-pill').forEach(p => p.classList.remove('active'));
  el.classList.add('active');
  document.getElementById('radius-desc').textContent = 'You\'ll be alerted when food appears within '+RADIUS_LABELS[r]+' of you';
  document.getElementById('wa-radius-txt').textContent = RADIUS_LABELS[r];
  updateMapRadius();
}
function toggleWhatsapp() {
  waOn = !waOn;
  const tgl = document.getElementById('wa-toggle');
  tgl.className = 'toggle'+(waOn?' on':'');
  const sec = document.getElementById('wa-section');
  sec.style.maxHeight = waOn ? '400px' : '0';
}
function togglePush() {
  pushOn = !pushOn;
  const tgl = document.getElementById('push-toggle');
  tgl.className = 'toggle'+(pushOn?' on':'');
}
function toggleUrgentOnly() {
  urgentOnly = !urgentOnly;
  const tgl = document.getElementById('urgent-toggle');
  tgl.className = 'toggle'+(urgentOnly?' on':'');
}
function toggleHalalFilter() {
  halalFilter = !halalFilter;
  const tgl = document.getElementById('halal-filter-toggle');
  tgl.className = 'toggle'+(halalFilter?' on':'');
}
function saveNotifSettings() {
  toast('✅ Settings saved');
  setTimeout(() => back('sc-profile'), 600);
}
```

- [ ] **Step 4: Verify**

Log in as Receiver → Profile → Notifications menu item → opens `sc-notif-settings`. Tap radius pills — description text and mini map circle update. Toggle WhatsApp — phone field and preview bubble slide open. Tap Save — toast + return to profile.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: add notification settings screen with radius picker and WhatsApp preview"
```

---

## Task 4: Carbon Credits — Impact Strip + Profile Stats

**Files:**
- Modify: `index.html` — feed impact strip + profile stats card

- [ ] **Step 1: Add carbon credit to impact strip**

Find the impact strip (around line 535):
```html
    <div class="impact-strip">
      <div class="impact-stat"><div class="impact-val">142</div><div class="impact-lbl">🍽️ MEALS</div></div>
      <div class="impact-div"></div>
      <div class="impact-stat"><div class="impact-val">89</div><div class="impact-lbl">⚖️ KG SAVED</div></div>
      <div class="impact-div"></div>
      <div class="impact-stat"><div class="impact-val">43</div><div class="impact-lbl">🌱 CO₂ kg</div></div>
    </div>
```

Replace it with:
```html
    <div class="impact-strip">
      <div class="impact-stat"><div class="impact-val" style="font-size:15px">142</div><div class="impact-lbl">🍽️ MEALS</div></div>
      <div class="impact-div"></div>
      <div class="impact-stat"><div class="impact-val" style="font-size:15px">89</div><div class="impact-lbl">⚖️ KG SAVED</div></div>
      <div class="impact-div"></div>
      <div class="impact-stat"><div class="impact-val" style="font-size:15px">43</div><div class="impact-lbl">🌱 CO₂ kg</div></div>
      <div class="impact-div"></div>
      <div class="impact-stat" onclick="toast('1 CR = 1kg CO₂ offset. Sell credits to corporate partners via FoodLink Pro.')" style="cursor:pointer"><div class="impact-val" style="font-size:15px;color:#7C3AED">21</div><div class="impact-lbl">🌿 CARBON CR</div></div>
    </div>
```

- [ ] **Step 2: Add carbon credit stat to profile stats card**

Find the profile stats card (around line 805):
```html
      <div class="prof-stats-card">
        <div class="prof-stat">
          <div class="prof-stat-ico">🍛</div>
          <div class="prof-stat-val" id="prof-stat-donated" style="color:var(--p)">0</div>
          <div class="prof-stat-lbl">Donated</div>
        </div>
        <div class="prof-div"></div>
        <div class="prof-stat">
          <div class="prof-stat-ico">🤲</div>
          <div class="prof-stat-val" id="prof-stat-claimed" style="color:var(--gd)">3</div>
          <div class="prof-stat-lbl">Claimed</div>
        </div>
        <div class="prof-div"></div>
        <div class="prof-stat">
          <div class="prof-stat-ico">🌿</div>
          <div class="prof-stat-val" id="prof-stat-saved" style="color:#7C3AED">6kg</div>
          <div class="prof-stat-lbl">Saved</div>
        </div>
      </div>
```

Replace it with:
```html
      <div class="prof-stats-card">
        <div class="prof-stat">
          <div class="prof-stat-ico" style="font-size:15px">🍛</div>
          <div class="prof-stat-val" id="prof-stat-donated" style="color:var(--p);font-size:18px">0</div>
          <div class="prof-stat-lbl">Donated</div>
        </div>
        <div class="prof-div"></div>
        <div class="prof-stat">
          <div class="prof-stat-ico" style="font-size:15px">🤲</div>
          <div class="prof-stat-val" id="prof-stat-claimed" style="color:var(--gd);font-size:18px">3</div>
          <div class="prof-stat-lbl">Claimed</div>
        </div>
        <div class="prof-div"></div>
        <div class="prof-stat">
          <div class="prof-stat-ico" style="font-size:15px">🌿</div>
          <div class="prof-stat-val" id="prof-stat-saved" style="color:#7C3AED;font-size:18px">6kg</div>
          <div class="prof-stat-lbl">Saved</div>
        </div>
        <div class="prof-div"></div>
        <div class="prof-stat" onclick="toast('Your 21 credits ≈ RM 63. Redeem via FoodLink Pro.')" style="cursor:pointer">
          <div class="prof-stat-ico" style="font-size:15px">🌱</div>
          <div class="prof-stat-val" id="prof-stat-credits" style="color:#7C3AED;font-size:18px">21</div>
          <div class="prof-stat-lbl">Credits</div>
        </div>
      </div>
```

- [ ] **Step 3: Verify**

Log in as Receiver → Feed: impact strip shows 4 metrics including purple `21 CARBON CR`; tap it shows toast. Profile → stats card shows 4 stats including `21 Credits`; tap it shows toast.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat: add carbon credits metric to impact strip and profile stats card"
```

---

## Task 5: Carbon Credits — History + Admin

**Files:**
- Modify: `index.html` — history screen items + admin stats grid

- [ ] **Step 1: Add CR banner and badges to history screen**

Find the history claims panel (around line 907):
```html
    <div id="hist-panel-claims">
      <div class="hist-item"><div class="hist-ico">🍛</div><div class="hist-info"><div class="hist-title">Nasi Lemak Ayam Berempah</div><div class="hist-meta">From Warung Mak Jah · 2 portions · Today 10:30 AM</div></div><span class="hist-badge" style="background:#DCFCE7;color:#16A34A">Collected</span></div>
      <div class="hist-item"><div class="hist-ico">🥟</div><div class="hist-info"><div class="hist-title">Curry Puff Sardin</div><div class="hist-meta">From Ahmad Warung · 3 portions · Yesterday 2:15 PM</div></div><span class="hist-badge" style="background:#DCFCE7;color:#16A34A">Collected</span></div>
      <div class="hist-item"><div class="hist-ico">🫓</div><div class="hist-info"><div class="hist-title">Roti Canai Special</div><div class="hist-meta">From Ahmad Warung · 1 portion · 3 days ago</div></div><span class="hist-badge" style="background:#FFF7ED;color:#C2410C">Pending</span></div>
      <div class="hist-item"><div class="hist-ico">🍜</div><div class="hist-info"><div class="hist-title">Mee Goreng Mamak</div><div class="hist-meta">From Warung Mak Jah · 2 portions · Last week</div></div><span class="hist-badge" style="background:#DCFCE7;color:#16A34A">Collected</span></div>
    </div>
```

Replace it with:
```html
    <div id="hist-panel-claims">
      <div style="background:linear-gradient(135deg,#F0FDF4,#DCFCE7);border:1.5px solid #86EFAC;border-radius:16px;padding:12px 16px;display:flex;align-items:center;gap:10px;margin-bottom:14px">
        <span style="font-size:24px">🌳</span>
        <div style="flex:1"><div style="font-size:13px;font-weight:700;color:#15803D">21 Carbon Credits Earned</div><div style="font-size:11.5px;color:#4ADE80;margin-top:2px">Like planting 3 trees · Est. value RM 63</div></div>
      </div>
      <div class="hist-item"><div class="hist-ico">🍛</div><div class="hist-info"><div class="hist-title">Nasi Lemak Ayam Berempah</div><div class="hist-meta">From Warung Mak Jah · 2 portions · Today 10:30 AM</div></div><div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px"><span class="hist-badge" style="background:#DCFCE7;color:#16A34A">Collected</span><span style="font-size:10.5px;font-weight:700;color:#7C3AED;background:#F5F3FF;border-radius:20px;padding:2px 8px">+0.5 CR</span></div></div>
      <div class="hist-item"><div class="hist-ico">🥟</div><div class="hist-info"><div class="hist-title">Curry Puff Sardin</div><div class="hist-meta">From Ahmad Warung · 3 portions · Yesterday 2:15 PM</div></div><div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px"><span class="hist-badge" style="background:#DCFCE7;color:#16A34A">Collected</span><span style="font-size:10.5px;font-weight:700;color:#7C3AED;background:#F5F3FF;border-radius:20px;padding:2px 8px">+0.5 CR</span></div></div>
      <div class="hist-item"><div class="hist-ico">🫓</div><div class="hist-info"><div class="hist-title">Roti Canai Special</div><div class="hist-meta">From Ahmad Warung · 1 portion · 3 days ago</div></div><div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px"><span class="hist-badge" style="background:#FFF7ED;color:#C2410C">Pending</span></div></div>
      <div class="hist-item"><div class="hist-ico">🍜</div><div class="hist-info"><div class="hist-title">Mee Goreng Mamak</div><div class="hist-meta">From Warung Mak Jah · 2 portions · Last week</div></div><div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px"><span class="hist-badge" style="background:#DCFCE7;color:#16A34A">Collected</span><span style="font-size:10.5px;font-weight:700;color:#7C3AED;background:#F5F3FF;border-radius:20px;padding:2px 8px">+0.5 CR</span></div></div>
    </div>
```

- [ ] **Step 2: Add carbon credits stat card to admin dashboard**

Find the admin stats grid (around line 1061):
```html
  <div class="admin-stats-grid">
    <div class="admin-stat"><div class="admin-stat-val">847</div><div class="admin-stat-lbl">👥 Total Users</div></div>
    <div class="admin-stat"><div class="admin-stat-val">234</div><div class="admin-stat-lbl">🍛 Food Listings</div></div>
    <div class="admin-stat"><div class="admin-stat-val" style="color:var(--g)">18</div><div class="admin-stat-lbl">✅ Claims Today</div></div>
    <div class="admin-stat"><div class="admin-stat-val" style="color:var(--b)">42</div><div class="admin-stat-lbl">🟢 Active Now</div></div>
  </div>
```

Replace it with:
```html
  <div class="admin-stats-grid">
    <div class="admin-stat"><div class="admin-stat-val">847</div><div class="admin-stat-lbl">👥 Total Users</div></div>
    <div class="admin-stat"><div class="admin-stat-val">234</div><div class="admin-stat-lbl">🍛 Food Listings</div></div>
    <div class="admin-stat"><div class="admin-stat-val" style="color:var(--g)">18</div><div class="admin-stat-lbl">✅ Claims Today</div></div>
    <div class="admin-stat"><div class="admin-stat-val" style="color:var(--b)">42</div><div class="admin-stat-lbl">🟢 Active Now</div></div>
    <div class="admin-stat" style="grid-column:1/-1;background:linear-gradient(135deg,#F0FDF4,#DCFCE7);border:1.5px solid rgba(34,197,94,.3)">
      <div class="admin-stat-val" style="color:#16A34A;font-size:24px">847 CR</div>
      <div class="admin-stat-lbl">🌿 Total Carbon Credits Issued · 847kg CO₂ offset · Est. market value <strong>RM 2,541</strong></div>
    </div>
  </div>
```

- [ ] **Step 3: Verify**

Log in as Receiver → Profile → History: green banner at top, each collected item shows `+0.5 CR` badge. Log in as Admin → Admin Dashboard: carbon credits full-width card visible below the 4 stat cards.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat: add carbon credits CR badges to history and admin dashboard stat card"
```

---

## Task 6: FoodLink Pro Admin Tab

**Files:**
- Modify: `index.html` — admin tab bar + add pro panel div + update switchAdminTab JS

- [ ] **Step 1: Add Pro tab to admin tab bar**

Find the admin tab bar (around line 1102):
```html
  <div class="tab-bar" id="admin-tabs" style="margin:0 22px">
    <button class="tab-btn active" data-tab="users" onclick="switchAdminTab('users')">Users</button>
    <button class="tab-btn" data-tab="food" onclick="switchAdminTab('food')">Food</button>
    <button class="tab-btn" data-tab="claims" onclick="switchAdminTab('claims')">Claims</button>
  </div>
```

Replace it with:
```html
  <div class="tab-bar" id="admin-tabs" style="margin:0 22px">
    <button class="tab-btn active" data-tab="users" onclick="switchAdminTab('users')">Users</button>
    <button class="tab-btn" data-tab="food" onclick="switchAdminTab('food')">Food</button>
    <button class="tab-btn" data-tab="claims" onclick="switchAdminTab('claims')">Claims</button>
    <button class="tab-btn" data-tab="pro" onclick="switchAdminTab('pro')" style="color:var(--p)">📊 Pro</button>
  </div>
```

- [ ] **Step 2: Add admin-panel-pro div**

Find `</div>` that closes the `<div class="sa"...>` in the admin screen (the line after the `admin-panel-claims` closing div, around line 1126):
```html>
    </div>
  </div>
</div>

</div><!-- /.app-wrapper -->
```

Find `<div id="admin-panel-claims"` and after its closing `</div>`, add:

```html
    <div id="admin-panel-pro" style="display:none">
      <!-- Bar chart -->
      <div style="background:var(--card);border-radius:16px;padding:16px;margin-bottom:14px;box-shadow:0 1px 4px rgba(0,0,0,.06)">
        <div style="font-family:'Sora',sans-serif;font-size:14px;font-weight:700;color:var(--tx);margin-bottom:4px">Food Saved This Week</div>
        <div style="font-size:11px;color:var(--mu);margin-bottom:8px">Meals rescued per day</div>
        <div class="pro-bar-chart">
          <div class="pro-bar-col"><div class="pro-bar-val">8</div><div class="pro-bar" style="height:26%"></div><div class="pro-bar-day">Mon</div></div>
          <div class="pro-bar-col"><div class="pro-bar-val">14</div><div class="pro-bar" style="height:45%"></div><div class="pro-bar-day">Tue</div></div>
          <div class="pro-bar-col"><div class="pro-bar-val">22</div><div class="pro-bar" style="height:71%"></div><div class="pro-bar-day">Wed</div></div>
          <div class="pro-bar-col"><div class="pro-bar-val">16</div><div class="pro-bar" style="height:52%"></div><div class="pro-bar-day">Thu</div></div>
          <div class="pro-bar-col"><div class="pro-bar-val">31</div><div class="pro-bar" style="height:100%"></div><div class="pro-bar-day">Fri</div></div>
          <div class="pro-bar-col"><div class="pro-bar-val">9</div><div class="pro-bar" style="height:29%"></div><div class="pro-bar-day">Sat</div></div>
          <div class="pro-bar-col"><div class="pro-bar-val">18</div><div class="pro-bar" style="height:58%"></div><div class="pro-bar-day">Sun</div></div>
        </div>
      </div>
      <!-- Donut + Legend -->
      <div style="background:var(--card);border-radius:16px;padding:16px;margin-bottom:14px;box-shadow:0 1px 4px rgba(0,0,0,.06)">
        <div style="font-family:'Sora',sans-serif;font-size:14px;font-weight:700;color:var(--tx);margin-bottom:12px">Food Type Breakdown</div>
        <div style="display:flex;align-items:center;gap:16px">
          <div class="pro-donut" style="background:conic-gradient(#F05A28 0% 42%,#F97316 42% 70%,#3B82F6 70% 88%,#94A3B8 88% 100%)"></div>
          <div style="flex:1;display:flex;flex-direction:column;gap:8px">
            <div style="display:flex;align-items:center;gap:8px"><div class="pro-legend-dot" style="background:#F05A28"></div><div style="font-size:12px;color:var(--tx);flex:1">🍚 Rice Dishes</div><div style="font-size:12px;font-weight:700;color:var(--tx)">42%</div></div>
            <div style="display:flex;align-items:center;gap:8px"><div class="pro-legend-dot" style="background:#F97316"></div><div style="font-size:12px;color:var(--tx);flex:1">🍞 Bread/Pastry</div><div style="font-size:12px;font-weight:700;color:var(--tx)">28%</div></div>
            <div style="display:flex;align-items:center;gap:8px"><div class="pro-legend-dot" style="background:#3B82F6"></div><div style="font-size:12px;color:var(--tx);flex:1">🧃 Beverages</div><div style="font-size:12px;font-weight:700;color:var(--tx)">18%</div></div>
            <div style="display:flex;align-items:center;gap:8px"><div class="pro-legend-dot" style="background:#94A3B8"></div><div style="font-size:12px;color:var(--tx);flex:1">Other</div><div style="font-size:12px;font-weight:700;color:var(--tx)">12%</div></div>
          </div>
        </div>
      </div>
      <!-- Campus Impact Summary -->
      <div style="background:var(--card);border-radius:16px;padding:16px;margin-bottom:14px;box-shadow:0 1px 4px rgba(0,0,0,.06)">
        <div style="font-family:'Sora',sans-serif;font-size:14px;font-weight:700;color:var(--tx);margin-bottom:12px">Campus Impact Summary</div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
          <div style="background:var(--el);border-radius:12px;padding:12px;text-align:center"><div style="font-family:'Sora',sans-serif;font-size:22px;font-weight:800;color:var(--tx)">312</div><div style="font-size:10.5px;color:var(--mu);font-weight:600">👥 Total Users</div></div>
          <div style="background:var(--el);border-radius:12px;padding:12px;text-align:center"><div style="font-family:'Sora',sans-serif;font-size:22px;font-weight:800;color:var(--tx)">48</div><div style="font-size:10.5px;color:var(--mu);font-weight:600">🏪 Active Donors</div></div>
          <div style="background:var(--el);border-radius:12px;padding:12px;text-align:center"><div style="font-family:'Sora',sans-serif;font-size:22px;font-weight:800;color:var(--g)">12 min</div><div style="font-size:10.5px;color:var(--mu);font-weight:600">⚡ Avg Claim Time</div></div>
          <div style="background:var(--el);border-radius:12px;padding:12px;text-align:center"><div style="font-family:'Sora',sans-serif;font-size:22px;font-weight:800;color:var(--g)">↓ 23%</div><div style="font-size:10.5px;color:var(--mu);font-weight:600">🌱 Waste vs Last Mo</div></div>
        </div>
      </div>
      <!-- Partner Cafeterias -->
      <div style="background:var(--card);border-radius:16px;padding:16px;margin-bottom:14px;box-shadow:0 1px 4px rgba(0,0,0,.06)">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px">
          <div style="font-family:'Sora',sans-serif;font-size:14px;font-weight:700;color:var(--tx)">Partner Cafeterias</div>
          <button onclick="toast('Partnership request sent! Our team will contact you.')" style="background:var(--p);border:none;border-radius:10px;padding:6px 12px;color:#fff;font-family:\'DM Sans\',sans-serif;font-size:11px;font-weight:700;cursor:pointer">+ Add Partner</button>
        </div>
        <div class="admin-row"><div style="font-size:22px">🏪</div><div class="admin-row-info"><div class="admin-row-name">Pak Ali's Café</div><div class="admin-row-sub">Kulliyyah A · 48 meals donated</div></div><span class="role-badge" style="background:#DCFCE7;color:#16A34A">● Active</span></div>
        <div class="admin-row"><div style="font-size:22px">🍽️</div><div class="admin-row-info"><div class="admin-row-name">Main Cafeteria IIUM</div><div class="admin-row-sub">Central · 124 meals donated</div></div><span class="role-badge" style="background:#DCFCE7;color:#16A34A">● Active</span></div>
        <div class="admin-row" style="margin-bottom:0"><div style="font-size:22px">☕</div><div class="admin-row-info"><div class="admin-row-name">Annexe Café</div><div class="admin-row-sub">Library Block · 12 meals donated</div></div><span class="role-badge" style="background:#FFF7ED;color:#C2410C">○ Pending</span></div>
      </div>
      <!-- Upgrade banner -->
      <div style="background:linear-gradient(160deg,#0F172A,#1E293B);border-radius:16px;padding:20px;margin-bottom:8px">
        <div style="font-size:18px;margin-bottom:8px">🚀</div>
        <div style="font-family:'Sora',sans-serif;font-size:16px;font-weight:700;color:#fff;margin-bottom:4px">FoodLink Pro — Institution License</div>
        <div style="font-size:12.5px;color:rgba(255,255,255,.7);margin-bottom:16px;line-height:1.5">RM 299/month · Full analytics · Priority support · Carbon credit marketplace access</div>
        <button onclick="toast('Our team will contact you within 24 hours. 🚀')" style="background:linear-gradient(135deg,var(--p),var(--p2));border:none;border-radius:12px;padding:12px 24px;color:#fff;font-family:\'DM Sans\',sans-serif;font-size:14px;font-weight:700;cursor:pointer;width:100%">Contact Us →</button>
      </div>
    </div>
```

- [ ] **Step 3: Update switchAdminTab to handle 'pro'**

Find the `switchAdminTab` function (around line 1478):
```javascript
function switchAdminTab(tab){
  activeAdminTab=tab;
  document.querySelectorAll('#admin-tabs .tab-btn').forEach(b=>b.className='tab-btn'+(b.dataset.tab===tab?' active':''));
  ['users','food','claims'].forEach(t=>{
    const p=document.getElementById('admin-panel-'+t);
    if(p)p.style.display=t===tab?'block':'none';
  });
}
```

Replace it with:
```javascript
function switchAdminTab(tab){
  activeAdminTab=tab;
  document.querySelectorAll('#admin-tabs .tab-btn').forEach(b=>b.className='tab-btn'+(b.dataset.tab===tab?' active':''));
  ['users','food','claims','pro'].forEach(t=>{
    const p=document.getElementById('admin-panel-'+t);
    if(p)p.style.display=t===tab?'block':'none';
  });
}
```

- [ ] **Step 4: Verify**

Log in as Admin → Admin Dashboard → tap `📊 Pro` tab. Bar chart, donut chart, campus impact summary, 3 partner cafeteria rows, and upgrade banner all visible. Tap `+ Add Partner` and `Contact Us` → each shows a toast. Other tabs (Users, Food, Claims) still work normally.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: add FoodLink Pro analytics tab to admin dashboard with charts and partner cafeterias"
```

---

## Task 7: SDG Badges + ASEAN Expansion + Login Pills

**Files:**
- Modify: `index.html` — onboarding slide 3 + login screen tagline

- [ ] **Step 1: Add SDG badges and ASEAN expansion to onboarding slide 3**

Find onboarding slide 2 (the "You're all set!" slide, around line 367):
```html
      <div style="background:var(--gl);border:1.5px solid rgba(34,197,94,.3);border-radius:16px;padding:16px;display:flex;align-items:flex-start;gap:12px">
        <span style="font-size:24px">💚</span>
        <div style="font-size:13px;color:var(--gd);line-height:1.5;font-weight:500">Every meal saved is a step toward a sustainable future.</div>
      </div>
```

Replace it with:
```html
      <div style="background:var(--gl);border:1.5px solid rgba(34,197,94,.3);border-radius:16px;padding:16px;display:flex;align-items:flex-start;gap:12px;margin-bottom:20px">
        <span style="font-size:24px">💚</span>
        <div style="font-size:13px;color:var(--gd);line-height:1.5;font-weight:500">Every meal saved is a step toward a sustainable future.</div>
      </div>
      <!-- SDG Badges -->
      <div style="font-size:11px;font-weight:600;color:var(--mu);text-align:center;margin-bottom:10px">Contributing to 3 UN Sustainable Development Goals</div>
      <div style="display:flex;gap:10px;justify-content:center;margin-bottom:20px">
        <div class="sdg-badge" style="background:#DDA63A"><div class="sdg-num">2</div><div class="sdg-lbl">Zero Hunger</div></div>
        <div class="sdg-badge" style="background:#BF8B2E"><div class="sdg-num">12</div><div class="sdg-lbl">Resp. Consumption</div></div>
        <div class="sdg-badge" style="background:#3F7E44"><div class="sdg-num">13</div><div class="sdg-lbl">Climate Action</div></div>
      </div>
      <!-- ASEAN Expansion -->
      <div style="background:var(--card);border:1.5px solid var(--br);border-radius:16px;padding:14px;width:100%">
        <div style="font-size:11px;font-weight:700;color:var(--mu);text-align:center;margin-bottom:10px;text-transform:uppercase;letter-spacing:.5px">Where We're Going</div>
        <div style="display:flex;justify-content:space-around">
          <div style="text-align:center"><div style="font-size:22px">🇲🇾</div><div style="font-size:10px;font-weight:700;color:var(--p);margin-top:3px">Malaysia</div><div style="font-size:9px;color:var(--p)">● Active</div></div>
          <div style="text-align:center"><div style="font-size:22px">🇮🇩</div><div style="font-size:10px;font-weight:700;color:var(--mu);margin-top:3px">Indonesia</div><div style="font-size:9px;color:var(--hi)">Soon</div></div>
          <div style="text-align:center"><div style="font-size:22px">🇧🇳</div><div style="font-size:10px;font-weight:700;color:var(--mu);margin-top:3px">Brunei</div><div style="font-size:9px;color:var(--hi)">Soon</div></div>
          <div style="text-align:center"><div style="font-size:22px">🇸🇬</div><div style="font-size:10px;font-weight:700;color:var(--mu);margin-top:3px">Singapore</div><div style="font-size:9px;color:var(--hi)">Soon</div></div>
        </div>
        <div style="font-size:10.5px;color:var(--mu);text-align:center;margin-top:10px;line-height:1.4">Halal-first food rescue — built for 300M Muslims across Southeast Asia</div>
      </div>
```

- [ ] **Step 2: Add SDG pill row to login screen**

Find the login screen tagline (around line 396):
```html
        <div style="font-size:12.5px;color:var(--mu);margin-top:4px">Connecting Surplus. Feeding Communities.</div>
```

Replace it with:
```html
        <div style="font-size:12.5px;color:var(--mu);margin-top:4px">Connecting Surplus. Feeding Communities.</div>
        <div style="display:flex;gap:8px;justify-content:center;margin-top:10px;flex-wrap:wrap">
          <span style="background:var(--pl);color:var(--p);font-size:11px;font-weight:700;padding:4px 10px;border-radius:20px">🌱 SDG 2</span>
          <span style="background:var(--pl);color:var(--p);font-size:11px;font-weight:700;padding:4px 10px;border-radius:20px">♻️ SDG 12</span>
          <span style="background:var(--pl);color:var(--p);font-size:11px;font-weight:700;padding:4px 10px;border-radius:20px">🌍 SDG 13</span>
        </div>
```

- [ ] **Step 3: Verify**

Open `index.html`. Onboarding: swipe to slide 3 ("You're all set!") — green quote, then 3 SDG colored badges, then ASEAN flag row with Malaysia highlighted in orange and others greyed. Login screen: below the tagline, 3 orange SDG pill chips visible before logging in.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat: add SDG badges, ASEAN expansion to onboarding and SDG pills to login screen"
```

---

## Self-Review Notes

- `updateMapRadius()` is called both when entering the map (feed header icon onclick) and when `setRadius()` is called in notif settings — both paths share `window.notifRadius` correctly.
- `showClaimFromMap(idx)` sets `claimFood` so that `confirmClaim()` and `showQR()` work correctly after claiming from the map.
- `switchAdminTab` updated to include `'pro'` — no other tab-switching code references `['users','food','claims']` directly so no other changes needed.
- The `toggleNotif` function remains in the JS (not deleted) — it's just no longer called since the menu item was updated. No harm leaving it.
- Profile stats card reduced font sizes (`font-size:18px`) to avoid overflow in 4-column layout.
