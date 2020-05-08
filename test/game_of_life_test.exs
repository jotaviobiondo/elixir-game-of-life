defmodule GameOfLifeTest do
  use ExUnit.Case
  alias GameOfLife.Grid

  doctest GameOfLife

  describe "next_generation/1" do
    # https://en.wikipedia.org/wiki/Still_life_(cellular_automaton)
    test "still life - block" do
      cell_matrix = [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0]
      ]

      assert Grid.new(cell_matrix)
             |> GameOfLife.next_generation()
             |> GameOfLife.next_generation()
             |> Grid.to_string() ==
               """
               +---------------+
               |   |   |   |   |
               |   | x | x |   |
               |   | x | x |   |
               |   |   |   |   |
               +---------------+
               """
    end

    # https://en.wikipedia.org/wiki/Oscillator_(cellular_automaton)
    test "oscillator - blinker" do
      cell_matrix = [
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0]
      ]

      first_generation = Grid.new(cell_matrix) |> GameOfLife.next_generation()

      assert first_generation |> Grid.to_string() ==
               """
               +-------------------+
               |   |   |   |   |   |
               |   |   |   |   |   |
               |   | x | x | x |   |
               |   |   |   |   |   |
               |   |   |   |   |   |
               +-------------------+
               """

      assert first_generation |> GameOfLife.next_generation() |> Grid.to_string() ==
               """
               +-------------------+
               |   |   |   |   |   |
               |   |   | x |   |   |
               |   |   | x |   |   |
               |   |   | x |   |   |
               |   |   |   |   |   |
               +-------------------+
               """
    end

    # https://en.wikipedia.org/wiki/Spaceship_(cellular_automaton)
    test "spaceship - glider" do
      cell_matrix = [
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0],
        [0, 1, 0, 1, 0, 0],
        [0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0]
      ]

      first_generation = Grid.new(cell_matrix) |> GameOfLife.next_generation()

      assert first_generation |> Grid.to_string() ==
               """
               +-----------------------+
               |   |   |   |   |   |   |
               |   |   | x |   |   |   |
               |   |   |   | x | x |   |
               |   |   | x | x |   |   |
               |   |   |   |   |   |   |
               |   |   |   |   |   |   |
               +-----------------------+
               """

      second_generation = GameOfLife.next_generation(first_generation)

      assert second_generation |> Grid.to_string() ==
               """
               +-----------------------+
               |   |   |   |   |   |   |
               |   |   |   | x |   |   |
               |   |   |   |   | x |   |
               |   |   | x | x | x |   |
               |   |   |   |   |   |   |
               |   |   |   |   |   |   |
               +-----------------------+
               """

      third_generation = GameOfLife.next_generation(second_generation)

      assert third_generation |> Grid.to_string() ==
               """
               +-----------------------+
               |   |   |   |   |   |   |
               |   |   |   |   |   |   |
               |   |   | x |   | x |   |
               |   |   |   | x | x |   |
               |   |   |   | x |   |   |
               |   |   |   |   |   |   |
               +-----------------------+
               """

      fourth_generation = GameOfLife.next_generation(third_generation)

      assert fourth_generation |> Grid.to_string() ==
               """
               +-----------------------+
               |   |   |   |   |   |   |
               |   |   |   |   |   |   |
               |   |   |   |   | x |   |
               |   |   | x |   | x |   |
               |   |   |   | x | x |   |
               |   |   |   |   |   |   |
               +-----------------------+
               """
    end
  end
end
