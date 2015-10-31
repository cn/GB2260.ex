defmodule GB2260.DivisionTest do
  use ExUnit.Case
  alias GB2260.Division

  doctest GB2260.Division

  test "build Division struct" do
    assert Division.build("110000", "北京市") == Fixture.beijing
    assert Division.build("110000", "北京市", 2013) == Fixture.beijing(2013)
  end

  test "get structs by batch" do
    result = [ Fixture.beijing, Fixture.bj_city, Fixture.dc_dist ]
    assert Division.batch(["110000", "110100", "110101"]) == result

    result_2013 = [
      Fixture.beijing(2013),
      Fixture.bj_city(2013),
      Fixture.dc_dist(2013)
    ]
    assert Division.batch(["110000", "110100", "110101"], 2013) == result_2013
  end

  test "get a province" do
    beijing = Fixture.beijing
    beijing_2013 = Fixture.beijing(2013)

    assert Fixture.beijing |> Division.province == beijing
    assert Fixture.bj_city |> Division.province == beijing
    assert Fixture.dc_dist |> Division.province == beijing

    assert Fixture.beijing(2013) |> Division.province == beijing_2013
    assert Fixture.bj_city(2013) |> Division.province == beijing_2013
    assert Fixture.dc_dist(2013) |> Division.province == beijing_2013
  end

  test "is_province?" do
    assert Division.is_province?(Fixture.beijing)
    assert !Division.is_province?(Fixture.bj_city)
  end

  test "get a prefecture" do
    bj_city = Fixture.bj_city

    assert Fixture.beijing |> Division.prefecture == nil
    assert Fixture.bj_city |> Division.prefecture == bj_city
    assert Fixture.dc_dist |> Division.prefecture == bj_city

    assert Fixture.beijing(2013) |> Division.prefecture == nil
    assert Fixture.bj_city(2013) |> Division.prefecture == Fixture.bj_city(2013)
    assert Fixture.dc_dist(2013) |> Division.prefecture == Fixture.bj_city(2013)
  end

  test "is_prefecture?" do
    assert !Division.is_prefecture?(Fixture.beijing)
    assert Division.is_prefecture?(Fixture.bj_city)
  end

  test "get a county" do
    dc_dist = Fixture.dc_dist

    assert Fixture.beijing |> Division.county == nil
    assert Fixture.bj_city |> Division.county == nil
    assert Fixture.dc_dist |> Division.county == dc_dist

    assert Fixture.beijing(2013) |> Division.county == nil
    assert Fixture.bj_city(2013) |> Division.county == nil
    assert Fixture.dc_dist(2013) |> Division.county == Fixture.dc_dist(2013)
  end

  test "prefectures" do
    assert Enum.member?(Division.prefectures(Fixture.beijing), Fixture.bj_city)
    assert !Enum.member?(Division.prefectures(Fixture.beijing), Fixture.dc_dist)
  end

  test "counties" do
    assert Enum.member?(Division.counties(Fixture.bj_city), Fixture.dc_dist)
    assert !Enum.member?(Division.counties(Fixture.bj_city), Fixture.beijing)
  end
end
