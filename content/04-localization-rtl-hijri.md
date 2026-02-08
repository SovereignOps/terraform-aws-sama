---
title: "Localization Engineering: RTL & Hijri Dates"
published: false
description: "A technical deep dive into building web applications for the Middle East, focusing on Right-to-Left (RTL) CSS logic and Hijri calendar implementation."
tags: frontend, localization, javascript, css, middle-east
---

# Localization Engineering: RTL & Hijri Dates

Building for the Gulf isn't just about translating strings. It requires fundamental changes to your layout engine and date handling. If your app doesn't support Right-to-Left (RTL) natively or display Hijri dates, it won't be adopted in the enterprise/government sector.

Here is the engineering guide to true localization.

## 1. The RTL Layout Engine (CSS Logical Properties)

Stop using `left` and `right`. In an RTL context (Arabic/Hebrew), "left" is the *end* of the container, not the start.

### The Old Way (Bad)
```css
.card {
  margin-left: 1rem;  /* Wrong in RTL */
  padding-right: 2rem; /* Wrong in RTL */
  text-align: left;    /* Wrong in RTL */
}
```

### The New Way (Logical Properties)
Use `inline-start` and `inline-end`. These properties respect the document's `dir="rtl"` or `dir="ltr"` attribute automatically.

```css
.card {
  margin-inline-start: 1rem; /* Becomes margin-right in RTL */
  padding-inline-end: 2rem;  /* Becomes padding-left in RTL */
  text-align: start;         /* Aligns naturally */
}
```

### Flexbox & Grid
Flexbox is direction-aware by default.
- `flex-direction: row` goes Right -> Left in RTL.
- `justify-content: flex-start` starts from the Right in RTL.

**Pro Tip:** Always set `<html dir="rtl" lang="ar">` when the language switches.

## 2. Hijri Dates (The Islamic Calendar)

Saudi Arabia uses the Hijri calendar officially. Storing dates in Hijri is a nightmare (month lengths vary based on moon sighting).

**Golden Rule:** Store in UTC (Gregorian). Convert to Hijri only at the presentation layer.

### The `Intl` API (No Libraries Needed)

Modern browsers have built-in support. You don't need Moment.js or date-fns for this.

```javascript
const date = new Date(); // Current Gregorian date

// Format: "1445-02-15" (Example)
const hijriDate = new Intl.DateTimeFormat('ar-SA-u-ca-islamic', {
  day: 'numeric',
  month: 'long',
  year: 'numeric'
}).format(date);

console.log(hijriDate); 
// Output: ١٥ صفر ١٤٤٥
```

### Handling Bi-Directional Input
If users input a Hijri date, convert it immediately to Gregorian for storage.

```javascript
// Example logic (Conceptual - requires a library like hijri-converter for precise math)
function hijriToGregorian(hYear, hMonth, hDay) {
  // 1445-02-15 -> 2023-09-01
  return toGregorian(hYear, hMonth, hDay); 
}
```

## Summary
1.  **CSS:** Replace all `left/right` with `inline-start/inline-end`.
2.  **HTML:** Toggle `dir="rtl"` on the root element.
3.  **JS:** Use `Intl.DateTimeFormat('ar-SA-u-ca-islamic')` for display.
4.  **Database:** Always store UTC Gregorian.

---
*Repo:* [github.com/SovereignOps/terraform-aws-sama](https://github.com/SovereignOps/terraform-aws-sama)
