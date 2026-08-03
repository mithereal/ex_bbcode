defmodule BBCode do
  alias BBCode.Generator
  alias BBCode.Parser

  @moduledoc """
  # BBCode

  A library providing BBCode parsing for Elixir applications.
  """

  def from_html(html_input) do
    bbcode_string =
      html_input
      |> HtmlSanitizeEx.basic_html()
      # Strip <p> and </p> tags
      |> String.replace(~r/<\/?p>/i, "")
      # Map common HTML formatting to BBCode tags
      |> String.replace(~r/<strong>(.*?)<\/strong>/is, "[b]\\1[/b]")
      |> String.replace(~r/<b>(.*?)<\/b>/is, "[b]\\1[/b]")
      |> String.replace(~r/<em>(.*?)<\/em>/is, "[i]\\1[/i]")
      |> String.replace(~r/<i>(.*?)<\/i>/is, "[i]\\1[/i]")

    BBCode.Parser.parse(bbcode_string)
  end

  def to_html(data) do
    with {:ok, tree} <- Parser.parse(data),
         {:ok, html} <- Generator.to_html(tree) do
      {:ok, html}
    else
      {:error, e} ->
        {:error, e}
    end
  end
end
