# Scribe — Design Document

Scribe is a **Twig-inspired templating engine written entirely in
[WFL](https://github.com/WebFirstLanguage/wfl)** (the WebFirst Language), a
natural-language programming language. Scribe follows WFL's 19 foundational
principles: it reads like English, minimizes special characters where it can,
reports clear errors, and — most importantly for a templating engine — is
**secure by default** (HTML auto-escaping on every interpolation).

This document describes the architecture, the template syntax, the WFL
constraints that shaped the design, and the roadmap.

---

## 1. Goals

1. **Familiar syntax.** If you know Twig / Jinja / Liquid, Scribe reads the
   same: `{{ output }}`, `{% logic %}`, `{# comments #}`.
2. **Secure by default.** Every `{{ ... }}` is HTML-escaped unless you
   explicitly opt out with the `raw` filter. This upholds WFL Principle 8
   (*Built-in Security Features*).
3. **Written in and idiomatic to WFL.** No Rust, no host-language escape
   hatch. Scribe is a pure WFL library, so it runs anywhere WFL runs and
   serves as a substantial, real-world WFL program.
4. **Small, readable, well-tested core** that can grow toward full Twig
   parity without rewrites.

## 2. The pipeline

Scribe uses the classic three-stage templating pipeline:

```
template text
     │
     ▼
  ┌───────┐   list of tokens    ┌────────┐   AST (list of nodes)   ┌──────────┐
  │ Lexer │ ──────────────────▶ │ Parser │ ──────────────────────▶ │ Renderer │ ──▶ output text
  └───────┘                     └────────┘                         └──────────┘
                                                                        ▲
                                                                   context (data)
```

* **Lexer** (`scribe_lex`) — a hand-written character scanner that splits the
  raw template into a flat list of tokens: literal text, `{{ output }}`,
  `{% tag %}`, and `{# comment #}`. Hand-rolled (rather than using WFL's
  pattern engine) so we control delimiter handling, whitespace, and errors
  precisely.
* **Parser** (`scribe_parse`) — turns the flat token list into a tree of
  nodes. Block tags (`if`, `for`, `verbatim`) recurse: their bodies are
  themselves lists of nodes. Produces a small, uniform AST.
* **Renderer** (`scribe_render_nodes`) — walks the AST against a *context*
  and produces the final string. Handles auto-escaping, filters, loop
  variables, and scope.

The public entry points are:

| Action | Purpose |
| --- | --- |
| `scribe_render of template and context` | Render a template string with a context map. Returns the output text. |
| `scribe_render_file of path and context` | Read a template file from disk, then render it. |

## 3. Data representation (and why)

WFL's value model shaped every structural decision. The relevant facts:

* **Maps are creation-time literals.** `create map` takes static string keys
  with dynamic values. There is **no** `map[key] as value` assignment and no
  stdlib setter — a map cannot grow or mutate a key after it is built. Reading
  a missing key *throws*, so every dynamic read is guarded with `contains`.
* **Lists are append + read.** `push with list and x` appends; `pop of list`
  removes the last element. You **cannot** assign `list[i] as x`.
* **Iterating a map yields its values only** — the keys are not recoverable at
  runtime.

Consequences for Scribe:

* **Tokens and AST nodes are maps with fixed key sets.** e.g. a text token is
  `{ "kind": "text", "text": "..." }`; an output node is
  `{ "kind": "output", "expr": <expr-node>, "raw": no }`. Static keys, dynamic
  values — exactly what `create map` supports. Nodes nest by storing child
  node **lists** under a key (`"body"`, `"else_body"`).
* **The render context is a map** supplied by the caller (JSON-shaped: maps,
  lists, text, numbers, booleans, nothing). Variables are looked up *by name
  from the template*, so we never need to enumerate the map's keys.
* **The mutable scope is an overlay, not the context.** Loop variables and
  `{% set %}` bindings can't be written into the immutable context map.
  Instead Scribe keeps a **scope**: a list of binding maps
  `{ "name": ..., "value": ... }`. Defining a variable *pushes* a binding;
  lookup scans from the newest binding backward (so inner scopes shadow outer
  ones); leaving a block *pops* bindings back to a saved depth. Lookups that
  miss the scope fall back to the context map.

This overlay-scope-over-immutable-context design is the heart of Scribe and is
the cleanest structure that WFL's value semantics allow.

## 4. Template syntax

### 4.1 Output — `{{ ... }}`

```twig
Hello {{ name }}!
Total: {{ order.total }}
{{ user.name | upper }}
```

* Auto-escaped for HTML by default (`<`, `>`, `&`, `"`, `'`).
* Dot paths walk into nested maps and lists (`order.items.0.title`).
* Filters chain with `|`.

### 4.2 Comments — `{# ... #}`

```twig
{# this never appears in the output #}
```

### 4.3 Tags — `{% ... %}`

| Tag | Form |
| --- | --- |
| Conditionals | `{% if EXPR %}` … `{% elseif EXPR %}` … `{% else %}` … `{% endif %}` |
| Loops | `{% for x in EXPR %}` … `{% else %}` (when empty) … `{% endfor %}` |
| Assignment | `{% set name = EXPR %}` |
| Include | `{% include "path" %}`, optionally `… with { key: EXPR, … } [only]` |
| Macros | `{% macro name(a, b) %}…{% endmacro %}`, called as `{{ name(x, y) }}` |
| Import | `{% import "path" as ns %}` / `{% from "path" import a, b %}` |
| Inheritance | `{% extends "base" %}` + `{% block name %}` … `{% endblock %}` (multi-level) |
| Raw block | `{% verbatim %}` … `{% endverbatim %}` (emits its body literally) |

Inside a `{% for %}` body a `loop` variable is available:

| Field | Meaning |
| --- | --- |
| `loop.index` | 1-based iteration number |
| `loop.index0` | 0-based iteration number |
| `loop.first` | `yes` on the first item |
| `loop.last` | `yes` on the last item |
| `loop.length` | total number of items |

### 4.4 Expressions

Expressions appear in `{{ ... }}` and in `if` / `elseif` / `for` / `set`.

* **Literals:** `"double"` or `'single'` quoted strings, numbers (`42`,
  `3.14`), `true` / `false`, `null`.
* **Variables & paths:** `name`, `user.name`, `items.0`.
* **Filters:** `value | filter`, `value | filter(arg, ...)`, chained.
* **Operators:** `==`, `!=`, `<`, `>`, `<=`, `>=`, `and`, `or`, `not`, and
  arithmetic `+ - * /`.
* **Grouping:** parentheses `( ... )`.

### 4.5 Filters (built-in)

`upper`, `lower`, `capitalize`, `title`, `trim`, `length`, `reverse`,
`first`, `last`, `join(sep)`, `default(fallback)`, `replace(from, to)`,
`abs`, `round`, `truncate(len, suffix)`, `striptags`, `date(format)`,
`asset(base)`, `url(base)`, `markdown`, `escape` / `e`, `raw`.

## 5. Truthiness

`if` conditions and boolean operators use Scribe's own truthiness rule
(implemented explicitly, because WFL's type checker rejects non-boolean
conditions):

* `nothing` / missing → false
* `false` → false, `true` → true
* `0` → false, any other number → true
* `""` (empty text) → false, any other text → true
* empty list / empty map → false, non-empty → true

## 6. Auto-escaping & security

`{{ ... }}` HTML-escapes its result. Escaping maps
`& < > " '` to `&amp; &lt; &gt; &quot; &#39;`. To emit trusted markup, opt
out per-expression with the `raw` filter: `{{ body | raw }}`. There is no
global "unsafe" switch — opting out is always explicit and local, which is the
secure default WFL Principle 8 asks for.

## 7. WFL constraints encountered (and worked around)

| Constraint | Impact | Work-around |
| --- | --- | --- |
| Maps are immutable after creation | Can't use a map as a mutable scope | Overlay scope built from a list of binding maps |
| No `list[i] as x` assignment | Can't patch a list element | Build lists append-only; rebuild when needed |
| Iterating a map yields values, not keys | Can't enumerate context keys | Look variables up by name; never enumerate |
| Value-returning calls need `name of a and b` (the `with a and b` form mis-parses `a and b` as a logical `and`) | API ergonomics | Every internal/public value call uses the `of … and …` form |
| Type checker rejects non-boolean `check if` conditions | Can't rely on implicit truthiness | Explicit `scribe_truthy` helper returns a real boolean |
| Sharing actions across files | Splitting engine from callers | Callers pull the engine in with `include from "…/scribe.wfl"`, which exposes its actions (unlike `load module`, whose scope is isolated) |
| A variable can't be `store`d twice in sibling branches, and `create list` can't run twice in a loop | Shapes control flow | Hoist the declaration and use `change`; reset lists with `change x to []` |

### WFL bugs found and reported (now fixed upstream)

Building Scribe surfaced two correctness bugs in WFL that were reported and
then fixed:

| Bug | Symptom | Status |
| --- | --- | --- |
| [wfl#582](https://github.com/WebFirstLanguage/wfl/issues/582) — a function parameter that shares a name with an existing **global** was overridden by the global's value | Any user global colliding with an engine parameter silently corrupted rendering | **Fixed upstream.** Scribe still prefixes every parameter with `sc_` defensively (harmless, and keeps it working on older WFL builds). |
| [wfl#583](https://github.com/WebFirstLanguage/wfl/issues/583) — the string value `"[]"` was coerced to an empty list | A rendered result equal to `[]` came back as a list | **Fixed upstream.** Independently, `scribe_to_text` now renders an empty collection as empty text (matching Twig), so a bare `{{ empty_list }}` never emits the literal `[]` in the first place. |

A third report, [wfl#584](https://github.com/WebFirstLanguage/wfl/issues/584)
(`load module` symbols invisible to the analyzer), was resolved by pointing
users at the `include from` construct, which is exactly how Scribe now loads
its engine.

## 8. Repository layout

```
Scribe/
├── src/scribe.wfl        # the entire engine (pure library: actions only)
├── tests/                # describe/test suite (pulls in the engine via include from)
├── examples/             # example templates + runnable demos with expected output
├── docs/                 # this design doc + the syntax reference
└── README.md
```

The engine lives in a single self-contained file. Callers (tests, examples,
your own programs) pull it in with `include from "…/scribe.wfl"`, which runs
the engine file and exposes its actions to the caller. The path is resolved
relative to the including file's directory.

## 9. Roadmap

Implemented: lexer, parser, renderer, expressions with filters and operators,
`if`/`for`/`set`/`verbatim`, `loop` variables, auto-escaping, the built-in
filter set, `{% include %}` (with an optional scoped `with { … } [only]`
context), **multi-level** `{% extends %}` / `{% block %}`, **macros**
(`{% macro %}`, `{% import … as %}`, `{% from … import %}`), and a test suite.

Template inheritance is threaded through the overlay scope. Rendering walks the
whole `extends` chain from the leaf child up to the root ancestor, binding each
level's `{% block %}` bodies as a scope binding named `"__scblock__<name>"` —
first (most-derived) definition wins. The root ancestor is then rendered, and
each `{% block %}` resolves to the collected override (or its own default). A
block override may itself contain blocks, which is how a mid-level theme layer
exposes new insertion points to the child.

Macros are stored as scope bindings whose value is a macro map
(`{ "__scribe_macro__": yes, "params": [...], "body": [...] }`). Definitions are
*hoisted* into scope before a node list renders, so a macro can be called before
its textual position. A call in an expression — `{{ name(args) }}` — is parsed
as a postfix `(` after a name/member and dispatched to the macro; its output is
marked safe so it isn't escaped a second time. `{% import "f" as ns %}` binds a
**namespace** value (a list of macro bindings) that member access resolves into;
`{% from "f" import a, b %}` binds the named macros directly.

Includes read and render another file against the current context and scope; a
`with { … }` clause pushes extra bindings for the partial's duration (popped
afterward), and `only` renders the partial against just those bindings.

Planned next:

* **`for key, value in map`** once WFL exposes map-key iteration.
* **Whitespace control** (`{{-` / `-}}`).
* **More filters & functions:** `number_format`, `slice`, `batch`, `range()`,
  `min`, `max`.
