# SW-Lab Claude Code Notes

## THIS IS THE PUBLISHING REPO

**This repo (`software-wrighter-lab.github.io`) is the LIVE deployed site.**

| Repo | Location | Purpose |
|------|----------|---------|
| `sw-lab` | `~/github/softwarewrighter/sw-lab` | Source/staging (development) |
| **THIS REPO** | `~/github/software-wrighter-lab/sw-lab.github.io.git` | **DEPLOYED SITE** |

### When Receiving Posts from sw-lab

Posts are created in `sw-lab` (source) then copied here to publish:
1. Copy post: `cp ~/github/softwarewrighter/sw-lab/_posts/YYYY-MM-DD-slug.md _posts/`
2. Copy images: `cp ~/github/softwarewrighter/sw-lab/assets/images/posts/*.png assets/images/posts/`
3. Commit and push: `git add . && git commit -m "Publish: Title" && git push`

**Pushing to this repo triggers GitHub Pages rebuild and updates the live site.**

Live site: https://software-wrighter-lab.github.io/

See `docs/daily-publish-workflow.md` for scheduling details.

---

## Local Development

**CRITICAL: NEVER use port 4000 - it is reserved for LiteLLM gateway.**

### Starting the Server

**ALWAYS use the serve script:**
```bash
./scripts/serve.sh
```

This script:
- Uses port **5907** (not 4000!)
- Includes `--drafts` and `--future` flags automatically
- Includes `--livereload` for auto-refresh

**Local preview URL: http://127.0.0.1:5907/**

Do NOT run `bundle exec jekyll serve` directly - use the script to ensure correct port.

## Key Files

- `_includes/youtube-embed.html` - Inline YouTube player with autoplay on scroll
- `_layouts/post.html` - Auto-embeds video when `video_url` frontmatter exists
- `_posts/` - Published posts
- `_drafts/` - Draft posts (symlinked to blog-planning/docs)

## Playwright Testing

**IMPORTANT: Always dismiss the "Customize Your Reading Experience" popup when viewing the local or live blog with Playwright.**

The blog shows a preferences popup to new visitors. Since Playwright uses a fresh browser context, it appears every time. Dismiss it by clicking "Got it!" button:

```javascript
// Dismiss popup before interacting with page
await page.click('button:has-text("Got it!")');
```

Or remove it via JavaScript:
```javascript
document.querySelector('.prefs-onboarding-overlay')?.remove();
```

## Frontmatter

Posts can include:
- `video_url` - YouTube URL for inline embed at bottom of post (auto-start muted)
- `repo_url` - GitHub repo URL
- `series` - Series name
- `series_part` - Part number in series

## Resource Box Video Thumbnails

For video links in the resource box, include a YouTube thumbnail:
```markdown
| **Video** | [Title](url)<br>[![Video](https://img.youtube.com/vi/VIDEO_ID/mqdefault.jpg){: .video-thumb}](url) |
```

## Video Project Files

When creating posts from video projects in `~/github/softwarewrighter/shorts/projects/`:

**Use for accurate terminology:**
- `work/description.txt` or `work/description.md`
- `work/slide-outlines.md`

**Avoid for terminology** (may have phonetic spellings for TTS):
- `work/narration.txt` or `work/narration.md`
