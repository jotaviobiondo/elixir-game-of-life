defmodule GameOfLife.GridTest do
  use ExUnit.Case
  alias GameOfLife.Grid
  doctest GameOfLife.Grid

  describe "Grid.new/1" do
    test "valid cell matrix" do
      cell_matrix = [
        [:alive, :dead],
        [:dead, :alive]
      ]

      grid = Grid.new(cell_matrix)

      assert grid.size == Enum.count(cell_matrix)

      assert grid.cells == %{
               {0, 0} => :alive,
               {0, 1} => :dead,
               {1, 0} => :dead,
               {1, 1} => :alive
             }
    end

    test "wrong size for cell matrix" do
      cell_matrix = [
        [:dead, :dead],
        [:dead, :dead],
        [:dead, :dead]
      ]

      assert_raise(
        ArgumentError,
        fn ->
          Grid.new(cell_matrix)
        end
      )
    end
  end

  test "Grid.new_empty/1" do
    size = 20
    grid = Grid.new_empty(size)

    assert grid.size == size
    assert Enum.count(grid.cells) == size * size

    assert grid.cells
           |> Map.values()
           |> Enum.all?(&(&1 == :dead))
  end

  test "Grid.neighbours/1" do
    assert Grid.neighbours({2, 5}) == [
             {1, 4},
             {1, 5},
             {1, 6},
             {2, 4},
             {2, 6},
             {3, 4},
             {3, 5},
             {3, 6}
           ]
  end

  test "Grid.alive_neighbours/2" do
    cell_matrix = [
      [:dead, :dead, :dead, :alive],
      [:dead, :dead, :alive, :dead],
      [:alive, :alive, :alive, :alive],
      [:dead, :dead, :alive, :alive]
    ]

    grid = Grid.new(cell_matrix)

    assert Grid.alive_neighbours(grid, {0, 0}) == 0
    assert Grid.alive_neighbours(grid, {0, 1}) == 1
    assert Grid.alive_neighbours(grid, {0, 2}) == 2
    assert Grid.alive_neighbours(grid, {0, 3}) == 1
    assert Grid.alive_neighbours(grid, {1, 0}) == 2
    assert Grid.alive_neighbours(grid, {1, 1}) == 4
    assert Grid.alive_neighbours(grid, {1, 2}) == 4
    assert Grid.alive_neighbours(grid, {1, 3}) == 4
    assert Grid.alive_neighbours(grid, {2, 0}) == 1
    assert Grid.alive_neighbours(grid, {2, 1}) == 4
    assert Grid.alive_neighbours(grid, {2, 2}) == 5
    assert Grid.alive_neighbours(grid, {2, 3}) == 4
    assert Grid.alive_neighbours(grid, {3, 0}) == 2
    assert Grid.alive_neighbours(grid, {3, 1}) == 4
    assert Grid.alive_neighbours(grid, {3, 2}) == 4
    assert Grid.alive_neighbours(grid, {3, 3}) == 3
  end
end
