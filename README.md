> [!WARNING]
> This project is working in progress. When MVP is merged to the main branch, a release will be published, so star the repo if interested and stay tuned!

# count.nvim

A Neovim plugin to extend the text counting capabilities.

Neovim already provides great built-in APIs for counting lines, byte, and words, however, they are quite basic and extending the functionalities is not always straightforward. Count.nvim aims to extends that by providing APIs for various counting functionalities, and mainly being aware of the following.

- File type: such as ignoring code blocks and hyphens for bulleted lists in markdown files.
- File format: such as ignoring front-matter in markdown files.
- Natural language: such as proper sentence segmentation for various languages.
