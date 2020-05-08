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

  @spec new(cell_matrix) :: t
  def new(cell_matrix) do
    with {:ok, cell_matrix} <- validate_not_empty(cell_matrix),
         {:ok, cell_matrix} <- validate_matrix_is_square(cell_matrix) do
      size = Enum.count(cell_matrix)
      cells = matrix_to_cells(cell_matrix, size)

      %Grid{cells: cells, size: size}
    else
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  @spec validate_not_empty(cell_matrix) :: {:ok, cell_matrix} | {:error, String.t()}
  defp validate_not_empty([]), do: {:error, "matrix can not be empty"}
  defp validate_not_empty([[]]), do: {:error, "matrix can not be empty"}
  defp validate_not_empty(matrix), do: {:ok, matrix}

  @spec validate_matrix_is_square(cell_matrix) :: {:ok, cell_matrix} | {:error, String.t()}
  defp validate_matrix_is_square(matrix) do
    columns_count = Enum.count(matrix)

    all_rows_has_same_size = Enum.all?(matrix, fn row -> Enum.count(row) == columns_count end)

    if all_rows_has_same_size, do: {:ok, matrix}, else: {:error, "matrix is not square"}
  end

  @spec matrix_to_cells(cell_matrix, size) :: cells
  defp matrix_to_cells(cell_matrix, size) do
    for x <- 0..(size - 1),
        y <- 0..(size - 1),
        into: %{} do
      {{x, y}, cell_matrix |> Enum.at(x) |> Enum.at(y)}
    end
  end

  @spec new_empty(size) :: t
  def new_empty(size) do
    :dead
    |> List.duplicate(size)
    |> List.duplicate(size)
    |> new()
  end

  @spec new_random(size) :: t
  def new_random(size) do
    (&Cell.random/0)
    |> Stream.repeatedly()
    |> Stream.take(size * size)
    |> Enum.chunk_every(size)
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
  def inside_grid?(grid, {x, y}), do: x in 0..(grid.size - 1) and y in 0..(grid.size - 1)

  @spec alive_neighbors(t, position) :: non_neg_integer
  def alive_neighbors(grid, cell_position) do
    grid
    |> neighbors(cell_position)
    |> Enum.map(fn neighbor -> get_cell(grid, neighbor) end)
    |> Enum.count(&(&1 == :alive))
  end

  @spec get_cell(t, position) :: Cell.t()
  def get_cell(grid, cell_position), do: Map.get(grid.cells, cell_position, :dead)

  @spec to_string(t) :: String.t()
  def to_string(grid) do
    grid_str =
      grid.cells
      |> Map.keys()
      |> Enum.sort()
      |> Enum.map_join("|", fn position ->
        cell_str = get_cell(grid, position) |> Cell.to_string()

        last_index = grid.size - 1

        case position do
          {0, 0} -> "|#{cell_str}"
          {^last_index, ^last_index} -> "#{cell_str}|"
          {_, ^last_index} -> "#{cell_str}|\n"
          {_, _} -> cell_str
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
