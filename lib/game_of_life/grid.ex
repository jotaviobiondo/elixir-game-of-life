defmodule GameOfLife.Grid do
  @moduledoc """
  Module that provides functions to create and retrieve information from the grid of the game of life.
  """

  alias GameOfLife.Cell
  alias GameOfLife.Grid

  @type position :: {integer, integer}
  @type cells :: %{required(position) => Cell.t()}
  @type cell_matrix :: [[integer]]
  @type size :: pos_integer

  @type t :: %__MODULE__{
          cells: cells,
          rows: pos_integer(),
          cols: pos_integer()
        }

  @enforce_keys [:cells, :rows, :cols]
  defstruct [:cells, :rows, :cols]

  @spec new(cell_matrix) :: t
  def new(cell_matrix) do
    with {:ok, cell_matrix} <- validate_not_empty(cell_matrix),
         {:ok, cell_matrix} <- validate_matrix_dimension(cell_matrix) do
      rows = Enum.count(cell_matrix)
      cols = cell_matrix |> List.first() |> Enum.count()

      cells = matrix_to_cells(cell_matrix, rows, cols)

      %Grid{cells: cells, rows: rows, cols: cols}
    else
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  @spec validate_not_empty(cell_matrix) :: {:ok, cell_matrix} | {:error, String.t()}
  defp validate_not_empty([]), do: {:error, "matrix can not be empty"}
  defp validate_not_empty([[]]), do: {:error, "matrix can not be empty"}
  defp validate_not_empty(matrix), do: {:ok, matrix}

  @spec validate_matrix_dimension(cell_matrix) :: {:ok, cell_matrix} | {:error, String.t()}
  defp validate_matrix_dimension(matrix) do
    first_row_count = matrix |> List.first() |> Enum.count()
    all_rows_has_same_size? = Enum.all?(matrix, fn row -> Enum.count(row) == first_row_count end)

    if all_rows_has_same_size?,
      do: {:ok, matrix},
      else: {:error, "matrix doesn't have rows with equal number of elements"}
  end

  @spec matrix_to_cells(cell_matrix(), rows :: pos_integer(), cols :: pos_integer()) :: cells()
  defp matrix_to_cells(cell_matrix, rows, cols) do
    for x <- 0..(rows - 1),
        y <- 0..(cols - 1),
        into: %{} do
      cell = cell_matrix |> Enum.at(x) |> Enum.at(y) |> Cell.from_int()

      {{x, y}, cell}
    end
  end

  @spec new_random(rows :: pos_integer(), cols :: pos_integer()) :: t
  def new_random(rows, cols) do
    (&Cell.random/0)
    |> Stream.repeatedly()
    |> Stream.take(rows * cols)
    |> Stream.map(&Cell.to_int/1)
    |> Enum.chunk_every(cols)
    |> new()
  end

  @spec neighbors(t, position) :: MapSet.t(position)
  def neighbors(grid, {cell_x, cell_y}) do
    for offset_x <- [-1, 0, 1],
        offset_y <- [-1, 0, 1],
        neighbor = {offset_x + cell_x, offset_y + cell_y},
        inside_grid?(grid, neighbor) and {offset_x, offset_y} != {0, 0},
        into: MapSet.new() do
      neighbor
    end
  end

  @spec inside_grid?(t, position) :: boolean
  defp inside_grid?(grid, {x, y}), do: x in 0..(grid.rows - 1) and y in 0..(grid.cols - 1)

  @spec live_neighbors(t, position) :: non_neg_integer
  def live_neighbors(grid, cell_position) do
    grid
    |> neighbors(cell_position)
    |> Enum.map(fn neighbor -> get_cell(grid, neighbor) end)
    |> Enum.count(&(&1 == :alive))
  end

  @spec get_cell(t, position) :: Cell.t()
  def get_cell(grid, cell_position), do: Map.get(grid.cells, cell_position, :dead)

  defimpl String.Chars, for: Grid do
    @spec to_string(Grid.t()) :: String.t()
    def to_string(grid) do
      grid_str =
        grid.cells
        |> Map.keys()
        |> Enum.sort()
        |> Enum.map_join("|", fn position ->
          cell_str = Grid.get_cell(grid, position) |> Cell.to_string()

          last_row_index = grid.rows - 1
          last_col_index = grid.cols - 1

          case position do
            {0, 0} -> "| #{cell_str} "
            {^last_row_index, ^last_col_index} -> " #{cell_str} |"
            {_, ^last_col_index} -> " #{cell_str} |\n"
            {_, _} -> " #{cell_str} "
          end
        end)

      grid_str_size = grid_str |> String.codepoints() |> Enum.find_index(&(&1 == "\n"))
      border = String.duplicate("-", grid_str_size - 2)

      """
      +#{border}+
      #{grid_str}
      +#{border}+
      """
    end
  end
end
