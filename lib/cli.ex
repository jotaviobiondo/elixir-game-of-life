defmodule GameOfLife.CLI do
  @moduledoc """
  Module that provides the Command Line Interface to run the game of life on terminal.
  """

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
    GameOfLife.get_random_stream(grid_size)
    |> Stream.take(generations)
    |> Stream.map(&to_string/1)
    |> Enum.each(fn grid_str ->
      IO.puts(grid_str)
      Process.sleep(500)
    end)
  end
end
