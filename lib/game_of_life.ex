defmodule GameOfLife do
  alias GameOfLife.Grid

  @spec start(pos_integer, pos_integer) :: no_return
  def start(generations \\ 5, grid_size \\ 10) do
    Grid.new_random(grid_size)
    |> Stream.iterate(&next_generation/1)
    |> Stream.take(generations)
    |> Stream.map(&Grid.to_string/1)
    |> Enum.each(fn grid_str ->
      IO.puts(grid_str)
      Process.sleep(500)
    end)
  end

  @spec next_generation(Grid.t()) :: Grid.t()
  defp next_generation(grid) do
    new_cells =
      for {position, cell} <- grid.cells, into: %{} do
        case {cell, Grid.alive_neighbors(grid, position)} do
          {:alive, 2} -> {position, :alive}
          {:alive, 3} -> {position, :alive}
          {:dead, 3} -> {position, :alive}
          _ -> {position, :dead}
        end
      end

    %Grid{cells: new_cells, size: grid.size}
  end
end
