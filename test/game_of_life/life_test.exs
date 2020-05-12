defmodule GameOfLife.LifeTest do
  use ExUnit.Case
  alias GameOfLife.Grid
  alias GameOfLife.Life

  test "get_stream/1" do
    cell_matrix = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0]
    ]

    stream = Life.get_stream(cell_matrix)

    assert stream |> Enum.take(10) |> Enum.count() == 10
    assert stream |> Enum.take(100) |> Enum.count() == 100
    assert stream |> Enum.take(1000) |> Enum.count() == 1000
  end

  test "get_random_stream/1" do
    stream = Life.get_random_stream()

    assert stream |> Enum.take(10) |> Enum.count() == 10
    assert stream |> Enum.take(100) |> Enum.count() == 100
    assert stream |> Enum.take(1000) |> Enum.count() == 1000
  end

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
             |> Life.next_generation()
             |> Life.next_generation()
             |> to_string() ==
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

      first_generation = Grid.new(cell_matrix) |> Life.next_generation()

      assert first_generation |> to_string() ==
               """
               +-------------------+
               |   |   |   |   |   |
               |   |   |   |   |   |
               |   | x | x | x |   |
               |   |   |   |   |   |
               |   |   |   |   |   |
               +-------------------+
               """

      assert first_generation |> Life.next_generation() |> to_string() ==
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

      first_generation = Grid.new(cell_matrix) |> Life.next_generation()

      assert first_generation |> to_string() ==
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

      second_generation = Life.next_generation(first_generation)

      assert second_generation |> to_string() ==
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

      third_generation = Life.next_generation(second_generation)

      assert third_generation |> to_string() ==
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

      fourth_generation = Life.next_generation(third_generation)

      assert fourth_generation |> to_string() ==
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
