defmodule GameOfLifeWeb.HomeLive do
  use GameOfLifeWeb, :live_view

  alias GameOfLife.Life
  alias GameOfLife.Grid
  alias Phoenix.LiveView.Socket

  @grid_size 30
  @update_interval to_timeout(millisecond: 100)

  @impl true
  def mount(_params, _session, %Socket{} = socket) do
    socket =
      socket
      |> assign(timer_ref: nil)
      |> assign(state: :paused)
      |> assign(grid: Grid.random(@grid_size, @grid_size))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <div>
        <div>
          <.button
            type="button"
            phx-click="start"
            disabled={@state == :running}
            class="disabled:opacity-50 disabled:pointer-events-none"
          >
            Start
          </.button>

          <.button
            type="button"
            phx-click="stop"
            disabled={@state == :paused}
            class="disabled:opacity-50 disabled:pointer-events-none"
          >
            Pause
          </.button>
        </div>
      </div>

      <div id="gridContainer" class="border">
        <table id="grid">
          <tr :for={row <- 0..(@grid.rows - 1)}>
            <td
              :for={col <- 0..(@grid.cols - 1)}
              class="border border-black text-center w-[20px] h-[20px] data-[alive]:bg-black hover:bg-gray-400"
              data-alive={Grid.get_cell(@grid, {row, col}) == :alive}
              phx-click={JS.push("cell_clicked", value: %{row: row, col: col})}
            >
            </td>
          </tr>
        </table>
      </div>

      <div>
        Current generation: <%= @grid.generation %>
      </div>
    </section>
    """
  end

  @impl true
  def handle_event("start", _params, %Socket{} = socket) do
    %{state: state} = socket.assigns

    socket =
      case state do
        :paused -> socket |> assign(state: :running) |> call_next_generation()
        :running -> socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _params, %Socket{} = socket) do
    Process.cancel_timer(socket.assigns.timer_ref)
    socket = assign(socket, state: :paused, timer_ref: nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("cell_clicked", %{"row" => row, "col" => col} = _params, %Socket{} = socket) do
    socket = update(socket, :grid, fn grid -> Grid.toggle_cell(grid, {row, col}) end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:next_generation, %Socket{} = socket) do
    %{grid: grid} = socket.assigns

    next_generation = Life.next_generation(grid)

    socket =
      socket
      |> assign(grid: next_generation)
      |> call_next_generation()

    {:noreply, socket}
  end

  defp call_next_generation(%Socket{} = socket) do
    timer_ref = Process.send_after(self(), :next_generation, @update_interval)
    assign(socket, timer_ref: timer_ref)
  end
end
