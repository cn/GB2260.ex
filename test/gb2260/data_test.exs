defmodule GB2260.DataTest do
  use ExUnit.Case

  doctest GB2260.Data
  alias GB2260.Data

  test "return last revision" do
    assert Data.last_revision == 2014
  end

  test "beijing" do
    assert Data.fetch("110000", 2014) == "北京市"
  end
end
