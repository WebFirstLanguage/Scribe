# Scribe

**A Twig-inspired templating engine written entirely in
[WFL](https://github.com/WebFirstLanguage/wfl)** — the WebFirst Language, where
programs read like plain English.

Scribe brings familiar `{{ variable }}` / `{% logic %}` / `{# comment #}`
templating to WFL, with **HTML auto-escaping on by default** so your output is
secure unless you explicitly opt out.

```twig
<h1>{{ post.title }}</h1>
{% if post.published %}
  <p>{{ post.body }}</p>
{% else %}
  <p><em>draft</em></p>
{% endif %}
<ul>
{% for tag in post.tags %}
  <li>{{ loop.index }}. {{ tag | upper }}</li>
{% endfor %}
</ul>
```

## Why Scribe

- **Familiar.** If you know Twig, Jinja, or Liquid, you already know Scribe.
- **Secure by default.** Every `{{ … }}` is HTML-escaped. Opt out locally and
  explicitly with `{{ trusted | raw }}` — never globally. (WFL Principle 8.)
- **Pure WFL.** No Rust, no host-language escape hatch. Scribe is one WFL file
  that runs anywhere WFL runs.
- **Small and tested.** A readable lexer → parser → renderer pipeline with a
  51-case test suite.

## Features

- Output with auto-escaping: `{{ user.name }}`
- Dotted paths into nested maps and lists: `{{ order.items.0.title }}`
- Filters, chainable: `{{ name | upper }}`, `{{ items | join(', ') }}`
- Filter set: `upper, lower, capitalize, title, trim, length, reverse, first,
  last, join, default, replace, abs, round, truncate, striptags, date, asset,
  url, markdown, escape/e, raw`
- Conditionals: `{% if %}` / `{% elseif %}` / `{% else %}` / `{% endif %}`
- Loops with a `loop` helper: `{% for x in items %}` … `{% else %}` …
  `{% endfor %}`, plus `loop.index / index0 / first / last / length`
- Variables: `{% set total = a + b %}`
- Expressions: `+ - * /`, `~` concat, `== != < > <= >=`, `and / or / not`,
  parentheses, string & number literals, `true / false / null`
- Macros: `{% macro name(a, b) %}…{% endmacro %}`, called as `{{ name(x, y) }}`;
  share them across files with `{% import "lib.html" as ui %}` (then
  `{{ ui.name(...) }}`) or `{% from "lib.html" import name %}`
- Includes: `{% include "partial.html" %}` (shares the current context), or with
  an explicit scoped context: `{% include "partial.html" with { key: value } %}`
  — add `only` to isolate the partial from the caller's variables
- Multi-level template inheritance: `{% extends "base.html" %}` with
  `{% block name %}…{% endblock %}` overrides and defaults, chained as many
  levels deep as you like (child → theme → base)
- Comments: `{# … #}`
- Raw blocks: `{% verbatim %}…{% endverbatim %}`

See **[docs/SYNTAX.md](docs/SYNTAX.md)** for the full language reference and
**[docs/DESIGN.md](docs/DESIGN.md)** for the architecture.

## Quick start

Scribe is a single WFL library file, `src/scribe.wfl`. Pull it into your own
program with `include from`, which exposes its actions to you:

```wfl
// my_app.wfl — your program
include from "src/scribe.wfl"

create map ctx:
    "name" is "World"
    "items" is ["one", "two", "three"]
end map

store out as scribe_render of "Hello {{ name }}! ({{ items | length }} items)" and ctx
display out
```

Run it:

```sh
wfl my_app.wfl
# => Hello World! (3 items)
```

The `include from` path is resolved relative to your file's directory, so
adjust it to wherever you keep `src/scribe.wfl`.

The public API is two actions:

| Action | Description |
| --- | --- |
| `scribe_render of template and context` | Render a template **string** with a context map → returns the output text |
| `scribe_render_file of path and context` | Read a template **file** from disk, then render it |

The `context` is an ordinary WFL map. Nest maps and lists to model richer data.

## Examples

`examples/blog.wfl` renders a small blog page end-to-end:

```sh
examples/run.sh examples/blog.wfl /path/to/wfl
```

`examples/inheritance.wfl` shows `{% extends %}` / `{% block %}` / `{% include %}`
against the templates in `examples/templates/` (run it from the repo root so the
relative paths resolve). Expected output for both is checked in next to each
example (`*.expected.html`).

`examples/theme.wfl` puts the ecosystem features together as a **theme layer**:
multi-level `{% extends %}` (child → blog shell → base skeleton), an
`{% import %}`-ed macro library, an `{% include ... with { … } only %}` partial,
and the `markdown` / `asset` / `url` filters.

## Running the tests

The suite uses WFL's built-in `describe` / `test` framework and pulls in the
engine with `include from`:

```sh
tests/run.sh /path/to/wfl
# Total: 51  Passed: 51  Failed: 0
```

> **Note on WFL's static checker.** The WFL type checker prints some
> `could not infer type` notes to *stderr* for calls into the engine's
> actions. These are non-fatal — the program runs and the tests exit 0.

## Project layout

```
Scribe/
├── src/scribe.wfl            # the entire engine (pure library)
├── tests/scribe.test.wfl     # test suite (51 cases), includes the engine
├── tests/run.sh              # run the tests with `wfl --test`
├── examples/blog.wfl         # worked example + expected output
├── examples/inheritance.wfl  # inheritance example + expected output
├── examples/theme.wfl        # theme-layering example (macros, multi-level, filters)
├── examples/run.sh           # run an example
└── docs/                     # SYNTAX.md and DESIGN.md
```

## Roadmap

Implemented: multi-level inheritance, macros (`{% macro %}` / `{% import %}` /
`{% from … import %}`), scoped `{% include … with { … } %}`, and the
`date / truncate / striptags / asset / url / markdown` filters.

Planned next: `for key, value in map` (pending WFL map-key iteration),
whitespace control (`{{-` / `-}}`), and more filters/functions. Details in
[docs/DESIGN.md](docs/DESIGN.md).

## Upstream WFL issues found while building Scribe

Building a non-trivial program in WFL surfaced a few language bugs, reported
upstream — all since addressed:

- [wfl#582](https://github.com/WebFirstLanguage/wfl/issues/582) — a function
  parameter was overridden by a same-named global variable. **Fixed upstream.**
  Scribe still prefixes every engine parameter `sc_` defensively (harmless, and
  keeps it working on older WFL builds).
- [wfl#583](https://github.com/WebFirstLanguage/wfl/issues/583) — the string
  value `"[]"` was coerced to an empty list. **Fixed upstream.** Separately,
  Scribe now renders an empty collection as empty text (Twig's behaviour), so a
  bare `{{ empty_list }}` no longer emits the literal `[]`.
- [wfl#584](https://github.com/WebFirstLanguage/wfl/issues/584) — `load module`
  symbols are invisible to the analyzer. Resolved by using `include from`
  instead, which exposes the included file's actions — this is how Scribe loads
  its engine.

## License

Apache-2.0. See [LICENSE](LICENSE).
