# Jekyll Blog Setup: software-wrighter-lab.github.io

Step-by-step instructions for creating and deploying the Software Wrighter Lab blog.

---

## Prerequisites

### macOS (with Homebrew)

```bash
# Install Ruby (system Ruby is outdated)
brew install ruby

# Add to your shell profile (~/.zshrc or ~/.bashrc)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$(gem environment gemdir)/bin:$PATH"

# Reload shell
source ~/.zshrc

# Verify versions
ruby -v    # Should be 3.x
gem -v     # Should be 3.x

# Install Bundler and Jekyll
gem install bundler jekyll
```

### Verify Installation

```bash
jekyll -v  # Should show jekyll 4.x
```

---

## Step 1: Create the Repository

### Option A: Create on GitHub first (recommended)

1. Go to https://github.com/new
2. Repository name: **software-wrighter-lab.github.io**
   - This exact name enables GitHub Pages at `https://software-wrighter-lab.github.io`
3. Set to **Public**
4. Check **Add a README file**
5. Add `.gitignore`: select **Jekyll**
6. Click **Create repository**
7. Clone locally:

```bash
cd ~/github/sw-lab  # or wherever you keep repos
git clone https://github.com/software-wrighter-lab/software-wrighter-lab.github.io.git
cd software-wrighter-lab.github.io
```

### Option B: Create locally first

```bash
mkdir software-wrighter-lab.github.io
cd software-wrighter-lab.github.io
git init
```

---

## Step 2: Initialize Jekyll

```bash
# Create new Jekyll site in current directory
jekyll new . --force

# This creates:
# ├── _config.yml
# ├── _posts/
# ├── Gemfile
# ├── index.markdown
# └── about.markdown
```

---

## Step 3: Create .gitignore

If you didn't select "Jekyll" when creating the repo on GitHub, create `.gitignore`:

```gitignore
# Jekyll build output
_site/
.jekyll-cache/
.jekyll-metadata

# Ruby / Bundler
.bundle/
vendor/
Gemfile.lock

# Sass cache
.sass-cache/

# OS files
.DS_Store
Thumbs.db

# IDE / Editor
.idea/
.vscode/
*.swp
*.swo
*~

# Drafts (if you want to keep them local only)
# _drafts/

# Environment
.env
.envrc

# Node (if using any JS build tools)
node_modules/
package-lock.json
```

**Notes:**
- `Gemfile.lock` is excluded because GitHub Pages uses its own gem versions
- `_drafts/` is commented out — uncomment if you want drafts to stay local-only

---

## Step 4: Configure _config.yml

Replace the default `_config.yml` with:

```yaml
# Site settings
title: Software Wrighter Lab
description: >-
  Building small, experimental software tools—often with AI,
  often just for myself.
url: "https://software-wrighter-lab.github.io"
baseurl: ""

# Author
author:
  name: Mike Wright
  email: # optional
  links:
    - label: "GitHub"
      url: "https://github.com/software-wrighter-lab"
    - label: "YouTube"
      url: "https://youtube.com/@softwarewrighter"  # update this
    - label: "Discord"
      url: "https://discord.gg/INVITE_CODE"  # update this

# Build settings
markdown: kramdown
highlighter: rouge
permalink: /:year/:month/:day/:title/

# Theme - using minima (default) for simplicity
# Can switch to minimal-mistakes or others later
theme: minima

# Minima theme settings
minima:
  skin: dark  # or: classic, dark, solarized, solarized-dark
  date_format: "%B %-d, %Y"

# Plugins
plugins:
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-sitemap

# Exclude from build
exclude:
  - Gemfile
  - Gemfile.lock
  - node_modules/
  - vendor/
  - README.md
  - LICENSE

# Collections (for organizing content beyond posts)
collections:
  topics:
    output: true
    permalink: /topics/:name/

# Defaults
defaults:
  - scope:
      path: ""
      type: "posts"
    values:
      layout: "post"
      author: "Mike Wright"
  - scope:
      path: ""
      type: "topics"
    values:
      layout: "page"

# Feed settings
feed:
  posts_limit: 20
```

---

## Step 5: Update Gemfile

Replace `Gemfile` with:

```ruby
source "https://rubygems.org"

gem "jekyll", "~> 4.3"
gem "minima", "~> 2.5"

# Plugins
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-seo-tag", "~> 2.8"
  gem "jekyll-sitemap", "~> 1.4"
end

# Windows and JRuby compatibility
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1", :platforms => [:mingw, :x64_mingw, :mswin]
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

# GitHub Pages compatibility (optional - use if deploying via gh-pages gem)
# gem "github-pages", group: :jekyll_plugins
```

Then install dependencies:

```bash
bundle install
```

---

## Step 6: Create Directory Structure

```bash
# Create directories
mkdir -p _posts
mkdir -p _drafts
mkdir -p _includes
mkdir -p _layouts
mkdir -p assets/images
mkdir -p _topics

# Your structure will look like:
# software-wrighter-lab.github.io/
# ├── _config.yml
# ├── _posts/           # Published posts
# ├── _drafts/          # Unpublished drafts (not deployed)
# ├── _includes/        # Reusable snippets
# ├── _layouts/         # Page templates
# ├── _topics/          # Topic landing pages
# ├── assets/
# │   └── images/
# ├── Gemfile
# ├── index.markdown
# └── about.markdown
```

---

## Step 7: Create Standard Blog Footer Include

Create `_includes/post-footer.html`:

```html
<div class="post-footer">
  <hr>
  <p><em>This blog is intentionally comment-free.</em></p>
  <ul>
    <li>Discussion: <a href="https://discord.gg/INVITE_CODE">Software Wrighter Lab Discord</a>
      {% if page.discord %}<code>{{ page.discord }}</code>{% endif %}
    </li>
    {% if page.repo %}
    <li>Related repo: <a href="{{ page.repo }}">{{ page.repo | split: '/' | last }}</a> (issues welcome)</li>
    {% endif %}
    {% if page.video %}
    <li>Video: <a href="{{ page.video }}">Watch on YouTube</a></li>
    {% endif %}
  </ul>
</div>
```

Then edit `_layouts/post.html` (copy from theme first if needed):

```bash
# Copy default layout to customize
bundle info minima  # shows theme location
cp $(bundle info minima --path)/_layouts/post.html _layouts/post.html
```

Add before the closing content div in `_layouts/post.html`:

```html
{% include post-footer.html %}
```

---

## Step 8: Create About Page

Replace `about.markdown`:

```markdown
---
layout: page
title: About
permalink: /about/
---

# Software Wrighter Lab

A blog about building small, experimental software tools—often with AI, often just for myself.

## What This Is

- Experiments with personal software and throwaway code
- Explorations of context reduction, LLM reasoning, and tool-first architectures
- Practical AI-assisted development, not hype

## What This Isn't

- A debate forum about whether AI is good or bad
- Product announcements or tutorials for specific tools
- Hot takes or thought leadership

## Where to Discuss

This blog is intentionally comment-free. Discussion happens elsewhere:

- **Social/general**: [Discord](https://discord.gg/INVITE_CODE)
- **Technical/bugs**: GitHub Issues on relevant repos

## Links

- [GitHub (sw-lab)](https://github.com/software-wrighter-lab)
- [GitHub (softwarewrighter)](https://github.com/softwarewrighter)
- [YouTube](https://youtube.com/@softwarewrighter)
- [Discord](https://discord.gg/INVITE_CODE)

## About Me

I'm Mike Wright. I build things.

More repos at [wrightmikea](https://github.com/wrightmikea) and various `sw-*` organizations.
```

---

## Step 9: Create First Post

Create `_posts/2025-01-24-personal-software.md`:

```markdown
---
layout: post
title: "Personal Software: Tools That Exist for One Afternoon"
date: 2025-01-24
tags: [personal-software, ai-assisted, throwaway-code]
discord: "#personal-tools-showcase"
---

*This is the first post on Software Wrighter Lab — a blog about building small, experimental software tools, often with AI, often just for myself. No comments here; discussion happens on [Discord](https://discord.gg/INVITE_CODE).*

---

Most of the software I rely on every week is software no one else will ever use.

It isn't polished.
It isn't documented.
It often isn't even versioned properly.

...

[REST OF POST CONTENT FROM blog/topics/personal-software/draft-01.md]
```

**Note:** Copy the full content from your draft in this planning repo.

---

## Step 10: Create Topic Landing Pages (Optional)

Create `_topics/personal-software.md`:

```markdown
---
layout: page
title: "Personal Software"
description: "Posts about building one-off tools for yourself"
---

# Personal Software

Posts about building small, disposable, personal tools—often with AI assistance.

## Posts

{% for post in site.posts %}
{% if post.tags contains 'personal-software' %}
- [{{ post.title }}]({{ post.url }}) — {{ post.date | date: "%B %Y" }}
{% endif %}
{% endfor %}

## Discuss

Join `#personal-tools-showcase` on [Discord](https://discord.gg/INVITE_CODE).
```

Repeat for other topics: `context-reduction.md`, `thinking-llms.md`, etc.

---

## Step 11: Test Locally

```bash
# Serve with live reload
bundle exec jekyll serve --livereload

# Or serve drafts too
bundle exec jekyll serve --livereload --drafts

# Open in browser
open http://localhost:4000
```

Check:
- [ ] Homepage shows posts
- [ ] Post pages render correctly
- [ ] Footer includes Discord link
- [ ] About page looks good
- [ ] RSS feed works at `/feed.xml`

---

## Step 12: Deploy to GitHub Pages

### Option A: Deploy from main branch (simplest)

1. Push to GitHub:

```bash
git add .
git commit -m "Initial Jekyll setup"
git push origin main
```

2. Enable GitHub Pages:
   - Go to repo → **Settings** → **Pages**
   - Source: **Deploy from a branch**
   - Branch: **main** / **/ (root)**
   - Click **Save**

3. Wait 1-2 minutes, then visit `https://software-wrighter-lab.github.io`

### Option B: Use GitHub Actions (more control)

Create `.github/workflows/jekyll.yml`:

```yaml
name: Deploy Jekyll site to Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
      - name: Setup Pages
        uses: actions/configure-pages@v4
      - name: Build with Jekyll
        run: bundle exec jekyll build
        env:
          JEKYLL_ENV: production
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

Then in repo Settings → Pages:
- Source: **GitHub Actions**

---

## Step 13: Optional Enhancements

### Add Tags Page

Create `tags.html` in root:

```html
---
layout: page
title: Tags
permalink: /tags/
---

<div class="tags">
{% for tag in site.tags %}
  <h2 id="{{ tag[0] }}">{{ tag[0] }}</h2>
  <ul>
  {% for post in tag[1] %}
    <li><a href="{{ post.url }}">{{ post.title }}</a> — {{ post.date | date: "%B %Y" }}</li>
  {% endfor %}
  </ul>
{% endfor %}
</div>
```

### Add Search (using lunr.js)

This requires more setup. Consider adding later if needed. For now, tags + RSS are sufficient.

### Add Reading Time

In `_includes/post-meta.html` or similar:

```liquid
{% assign words = content | number_of_words %}
{% assign minutes = words | divided_by: 200 %}
{% if minutes < 1 %}1{% else %}{{ minutes }}{% endif %} min read
```

### Custom Domain (Later)

1. Buy domain (e.g., `softwarewrighterlab.com`)
2. Create `CNAME` file in repo root with domain name
3. Configure DNS:
   - A records pointing to GitHub's IPs
   - Or CNAME to `software-wrighter-lab.github.io`
4. Enable HTTPS in repo Settings → Pages

---

## Step 14: Workflow for Publishing

### From draft in planning repo to published post:

1. Edit draft in `sw-lab/blog/topics/<topic>/draft-NN.md`
2. When ready, copy to `software-wrighter-lab.github.io/_posts/YYYY-MM-DD-title.md`
3. Update front matter:
   - Set actual date
   - Fill in `repo:` and `video:` if applicable
   - Replace `INVITE_CODE` with real Discord invite
4. Test locally: `bundle exec jekyll serve`
5. Commit and push:

```bash
git add _posts/YYYY-MM-DD-title.md
git commit -m "Publish: Title of Post"
git push
```

6. Announce on Discord `#blog-video-links`

---

## Final Checklist

- [ ] Ruby and Jekyll installed
- [ ] Repository created: `software-wrighter-lab.github.io`
- [ ] `_config.yml` configured with correct URLs
- [ ] `Gemfile` set up with plugins
- [ ] Directory structure created
- [ ] `_includes/post-footer.html` created
- [ ] `about.markdown` written
- [ ] First post created in `_posts/`
- [ ] Local build works (`bundle exec jekyll serve`)
- [ ] GitHub Pages enabled
- [ ] Site accessible at `https://software-wrighter-lab.github.io`
- [ ] RSS feed works at `/feed.xml`
- [ ] Discord invite link updated in all files

---

## Files to Update with Discord Invite

Once you have your Discord invite code, replace `INVITE_CODE` in:

- `_config.yml` (author links)
- `_includes/post-footer.html`
- `about.markdown`
- All posts in `_posts/`

---

## Troubleshooting

### "Could not find gem" errors

```bash
bundle install
```

### Build fails on GitHub

Check the Actions tab for error logs. Common issues:
- Missing plugin in `Gemfile`
- YAML syntax error in `_config.yml`
- Invalid front matter in a post

### CSS not loading

Check `baseurl` in `_config.yml`. For `username.github.io` repos, it should be empty (`""`).

### Posts not showing

- Filename must be `YYYY-MM-DD-title.md`
- Date in front matter must not be in the future
- Check for YAML front matter errors (must have `---` at top and bottom)
