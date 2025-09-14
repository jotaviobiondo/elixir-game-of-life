defmodule GameOfLifeWeb.HomeLive do
  use GameOfLifeWeb, :live_view

  alias Phoenix.LiveView.Socket

  alias GameOfLife.Grid
  alias GameOfLife.Life

  @grid_size 30
  @update_interval to_timeout(millisecond: 75)

  @impl true
  def mount(_params, _session, %Socket{} = socket) do
    grid =
      if connected?(socket),
        do: Grid.random(@grid_size, @grid_size),
        else: Grid.empty!(@grid_size, @grid_size)

    socket =
      socket
      |> assign(timer_ref: nil)
      |> assign(state: :paused)
      |> assign(grid: grid)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="synthwave-grid px-8 min-h-screen grid grid-rows-[auto_1fr_auto]">
      <header class="py-8 text-center">
        <h1 class="text-4xl font-bold text-neutral-300 synthwave-text mb-2">
          Conway's Game of Life
        </h1>

        <h6 class="text-center text-xs text-neutral-400">
          Rules: Live cells with 2-3 neighbors survive • Dead cells with exactly 3 neighbors become alive
        </h6>
      </header>

      <main class="px-8 py-15">
        <.flash_group flash={@flash} />

        <.grid grid={@grid} state={@state} />
      </main>

      <footer class="px-4 py-8 text-center">
        <p class="text-white/70 text-sm">
          Made with
          <a href="https://https://www.phoenixframework.org/" target="_blank">
            <img src={~p"/images/logo.svg"} width="24" class="inline" />
          </a>
          by
          <a
            href="https://github.com/jotaviobiondo"
            class="font-medium text-white/90 hover:text-primary transition-colors duration-100"
            target="_blank"
            rel="noopener noreferrer"
          >
            @jotaviobiondo
          </a>
        </p>
      </footer>
    </div>
    """
  end

  defp grid(assigns) do
    ~H"""
    <section class="flex flex-col items-center gap-8">
      <div class="flex justify-center gap-4 flex-wrap">
        <.button :if={@state == :paused} phx-click="start">
          <.icon name="hero-play" class="size-5" /> Start
        </.button>

        <.button :if={@state == :running} phx-click="stop">
          <.icon name="hero-pause" class="size-5" /> Pause
        </.button>

        <.button phx-click="random_grid" disabled={@state == :running}>
          Random
        </.button>

        <.button phx-click="clear_grid" disabled={@state == :running}>
          Clear
        </.button>
      </div>

      <div class="flex justify-center">
        <div class="bg-secondary/15 p-2 border-2 border-neon rounded-xl backdrop-blur-xs">
          <div
            class="grid gap-1aaa"
            style={[
              "grid-template-columns: repeat(#{@grid.cols}, 20px);",
              "grid-template-rows: repeat(#{@grid.rows}, 20px)"
            ]}
          >
            <%= for row <- 0..(@grid.rows - 1), col <- 0..(@grid.cols - 1) do %>
              <div
                class="p-0.5 cursor-pointer"
                phx-click={JS.push("cell_clicked", value: %{row: row, col: col})}
              >
                <div
                  class={[
                    "h-full w-full",
                    "border border-secondary/20 ",
                    "data-[alive]:bg-primary",
                    "hover:bg-primary/20 data-[alive]:hover:bg-primary/40",
                    "transition-colors duration-75"
                  ]}
                  data-alive={Grid.get_cell(@grid, {row, col}) == :alive}
                >
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <div class="flex justify-center gap-8 rounded-lg px-3 py-2 text-sm text-neutral-300 ring-1 ring-neutral-100/15 synthwave-text backdrop-blur-xs">
        <div class="flex items-center flex-col">
          <span class="font-semibold text-2xl">{@grid.generation}</span>
          <span class="text-neutral-300 font-medium">Generation</span>
        </div>

        <div class="flex items-center flex-col">
          <span class="font-semibold text-2xl">{Grid.count_live_cells(@grid)}</span>
          <span class="text-neutral-300 font-medium">Live Cells</span>
        </div>
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
  def handle_event("random_grid", _params, %Socket{} = socket) do
    socket = assign(socket, grid: Grid.random(@grid_size, @grid_size))
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_grid", _params, %Socket{} = socket) do
    socket = update(socket, :grid, &Grid.clear/1)
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
