defmodule GameOfLifeWeb.HomeLive do
  use GameOfLifeWeb, :live_view

  alias GameOfLife.Life
  alias GameOfLife.Grid
  alias Phoenix.LiveView.Socket

  @grid_size 50
  @update_interval to_timeout(millisecond: 100)

  @impl true
  def mount(_params, _session, %Socket{} = socket) do
    socket =
      socket
      |> assign(timer_ref: nil)
      |> assign(state: :paused)
      |> assign(grid: Grid.new_random(@grid_size))
      |> assign(current_iteration: 1)

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
          <tr :for={row <- 0..(@grid.size - 1)}>
            <td
              :for={col <- 0..(@grid.size - 1)}
              class="border border-black text-center w-[15px] h-[15px] data-[alive]:bg-black"
              data-alive={Grid.get_cell(@grid, {row, col}) == :alive}
            >
            </td>
          </tr>
        </table>
      </div>

      <div>
        Current generation: <%= @current_iteration %>
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
  def handle_event("stop", _params, socket) do
    Process.cancel_timer(socket.assigns.timer_ref)
    socket = assign(socket, state: :paused, timer_ref: nil)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:next_generation, %Socket{} = socket) do
    %{grid: grid, current_iteration: current_iteration} = socket.assigns

    next_generation = Life.next_generation(grid)

    socket =
      socket
      |> assign(grid: next_generation, current_iteration: current_iteration + 1)
      |> call_next_generation()

    {:noreply, socket}
  end

  defp call_next_generation(%Socket{} = socket) do
    timer_ref = Process.send_after(self(), :next_generation, @update_interval)
    assign(socket, timer_ref: timer_ref)
  end
end
