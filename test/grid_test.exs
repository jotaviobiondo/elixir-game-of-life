defmodule GameOfLife.GridTest do
  use ExUnit.Case
  alias GameOfLife.Grid

  describe "new/1" do
    test "valid cell matrix" do
      cell_matrix = [
        [1, 1],
        [0, 0]
      ]

      grid = Grid.new(cell_matrix)

      assert grid.size == Enum.count(cell_matrix)

      assert grid.cells == %{
               {0, 0} => :alive,
               {0, 1} => :alive,
               {1, 0} => :dead,
               {1, 1} => :dead
             }
    end

    test "empty cell matrix" do
      assert_raise(ArgumentError, fn -> Grid.new([]) end)
      assert_raise(ArgumentError, fn -> Grid.new([[]]) end)
    end

    test "wrong size for cell matrix (not a square matrix)" do
      cell_matrix = [
        [0, 0],
        [0, 0],
        [0, 0]
      ]

      assert_raise(ArgumentError, fn -> Grid.new(cell_matrix) end)
    end
  end

  test "new_empty/1" do
    size = 20
    grid = Grid.new_empty(size)

    assert grid.size == size
    assert Enum.count(grid.cells) == size * size

    assert grid.cells
           |> Map.values()
           |> Enum.all?(&(&1 == :dead))
  end

  test "new_random/1" do
    size = 20
    grid = Grid.new_random(size)

    assert grid.size == size
    assert Enum.count(grid.cells) == size * size

    assert grid.cells
           |> Map.values()
           |> Enum.all?(&(&1 in [:alive, :dead]))
  end

  test "neighbors/2" do
    grid = Grid.new_empty(3)

    #   [(0, 0) (0, 1) (0, 2)]
    #   [(1, 0) (1, 1) (1, 2)]
    #   [(2, 0) (2, 1) (2, 2)]

    assert Grid.neighbors(grid, {0, 0}) == MapSet.new([{0, 1}, {1, 0}, {1, 1}])
    assert Grid.neighbors(grid, {0, 1}) == MapSet.new([{0, 0}, {0, 2}, {1, 0}, {1, 1}, {1, 2}])
    assert Grid.neighbors(grid, {0, 2}) == MapSet.new([{0, 1}, {1, 1}, {1, 2}])
    assert Grid.neighbors(grid, {1, 0}) == MapSet.new([{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}])

    assert Grid.neighbors(grid, {1, 1}) ==
             MapSet.new([{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 2}, {2, 0}, {2, 1}, {2, 2}])

    assert Grid.neighbors(grid, {1, 2}) == MapSet.new([{0, 1}, {0, 2}, {1, 1}, {2, 1}, {2, 2}])
    assert Grid.neighbors(grid, {2, 0}) == MapSet.new([{1, 0}, {1, 1}, {2, 1}])
    assert Grid.neighbors(grid, {2, 1}) == MapSet.new([{1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 2}])
    assert Grid.neighbors(grid, {2, 2}) == MapSet.new([{1, 1}, {1, 2}, {2, 1}])
  end

  test "live_neighbors/2" do
    cell_matrix = [
      [0, 0, 0, 1],
      [0, 0, 1, 0],
      [1, 1, 1, 1],
      [0, 0, 1, 1]
    ]

    grid = Grid.new(cell_matrix)

    assert Grid.live_neighbors(grid, {0, 0}) == 0
    assert Grid.live_neighbors(grid, {0, 1}) == 1
    assert Grid.live_neighbors(grid, {0, 2}) == 2
    assert Grid.live_neighbors(grid, {0, 3}) == 1
    assert Grid.live_neighbors(grid, {1, 0}) == 2
    assert Grid.live_neighbors(grid, {1, 1}) == 4
    assert Grid.live_neighbors(grid, {1, 2}) == 4
    assert Grid.live_neighbors(grid, {1, 3}) == 4
    assert Grid.live_neighbors(grid, {2, 0}) == 1
    assert Grid.live_neighbors(grid, {2, 1}) == 4
    assert Grid.live_neighbors(grid, {2, 2}) == 5
    assert Grid.live_neighbors(grid, {2, 3}) == 4
    assert Grid.live_neighbors(grid, {3, 0}) == 2
    assert Grid.live_neighbors(grid, {3, 1}) == 4
    assert Grid.live_neighbors(grid, {3, 2}) == 4
    assert Grid.live_neighbors(grid, {3, 3}) == 3
  end

  describe "get_cell/2" do
    setup do
      cell_matrix = [
        [0, 1],
        [0, 1]
      ]

      {:ok, grid: Grid.new(cell_matrix)}
    end

    test "valid positions", %{grid: grid} do
      assert Grid.get_cell(grid, {0, 0}) == :dead
      assert Grid.get_cell(grid, {0, 1}) == :alive
      assert Grid.get_cell(grid, {1, 0}) == :dead
      assert Grid.get_cell(grid, {1, 1}) == :alive
    end

    test "invalid positions must return :dead as default value", %{grid: grid} do
      assert Grid.get_cell(grid, {-1, 0}) == :dead
      assert Grid.get_cell(grid, {0, -1}) == :dead
      assert Grid.get_cell(grid, {-1, -1}) == :dead
    end
  end

  test "to_string/1" do
    cell_matrix = [
      [0, 0, 0, 1],
      [0, 0, 1, 0],
      [1, 1, 1, 1],
      [0, 0, 1, 1]
    ]

    grid = Grid.new(cell_matrix)

    assert to_string(grid) ==
             """
             +---------------+
             |   |   |   | x |
             |   |   | x |   |
             | x | x | x | x |
             |   |   | x | x |
             +---------------+
             """
  end
end
