defmodule TunezWeb.Constants do
  @moduledoc false

  @default_debounce "250"
  def default_debounce, do: @default_debounce

  defdelegate default_pagination_limit, to: Tunez.Constants
end
