# Conway's Game of Life
[![Elixir CI](https://github.com/jotaviobiondo/elixir-game-of-life/workflows/Elixir%20CI/badge.svg)](https://github.com/jotaviobiondo/elixir-game-of-life/actions)

A [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) implementation to learn Elixir.

The initial implementation was running as a CLI application.
Later this was improved with an additional LiveView web application.

**Live demo**: https://elixir-game-of-life.onrender.com/

## Usage

### Requirements
- [Elixir 1.18](https://elixir-lang.org/install.html)

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



https://github.com/user-attachments/assets/45b30f58-8a74-4c56-8639-5cff5291ce7d



To run the CLI, execute the following script:
```
mix cli.run
```

The CLI accepts the following optional arguments:
- `--generations` or `-g`: The number of generations (iterations). Default: `5`.
- `--rows` or `-r`: The rows size of the grid. Default: `10`.
- `--columns` or `-c`: The columns size of the grid. Default: `10`.

### Running the LiveView application

<img width="1000" height="1107" alt="image" src="https://github.com/user-attachments/assets/a80a20c0-05de-46fc-84a7-fa9dfcbcc856" />


To run the LiveView application, execute the following script:
```
iex -S mix phx.server
```
