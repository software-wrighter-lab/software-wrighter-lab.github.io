#!/bin/bash
# deploy.sh - Pre-built deployment to GitHub Pages
# Builds Jekyll locally, pushes static files to gh-pages branch
# Usage: ./scripts/deploy.sh ["Commit message"]

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
PUBLISH_DIR="$HOME/github/software-wrighter-lab/sw-lab.github.io.git"
LIVE_URL="https://software-wrighter-lab.github.io"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Pre-Built Deployment to GitHub Pages ===${NC}"
echo ""

# Step 0: Check for orphaned posts (posts without series metadata)
echo -e "${YELLOW}[0/6] Checking for orphaned posts...${NC}"
ORPHANED=()
# Posts that are intentionally standalone (not part of any series)
ALLOWED_ORPHANS="welcome-to-software-wrighter-lab"

for post in "$SOURCE_DIR/_posts/"*.md; do
    if ! grep -q "^series:" "$post"; then
        BASENAME=$(basename "$post" .md)
        # Check if it's in the allowed orphans list
        SLUG=$(echo "$BASENAME" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')
        if [[ ! "$ALLOWED_ORPHANS" == *"$SLUG"* ]]; then
            ORPHANED+=("$BASENAME")
        fi
    fi
done

if [ ${#ORPHANED[@]} -gt 0 ]; then
    echo -e "${RED}ERROR: Found orphaned posts (not in any series):${NC}"
    for orphan in "${ORPHANED[@]}"; do
        echo -e "  ${RED}• $orphan${NC}"
    done
    echo ""
    echo "Each post should have 'series:' and 'series_part:' in front matter."
    echo "Allowed standalone posts: $ALLOWED_ORPHANS"
    exit 1
fi
echo -e "${GREEN}  All posts are in a series (or allowed standalone)${NC}"

# Step 1: Build the site locally
echo -e "${YELLOW}[1/6] Building site locally...${NC}"
cd "$SOURCE_DIR"
JEKYLL_ENV=production bundle exec jekyll build
echo -e "${GREEN}Build complete: $(ls -1 _site | wc -l | tr -d ' ') top-level items in _site${NC}"

# Step 2: Identify recent posts for verification
echo -e "\n${YELLOW}[2/6] Identifying recent posts for verification...${NC}"
RECENT_POSTS=$(ls -1 "$SOURCE_DIR/_posts/"*.md 2>/dev/null | sort -r | head -2)
for post in $RECENT_POSTS; do
    echo "  $(basename "$post")"
done

# Step 3: Switch to gh-pages branch and clean
echo -e "\n${YELLOW}[3/6] Preparing publishing repo (gh-pages branch)...${NC}"
cd "$PUBLISH_DIR"
git checkout gh-pages

# macOS-compatible cleanup: remove everything except .git
# Using explicit loop instead of find (find ! syntax doesn't work on macOS)
for item in *; do
    [ -e "$item" ] && rm -rf "$item"
done
for item in .[!.]*; do
    [ "$item" != ".git" ] && [ -e "$item" ] && rm -rf "$item"
done
echo "  Cleaned publishing directory"

# Step 4: Copy built site
echo -e "\n${YELLOW}[4/6] Copying built site...${NC}"
cp -r "$SOURCE_DIR/_site/"* .
touch .nojekyll
FILE_COUNT=$(find . -type f | wc -l | tr -d ' ')
echo "  Copied $FILE_COUNT files"

# Step 5: Commit and push
echo -e "\n${YELLOW}[5/6] Committing and pushing...${NC}"
git add -A

COMMIT_MSG="${1:-Publish: $(date +%Y-%m-%d_%H:%M)}"
CHANGED_FILES=$(git diff --cached --numstat | wc -l | tr -d ' ')

if [ "$CHANGED_FILES" -eq 0 ]; then
    echo -e "${YELLOW}No changes to deploy.${NC}"
    exit 0
fi

echo "  $CHANGED_FILES files changed"
git commit -m "$COMMIT_MSG

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push origin gh-pages
echo -e "${GREEN}Pushed to gh-pages${NC}"

# Step 6: Verify deployment
echo -e "\n${YELLOW}[6/6] Verifying deployment...${NC}"
echo "  Waiting 10 seconds for GitHub Pages propagation..."
sleep 10

VERIFY_FAILED=0
for post in $RECENT_POSTS; do
    FILENAME=$(basename "$post" .md)
    DATE_PARTS=$(echo "$FILENAME" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
    YEAR=$(echo "$DATE_PARTS" | cut -d- -f1)
    MONTH=$(echo "$DATE_PARTS" | cut -d- -f2)
    DAY=$(echo "$DATE_PARTS" | cut -d- -f3)
    SLUG=$(echo "$FILENAME" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')

    POST_URL="$LIVE_URL/$YEAR/$MONTH/$DAY/$SLUG/"
    LOCAL_FILE="$PUBLISH_DIR/$YEAR/$MONTH/$DAY/$SLUG/index.html"

    echo -n "  Checking $SLUG... "

    # Get title from local file
    LOCAL_TITLE=$(grep -o '<title>[^<]*</title>' "$LOCAL_FILE" 2>/dev/null | head -1)

    # Get title from live site (bypass cache with unique query param)
    LIVE_TITLE=$(curl -s "$POST_URL?nocache=$(date +%s)" | grep -o '<title>[^<]*</title>' 2>/dev/null | head -1)

    if [ "$LOCAL_TITLE" = "$LIVE_TITLE" ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}MISMATCH${NC}"
        echo "    Local: $LOCAL_TITLE"
        echo "    Live:  $LIVE_TITLE"
        VERIFY_FAILED=1
    fi
done

echo ""
if [ "$VERIFY_FAILED" -eq 1 ]; then
    echo -e "${RED}=== VERIFICATION FAILED ===${NC}"
    echo "Live site does not match local build."
    echo "This may be a propagation delay - try again in a few minutes."
    exit 1
else
    echo -e "${GREEN}=== Deployment Successful ===${NC}"
    echo "Live site: $LIVE_URL"
fi
