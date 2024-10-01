defmodule GameOfLife.LifeTest do
  use ExUnit.Case

  alias GameOfLife.Grid
  alias GameOfLife.Life

  test "stream_generations/1" do
    cell_matrix = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0]
    ]

    stream = cell_matrix |> Grid.new!() |> Life.stream_generations()

    assert 10 == stream |> Enum.take(10) |> Enum.count()
    assert 100 == stream |> Enum.take(100) |> Enum.count()
    assert 1000 == stream |> Enum.take(1000) |> Enum.count()
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

      assert """
             +---------------+
             |   |   |   |   |
             |   | x | x |   |
             |   | x | x |   |
             |   |   |   |   |
             +---------------+
             """ ==
               Grid.new!(cell_matrix)
               |> Life.next_generation()
               |> Life.next_generation()
               |> to_string()
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

      first_generation = Grid.new!(cell_matrix) |> Life.next_generation()

      assert """
             +-------------------+
             |   |   |   |   |   |
             |   |   |   |   |   |
             |   | x | x | x |   |
             |   |   |   |   |   |
             |   |   |   |   |   |
             +-------------------+
             """ == to_string(first_generation)

      assert """
             +-------------------+
             |   |   |   |   |   |
             |   |   | x |   |   |
             |   |   | x |   |   |
             |   |   | x |   |   |
             |   |   |   |   |   |
             +-------------------+
             """ == first_generation |> Life.next_generation() |> to_string()
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

      first_generation = Grid.new!(cell_matrix) |> Life.next_generation()

      assert """
             +-----------------------+
             |   |   |   |   |   |   |
             |   |   | x |   |   |   |
             |   |   |   | x | x |   |
             |   |   | x | x |   |   |
             |   |   |   |   |   |   |
             |   |   |   |   |   |   |
             +-----------------------+
             """ == to_string(first_generation)

      second_generation = Life.next_generation(first_generation)

      assert """
             +-----------------------+
             |   |   |   |   |   |   |
             |   |   |   | x |   |   |
             |   |   |   |   | x |   |
             |   |   | x | x | x |   |
             |   |   |   |   |   |   |
             |   |   |   |   |   |   |
             +-----------------------+
             """ == to_string(second_generation)

      third_generation = Life.next_generation(second_generation)

      assert """
             +-----------------------+
             |   |   |   |   |   |   |
             |   |   |   |   |   |   |
             |   |   | x |   | x |   |
             |   |   |   | x | x |   |
             |   |   |   | x |   |   |
             |   |   |   |   |   |   |
             +-----------------------+
             """ == to_string(third_generation)

      fourth_generation = Life.next_generation(third_generation)

      assert """
             +-----------------------+
             |   |   |   |   |   |   |
             |   |   |   |   |   |   |
             |   |   |   |   | x |   |
             |   |   | x |   | x |   |
             |   |   |   | x | x |   |
             |   |   |   |   |   |   |
             +-----------------------+
             """ == to_string(fourth_generation)
    end
  end
end
