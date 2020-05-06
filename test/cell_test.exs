defmodule GameOfLife.CellTest do
  use ExUnit.Case
  alias GameOfLife.Cell
  doctest GameOfLife.Cell

  test "Cell.random/0 only contains :dead or :alive values" do
    frequency_keys = Stream.repeatedly(&Cell.random/0)
    |> Stream.take(50)
    |> Enum.frequencies()
    |> Map.keys()

    assert frequency_keys == [:alive, :dead]
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
