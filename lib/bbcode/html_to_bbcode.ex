defmodule BBCode.HtmlToBbcode do
  @moduledoc """
  Takes sanitized HTML strings and translates relevant HTML tags into
  standard phpBB2 BBCode equivalents.
  """

  alias BBCode.HtmlSanitizer

  @spec convert(String.t() | nil) :: String.t()
  def convert(nil), do: ""
  def convert(html) when not is_binary(html), do: ""

  def convert(html) do
    html
    # 1. Ensure content is fully sanitized first
    |> HtmlSanitizer.sanitize()
      # 2. Translate supported formatting tags into BBCode equivalents safely
    |> Regex.replace(~r/<strong>([\s\S]*?)<\/strong>/ui, "[b]\\1[/b]")
    |> Regex.replace(~r/<b>([\s\S]*?)<\/b>/ui, "[b]\\1[/b]")
    |> Regex.replace(~r/<em>([\s\S]*?)<\/em>/ui, "[i]\\1[/i]")
    |> Regex.replace(~r/<i>([\s\S]*?)<\/i>/ui, "[i]\\1[/i]")
    |> Regex.replace(~r/<u[^>]*>([\s\S]*?)<\/u>/ui, "[u]\\1[/u]")
    |> format_anchors()
    |> Regex.replace(~r/<blockquote>\s*<p>([\s\S]*?)<\/p>\s*<\/blockquote>/ui, "[quote]\\1[/quote]")
    |> Regex.replace(~r/<blockquote>([\s\S]*?)<\/blockquote>/ui, "[quote]\\1[/quote]")
    |> Regex.replace(~r/<br\s*[\/]?>/ui, "\n")
    |> Regex.replace(~r/<\/p>/ui, "\n")
    |> Regex.replace(~r/<p[^>]*>/ui, "")
      # 3. Strip out any remaining unmapped HTML tags to ensure complete containment
    |> Regex.replace(~r/<\/?[a-z][a-z0-9]*[^<>]*>/ui, "")
      # 4. Unescape common HTML entities
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#39;", "'")
    |> String.trim()
  end

  defp format_anchors(html) do
    Regex.replace(~r/<a\s+(?:[^>]*?\s+)?href="([^"]*)"[^>]*>([\s\S]*?)<\/a>/ui, html, fn _, url, text ->
      "[url=#{url}]#{text}[/url]"
    end)
  end
end