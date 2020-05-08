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
  def next_generation(grid) do
    new_cells =
      for cell <- grid.cells, into: %{} do
        next_cell_generation(grid, cell)
      end

    %Grid{cells: new_cells, size: grid.size}
  end

  @spec next_cell_generation(Grid.t(), {Grid.position(), Cell.t()}) :: {Grid.position(), Cell.t()}
  defp next_cell_generation(grid, {cell_position, cell_state}) do
    case {cell_state, Grid.live_neighbors(grid, cell_position)} do
      {:alive, 2} -> {cell_position, :alive}
      {:alive, 3} -> {cell_position, :alive}
      {:dead, 3} -> {cell_position, :alive}
      _ -> {cell_position, :dead}
    end
  end
end
