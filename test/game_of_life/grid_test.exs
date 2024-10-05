defmodule GameOfLife.GridTest do
  use ExUnit.Case, async: true

  alias GameOfLife.Grid

  describe "new!/1" do
    test "valid cell matrix" do
      assert %Grid{
               rows: 2,
               cols: 2,
               cells: %{
                 {0, 0} => :alive,
                 {0, 1} => :alive,
                 {1, 0} => :dead,
                 {1, 1} => :dead
               }
             } =
               Grid.new!([
                 [1, 1],
                 [0, 0]
               ])

      assert %Grid{
               rows: 2,
               cols: 3,
               cells: %{
                 {0, 0} => :alive,
                 {0, 1} => :alive,
                 {0, 2} => :dead,
                 {1, 0} => :dead,
                 {1, 1} => :dead,
                 {1, 2} => :alive
               }
             } =
               Grid.new!([
                 [1, 1, 0],
                 [0, 0, 1]
               ])

      assert %Grid{
               rows: 3,
               cols: 2,
               cells: %{
                 {0, 0} => :alive,
                 {0, 1} => :alive,
                 {1, 0} => :dead,
                 {1, 1} => :dead,
                 {2, 0} => :alive,
                 {2, 1} => :dead
               }
             } =
               Grid.new!([
                 [1, 1],
                 [0, 0],
                 [1, 0]
               ])
    end

    test "empty cell matrix" do
      assert_raise(ArgumentError, "matrix can not be empty", fn -> Grid.new!([]) end)
      assert_raise(ArgumentError, "matrix can not be empty", fn -> Grid.new!([[]]) end)
    end

    test "should raise when rows don't have the same size" do
      cell_matrix = [
        [0, 0, 0],
        [0, 0]
      ]

      assert_raise(ArgumentError, "matrix doesn't have rows with equal number of elements", fn ->
        Grid.new!(cell_matrix)
      end)
    end
  end

  test "random/1" do
    grid = Grid.random(3, 2)

    assert 3 == grid.rows
    assert 2 == grid.cols
    assert 6 == Enum.count(grid.cells)

    assert grid.cells
           |> Map.values()
           |> Enum.all?(&(&1 in [:alive, :dead]))
  end

  describe "clear/1" do
    test "should set all cells to :dead" do
      matrix = [
        [1, 1],
        [1, 1]
      ]

      grid = matrix |> Grid.new!() |> struct!(generation: 7)

      assert %Grid{
               rows: 2,
               cols: 2,
               generation: 1,
               cells: %{
                 {0, 0} => :dead,
                 {0, 1} => :dead,
                 {1, 0} => :dead,
                 {1, 1} => :dead
               }
             } = Grid.clear(grid)
    end
  end

  test "neighbors/2" do
    grid = Grid.random(3, 3)

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

  test "count_neighbors_alive/2" do
    cell_matrix = [
      [0, 0, 0, 1],
      [0, 0, 1, 0],
      [1, 1, 1, 1],
      [0, 0, 1, 1]
    ]

    grid = Grid.new!(cell_matrix)

    assert Grid.count_neighbors_alive(grid, {0, 0}) == 0
    assert Grid.count_neighbors_alive(grid, {0, 1}) == 1
    assert Grid.count_neighbors_alive(grid, {0, 2}) == 2
    assert Grid.count_neighbors_alive(grid, {0, 3}) == 1
    assert Grid.count_neighbors_alive(grid, {1, 0}) == 2
    assert Grid.count_neighbors_alive(grid, {1, 1}) == 4
    assert Grid.count_neighbors_alive(grid, {1, 2}) == 4
    assert Grid.count_neighbors_alive(grid, {1, 3}) == 4
    assert Grid.count_neighbors_alive(grid, {2, 0}) == 1
    assert Grid.count_neighbors_alive(grid, {2, 1}) == 4
    assert Grid.count_neighbors_alive(grid, {2, 2}) == 5
    assert Grid.count_neighbors_alive(grid, {2, 3}) == 4
    assert Grid.count_neighbors_alive(grid, {3, 0}) == 2
    assert Grid.count_neighbors_alive(grid, {3, 1}) == 4
    assert Grid.count_neighbors_alive(grid, {3, 2}) == 4
    assert Grid.count_neighbors_alive(grid, {3, 3}) == 3
  end

  describe "get_cell/2" do
    setup do
      cell_matrix = [
        [0, 1],
        [0, 1]
      ]

      [grid: Grid.new!(cell_matrix)]
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

  describe "toggle_cell/2" do
    setup do
      matrix = [
        [0, 0],
        [0, 0]
      ]

      [grid: Grid.new!(matrix)]
    end

    test "should toggle the cell value between :alive and :dead", %{grid: grid} do
      grid
      |> tap(fn grid -> assert :dead == Grid.get_cell(grid, {0, 0}) end)
      |> Grid.toggle_cell({0, 0})
      |> tap(fn grid -> assert :alive == Grid.get_cell(grid, {0, 0}) end)
      |> Grid.toggle_cell({0, 0})
      |> tap(fn grid -> assert :dead == Grid.get_cell(grid, {0, 0}) end)
      |> Grid.toggle_cell({0, 0})
      |> tap(fn grid -> assert :alive == Grid.get_cell(grid, {0, 0}) end)
    end

    test "should raise when position is outside the grid", %{grid: grid} do
      assert_raise(ArgumentError, "position given is outside the grid. Got '{-1, 0}'", fn ->
        Grid.toggle_cell(grid, {-1, 0})
      end)

      assert_raise(ArgumentError, "position given is outside the grid. Got '{0, -1}'", fn ->
        Grid.toggle_cell(grid, {0, -1})
      end)

      assert_raise(ArgumentError, "position given is outside the grid. Got '{2, 0}'", fn ->
        Grid.toggle_cell(grid, {2, 0})
      end)

      assert_raise(ArgumentError, "position given is outside the grid. Got '{0, 2}'", fn ->
        Grid.toggle_cell(grid, {0, 2})
      end)

      assert %Grid{} = Grid.toggle_cell(grid, {0, 0})
      assert %Grid{} = Grid.toggle_cell(grid, {0, 1})
      assert %Grid{} = Grid.toggle_cell(grid, {1, 0})
      assert %Grid{} = Grid.toggle_cell(grid, {1, 1})
    end
  end

  test "to_string/1" do
    cell_matrix = [
      [0, 0, 0, 1],
      [0, 0, 1, 0],
      [1, 1, 1, 1],
      [0, 0, 1, 1]
    ]

    grid = Grid.new!(cell_matrix)

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
