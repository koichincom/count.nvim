# count.nvim - Design Document

## Overview

A Neovim plugin providing filetype-aware, high-performance text counting that goes beyond the built-in `wordcount()` API.

**Key Features:**

- Excludes code blocks, frontmatter, and markup from counts
- Accurate word and sentence segmentation
- High-performance Zig core with automatic caching
- Simple API with smart defaults

---

## Processing Flow

```
1. Cache Check
   ↓ (changedtick comparison)
2. Text Extraction (Neovim API)
   ↓ (get buffer/cursor/visual range)
3. Exclusion Range Detection (Treesitter)
   ↓ (find code blocks, frontmatter, etc.)
4. Text Filtering (Lua)
   ↓ (remove excluded ranges)
5. Statistical Analysis (Zig - single FFI call)
   ↓ (bytes, chars, words, sentences)
6. Cache & Return
```

---

## APIs Used

### Neovim APIs (Text Extraction)

- `vim.api.nvim_buf_get_lines()` - Get buffer text
- `vim.api.nvim_win_get_cursor()` - Cursor position
- `vim.fn.getpos("'<")`, `vim.fn.getpos("'>")` - Visual selection
- `vim.api.nvim_buf_get_changedtick()` - Cache invalidation

### Treesitter APIs (Structure Detection)

- `vim.treesitter.get_parser()` - Get parser for filetype
- `vim.treesitter.query.parse()` - Query syntax nodes
- `node:range()` - Get line ranges to exclude

**Node types to detect:**

- `fenced_code_block` - Code blocks
- `yaml_metadata_block` - Frontmatter
- `inline` - Inline code
- `link_destination` - URLs

### Not Used

- `wordcount()` - Cannot filter content
- `vim.fn.strchars()` - Zig handles UTF-8

---

## Zig Implementation Strategy

### Core Design Decision

**Lightweight stats (bytes, chars):** Always calculate - flag checking costs more than computation

**Complex stats (CJK words, UAX\#29 sentences):** Split into pattern functions to avoid branching

### MVP: 4 Pattern Functions

Each function performs **single-loop processing** with **no conditional branching** for maximum performance:

```
1. analyze_simple()
   - bytes: buffer size
   - chars: UTF-8 boundary count
   - words: whitespace split
   - sentences: [.!?] detection

2. analyze_with_cjk_words()
   - bytes/chars: same as simple
   - words: dictionary-based morphological analysis
   - sentences: simple

3. analyze_with_uax29_sentences()
   - bytes/chars: same as simple
   - words: simple
   - sentences: UAX#29 rules + abbreviation handling

4. analyze_with_cjk_and_uax29()
   - bytes/chars: same as simple
   - words: CJK analysis
   - sentences: UAX#29
```

**Why this approach:**

- Single text scan per function (cache-efficient)
- No branching inside loops (CPU pipeline-friendly)
- Each pattern optimized independently
- FFI overhead: only 1 call per count operation

### Future: Code Generation

When complex features exceed 3-4 items (8-16 function combinations):

**Create:** `scripts/generate_analyzers.py`

- Define feature list and templates
- Generate all pattern combinations automatically
- Commit generated files to git (avoid Python build dependency)

**Benefits:**

- DRY principle maintained
- Easy to add new features
- Generated code remains optimized

---

## API Design

```lua
count(opts)
```

**Parameters:**

- `bufnr`: Buffer number (default: current)
- `range`: "buffer" | "cursor" | "visual" (default: "buffer")
- `cache`: boolean (default: true)
- `mode`: "simple" | "accurate" (default: "simple")

**Returns:** `{ bytes, chars, words, sentences }`

**Convenience functions:**

- `count_words(opts)` → number
- `count_chars(opts)` → number
- `count_sentences(opts)` → number

---

## Caching Strategy

### changedtick-based Cache (Default: ON)

**Why include caching in plugin:**

- Users shouldn't write boilerplate cache logic
- 99% of use cases need this optimization
- Follows nvim-treesitter and other successful plugins

**How it works:**

- Store `{ tick, stats }` per buffer
- Same tick → return cache (no recalculation)
- Changed tick → recalculate and update cache

**External file changes:**
User should configure (recommend in docs):

```vim
set autoread
autocmd FocusGained,BufEnter * checktime
```

**Opt-out:** `count({ cache = false })` for debugging/testing

---

## Mode Design

### simple (MVP, Default)

- Fast, accurate for most cases
- words: whitespace split (accurate for English, approximate for CJK)
- sentences: basic punctuation detection

### accurate (Phase 2)

- Slower but precise
- words: CJK morphological analysis
- sentences: UAX\#29 full implementation

**Backward compatibility:**

- Default stays `simple` (fast)
- Users explicitly opt-in to `accurate`
- Future v2.0 can change default with migration guide

---

## Performance Optimizations

### 1. Single FFI Call

Get all stats (bytes, chars, words, sentences) in one call instead of multiple

### 2. Single-Loop Processing

Each Zig function scans text once, calculates all stats simultaneously

### 3. Always Calculate Lightweight Stats

bytes/chars calculation cost < branch prediction cost → always compute

### 4. changedtick Cache

Most effective optimization - zero recalculation when unchanged

---

## Implementation Priority

### MVP (Immediate)

1. Lua layer with basic `count()` API
2. changedtick caching
3. Treesitter integration for Markdown
4. Zig `analyze_simple()` function
5. FFI bindings

### Phase 2 (Enhancement)

1. Remaining 3 Zig functions
2. `mode` parameter implementation
3. Additional filetype support
4. Documentation

### Phase 3 (Advanced)

1. Code generation script
2. Additional complex features (readability, language detection)
3. Performance tuning

---

## Why Zig

**Performance:** 2-3x faster than LuaJIT for complex text processing

**Optimization:** Single FFI call, no allocations, cache-friendly

**Maintainability:** Type-safe, compile-time error detection

**Learning value:** Low-level optimization skills, preparation for Neovim contributions

---

## Key Principles

1. **Simple to use:** `count()` works out of the box
2. **Fast by default:** Caching and optimization built-in
3. **Flexible:** Options for special use cases
4. **Future-proof:** Design accommodates extensions
5. **Maintainable:** Clean architecture from MVP stage
