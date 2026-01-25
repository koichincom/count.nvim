# count.nvim - Design Document

## Overview

A Neovim plugin providing filetype-aware, high-performance text counting that goes beyond the built-in `wordcount()` API.

## Processing Flow

```
1. Cache Check
   ↓ (changedtick comparison)
2. Text Extraction (Neovim API)
   ↓ (get buffer/cursor/visual range)
3. Exclusion Range Detection (Treesitter)
   ↓ (find code blocks, frontmatter, etc.)
4. Text Filtering (Zig)
   ↓ (remove excluded ranges)
5. Statistical Analysis (Zig)
   ↓ (bytes, chars, words, sentences)
6. Cache & Return
```

## APIs Used

- `vim.api.nvim_buf_get_lines()` - Get buffer text
- `vim.api.nvim_win_get_cursor()` - Cursor position
- `vim.fn.getpos("'<")`, `vim.fn.getpos("'>")` - Visual selection
- `vim.api.nvim_buf_get_changedtick()` - Cache invalidation

To use the Zig library for text processing, write the build.zig and build.zig.zon to use the build.zig in the library and compile in this repo when it's run.
