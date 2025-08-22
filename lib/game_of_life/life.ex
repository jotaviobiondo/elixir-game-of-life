defmodule GameOfLife.Life do
  @moduledoc """
  Module that provides functions to start the game of life and generate the next generations.
  """

  alias GameOfLife.Cell
  alias GameOfLife.Grid

  @doc """
  Returns an infinite stream where each element is the next generation of the previous one.
  The first generation starts with the provided 'grid' argument.
  """
  @spec stream_generations(Grid.t()) :: Enumerable.t()
  def stream_generations(%Grid{} = grid) do
    Stream.iterate(grid, &next_generation/1)
  end

  @spec next_generation(Grid.t()) :: Grid.t()
  def next_generation(%Grid{} = grid) do
    new_cells = Map.new(grid.cells, fn cell -> next_cell_generation(grid, cell) end)

    %{grid | cells: new_cells, generation: grid.generation + 1}
  end

  @spec next_cell_generation(Grid.t(), {Grid.position(), Cell.t()}) :: {Grid.position(), Cell.t()}
  defp next_cell_generation(grid, {cell_position, cell_state}) do
    case {cell_state, Grid.count_neighbors_alive(grid, cell_position)} do
      {:alive, 2} -> {cell_position, :alive}
      {:alive, 3} -> {cell_position, :alive}
      {:dead, 3} -> {cell_position, :alive}
      _ -> {cell_position, :dead}
    end
  end
end
