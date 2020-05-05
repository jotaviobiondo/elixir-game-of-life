defmodule GameOfLife.CellTest do
  use ExUnit.Case
  alias GameOfLife.Cell
  doctest GameOfLife.Cell

  test "cell should not be alive when created" do
    cell = %Cell{}

    assert cell.alive == false
  end

  describe "Cell.to_string/1" do
    test "when dead" do
      cell = %Cell{}

      assert Cell.to_string(cell) == "   "
    end

    test "when alive" do
      cell = %Cell{alive: true}

      assert Cell.to_string(cell) == " x "
    end
  end

end
