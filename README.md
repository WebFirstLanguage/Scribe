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
  30-case test suite.

## Features

- Output with auto-escaping: `{{ user.name }}`
- Dotted paths into nested maps and lists: `{{ order.items.0.title }}`
- Filters, chainable: `{{ name | upper }}`, `{{ items | join(', ') }}`
- Filter set: `upper, lower, capitalize, title, trim, length, reverse, first,
  last, join, default, replace, abs, round, escape/e, raw`
- Conditionals: `{% if %}` / `{% elseif %}` / `{% else %}` / `{% endif %}`
- Loops with a `loop` helper: `{% for x in items %}` … `{% else %}` …
  `{% endfor %}`, plus `loop.index / index0 / first / last / length`
- Variables: `{% set total = a + b %}`
- Expressions: `+ - * /`, `~` concat, `== != < > <= >=`, `and / or / not`,
  parentheses, string & number literals, `true / false / null`
- Includes: `{% include "partial.html" %}` (shares the current context)
- Template inheritance: `{% extends "base.html" %}` with
  `{% block name %}…{% endblock %}` overrides and defaults
- Comments: `{# … #}`
- Raw blocks: `{% verbatim %}…{% endverbatim %}`

See **[docs/SYNTAX.md](docs/SYNTAX.md)** for the full language reference and
**[docs/DESIGN.md](docs/DESIGN.md)** for the architecture.

## Quick start

Scribe is a single WFL library file, `src/scribe.wfl`. Because WFL's
`load module` doesn't share actions across files, you combine the engine with
your own script using the tiny bundler in `build/bundle.sh`.

```wfl
// my_app.wfl — your caller script
create map ctx:
    "name" is "World"
    "items" is ["one", "two", "three"]
end map

store out as scribe_render of "Hello {{ name }}! ({{ items | length }} items)" and ctx
display out
```

Run it:

```sh
# bundle the engine + your script, then run with the wfl binary
build/bundle.sh my_app.wfl build/my_app.run.wfl
wfl build/my_app.run.wfl
# => Hello World! (3 items)
```

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

## Running the tests

The suite uses WFL's built-in `describe` / `test` framework:

```sh
tests/run.sh /path/to/wfl
# Total: 30  Passed: 30  Failed: 0
```

`tests/run.sh` bundles `src/scribe.wfl` with `tests/scribe.test.wfl` and runs
it under `wfl --test`.

> **Note on WFL's static checker.** When you run a bundled program the WFL
> type checker prints a number of `could not infer type` notes to *stderr*.
> These are non-fatal (a limitation of type inference across user-defined
> actions) and do not affect the result — the program still runs and exits 0.
> See the roadmap for the upstream issue.

## Project layout

```
Scribe/
├── src/scribe.wfl            # the entire engine (pure library)
├── build/bundle.sh           # engine + caller -> runnable program
├── tests/scribe.test.wfl     # test suite (30 cases)
├── tests/run.sh              # bundle + run the tests
├── examples/blog.wfl         # worked example + expected output
├── examples/run.sh           # bundle + run an example
└── docs/                     # SYNTAX.md and DESIGN.md
```

## Roadmap

Planned next: multi-level inheritance, macros (`{% macro %}` / `{% import %}`),
`for key, value in map` (pending WFL map-key iteration), whitespace control, and
more filters/functions. Details in [docs/DESIGN.md](docs/DESIGN.md).

## Upstream WFL issues found while building Scribe

Building a non-trivial program in WFL surfaced a few language bugs, reported
upstream:

- [wfl#582](https://github.com/WebFirstLanguage/wfl/issues/582) — a function
  parameter is overridden by a same-named global variable. (This is why every
  engine parameter is prefixed `sc_`.)
- [wfl#583](https://github.com/WebFirstLanguage/wfl/issues/583) — the string
  value `"[]"` is coerced to an empty list.
- [wfl#584](https://github.com/WebFirstLanguage/wfl/issues/584) — actions from
  `load module` are invisible to the static analyzer, which is why Scribe ships
  as one file plus a bundler.

## License

Apache-2.0. See [LICENSE](LICENSE).
