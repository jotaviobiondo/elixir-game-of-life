defmodule GameOfLife.CLI do
  @generations_default 5
  @grid_size_default 10

  @default_options %{
    :generations => @generations_default,
    :grid_size => @grid_size_default
  }

  def main(args) do
    args |> parse_args() |> start_game_of_life()
  end

  defp parse_args(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [generations: :integer, grid_size: :integer],
        aliases: [g: :generations, s: :grid_size]
      )

    Enum.into(options, @default_options)
  end

  def start_game_of_life(%{generations: generations, grid_size: grid_size}) do
    GameOfLife.start(generations, grid_size)
  end

  def start_game_of_life(_) do
    IO.puts("Invalid input")
  end
end
