# Apprentice

You're the sorcerer, let your apprentice do the dirty work.

Apprentice will watch you files for you and execute arbitrary code on your
behalf.  Apprentice currently comes with `Apprentice.ExUnit` to run your tests
and `Apprentice.Handlebars`

## To use Apprentice:

Add it to your deps

```elixir
{ :apprentice, github: "ElixirCasts/apprentice" }
```

Install and edit the `workshop.exs` template

```bash
mix apprentice.install
```

Have your apprentices watch your files

```bash
mix apprentice
```

## Limitations

* This is a very early release, it needs work
* This library currently only works on OSX

## Contribute

Fork the repo
Clone the repo
Run the tests: `mix apprentice` or `mix test`
Submit a pull request
