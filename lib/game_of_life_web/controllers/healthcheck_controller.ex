defmodule GameOfLifeWeb.Controllers.HealthcheckController do
  @moduledoc """
  Controller for healthcheck endpoint.
  """
  use GameOfLifeWeb, :controller

  def healthcheck(%Plug.Conn{} = conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{api: "up"})
  end
end
