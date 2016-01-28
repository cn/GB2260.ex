defmodule GB2260.DivisionTest do
  use ExUnit.Case
  alias GB2260.Division

  doctest GB2260.Division

  test "build Division struct" do
    assert Division.build("110000", "北京市") == Fixture.beijing
    assert Division.build("110000", "北京市", "2013") == Fixture.beijing("2013")
  end
end
