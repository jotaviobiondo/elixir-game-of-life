defmodule GameOfLife.Cell do
  @moduledoc """
  Module that provides functions to manipulate cell state (alive or dead).
  """

  @type t :: :alive | :dead

  @spec random :: t
  def random, do: Enum.random([:alive, :dead])

  @spec to_string(t) :: String.t()
  def to_string(:alive), do: "x"
  def to_string(:dead), do: " "

  @spec from_int(integer) :: t
  def from_int(0), do: :dead
  def from_int(x) when is_integer(x), do: :alive

  @spec to_int(t) :: integer
  def to_int(:dead), do: 0
  def to_int(:alive), do: 1
end
