# GB2260

**The Elixir implementation for looking up the Chinese administrative divisions**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add gb2260 to your list of dependencies in `mix.exs`:

        def deps do
          [{:gb2260, "~> 0.2.0"}]
        end

  2. Ensure gb2260 is started before your application:

        def application do
          [applications: [:gb2260]]
        end

## Usage

More example can be found in tests.

```elixir

# build a custom divistion
beijing = GB2260.Division.build("110000", "北京市")

# get by code
beijing = GB2260.Division.get("110000", 2013)
bj_city = GB2260.Division.get("110101")

```
