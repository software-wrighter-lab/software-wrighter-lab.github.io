#!/bin/bash
# Safe deployment script for sw-lab blog
# Pushes Jekyll SOURCE files to publishing repo for GitHub Actions to build
# This enables scheduled posts via daily cron rebuild

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
PUBLISH_DIR="$HOME/github/software-wrighter-lab/sw-lab.github.io.git"

echo "=== SW-Lab Safe Deployment ==="
echo ""

# Step 1: Kill any running Jekyll server
echo "[1/5] Stopping any running Jekyll servers..."
pkill -f "jekyll serve" 2>/dev/null || true
sleep 1

# Step 2: Verify no drafts will be published
echo "[2/5] Checking for draft safety..."
if ls "$SOURCE_DIR/_drafts"/*.md >/dev/null 2>&1; then
    DRAFT_COUNT=$(ls "$SOURCE_DIR/_drafts"/*.md 2>/dev/null | wc -l)
    echo "  Found $DRAFT_COUNT drafts in _drafts/ (these will NOT be published)"
fi
echo "  Drafts excluded. Safe to deploy."

# Step 3: Sync source files to publishing repo
echo "[3/5] Syncing source files to publishing repo..."
cd "$PUBLISH_DIR"

# Preserve .git and .github directories
# Remove old pre-built HTML directories (from old HTML deployment workflow)
rm -rf abstracts index-all archive categories tags search series 2>/dev/null || true
# Remove old source files and any pre-built index.html
rm -rf _data _includes _layouts _posts _sass assets 2>/dev/null || true
rm -f about.* archive.* index.* blog.* categories.* tags.* series.* papers.* \
      abstracts.* index-all.* 404.* feed.xml search.* \
      Gemfile Gemfile.lock _config.yml 2>/dev/null || true

# Copy Jekyll source files (excluding drafts, _site, .git)
cp "$SOURCE_DIR/_config.yml" . || { echo "ERROR: _config.yml not found"; exit 1; }
cp "$SOURCE_DIR/Gemfile" . 2>/dev/null || true
cp "$SOURCE_DIR/Gemfile.lock" . 2>/dev/null || true

# Copy page templates - check ALL possible extensions (.html, .md, .markdown)
PAGES="index about archive blog categories tags series papers abstracts index-all 404 search"
for page in $PAGES; do
    FOUND=false
    for ext in html md markdown; do
        if [ -f "$SOURCE_DIR/$page.$ext" ]; then
            cp "$SOURCE_DIR/$page.$ext" .
            FOUND=true
            break
        fi
    done
    # Warn if critical pages are missing (but don't fail for optional ones)
    if [ "$FOUND" = false ]; then
        case "$page" in
            index|about|404)
                echo "ERROR: Required page $page not found (checked .html, .md, .markdown)"
                exit 1
                ;;
            *)
                # Optional pages - just note if missing
                ;;
        esac
    fi
done
cp "$SOURCE_DIR/feed.xml" . 2>/dev/null || true
cp -r "$SOURCE_DIR/_data" . 2>/dev/null || true
cp -r "$SOURCE_DIR/_includes" . 2>/dev/null || true
cp -r "$SOURCE_DIR/_layouts" . 2>/dev/null || true
cp -r "$SOURCE_DIR/_posts" . 2>/dev/null || true
cp -r "$SOURCE_DIR/_sass" . 2>/dev/null || true
cp -r "$SOURCE_DIR/assets" . 2>/dev/null || true

# Do NOT copy _drafts - they must never be published

# Step 4: Add README
echo "[4/6] Updating README..."
cat > README.md << 'EOF'
# Software Wrighter Lab

A blog about AI, machine learning, and programming.

**Live site:** https://software-wrighter-lab.github.io/

## About

Software Wrighter Lab explores:
- Machine learning concepts and research papers
- AI agents and continuous learning
- Rust, WebAssembly, and systems programming
- Throwback Thursday programming history

## Build

This repo contains Jekyll source files. GitHub Actions builds and deploys automatically.
- Push to main → immediate build
- Daily cron (00:30 Pacific) → publishes scheduled posts
EOF

# Step 5: Validate critical files before committing
echo "[5/6] Validating deployment..."
MISSING=""
# Check critical files exist (only check files we actually have, not theme defaults)
for required in _config.yml _layouts/post.html; do
    if [ ! -f "$required" ]; then
        MISSING="$MISSING $required"
    fi
done
# Check at least one page template for each critical page
for page in index about 404; do
    if ! ls "$page".* >/dev/null 2>&1; then
        MISSING="$MISSING $page.*"
    fi
done
# Check posts exist
POST_COUNT=$(ls _posts/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$POST_COUNT" -lt 10 ]; then
    echo "ERROR: Only $POST_COUNT posts found - something went wrong!"
    exit 1
fi
# Check no pre-built HTML directories exist (these block Jekyll regeneration)
for dir in abstracts index-all archive categories tags search series; do
    if [ -d "$dir" ]; then
        echo "ERROR: Pre-built directory $dir/ exists - remove it!"
        exit 1
    fi
done
# Check critical page templates have Jekyll front matter
for page in index about 404; do
    PAGEFILE=$(ls "$page".* 2>/dev/null | head -1)
    if [ -n "$PAGEFILE" ]; then
        if ! head -1 "$PAGEFILE" | grep -q "^---$"; then
            echo "ERROR: $PAGEFILE is not a Jekyll template (missing front matter)"
            exit 1
        fi
    fi
done
if [ -n "$MISSING" ]; then
    echo "ERROR: Missing critical files:$MISSING"
    exit 1
fi
echo "  Validated: $POST_COUNT posts, critical files present, no pre-built dirs"

# Step 6: Commit and push
echo "[6/6] Committing and pushing to live..."
git add -A
if git diff --cached --quiet; then
    echo "  No changes to deploy."
else
    COMMIT_MSG="${1:-Deploy: $(date +%Y-%m-%d_%H:%M)}"
    git commit -m "$COMMIT_MSG

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
    git push
    echo ""
    echo "=== Deployment Complete ==="
    echo "Live site: https://software-wrighter-lab.github.io/"
    echo ""
    echo "Scheduled posts will publish automatically via daily cron (00:30 Pacific)"
fi
