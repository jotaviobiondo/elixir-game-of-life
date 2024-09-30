defmodule GameOfLifeCLI.CLI do
  @moduledoc """
  Module that provides the Command Line Interface to run the game of life on terminal.
  """
  alias GameOfLife.Life

  @default_options %{
    generations: 5,
    rows: 10,
    columns: 10
  }

  @spec main([String.t()]) :: no_return
  def main(args) do
    args
    |> parse_args()
    |> start_game_of_life()
  end

  @spec parse_args([String.t()]) :: %{generations: pos_integer, grid_size: pos_integer}
  def parse_args(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [generations: :integer, rows: :integer, columns: :integer],
        aliases: [g: :generations, r: :rows, c: :columns]
      )

    Enum.into(options, @default_options)
  end

  defp start_game_of_life(%{generations: max_generations, rows: rows, columns: columns}) do
    information_lines = 1
    borders_top_and_bottom = 2
    number_of_lines_printed = rows + borders_top_and_bottom + information_lines

    rows
    |> Life.get_random_stream(columns)
    |> Stream.take(max_generations)
    |> Stream.map(&to_string/1)
    |> Stream.with_index(1)
    |> Enum.each(fn {grid_str, current_generation} ->
      grid_str |> with_color(:blue) |> IO.write()
      "Generation: #{current_generation}/#{max_generations}" |> with_color(:yellow) |> IO.puts()

      Process.sleep(100)

      last_generation? = current_generation == max_generations

      if not last_generation? do
        for _i <- 1..number_of_lines_printed, do: clear_line()
      end
    end)
  end

  defp with_color(text, :blue), do: IO.ANSI.blue() <> text <> IO.ANSI.reset()
  defp with_color(text, :yellow), do: IO.ANSI.yellow() <> text <> IO.ANSI.reset()

  defp clear_line, do: IO.write(IO.ANSI.cursor_up(1) <> IO.ANSI.clear_line())
end
