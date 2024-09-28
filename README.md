# Conway's Game of Life
[![Elixir CI](https://github.com/jotaviobiondo/elixir-game-of-life/workflows/Elixir%20CI/badge.svg)](https://github.com/jotaviobiondo/elixir-game-of-life/actions)

A [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) implementation to learn Elixir.


## Usage

### Requirements
- [Elixir 1.17](https://elixir-lang.org/install.html)

Install the dependencies:
```
mix deps.get
```

### Running Tests

Execute the following command to run the tests:

```
mix test
```

### Running the CLI

To run the CLI, execute the following script:
```
./run-cli.sh
```

The CLI accepts the following optional arguments:
- `--generations` or `-g`: The number of generations (iterations). Default: 5.
- `--grid-size` or `-s`: The size of the grid. Default: 10.

## TODO
- [ ] Web interface with phoenix LiveView.
