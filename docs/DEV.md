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

Possible idea: auto debounce mode based on the file size

prose-gauge is a Zig library for counting human-readable text in Markdown and other files, built on syntax-aware parsers to exclude non-readable text such as code blocks, frontmatter, and metadata. Use md4c as the dependency (Markdown parser) and prioritize the Markdown support first, then qmd, rmd, mdx, and other format support later. API interface is simple; taking the file extension, file content, and output type as input, and returning the counters of the human-readable text. Counters include word, character, sentence, paragraph, byte, and line, and can be extended later. CJK support using unicode segmentation algorithms is planned but not prioritized.
