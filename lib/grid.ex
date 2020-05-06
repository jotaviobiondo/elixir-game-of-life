defmodule GameOfLife.Grid do
  @moduledoc false

  alias GameOfLife.Grid
  alias GameOfLife.Cell

  @type position :: {integer, integer}
  @type cells :: %{required(position) => Cell.t()}
  @type cell_matrix :: [[Cell.t()]]
  @type size :: pos_integer

  @type t :: %__MODULE__{
          cells: cells,
          size: size
        }

  @enforce_keys [:cells]
  defstruct [:cells, size: 10]

  @spec new(cell_matrix) :: %Grid{}
  def new(cell_matrix) do
    validate_matrix_is_square!(cell_matrix)

    size = Enum.count(cell_matrix)
    cells = matrix_to_cells(cell_matrix, size)

    %Grid{cells: cells, size: size}
  end

  @spec validate_matrix_is_square!(cell_matrix) :: no_return
  defp validate_matrix_is_square!(matrix) do
    columns_count = Enum.count(matrix)

    all_rows_has_same_size =
      Enum.all?(matrix, fn row ->
        Enum.count(row) == columns_count
      end)

    unless all_rows_has_same_size, do: raise(ArgumentError, "matrix is not square")
  end

  @spec matrix_to_cells(cell_matrix, size) :: cells
  defp matrix_to_cells(cell_matrix, size) do
    for x <- 0..(size - 1),
        y <- 0..(size - 1),
        into: %{} do
      {{x, y}, cell_matrix |> Enum.at(x) |> Enum.at(y)}
    end
  end

  @spec new_empty(size) :: %Grid{}
  def new_empty(size) do
    cells =
      for x <- 0..(size - 1),
          y <- 0..(size - 1),
          into: %{} do
        {{x, y}, :dead}
      end

    %Grid{cells: cells, size: size}
  end

  @spec new_random(size) :: %Grid{}
  def new_random(size) do
    cells =
      for x <- 0..(size - 1),
          y <- 0..(size - 1),
          into: %{} do
        {{x, y}, Cell.random()}
      end

    %Grid{cells: cells, size: size}
  end

  @spec neighbours(position) :: [position]
  def neighbours({cell_x, cell_y}) do
    for offset_x <- [-1, 0, 1],
        offset_y <- [-1, 0, 1],
        {offset_x, offset_y} != {0, 0} do
      {offset_x + cell_x, offset_y + cell_y}
    end
  end

  @spec alive_neighbours(%Grid{}, position) :: non_neg_integer
  def alive_neighbours(grid, cell) do
    cell
    |> neighbours()
    |> Enum.map(fn neighbour -> Map.get(grid.cells, neighbour, false) end)
    |> Enum.count(&(&1 == :alive))
  end
end
