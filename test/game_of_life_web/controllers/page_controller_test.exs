defmodule GameOfLifeWeb.PageControllerTest do
  use GameOfLifeWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/other")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
