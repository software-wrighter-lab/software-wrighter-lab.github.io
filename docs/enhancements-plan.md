# Blog Enhancements Plan

## Current Implementation

### Home Page Pagination (Implemented)
- JavaScript-based client-side pagination
- Posts per page dropdown: 5, 10, 25, 50, 100
- Navigation: < Prev | 1 2 3 ... N | Next >
- Controls at both top and bottom of post list
- Shows "Showing X-Y of Z" count
- Maximum 100 most recent posts on home page
- Older posts accessible via Archive, Index, Series, Tags, Categories, Search

### Performance Optimization (Implemented)
- First 10 posts visible immediately via CSS (no JS wait)
- CSS rule: `.post-item:nth-child(-n+10) { display: block; }`
- Once JS loads, it adds `.js-pagination` class and takes over
- Result: Above-the-fold content appears before JS executes

---

## Future Enhancements

### Lazy Loading Posts (Not Implemented)

**Problem**: With 100 posts including excerpts, TOCs, and video embeds, the HTML could be 500KB-1MB even though only 10 posts are visible initially.

**Proposed Solution**:

1. **Server-side**: Only render first 20 posts in HTML
2. **JSON endpoint**: Create `/api/posts.json` with metadata for remaining posts:
   ```json
   [
     {
       "title": "Post Title",
       "url": "/2026/01/15/post-slug/",
       "date": "2026-01-15",
       "excerpt": "First paragraph...",
       "author": "Software Wrighter",
       "tags": ["tag1", "tag2"],
       "series": "Series Name",
       "series_part": 1,
       "video_url": "https://youtube.com/...",
       "word_count": 850,
       "reading_time": "4 min"
     }
   ]
   ```
3. **Client-side**: Fetch and render posts on demand when user navigates past initial set

**Benefits**:
- Initial page load under 100KB regardless of total posts
- Faster Time to First Contentful Paint (FCP)
- Reduced bandwidth for users who only view first page

**Complexity**:
- Requires Jekyll plugin or build script to generate JSON
- Client-side templating to render fetched posts
- Need to handle TOC generation client-side or pre-render

**Recommendation**: Implement when post count exceeds 50 and page load becomes noticeably slow.

---

### Other Potential Enhancements

#### Infinite Scroll Option
- Alternative to pagination
- Load more posts as user scrolls
- Keep pagination as fallback/preference

#### Search Improvements
- Client-side fuzzy search with lunr.js
- Search within post content (not just titles)
- Highlight matching terms in results

#### Reading Progress
- Progress bar on individual post pages
- "Back to top" floating button
- Estimated reading time already implemented

#### Dark Mode Improvements
- System preference detection (already works)
- Smooth transition animation
- Per-image dark mode alternatives

---

*Last updated: 2026-02-01*
