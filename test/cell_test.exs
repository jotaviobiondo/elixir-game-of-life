defmodule GameOfLife.CellTest do
  use ExUnit.Case
  alias GameOfLife.Cell
  doctest GameOfLife.Cell

  test "Cell.random/0 only contains :dead or :alive values" do
    only_alive_or_dead =
      (&Cell.random/0)
      |> Stream.repeatedly()
      |> Enum.take(100)
      |> Enum.all?(fn cell -> cell in [:alive, :dead] end)

    assert only_alive_or_dead
  end

  describe "Cell.to_string/1" do
    test "when dead" do
      assert Cell.to_string(:dead) == "   "
    end

    test "when alive" do
      assert Cell.to_string(:alive) == " x "
    end

    test "both representations must have the same length" do
      str_alive = Cell.to_string(:alive)
      str_dead = Cell.to_string(:dead)

      assert String.length(str_alive) == String.length(str_dead)
    end
  end
end
