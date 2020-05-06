defmodule GameOfLife.Cell do
  @moduledoc false

  @type t :: :alive | :dead

  @spec to_string(t) :: String.t()
  def to_string(:alive), do: " x "
  def to_string(:dead), do: "   "

end
