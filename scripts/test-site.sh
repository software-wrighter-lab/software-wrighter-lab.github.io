#!/bin/bash
# Site regression tests - run before/after deploy to catch broken pages
# Usage:
#   ./scripts/test-site.sh local    # Test local source repo structure
#   ./scripts/test-site.sh live     # Test live site URLs and content
#   ./scripts/test-site.sh both     # Run both (default)

# Don't use set -e because we handle errors ourselves
# set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
PUBLISH_DIR="$HOME/github/software-wrighter-lab/sw-lab.github.io.git"
SITE_URL="https://software-wrighter-lab.github.io"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0
MODE="${1:-both}"

log_error() {
    echo -e "${RED}FAIL: $1${NC}"
    ((ERRORS++))
}

log_ok() {
    echo -e "${GREEN}OK: $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}WARN: $1${NC}"
    ((WARNINGS++))
}

# ============================================================
# LOCAL STRUCTURE TESTS
# ============================================================
test_local_structure() {
    echo ""
    echo "=== Local Structure Tests ==="
    echo ""

    # Critical source files
    echo "Checking critical source files..."
    for file in _config.yml Gemfile; do
        if [ -f "$SOURCE_DIR/$file" ]; then
            log_ok "$file exists"
        else
            log_error "$file missing from source"
        fi
    done

    # Critical pages (any extension)
    echo ""
    echo "Checking critical pages..."
    for page in index about 404; do
        if ls "$SOURCE_DIR/$page".* >/dev/null 2>&1; then
            FOUND=$(ls "$SOURCE_DIR/$page".* 2>/dev/null | head -1)
            log_ok "$page page exists ($(basename "$FOUND"))"
        else
            log_error "$page page missing (no $page.html, $page.md, or $page.markdown)"
        fi
    done

    # Layouts
    echo ""
    echo "Checking layouts..."
    for layout in post home; do
        if [ -f "$SOURCE_DIR/_layouts/$layout.html" ]; then
            log_ok "_layouts/$layout.html exists"
        else
            log_error "_layouts/$layout.html missing"
        fi
    done

    # Posts count
    echo ""
    echo "Checking posts..."
    POST_COUNT=$(ls "$SOURCE_DIR/_posts"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$POST_COUNT" -gt 50 ]; then
        log_ok "$POST_COUNT posts found"
    elif [ "$POST_COUNT" -gt 10 ]; then
        log_warn "Only $POST_COUNT posts found (expected 50+)"
    else
        log_error "Only $POST_COUNT posts found (expected 50+)"
    fi

    # Navigation links - check config or custom header
    echo ""
    echo "Checking navigation config..."
    if grep -q "header_pages" "$SOURCE_DIR/_config.yml"; then
        # Using theme header with header_pages config
        for page in about series; do
            if grep -q "$page" "$SOURCE_DIR/_config.yml"; then
                log_ok "header_pages includes $page"
            else
                log_warn "header_pages missing $page"
            fi
        done
    elif [ -f "$SOURCE_DIR/_includes/header.html" ]; then
        # Custom header
        for link in About Series; do
            if grep -q "$link" "$SOURCE_DIR/_includes/header.html"; then
                log_ok "Header contains $link link"
            else
                log_warn "Header missing $link link"
            fi
        done
    else
        log_warn "No header_pages config and no custom header.html"
    fi

    # Check all page templates have front matter (skip README, LICENSE, etc.)
    echo ""
    echo "Checking page templates have front matter..."
    for file in "$SOURCE_DIR"/*.html "$SOURCE_DIR"/*.md "$SOURCE_DIR"/*.markdown; do
        [ -f "$file" ] || continue
        BASENAME=$(basename "$file")
        # Skip non-template files
        case "$BASENAME" in
            README.md|LICENSE*|CONTRIBUTING*|CHANGELOG*|*.txt)
                continue
                ;;
        esac
        if head -1 "$file" | grep -q "^---$"; then
            log_ok "$BASENAME has front matter"
        else
            log_error "$BASENAME missing front matter (not a Jekyll template!)"
        fi
    done
}

# ============================================================
# LIVE SITE TESTS
# ============================================================
test_live_site() {
    echo ""
    echo "=== Live Site Tests ==="
    echo ""

    # Critical pages return 200
    echo "Checking critical pages return 200..."
    for path in "" "about/" "series/" "index-all/" "abstracts/"; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL/$path")
        if [ "$STATUS" = "200" ]; then
            log_ok "/$path returns 200"
        else
            log_error "/$path returns $STATUS (expected 200)"
        fi
    done

    # Check navigation links exist on homepage
    echo ""
    echo "Checking homepage navigation..."
    HOMEPAGE=$(curl -s "$SITE_URL/")
    for link in About Series; do
        if echo "$HOMEPAGE" | grep -q ">$link<"; then
            log_ok "Homepage has $link link"
        elif echo "$HOMEPAGE" | grep -qi "href=.*$link"; then
            log_ok "Homepage has $link link (in href)"
        else
            log_error "Homepage missing $link navigation link"
        fi
    done

    # Check recent posts appear on index pages
    echo ""
    echo "Checking recent posts on index..."
    YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
    INDEX_ALL=$(curl -s "$SITE_URL/index-all/")

    # Count posts from yesterday
    YESTERDAY_COUNT=$(echo "$INDEX_ALL" | grep -c "$YESTERDAY" || true)
    if [ "$YESTERDAY_COUNT" -gt 0 ]; then
        log_ok "$YESTERDAY_COUNT references to yesterday's date on index-all"
    else
        log_warn "No posts from yesterday visible on index-all"
    fi

    # Check series navigation on a random series post
    echo ""
    echo "Checking series navigation..."
    SERIES_NAV=$(curl -s "$SITE_URL/2026/02/10/five-ml-concepts-7/" | grep -c "series-nav" || true)
    if [ "$SERIES_NAV" -gt 0 ]; then
        log_ok "Series navigation present on series posts"
    else
        log_error "Series navigation missing from series posts"
    fi

    # Check video embeds work
    echo ""
    echo "Checking video embeds..."
    VIDEO_EMBED=$(curl -s "$SITE_URL/2026/02/10/five-ml-concepts-7/" | grep -c "youtube-embed" || true)
    if [ "$VIDEO_EMBED" -gt 0 ]; then
        log_ok "Video embeds present"
    else
        log_warn "No video embeds found on sample post"
    fi

    # Check no pre-built HTML in publishing repo (local check)
    echo ""
    echo "Checking publishing repo structure..."
    PREBUILT=0
    for dir in "$PUBLISH_DIR/abstracts" "$PUBLISH_DIR/index-all" "$PUBLISH_DIR/categories"; do
        if [ -d "$dir" ]; then
            log_error "Pre-built directory exists: $(basename "$dir")/"
            ((PREBUILT++))
        fi
    done
    if [ $PREBUILT -eq 0 ]; then
        log_ok "No pre-built HTML directories"
    fi
}

# ============================================================
# MAIN
# ============================================================
echo "=== Site Regression Tests ==="
echo "Mode: $MODE"

case "$MODE" in
    local)
        test_local_structure
        ;;
    live)
        test_live_site
        ;;
    both|*)
        test_local_structure
        test_live_site
        ;;
esac

# Summary
echo ""
echo "=== Test Summary ==="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}Passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}FAILED: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
fi
