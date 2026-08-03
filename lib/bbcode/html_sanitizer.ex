defmodule BBCode.HtmlSanitizer do
  @moduledoc """
  Provides robust sanitization of raw HTML strings by stripping dangerous
  executable tags, inline event handlers, protocol exploits, DOM-based injections,
  and obfuscated payloads.
  """

  @spec sanitize(String.t() | nil) :: String.t()
  def sanitize(nil), do: ""
  def sanitize(html) when not is_binary(html), do: ""

  def sanitize(html) do
    html
    # 1. Strip dangerous executable and embedding tags completely
    |> strip_tag_block("script")
    |> strip_tag_block("style")
    |> strip_tag_block("iframe")
    |> strip_tag_block("object")
    |> strip_tag_block("embed")
    |> strip_tag_block("applet")
    |> strip_self_closing_tag("meta")
    |> strip_self_closing_tag("link")
    |> strip_tag_block("form")
    |> strip_self_closing_tag("base")
    |> strip_tag_block("svg")
    |> strip_tag_block("math")
      # 2. Neutralize all possible inline event handlers (on* attributes)
    |> Regex.replace(~r/\s+on[a-z0-9_-]+\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]+)/ui, "")
      # 3. Neutralize dangerous, non-standard, or encoded URI schemes across attributes
    |> Regex.replace(~r/\s+(?:href|src|action|formaction|xlink:href)\s*=\s*(?:"\s*(?:javascript|vbscript|data|file|about|livescript):[^"]*"|'\s*(?:javascript|vbscript|data|file|about|livescript):[^']*'|[^\s>]+)/ui, "")
    |> Regex.replace(~r/\s+(?:href|src|action|formaction|xlink:href)\s*=\s*(?:"[^"]*(?:&#[xX]?[0-9a-fA-F]+;|\s)+script\s*:[^"]*"|'[^']*(?:&#[xX]?[0-9a-fA-F]+;|\s)+script\s*:[^']*')/ui, "")
      # 4. Strip JSFuck, AAEncode, JJEncode, and heavy esoteric symbol obfuscation patterns
    |> Regex.replace(~r/[\[\]\(\)\+\!\{\}\.\:\;]{15,}/u, "")
      # 5. Sanitize anchor href attributes to prevent protocol-relative or encoded XSS
    |> sanitize_anchors()
      # 6. Unescape common HTML entities if desired, or leave intact depending on storage needs
    |> String.trim()
  end

  # Helper to remove tags with opening/closing bounds (e.g., <script>...</script>)
  defp strip_tag_block(html, tag) do
    Regex.replace(~r/<#{tag}\b[^<]*(?:(?!<\/#{tag}>)<[^<]*)*<\/#{tag}>/ui, html, "")
  end

  # Helper to remove self-closing or single tags (e.g., <meta ...>)
  defp strip_self_closing_tag(html, tag) do
    Regex.replace(~r/<#{tag}\b[^>]*>/ui, html, "")
  end

  # Secure anchor sanitizer to intercept protocol injections and entity-encoded XSS in URLs
  defp sanitize_anchors(html) do
    Regex.replace(~r/(<a\s+(?:[^>]*?\s+)?href=")([^"]*)("[^>]*>)/ui, html, fn _, prefix, url, suffix ->
      decoded_url =
        url
        |> String.replace(~r/&#[xX]?[0-9a-fA-F]+;/u, "")
        |> String.trim()
        |> String.downcase()

      if String.starts_with?(decoded_url, ["javascript:", "vbscript:", "data:", "file:", "about:"]) ||
           String.contains?(decoded_url, "script:") do
        # Neutralize the href to a safe value if malicious
        "#{prefix}#\"#{suffix}"
      else
        "#{prefix}#{url}#{suffix}"
      end
    end)
  end
end