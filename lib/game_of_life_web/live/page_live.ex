defmodule GameOfLifeWeb.PageLive do
  use GameOfLifeWeb, :live_view

  alias GameOfLife.Life
  alias GameOfLife.Grid

  @grid_size 10

  @impl true
  def mount(_params, _session, socket) do
    grid = Grid.new_random(@grid_size)

    socket =
      assign(
        socket,
        tref: nil,
        state: :stopped,
        grid: grid
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("start", _params, socket) do
    {:ok, tref} = :timer.send_interval(1000, self(), :update)

    socket = assign(socket, state: :running, tref: tref)

    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _params, socket) do
    :timer.cancel(socket.assigns.tref)

    socket = assign(socket, state: :stopped, tref: nil)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:update, socket) do
    %{grid: grid} = socket.assigns

    next_generation = Life.next_generation(grid)

    {:noreply, assign(socket, grid: next_generation)}
  end

  def grid_to_html(grid) do
    grid
    |> to_string()
    |> String.replace("\n", "<br>")
  end
end
