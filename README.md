> [!WARNING]
> This project is working in progress and not functional yet. When MVP is merged to the main branch, a release will be published. You can see the progress in the dev branch. Star the repo to stay tuned!

<div align="center">
  <h1>count.nvim</h1>
  <p>A Neovim plugin to extend the text counting capabilities</p>
</div>

## About

Neovim already provides great built-in APIs for counting lines, byte, and words. However, they are quite basic and extending the functionalities is not always straightforward. Count.nvim aims to extend that by providing APIs for various counting functionalities, and mainly being aware of the following.

- File type: such as ignoring code blocks and hyphens for bulleted lists in markdown files.
- File format: such as ignoring front-matter in markdown files.
- Natural language: such as proper sentence segmentation for various languages.
