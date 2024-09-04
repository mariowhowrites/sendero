# Sendero

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# Technical Overview

The goal of this project is to create a collaborative choose-your-own-adventure platform.

Authors create stories, each consisting of a number of chapters. 

Stories have `statuses`:

* `active`, meaning the author is currently adding new chapters
* `complete`, meaning no new chapters will be added and the story is locked in as-is

If a story is active, it has at least one `current_chapter`, meaning the chapter most recently published.

Each current_chapter has one or more `choices`. There represent the links between chapters.

In comp sci terms, we can think of stories as tree structures, with the first chapter as the root node. Each chapter represents one node.
The reading community votes on which links the tree traversal follows.
