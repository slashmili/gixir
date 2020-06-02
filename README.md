# Gixir


## State of this repo

I've tried multiple approaches, non of them sound good.

1. Using [C NIFs](https://github.com/slashmili/gixir/tree/c-impl). You don't want to crash beam because a memory issue or something like that
2. Using [Rust NIFs](https://github.com/slashmili/gixir/tree/rustler). This sounded promising when I started but after few implements got stuck in handling lifetime of libgit objects and nif reference
3. At last I tried implementing in [pure Elixir](https://github.com/slashmili/gixir/tree/pure-elixir) but that also looks like a waste of time. Looking into git internal objects from Elixir looks interesting but it’s hard to keep up with the changes
