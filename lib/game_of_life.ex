defmodule GameOfLife do

  def start(generations \\ 5, grid_size \\ 10) do
    initial_grid = random_grid(grid_size)
    print_grid(initial_grid, grid_size)

    Enum.reduce(
      1..generations,
      initial_grid,
      fn _, current_grid ->
        next_gen = next_generation(current_grid)

        print_grid(next_gen, grid_size)

        Process.sleep(500)

        next_gen
      end
    )
  end

  defp next_generation(grid) do
    for {cell, is_alive} <- grid, into: %{} do
      case {is_alive, alive_neighbours(grid, cell)} do
        {true, alive_neighbours} when alive_neighbours in [2, 3] -> {cell, false}
        {false, alive_neighbours} when alive_neighbours == 3 -> {cell, true}
        _ -> {cell, is_alive}
      end
    end
  end

  defp alive_neighbours(grid, cell) do
    for offset_x <- -1..1,
        offset_y <- -1..1,
        {offset_x, offset_y} != {0, 0} do
      {cell_x, cell_y} = cell
      {offset_x + cell_x, offset_y + cell_y}
    end
    |> Enum.map(fn neighbour -> Map.get(grid, neighbour, false) end)
    |> Enum.count(&(&1 == true))
  end

  defp empty_grid(size) do
    for x <- 1..(size - 1),
        y <- 1..(size - 1),
        into: %{} do
      {{x, y}, false}
    end
  end

  defp random_grid(size) do
    for x <- 1..(size - 1),
        y <- 1..(size - 1),
        into: %{} do
      {{x, y}, Enum.random([true, false])}
    end
  end

  defp print_grid(grid, size \\ 10) do
    Enum.each(0..(size - 1), fn x ->
      Enum.each(0..(size - 1), fn y ->
        is_alive = grid[{x, y}]

        if is_alive, do: IO.write("| x "), else: IO.write("|   ")
      end)

      IO.puts("")
    end)

    IO.puts("------------------------------------------------------------")
  end
end
