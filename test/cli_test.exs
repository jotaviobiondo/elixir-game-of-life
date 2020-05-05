defmodule GameOfLife.CLITest do
  use ExUnit.Case
  alias GameOfLife.CLI
  doctest GameOfLife.CLI

  describe "CLI.parse_args/1" do
    test "with all args" do
      options = CLI.parse_args(["--generations", "50", "--grid-size", "100"])

      assert options == %{generations: 50, grid_size: 100}
    end

    test "with no args must have default values" do
      options = CLI.parse_args([])

      assert Map.keys(options) == [:generations, :grid_size]
    end

    test "with 1 argument and others must have default values" do
      options = CLI.parse_args(["--generations", "50"])

      assert Map.keys(options) == [:generations, :grid_size]
      assert %{generations: 50} = options
    end
  end
end
