defmodule GameOfLife.CellTest do
  use ExUnit.Case, async: true

  alias GameOfLife.Cell

  test "random/0 only contains :dead or :alive values" do
    only_alive_or_dead =
      (&Cell.random/0)
      |> Stream.repeatedly()
      |> Enum.take(100)
      |> Enum.all?(fn cell -> cell in [:alive, :dead] end)

    assert only_alive_or_dead
  end

  describe "to_string/1" do
    test "when dead" do
      assert Cell.to_string(:dead) == " "
    end

    test "when alive" do
      assert Cell.to_string(:alive) == "x"
    end

    test "both representations must have the same length" do
      str_alive = Cell.to_string(:alive)
      str_dead = Cell.to_string(:dead)

      assert String.length(str_alive) == String.length(str_dead)
    end
  end

  describe "from_int/1" do
    test "should return expected values" do
      assert :dead == Cell.from_int(0)
      assert :alive == Cell.from_int(1)
      assert :alive == Cell.from_int(-10)
      assert :alive == Cell.from_int(10)
    end

    test "should raise on invalid arguments" do
      assert_raise(FunctionClauseError, fn -> Cell.from_int("0") end)
      assert_raise(FunctionClauseError, fn -> Cell.from_int(1.0) end)
      assert_raise(FunctionClauseError, fn -> Cell.from_int(:dead) end)
      assert_raise(FunctionClauseError, fn -> Cell.from_int(:alive) end)
      assert_raise(FunctionClauseError, fn -> Cell.from_int(nil) end)
    end
  end

  describe "to_int/1" do
    test "should return expected values" do
      assert 1 == Cell.to_int(:alive)
      assert 0 == Cell.to_int(:dead)
    end
  end
end
