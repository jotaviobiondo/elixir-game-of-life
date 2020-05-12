defmodule GameOfLife.Life do
  @moduledoc """
  Module that provides functions to start the game of life and generate the next generations.
  """

  alias GameOfLife.Grid

  @doc """
  Returns a infinite enumerable where each element is the next generation of the previous one.
  The first generation starts with the provided 'cell_matrix' argument.
  """
  @spec get_stream(Grid.cell_matrix()) :: Enumerable.t()
  def get_stream(cell_matrix) do
    Grid.new(cell_matrix) |> Stream.iterate(&next_generation/1)
  end

  @doc """
  Returns a infinite enumerable where each element is the next generation of the previous one.
  The first generation is a random grid with the size provided by the argument 'grid_size'.
  """
  @spec get_random_stream(pos_integer) :: Enumerable.t()
  def get_random_stream(grid_size \\ 10) do
    Grid.new_random(grid_size) |> Stream.iterate(&next_generation/1)
  end

  @spec next_generation(Grid.t()) :: Grid.t()
  def next_generation(grid) do
    new_cells = Map.new(grid.cells, fn cell -> next_cell_generation(grid, cell) end)

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
