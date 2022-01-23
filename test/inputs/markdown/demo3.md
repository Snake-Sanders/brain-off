# table of content
- [table of content](#table-of-content)
  - [adding vscode as diff tool](#adding-vscode-as-diff-tool)
  - [references](#references)

## adding vscode as diff tool

    [diff]
        tool = default-difftool
    [difftool "default-difftool"]
        cmd = code --wait --diff $LOCAL $REMOTE

## references

https://education.github.com/git-cheat-sheet-education.pdf