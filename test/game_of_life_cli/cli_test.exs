defmodule GameOfLifeCLI.CLITest do
  use ExUnit.Case
  alias GameOfLifeCLI.CLI

  describe "parse_args/1" do
    test "with all args" do
      options = CLI.parse_args(["--generations", "50", "--rows", "100", "--columns", "50"])

      assert options == %{generations: 50, rows: 100, columns: 50}
    end

    test "with no args must have default values" do
      options = CLI.parse_args([])

      assert %{generations: 5, rows: 10, columns: 10} == options
    end

    test "with 1 argument and others must have default values" do
      options = CLI.parse_args(["--generations", "50"])

      assert %{generations: 50, rows: 10, columns: 10} == options
    end

    test "should ignore wrong arguments" do
      options = CLI.parse_args(["--wrong", "value"])

      assert %{generations: 5, rows: 10, columns: 10} == options
    end
  end
end
