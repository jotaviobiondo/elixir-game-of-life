defmodule GameOfLife.Cell do
  @moduledoc false

  @type t :: %__MODULE__{
          alive: boolean()
        }

  defstruct alive: false

  @spec to_string(t) :: String.t()
  def to_string(cell) do
    if cell.alive, do: " x ", else: "   "
  end
end
