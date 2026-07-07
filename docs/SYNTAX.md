# Scribe Template Syntax

Scribe templates are plain text with three kinds of markup, borrowed from
Twig / Jinja:

| Markup | Purpose |
| --- | --- |
| `{{ expression }}` | Print a value (HTML-escaped by default) |
| `{% tag %}` | Logic: `if`, `for`, `set`, `verbatim` |
| `{# comment #}` | A comment — never rendered |

Everything else is literal text and is copied to the output verbatim.

---

## Printing values — `{{ ... }}`

```twig
Hello {{ name }}!
{{ user.email }}
{{ items.0 }}
{{ price * quantity }}
```

* The result is **HTML-escaped** (`< > & " '`). This is on by default and is
  the recommended, secure behaviour.
* To emit trusted HTML unescaped, pipe through the `raw` filter:
  `{{ content | raw }}`.

### Variables and paths

A bare name (`title`) is looked up first in the local scope (loop variables,
`{% set %}`), then in the context you passed to `scribe_render`.

Dotted paths walk into nested data:

```twig
{{ user.address.city }}   {# nested maps #}
{{ tags.0 }}              {# list index (0-based) #}
```

A path segment that doesn't exist yields *nothing*, which prints as an empty
string — templates don't crash on missing data.

### Filters

Filters transform a value and chain left-to-right with `|`:

```twig
{{ name | upper }}
{{ title | lower | trim }}
{{ price | round }}
{{ items | join(', ') }}
{{ bio | default('No bio provided') }}
```

Built-in filters:

| Filter | Effect |
| --- | --- |
| `upper` | Uppercase |
| `lower` | Lowercase |
| `capitalize` | First letter uppercase, rest lowercase |
| `title` | Capitalize the first letter of each word |
| `trim` | Strip leading/trailing whitespace |
| `length` | Length of a list or string |
| `reverse` | Reverse a list or string |
| `first` / `last` | First / last element (list) or character (string) |
| `join(sep)` | Join a list into a string with `sep` |
| `default(fallback)` | Use `fallback` when the value is empty/nothing |
| `replace(from, to)` | Replace every `from` with `to` |
| `abs` / `round` | Numeric absolute value / rounding |
| `escape` / `e` | Explicitly HTML-escape (safe against double-escaping) |
| `raw` | Opt out of auto-escaping for this value |

### Expressions

Inside `{{ }}` and in `if` / `for` / `set` you can write:

* **Literals:** `"double"` or `'single'` strings, numbers (`42`, `3.14`),
  `true`, `false`, `null`.
* **Operators:** `+ - * /`, `~` (string concatenation), comparisons
  `== != < > <= >=`, and logic `and`, `or`, `not`.
* **Grouping:** parentheses `( … )`.

```twig
{{ 'Hi ' ~ user.name }}
{{ (a + b) * 2 }}
```

---

## Conditionals — `{% if %}`

```twig
{% if user.admin %}
  Welcome, boss.
{% elseif user.member %}
  Welcome back.
{% else %}
  Please sign in.
{% endif %}
```

Truthiness: `nothing`, `false`, `0`, `""`, empty lists and empty maps are
false; everything else is true.

---

## Loops — `{% for %}`

```twig
<ul>
{% for item in items %}
  <li>{{ loop.index }}. {{ item.name }}</li>
{% else %}
  <li>Nothing here yet.</li>
{% endfor %}
</ul>
```

* Iterates a list. The optional `{% else %}` block renders when the list is
  empty (or the value isn't a list).
* Inside the loop, a `loop` object is available:

| Field | Meaning |
| --- | --- |
| `loop.index` | 1-based position |
| `loop.index0` | 0-based position |
| `loop.first` | `true` on the first item |
| `loop.last` | `true` on the last item |
| `loop.length` | total number of items |

---

## Assignment — `{% set %}`

```twig
{% set full_name = user.first ~ ' ' ~ user.last %}
{{ full_name }}
```

`set` binds a variable in the current scope. Inside a `for` loop the binding
is scoped to the loop body.

---

## Comments — `{# ... #}`

```twig
{# This note is for template authors only and never reaches the output. #}
```

---

## Includes — `{% include %}`

Render another template file inline, sharing the current context:

```twig
<body>
  {{ content }}
  {% include "partials/footer.html" %}
</body>
```

The path is an expression, so `{% include partial_name %}` (a variable) works
too. Paths are resolved relative to the process's working directory.

## Template inheritance — `{% extends %}` / `{% block %}`

A **base** template defines named blocks with default content:

```twig
{# base.html #}
<!doctype html>
<title>{% block title %}My Site{% endblock %}</title>
<body>
  <main>{% block content %}{% endblock %}</main>
  {% include "footer.html" %}
</body>
```

A **child** template extends the base and overrides the blocks it cares about;
any block it leaves out keeps the base's default:

```twig
{% extends "base.html" %}
{% block title %}Home{% endblock %}
{% block content %}
  <h1>Welcome</h1>
{% endblock %}
```

`{% extends %}` must name the parent template; the child's content outside of
`{% block %}` tags is ignored (as in Twig). A single level of inheritance is
supported.

## Verbatim — `{% verbatim %}`

Emit Scribe syntax literally, without interpreting it:

```twig
{% verbatim %}
  Here is how you print a variable: {{ name }}
{% endverbatim %}
```

Everything between `{% verbatim %}` and `{% endverbatim %}` is copied as-is.

---

## Calling the engine from WFL

```wfl
create map ctx:
    "name" is "World"
end map

store out as scribe_render of "Hello {{ name }}!" and ctx
display out
// => Hello World!
```

Or render a template file:

```wfl
store out as scribe_render_file of "templates/page.html" and ctx
```

The context is an ordinary WFL map. Nest maps and lists to build richer data;
paths in the template walk them.

---

## Known limitations (current version)

* Template inheritance is single-level: a child `{% extends %}` a base, but the
  base cannot itself extend a grandparent yet. Macros are not yet implemented —
  see the roadmap in [DESIGN.md](DESIGN.md).
* `for key, value in map` is not supported (WFL does not expose map-key
  iteration); iterate lists instead.
* A rendered result that is exactly the two characters `[]` is affected by a
  WFL runtime quirk (a string equal to `[]` is coerced to an empty list). Any
  surrounding content avoids it. This is tracked upstream.
