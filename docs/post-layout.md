# Post Layout System

Documentation for the blog's post layout CSS, including TOC, tables, and float behavior.

## How It Works

Posts use a float-based layout where:
- **TOC** floats left (~280px wide)
- **Post marker image** floats left next to TOC
- **Resource box** floats right
- **Content** flows around all floated elements

The key CSS rule that makes this work:

```css
.post-content {
  overflow: hidden;
}
```

This creates a new block formatting context, ensuring all content (including tables) flows around floated elements instead of clearing them.

## TOC (Table of Contents)

Located in `_includes/toc.html`. Automatically generated from H2/H3 headings.

```css
.toc {
  float: left;
  max-width: 280px;
  margin: 0 1.5rem 1rem 0;
  background: #fffde7;  /* Light mode */
}
```

The TOC hides itself if fewer than 3 headings exist.

## Tables

### Default Behavior

Tables automatically flow alongside the TOC due to `overflow: hidden` on `.post-content`. No wrapper needed for most tables.

### Narrower Tables with Text Wrapping

For tables that should be narrower with wrapped text (e.g., References tables), use the `references-float` class:

```markdown
<div class="references-float" markdown="1">

| Concept | Reference |
|---------|-----------|
| **Term** | [Link to paper](https://...) (Author et al. 2023) |

</div>
```

This applies:
- `overflow: hidden` (contains the table)
- Smaller heading (`font-size: 1.25rem`)
- Smaller table text (`font-size: 0.9em`)
- First column fixed-width, bold
- Other columns wrap text

## Resource Box

Floats right, contains links to code, demos, videos:

```markdown
<div class="resource-box" markdown="1">

| Resource | Link |
|----------|------|
| **Code** | [repo-name](https://github.com/...) |
| **Video** | [Title](https://youtube.com/...) |

</div>
```

## Post Marker Image

Small decorative image that floats left:

```markdown
<img src="/assets/images/posts/image-name.png" class="post-marker" alt="">
```

Requirements:
- Transparent background
- Black lines (inverts in dark mode via CSS filter)
- ~300px wide
- Located in `assets/images/posts/`

## Dark Mode

Dark mode is handled via CSS variables and filters:
- TOC background changes via `[data-theme="dark"]` selector
- Post marker images invert via `filter: invert(1)`

## Common Issues

### Gap Before First Heading

**Fixed:** Previously, `.post-content h2:first-of-type { clear: both }` forced headings below the TOC. This was removed.

### Table Too Wide

**Fixed:** `overflow: hidden` on `.post-content` now makes tables flow alongside the TOC. For narrower tables, use `references-float` wrapper.

### Content Not Flowing Around TOC

Check that:
1. `.post-content { overflow: hidden }` exists in `toc.html`
2. No `clear: both` on early content

## File Locations

| File | Purpose |
|------|---------|
| `_includes/toc.html` | TOC markup, CSS, and JavaScript |
| `assets/main.scss` | Additional post styling |
| `_sass/custom-dark.scss` | Dark mode overrides |

## Changelog

- **2026-02-05**: Added `overflow: hidden` to `.post-content` for automatic float containment
- **2026-02-05**: Removed `clear: both` on first H2 to eliminate gap
- **2026-02-05**: Added `.references-float` class for narrower tables
