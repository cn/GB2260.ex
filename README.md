# GB2260

**The Elixir implementation for looking up the Chinese administrative divisions**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add gb2260 to your list of dependencies in `mix.exs`:

        def deps do
          [{:gb2260, "~> 0.6.1"}]
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
beijing = GB2260.get("110000", "2013")
prefecture = GB2260.get("110100")
county = GB2260.get("110102")

# list all prefectures for beijing
GB2260.prefectures(beijing)

# list all counties for beijing
GB2260.counties(beijing)
GB2260.counties(prefecture)


GB2260.province(county) 
# => %GB2260.Division{code: "110000", name: "北京市", revision: "2014"}

GB2260.prefecture(county) # => 
# => %GB2260.Division{code: "110100", name: "市辖区", revision: "2014"}
```
