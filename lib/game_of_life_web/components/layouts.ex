defmodule GameOfLifeWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use GameOfLifeWeb, :controller` and
  `use GameOfLifeWeb, :live_view`.
  """
  use GameOfLifeWeb, :html

  embed_templates "layouts/*"
end
