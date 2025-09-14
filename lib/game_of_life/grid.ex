defmodule GameOfLife.Grid do
  @moduledoc """
  Module that provides functions to create and retrieve information from the grid of the game of life.
  """

  alias GameOfLife.Cell

  @type position :: {row :: integer, columns :: integer}
  @type cells :: %{required(position) => Cell.t()}
  @type cell_matrix :: [[integer]]
  @type size :: pos_integer

  @type t :: %__MODULE__{
          cells: cells,
          rows: pos_integer(),
          cols: pos_integer(),
          generation: pos_integer()
        }

  @enforce_keys [:cells, :rows, :cols, :generation]
  defstruct [:cells, :rows, :cols, :generation]

  @spec new!(cell_matrix()) :: t()
  def new!(cell_matrix) do
    with {:ok, cell_matrix} <- validate_not_empty(cell_matrix),
         {:ok, cell_matrix} <- validate_matrix_dimension(cell_matrix) do
      rows = Enum.count(cell_matrix)
      cols = cell_matrix |> List.first() |> Enum.count()

      cells = matrix_to_cells(cell_matrix, rows, cols)

      %__MODULE__{cells: cells, rows: rows, cols: cols, generation: 1}
    else
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @spec empty!(rows :: pos_integer(), cols :: pos_integer()) :: t()
  def empty!(rows, cols) do
    cells =
      for row <- 0..(rows - 1), col <- 0..(cols - 1), into: %{} do
        {{row, col}, :dead}
      end

    %__MODULE__{cells: cells, rows: rows, cols: cols, generation: 1}
  end

  defp validate_not_empty([]), do: {:error, "matrix can not be empty"}
  defp validate_not_empty([[]]), do: {:error, "matrix can not be empty"}
  defp validate_not_empty(matrix), do: {:ok, matrix}

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

  @spec random(rows :: pos_integer(), cols :: pos_integer()) :: t
  def random(rows, cols) do
    (&Cell.random/0)
    |> Stream.repeatedly()
    |> Stream.take(rows * cols)
    |> Stream.map(&Cell.to_int/1)
    |> Enum.chunk_every(cols)
    |> new!()
  end

  @spec clear(t()) :: t
  def clear(%__MODULE__{} = grid) do
    new_cells = Map.new(grid.cells, fn {position, _value} -> {position, :dead} end)

    %{grid | cells: new_cells, generation: 1}
  end

  @spec neighbors(t(), position()) :: MapSet.t(position)
  def neighbors(%__MODULE__{} = grid, {cell_x, cell_y}) do
    for offset_x <- [-1, 0, 1],
        offset_y <- [-1, 0, 1],
        neighbor = {offset_x + cell_x, offset_y + cell_y},
        inside_grid?(grid, neighbor) and {offset_x, offset_y} != {0, 0},
        into: MapSet.new() do
      neighbor
    end
  end

  @spec inside_grid?(t(), position()) :: boolean()
  defp inside_grid?(%__MODULE__{} = grid, {x, y}),
    do: x in 0..(grid.rows - 1) and y in 0..(grid.cols - 1)

  @spec count_neighbors_alive(t(), position()) :: non_neg_integer
  def count_neighbors_alive(%__MODULE__{} = grid, cell_position) do
    grid
    |> neighbors(cell_position)
    |> Enum.map(fn neighbor -> get_cell(grid, neighbor) end)
    |> Enum.count(&(&1 == :alive))
  end

  @spec get_cell(t(), position()) :: Cell.t()
  def get_cell(%__MODULE__{} = grid, cell_position), do: Map.get(grid.cells, cell_position, :dead)

  @spec toggle_cell(t(), position()) :: t()
  def toggle_cell(%__MODULE__{} = grid, cell_position) do
    if not inside_grid?(grid, cell_position) do
      raise ArgumentError, "position given is outside the grid. Got '#{inspect(cell_position)}'"
    end

    new_cell =
      case get_cell(grid, cell_position) do
        :alive -> :dead
        :dead -> :alive
      end

    updated_cells = Map.put(grid.cells, cell_position, new_cell)
    %{grid | cells: updated_cells}
  end

  @doc """
  Counts the number of live cells in the grid.

  ## Examples

      iex> grid = GameOfLife.Grid.empty!(3, 3)
      iex> GameOfLife.Grid.count_live_cells(grid)
      0

  """
  @spec count_live_cells(t()) :: non_neg_integer()
  def count_live_cells(%__MODULE__{} = grid) do
    grid.cells
    |> Map.values()
    |> Enum.count(&(&1 == :alive))
  end

  defimpl String.Chars do
    @spec to_string(GameOfLife.Grid.t()) :: String.t()
    def to_string(%GameOfLife.Grid{} = grid) do
      grid_str =
        grid.cells
        |> Map.keys()
        |> Enum.sort()
        |> Enum.map_join("|", fn position ->
          cell_str = grid |> GameOfLife.Grid.get_cell(position) |> Cell.to_string()

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
