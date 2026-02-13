# Software Wrighter Lab - Plan

## Overview

This repo (`sw-lab`) is the planning and drafting hub for the Software Wrighter Lab project, which includes:

- **Blog**: Static site (Jekyll) at `sw-lab.github.io` (separate public repo)
- **Discord**: "Software Wrighter Lab" server for community discussion
- **Content**: Videos, blog posts, and repos spanning multiple GitHub users/orgs

## Repo Architecture

```
software-wrighter-lab (org)
├── sw-lab (private)              ← THIS REPO - planning, research, drafts
│   ├── docs/
│   │   ├── research.txt          # ChatGPT research session
│   │   ├── plan.md               # This file
│   │   └── status.md             # Progress tracking
│   └── blog/
│       └── topics/               # Draft staging area
│           ├── personal-software/
│           ├── context-reduction/
│           ├── thinking-llms/
│           └── ...
│
└── software-wrighter-lab.github.io (public)  ← FUTURE - Jekyll blog
    ├── _posts/
    ├── _config.yml
    └── ...
```

## Content Sources (GitHub)

The blog/videos reference repos across multiple owners:

| Owner | Purpose | Audience |
|-------|---------|----------|
| `wrightmikea` | Personal projects (some public) | General |
| `softwarewrighter` | Active video-related projects | Subscribers |
| `sw-fun` | Games, fun projects | Gamers |
| `sw-web-dev` | Web development tools | Web devs |
| `sw-cli-tools` | Command-line utilities | CLI users |
| `sw-emacs` | Emacs packages | Emacs users |
| `sw-*` (others) | Topic-specific orgs | Varies |

## Blog Strategy

### Principles
- **Broadcast-only**: No comments on blog posts
- **Discussion routing**: Steer readers to Discord (social) and GitHub (technical)
- **Cross-linking**: Every post links to related repo + Discord channel + video

### Standard Footer (all posts)
```
---
This blog is intentionally comment-free.

- Social discussion: [Discord](https://discord.gg/XXX)
- Technical follow-ups: [GitHub Discussions](https://github.com/sw-lab/...)

[Related video](https://youtube.com/...) | [Source repo](https://github.com/...)
```

### Drafts Workflow
1. Ideas/research → `docs/research.txt`
2. Drafts → `blog/topics/<topic>/draft-NN.md`
3. Ready to publish → copy to `sw-lab.github.io/_posts/`
4. Announce → Discord `#blog-video-links`

## Discord Server: Software Wrighter Lab

### Categories & Channels

**START HERE**
- `#welcome`
- `#how-this-server-works`
- `#announcements` (read-only)

**MAKING**
- `#personal-tools-showcase`
- `#throwaway-code`
- `#maker-lounge`
- `#pairing-sessions`

**IDEAS**
- `#context-reduction`
- `#llm-reasoning`
- `#recursive-models`
- `#graphs-over-text`
- `#eli5-ml`

**SKEPTICISM**
- `#ai-skeptic-corner` (skepticism welcome, cynicism not)

**LIVE**
- Voice: Maker Room
- Voice: Pair Programming
- Voice: Office Hours

**LINKS OUT**
- `#github-updates`
- `#blog-video-links`

### Invite Text (short)
> Software Wrighter Lab
>
> A place for people who enjoy building small, experimental software tools—often with AI, often just for themselves.
>
> This is not a debate server. It's a workshop.
>
> You don't need to like AI. You do need to be curious.

### Moderation Philosophy
- This server is for building, testing, and comparing ideas
- Debate is welcome; culture wars are not
- If something can be tested, we test it

## Content Map

```
BLOG POSTS
│
├─ Personal Software
│   ├─ Repos: personal-tools/*
│   └─ Discord: #personal-tools-showcase
│
├─ Context Reduction
│   ├─ Repos: rlm-reducers/*
│   └─ Discord: #context-reduction
│
├─ Thinking vs Tools
│   ├─ Repos: thinking-experiments/*
│   └─ Discord: #llm-reasoning
│
├─ Recursive Reduction
│   ├─ Repos: rlm-graph/*
│   └─ Discord: #recursive-models
│
├─ Graphs over Text
│   ├─ Repos: graph-state/*
│   └─ Discord: #graphs-over-text
│
└─ Social Software Making
    ├─ Repos: maker-experiments/*
    └─ Discord: #maker-lounge
```

## Planned Blog Topics

### Priority 1 (drafted)
1. Personal Software: Tools That Exist for One Afternoon
2. Why I Stopped Stuffing Context into Prompts
3. Thinking Is Expensive: When LLM Reasoning Helps (and When It Hurts)

### Priority 2 (outlined in research)
4. Recursive Reduction: Shrinking Problems Before Solving Them
5. Graphs Over Text: Why Structure Beats Prose
6. ELI5 ML: Foundational Papers Explained Simply
7. The Throwaway Code Philosophy
8. Social Software Making: Building in Public

### Future
- Video/podcast adaptations of blog posts
- Audiobook-style readings
- Live coding sessions

## Technical Setup

### Jekyll Blog

**Status:** Live at https://software-wrighter-lab.github.io with default template
**Repo:** `github.com/software-wrighter-lab/software-wrighter-lab.github.io`
**Local:** `/Users/mike/github/tmp/software-wrighter-lab.github.io`

- Theme: minima (dark skin) - DONE
- Hosting: GitHub Pages - DONE
- RSS feed: enabled via jekyll-feed plugin - DONE

#### Remaining Setup Tasks

1. **Customize `_config.yml`**
   - Set `title: Software Wrighter Lab`
   - Set `description` (from jekyll-setup.md)
   - Set `url: "https://software-wrighter-lab.github.io"`
   - Add author info and social links

2. **Update `about.markdown`**
   - Replace default content with real about page (see jekyll-setup.md Step 8)

3. **Create `_includes/post-footer.html`**
   - Add Discord link
   - Add repo link placeholder
   - Add video link placeholder
   - See jekyll-setup.md Step 7

4. **Create directory structure**
   - `mkdir -p _drafts _includes _layouts assets/images _topics`

5. **Copy post layout to customize**
   - `cp $(bundle info minima --path)/_layouts/post.html _layouts/post.html`
   - Add `{% include post-footer.html %}` before closing div

6. **Test local build**
   - `bundle install`
   - `bundle exec jekyll serve --livereload`

7. **Create first real post**
   - Copy from `blog/topics/personal-software/draft-01.md`
   - Format as `_posts/YYYY-MM-DD-personal-software.md`
   - Update front matter with date, tags, discord channel

8. **Update Discord invite links**
   - Replace `INVITE_CODE` placeholders once Discord server is created

### Integration Points (Future)
- Discord webhooks for `#github-updates` and `#blog-video-links`
- YouTube channel integration
- Custom domain (optional)
