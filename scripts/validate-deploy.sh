#!/bin/bash
# Validate that a deployment was successful
# Run after deploy.sh to verify posts appear correctly on live site

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
PUBLISH_DIR="$HOME/github/software-wrighter-lab/sw-lab.github.io.git"
SITE_URL="https://software-wrighter-lab.github.io"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "=== Post-Deployment Validation ==="
echo ""

# 1. Check publishing repo has no pre-built HTML directories
echo "[1/6] Checking for pre-built HTML directories..."
PREBUILT_DIRS=""
for dir in abstracts index-all archive categories tags search series; do
    if [ -d "$PUBLISH_DIR/$dir" ]; then
        PREBUILT_DIRS="$PREBUILT_DIRS $dir/"
    fi
done
if [ -n "$PREBUILT_DIRS" ]; then
    echo -e "  ${RED}ERROR: Pre-built directories found:$PREBUILT_DIRS${NC}"
    echo "  These block Jekyll from regenerating pages. Run deploy.sh again."
    ((ERRORS++))
else
    echo -e "  ${GREEN}OK: No pre-built HTML directories${NC}"
fi

# 2. Check source templates have Jekyll front matter
echo ""
echo "[2/6] Checking source templates have Jekyll front matter..."
MISSING_FRONTMATTER=""
for file in index.html abstracts.html index-all.html; do
    if [ -f "$PUBLISH_DIR/$file" ]; then
        if ! head -1 "$PUBLISH_DIR/$file" | grep -q "^---$"; then
            MISSING_FRONTMATTER="$MISSING_FRONTMATTER $file"
        fi
    else
        echo -e "  ${YELLOW}WARNING: Missing $file${NC}"
        ((WARNINGS++))
    fi
done
if [ -n "$MISSING_FRONTMATTER" ]; then
    echo -e "  ${RED}ERROR: Files without front matter:$MISSING_FRONTMATTER${NC}"
    echo "  These are pre-built HTML, not Jekyll templates!"
    ((ERRORS++))
else
    echo -e "  ${GREEN}OK: All templates have Jekyll front matter${NC}"
fi

# 3. Check recent posts exist in publishing repo
echo ""
echo "[3/6] Checking recent posts in publishing repo..."
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
RECENT_POSTS=$(ls "$PUBLISH_DIR/_posts/$TODAY"*.md "$PUBLISH_DIR/_posts/$YESTERDAY"*.md 2>/dev/null | wc -l | tr -d ' ')
echo "  Found $RECENT_POSTS posts from today/yesterday"
if [ "$RECENT_POSTS" -eq 0 ]; then
    echo -e "  ${YELLOW}WARNING: No posts from last 2 days${NC}"
    ((WARNINGS++))
else
    echo -e "  ${GREEN}OK: Recent posts present${NC}"
fi

# 4. Check GitHub Actions workflow status
echo ""
echo "[4/6] Checking latest GitHub Actions workflow..."
LATEST_RUN=$(gh run list --repo software-wrighter-lab/software-wrighter-lab.github.io -L 1 --json status,conclusion,displayTitle 2>/dev/null)
if [ -n "$LATEST_RUN" ]; then
    STATUS=$(echo "$LATEST_RUN" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    CONCLUSION=$(echo "$LATEST_RUN" | grep -o '"conclusion":"[^"]*"' | cut -d'"' -f4)
    TITLE=$(echo "$LATEST_RUN" | grep -o '"displayTitle":"[^"]*"' | cut -d'"' -f4)

    if [ "$STATUS" = "completed" ] && [ "$CONCLUSION" = "success" ]; then
        echo -e "  ${GREEN}OK: Latest build succeeded${NC}"
        echo "  Title: $TITLE"
    elif [ "$STATUS" = "in_progress" ]; then
        echo -e "  ${YELLOW}WARNING: Build still in progress${NC}"
        echo "  Wait for completion and re-run validation"
        ((WARNINGS++))
    else
        echo -e "  ${RED}ERROR: Latest build failed or cancelled${NC}"
        echo "  Status: $STATUS, Conclusion: $CONCLUSION"
        ((ERRORS++))
    fi
else
    echo -e "  ${YELLOW}WARNING: Could not check workflow status (gh CLI)${NC}"
    ((WARNINGS++))
fi

# 5. Check live site is accessible
echo ""
echo "[5/6] Checking live site accessibility..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL/")
if [ "$HTTP_STATUS" = "200" ]; then
    echo -e "  ${GREEN}OK: Site returns 200${NC}"
else
    echo -e "  ${RED}ERROR: Site returned $HTTP_STATUS${NC}"
    ((ERRORS++))
fi

# 6. Check that posts from today/yesterday appear on index pages
echo ""
echo "[6/6] Checking posts appear on live index pages..."

# Get posts that should be visible (date <= now)
NOW_UTC=$(date -u +%Y-%m-%dT%H:%M:%S)
VISIBLE_POSTS=0
MISSING_POSTS=""

for post_file in "$PUBLISH_DIR/_posts/$TODAY"*.md "$PUBLISH_DIR/_posts/$YESTERDAY"*.md; do
    [ -f "$post_file" ] || continue

    # Extract date from frontmatter
    POST_DATE=$(grep "^date:" "$post_file" | head -1 | sed 's/date: *//' | tr -d '"')
    if [ -z "$POST_DATE" ]; then
        continue
    fi

    # Extract the URL slug from filename
    BASENAME=$(basename "$post_file" .md)
    # Format: YYYY-MM-DD-slug -> /YYYY/MM/DD/slug/
    YEAR=$(echo "$BASENAME" | cut -d'-' -f1)
    MONTH=$(echo "$BASENAME" | cut -d'-' -f2)
    DAY=$(echo "$BASENAME" | cut -d'-' -f3)
    SLUG=$(echo "$BASENAME" | cut -d'-' -f4-)
    POST_URL="/$YEAR/$MONTH/$DAY/$SLUG/"

    # Check if post appears in index-all
    if curl -s "$SITE_URL/index-all/" | grep -q "$SLUG"; then
        ((VISIBLE_POSTS++))
    else
        MISSING_POSTS="$MISSING_POSTS\n  - $BASENAME"
    fi
done

if [ -n "$MISSING_POSTS" ]; then
    echo -e "  ${RED}ERROR: Posts not appearing on index-all:${NC}"
    echo -e "$MISSING_POSTS"
    echo ""
    echo "  Possible causes:"
    echo "  - Build not yet complete (wait and retry)"
    echo "  - CDN caching (wait 10 minutes)"
    echo "  - Post date is in the future"
    ((ERRORS++))
else
    echo -e "  ${GREEN}OK: $VISIBLE_POSTS recent posts visible on index${NC}"
fi

# Summary
echo ""
echo "=== Validation Summary ==="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}Passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}Failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    exit 1
fi
