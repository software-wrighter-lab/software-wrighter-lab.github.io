# Software Wrighter Lab

**Live site:** [https://software-wrighter-lab.github.io](https://software-wrighter-lab.github.io)

A blog exploring AI coding agents, systems programming, and practical machine learning.

## Adding New Posts

1. Create a new file in `_posts/` with the naming format:
   ```
   YYYY-MM-DD-title-slug.md
   ```

2. Add front matter at the top:
   ```yaml
   ---
   layout: post
   title: "Your Post Title"
   date: YYYY-MM-DD 09:00:00 -0800
   categories: [category1, category2]
   tags: [tag1, tag2, tag3]
   author: Software Wrighter
   ---
   ```

3. Optional front matter for series posts:
   ```yaml
   series: "Series Name"
   series_part: 1
   video_url: "https://youtube.com/..."
   repo_url: "https://github.com/..."
   ```

4. Add a post marker image after the front matter:
   ```html
   <img src="/assets/images/site/post-marker-floral.png" class="post-marker" alt="">
   ```
   Available markers: `post-marker-floral.png`, `post-marker-pot.png`, `post-marker-coffee-pot.png`, `post-marker-gimlet.png`

5. Add a resource box for links:
   ```html
   <div class="resource-box" markdown="1">

   | Resource | Link |
   |----------|------|
   | **Paper** | [Title](https://...) |
   | **Code** | [repo-name](https://github.com/...) |

   [![Video](https://img.youtube.com/vi/VIDEO_ID/mqdefault.jpg){: .video-thumb}](https://youtube.com/...)

   </div>
   ```

## Scheduling Posts

Posts with future dates are **hidden by default**. They will only appear after:
1. The date has passed, AND
2. The site has been rebuilt

GitHub Pages only rebuilds when you push a commit.

### Publishing a Scheduled Post

When you're ready to publish a future-dated post (after its date has arrived):

```bash
# Option 1: Push an empty commit to trigger rebuild
git commit --allow-empty -m "Publish scheduled posts"
git push

# Option 2: Make any change and push
echo "" >> README.md
git add README.md
git commit -m "Trigger rebuild"
git push
```

## Local Development

```bash
# Install dependencies
bundle install

# Run local server (shows all posts including future)
bundle exec jekyll serve --future

# Run without future posts (matches production)
bundle exec jekyll serve
```

## Repository Structure

```
_posts/           # Blog posts (YYYY-MM-DD-title.md)
_includes/        # Reusable HTML components
_layouts/         # Page layouts
assets/
  images/
    site/         # Site-wide images (logo, post markers)
    posts/        # Post-specific images
  js/             # JavaScript (theme toggle, font size, search)
  main.scss       # Custom styles
```

## Features

- Dark/light mode with OS preference detection
- Font size controls (A-/A/A+)
- Decorative post markers (auto-invert for dark mode)
- Resource boxes with video thumbnails
- Full-text search
- Archive, Series, Tags, Categories pages
