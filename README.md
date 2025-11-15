# count.nvim

This repository has just been created, and currently "work-in-progress" for the MVP release. No functional code exists yet.

Provide extended sentence, word, and char counting functionalities beyond the Neovim's built-in APIs.

---

Neovim provides great built-in APIs for counting lines, byte, words and so forth, however, they are quite basic and extending the functionalities is technically possible but not straightforward. This plugin aims to extends that by providing APIs for various counting functionalities, and mainly being aware of the following.

- File type: such as ignoring code blocks and hyphens for bulleted lists in markdown files.
- File format: such as ignoring front-matter in markdown files.
- Natural language: such as proper sentence segmentation for various languages.

Resources:
https://neovim.io/doc/user/vimfn.html#wordcount()
