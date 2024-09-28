defmodule GameOfLifeCLI.CLITest do
  use ExUnit.Case
  alias GameOfLifeCLI.CLI

  describe "parse_args/1" do
    test "with all args" do
      options = CLI.parse_args(["--generations", "50", "--grid-size", "100"])

      assert options == %{generations: 50, grid_size: 100}
    end

    test "with no args must have default values" do
      options = CLI.parse_args([])

      assert %{generations: 5, grid_size: 10} == options
    end

    test "with 1 argument and others must have default values" do
      options = CLI.parse_args(["--generations", "50"])

      assert %{generations: 50, grid_size: 10} == options
    end

    # TODO: test when wrong parameters are given
  end
end
