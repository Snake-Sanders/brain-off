# Tools

This is a simple command line tool written in Elixir. It converts markdown files into HTML pages. It is nothing special, just uses [Earmark](https://github.com/pragdave/earmark) module.
It is more convinient to have all the personal notes in a single browser's tab than having to open the markdown files individually and using the VSCode preview each time, additionally it is annoying to mix code and markdown notes in the same working space.

## Configuration and execution

- Place your markdown file in the folder `./user/makrdown`
- If there are images place them in the folder `./user/makrdown/img`
- run the mix command: `mix gen.html`
- the html page will be generated in `./web` folder
