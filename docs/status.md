# Software Wrighter Lab - Status

## Current Phase: Setup

### Milestones

| Milestone | Status | Notes |
|-----------|--------|-------|
| Research & planning | DONE | See `research.txt` |
| Create `software-wrighter-lab` org | DONE | |
| Draft blog posts | IN PROGRESS | 3 drafts ready for editing |
| Set up Discord server | TODO | "Software Wrighter Lab" |
| Set up Jekyll blog repo | DONE | `software-wrighter-lab.github.io` - live with default template |
| Customize blog (title, about, footer) | TODO | |
| Publish first blog post | TODO | |
| Announce Discord | TODO | |

---

## Blog Posts

### Drafts Ready for Editing
| # | Title | File | Status |
|---|-------|------|--------|
| 1 | Personal Software: Tools That Exist for One Afternoon | `blog/topics/personal-software/draft-01.md` | DRAFT |
| 2 | Why I Stopped Stuffing Context into Prompts | `blog/topics/context-reduction/draft-01.md` | DRAFT |
| 3 | Thinking Is Expensive: When LLM Reasoning Helps | `blog/topics/thinking-llms/draft-01.md` | DRAFT |

### Planned (not drafted)
- Recursive Reduction: Shrinking Problems Before Solving Them
- Graphs Over Text: Why Structure Beats Prose
- ELI5 ML: Foundational Papers Explained Simply
- The Throwaway Code Philosophy
- Social Software Making: Building in Public

---

## Discord Server

See `docs/discord-setup.md` for detailed instructions.

| Task | Status |
|------|--------|
| Create server | TODO |
| Enable Community features | TODO |
| Configure verification (Medium) | TODO |
| Set up Member Screening | TODO |
| Create categories & channels | TODO |
| Set read-only permissions | TODO |
| Write `#welcome` message | TODO |
| Write `#how-this-server-works` | TODO |
| Create permanent invite link | TODO |
| Update blog drafts with invite link | TODO |

---

## Jekyll Blog

See `docs/jekyll-setup.md` for detailed instructions.

**Repo:** `github.com/software-wrighter-lab/software-wrighter-lab.github.io`
**Live site:** https://software-wrighter-lab.github.io (working with default template)
**Local clone:** `/Users/mike/github/tmp/software-wrighter-lab.github.io`

| Task | Status |
|------|--------|
| Install Ruby/Jekyll locally | DONE |
| Create `software-wrighter-lab.github.io` repo | DONE |
| Initialize Jekyll (default minima theme) | DONE |
| Configure `_config.yml` | PARTIAL - still has placeholder title/description |
| Update `Gemfile` with plugins | DONE |
| Create directory structure | PARTIAL - basic structure only |
| Create `_includes/post-footer.html` | TODO |
| Write `about.markdown` | PARTIAL - default content only |
| Create first post | DONE - default "Welcome to Jekyll" post |
| Test local build | TODO |
| Enable GitHub Pages | DONE - auto-enabled, builds succeed |
| Verify site at `https://software-wrighter-lab.github.io` | DONE - live with default template |
| Customize site title/description in `_config.yml` | TODO |
| Add custom post-footer with Discord/repo links | TODO |
| Update about page with real content | TODO |
| Create first real blog post from drafts | TODO |
| Update Discord invite links | TODO |

---

## Next Actions

1. [ ] Customize `_config.yml` with real title/description
2. [ ] Update `about.markdown` with real content
3. [ ] Create `_includes/post-footer.html` with Discord/repo links
4. [ ] Edit first blog draft (`personal-software/draft-01.md`)
5. [ ] Create Discord server "Software Wrighter Lab"
6. [ ] Update Discord invite links in blog
7. [ ] Publish first real post
8. [ ] Announce on Discord

---

## Log

### 2026-01-24
- Created `software-wrighter-lab.github.io` repo under `software-wrighter-lab` org
- Initialized Jekyll with minima theme (dark skin)
- Added Gemfile with jekyll-feed, jekyll-seo-tag, jekyll-sitemap plugins
- Created initial pages: index.markdown, about.markdown, 404.html
- Added .gitignore for Jekyll (build output, bundler, editor files, drafts)
- Enabled GitHub Pages - site live at https://software-wrighter-lab.github.io
- Verified builds succeed via GitHub Actions
- Local clone at `/Users/mike/github/tmp/software-wrighter-lab.github.io`
- Note: Site currently shows default "Your awesome title" placeholder - needs customization

### 2025-01-24
- Created planning structure (`docs/plan.md`, `docs/status.md`)
- Extracted 3 blog drafts from research to `blog/topics/`
- Defined repo architecture and content strategy
- Updated blog footers: Discord-only discussion, no GitHub Discussions
- Added intro paragraph to first blog post
- Created `docs/discord-setup.md` with detailed setup instructions
- Created `docs/jekyll-setup.md` with detailed setup instructions
