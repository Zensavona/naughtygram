defmodule Naughtygram.Cookie do
  @moduledoc """
  Handles cookies
  """

  @doc """
  Parses a header item and returns the cookie name and content
  """
  def parse(header_item) do
    {name, content} = header_item
    case name do
      "Set-Cookie" ->
        List.first(:hackney_cookie.parse_cookie(content))
      _ ->
        :nah
    end
  end
end
