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
echo -e "${YELLOW}[1/7] Building site locally...${NC}"
cd "$SOURCE_DIR"
JEKYLL_ENV=production bundle exec jekyll build
echo -e "${GREEN}Build complete: $(ls -1 _site | wc -l | tr -d ' ') top-level items in _site${NC}"

# Step 2: Validate series navigation
echo -e "\n${YELLOW}[2/7] Validating series navigation...${NC}"
SERIES_ERRORS=0

# Get all unique series names
SERIES_LIST=$(grep -h "^series:" "$SOURCE_DIR/_posts/"*.md 2>/dev/null | sed 's/series: *"\([^"]*\)"/\1/' | sort -u)

for series_name in $SERIES_LIST; do
    # Get all posts in this series with their parts
    SERIES_POSTS=()
    while IFS= read -r post; do
        PART=$(grep "^series_part:" "$post" | sed 's/series_part: *//')
        SERIES_POSTS+=("$PART:$post")
    done < <(grep -l "^series: \"$series_name\"" "$SOURCE_DIR/_posts/"*.md 2>/dev/null)

    # Sort by part number
    IFS=$'\n' SORTED_POSTS=($(printf '%s\n' "${SERIES_POSTS[@]}" | sort -t: -k1 -n))
    unset IFS

    # Check for duplicates
    PARTS_ONLY=$(printf '%s\n' "${SORTED_POSTS[@]}" | cut -d: -f1)
    UNIQUE_PARTS=$(echo "$PARTS_ONLY" | sort -u)
    if [ "$(echo "$PARTS_ONLY" | wc -l)" != "$(echo "$UNIQUE_PARTS" | wc -l)" ]; then
        echo -e "  ${RED}ERROR: Duplicate series_part in '$series_name'${NC}"
        SERIES_ERRORS=1
    fi

    # Check that each non-max post has "Next" link in built HTML
    MAX_PART=$(echo "$PARTS_ONLY" | tail -1)
    for entry in "${SORTED_POSTS[@]}"; do
        PART=$(echo "$entry" | cut -d: -f1)
        POST_PATH=$(echo "$entry" | cut -d: -f2-)

        if [ "$PART" != "$MAX_PART" ]; then
            # Get the built HTML path
            FILENAME=$(basename "$POST_PATH" .md)
            DATE_PARTS=$(echo "$FILENAME" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
            YEAR=$(echo "$DATE_PARTS" | cut -d- -f1)
            MONTH=$(echo "$DATE_PARTS" | cut -d- -f2)
            DAY=$(echo "$DATE_PARTS" | cut -d- -f3)
            SLUG=$(echo "$FILENAME" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')

            HTML_FILE="$SOURCE_DIR/_site/$YEAR/$MONTH/$DAY/$SLUG/index.html"
            NEXT_PART=$((PART + 1))

            if [ -f "$HTML_FILE" ]; then
                if ! grep -q "Next: Part $NEXT_PART" "$HTML_FILE"; then
                    echo -e "  ${RED}ERROR: '$series_name' part $PART missing 'Next: Part $NEXT_PART' link${NC}"
                    echo "    File: $FILENAME"
                    SERIES_ERRORS=1
                fi
            fi
        fi
    done
done

if [ "$SERIES_ERRORS" -eq 1 ]; then
    echo -e "${RED}Series navigation validation failed.${NC}"
    exit 1
fi
echo -e "${GREEN}  All series navigation links verified${NC}"

# Step 3: Identify recent posts for verification
echo -e "\n${YELLOW}[3/7] Identifying recent posts for verification...${NC}"
RECENT_POSTS=$(ls -1 "$SOURCE_DIR/_posts/"*.md 2>/dev/null | sort -r | head -2)
for post in $RECENT_POSTS; do
    echo "  $(basename "$post")"
done

# Step 4: Switch to gh-pages branch and clean
echo -e "\n${YELLOW}[4/7] Preparing publishing repo (gh-pages branch)...${NC}"
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

# Step 5: Copy built site
echo -e "\n${YELLOW}[5/7] Copying built site...${NC}"
cp -r "$SOURCE_DIR/_site/"* .
touch .nojekyll
FILE_COUNT=$(find . -type f | wc -l | tr -d ' ')
echo "  Copied $FILE_COUNT files"

# Step 6: Commit and push
echo -e "\n${YELLOW}[6/7] Committing and pushing...${NC}"
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

# Step 7: Verify deployment
echo -e "\n${YELLOW}[7/7] Verifying deployment...${NC}"
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
