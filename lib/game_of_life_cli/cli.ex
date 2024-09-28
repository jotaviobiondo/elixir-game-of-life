defmodule GameOfLifeCLI.CLI do
  @moduledoc """
  Module that provides the Command Line Interface to run the game of life on terminal.
  """
  alias GameOfLife.Life

  @default_options %{
    generations: 5,
    grid_size: 10
  }

  @spec main([String.t()]) :: no_return
  def main(args) do
    args |> parse_args() |> start_game_of_life()
  end

  @spec parse_args([String.t()]) :: %{generations: pos_integer, grid_size: pos_integer}
  def parse_args(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [generations: :integer, grid_size: :integer],
        aliases: [g: :generations, s: :grid_size]
      )

    Enum.into(options, @default_options)
  end

  defp start_game_of_life(%{generations: generations, grid_size: grid_size}) do
    # IO.puts(IO.ANSI.blue_background())

    Life.get_random_stream(grid_size)
    |> Stream.take(generations)
    |> Stream.map(&to_string/1)
    |> Enum.each(fn grid_str ->
      IO.write(grid_str)
      Process.sleep(100)

      for _i <- 1..grid_size + 2, do: IO.write(IO.ANSI.cursor_up(1) <> IO.ANSI.clear_line())
      # IO.write(IO.ANSI.cursor_down(grid_size))
    end)

    IO.puts(IO.ANSI.reset())
  end
end
