# ExBBCode

A modern, high-performance Elixir library for high-fidelity HTML-to-BBCode conversion and structured Abstract Syntax Tree (AST) parsing. Built with `NimbleParsec` for robust, nested tag processing in Phoenix and Ash-based web applications.

---

## Features

* **HTML-to-BBCode Conversion:** Translates rich client-side HTML input into clean, standardized BBCode tags.
* **AST Parsing Pipeline:** Leverages `NimbleParsec` to tokenize and build deeply nested Abstract Syntax Trees without fragile regex nesting bugs.
* **Extensible Rendering:** Easily transform parsed AST nodes back into clean HTML, plain text, or custom formats for Phoenix LiveView templates.

---

## Installation

Add `ex_bbcode` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_bbcode, "~> 0.1.0"},
    {:nimble_parsec, "~> 1.4"}
  ]
end
```

---

## Usage Guide & Examples

### 1. Converting HTML Strings to BBCode (Writing / Input)

When handling user input from rich-text or WYSIWYG editors, you can normalize and convert HTML elements into standardized BBCode tags before saving them to your database.


#### Example:

```elixir
# 1. Default behavior (create_ast defaults to false, skips AST parsing)
BBCode.from_html("<p>Hello <strong>World</strong></p>")
# => {:ok, "[b]Hello World[/b]"}

# 2. Explicitly opting in to create the AST
BBCode.HtmlToBbcode.convert("<p>Hello <strong>World</strong></p>", create_ast: true)
# => {:ok, "[b]Hello World[/b]", ast_term}
```

---

### 2. Parsing BBCode into an AST & Rendering HTML (Reading / Output)

When reading BBCode from storage, you can parse it directly using `BBCode.Parser` into a structured AST, then map those nodes back into safe, semantic HTML for your views.

#### Example:

```elixir
bbcode_input = "[p]Welcome to [b]Elixir[/b]! Check out [url=https://elixir-lang.org]the official site[/url].[/p]"

{:ok, html_output} = BBCode.to_html(bbcode_input)

# Result:
# "<p>Welcome to <strong>Elixir</strong>! Check out <a href="https://elixir-lang.org" target="_blank" rel="noopener">the official site</a>.</p>"
```

---

## Integration with Ash Framework

You can seamlessly combine the parser and renderer inside an Ash resource calculation or attribute hook for reactive display formatting:

```elixir
defmodule MyApp.Forums.Post do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "posts"
    repo MyApp.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :content_bbcode, :string, allow_nil?: false
  end

  calculations do
    calculate :rendered_html, :string, fn records, _context ->
      Enum.map(records, fn record ->
        case ExBBCode.Renderer.render(record.content_bbcode) do
          {:ok, html} -> html
          _ -> ""
        end
      end)
    end
  end
end
```

---

## License

MIT License. See `LICENSE` for details.
