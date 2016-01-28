defmodule GB2260Test do
  use ExUnit.Case
  doctest GB2260

  test "GB2260.get" do
    assert GB2260.get("110000") == Fixture.beijing
    assert GB2260.get("110000", 2013) == Fixture.beijing(2013)
  end

  test "all provinces" do
    assert Enum.member?(GB2260.provinces, Fixture.beijing)
    assert !Enum.member?(GB2260.provinces, Fixture.bj_city)
    assert !Enum.member?(GB2260.provinces, Fixture.dc_dist)

    assert Enum.member?(GB2260.provinces(2013), Fixture.beijing(2013))
    assert !Enum.member?(GB2260.provinces(2013), Fixture.bj_city(2013))
    assert !Enum.member?(GB2260.provinces(2013), Fixture.dc_dist(2013))
  end

  test "get structs by batch" do
    result = [ Fixture.beijing, Fixture.bj_city, Fixture.dc_dist ]
    assert GB2260.batch(["110000", "110100", "110101"]) == result

    result_2013 = [
      Fixture.beijing(2013),
      Fixture.bj_city(2013),
      Fixture.dc_dist(2013)
    ]
    assert GB2260.batch(["110000", "110100", "110101"], 2013) == result_2013
  end

  test "get all provinces for specify revision" do
    assert Enum.member?(GB2260.provinces, Fixture.beijing)
  end

  test "get all prefectures for specify revision" do
    beijing = Fixture.beijing

    assert Enum.member?(GB2260.prefectures(beijing), Fixture.bj_city)
  end

  test "get all counties for specify revision" do
    bj_city = Fixture.bj_city
    dc_dist = Fixture.dc_dist

    assert Enum.member?(GB2260.counties(bj_city), dc_dist)
  end

  test "get a province" do
    beijing = Fixture.beijing
    beijing_2013 = Fixture.beijing(2013)

    assert Fixture.beijing |> GB2260.province == beijing
    assert Fixture.bj_city |> GB2260.province == beijing
    assert Fixture.dc_dist |> GB2260.province == beijing

    assert Fixture.beijing(2013) |> GB2260.province == beijing_2013
    assert Fixture.bj_city(2013) |> GB2260.province == beijing_2013
    assert Fixture.dc_dist(2013) |> GB2260.province == beijing_2013
  end

  test "is_province?" do
    assert GB2260.is_province?(Fixture.beijing)
    assert !GB2260.is_province?(Fixture.bj_city)
  end

  test "get a prefecture" do
    bj_city = Fixture.bj_city

    assert Fixture.beijing |> GB2260.prefecture == nil
    assert Fixture.bj_city |> GB2260.prefecture == bj_city
    assert Fixture.dc_dist |> GB2260.prefecture == bj_city

    assert Fixture.beijing(2013) |> GB2260.prefecture == nil
    assert Fixture.bj_city(2013) |> GB2260.prefecture == Fixture.bj_city(2013)
    assert Fixture.dc_dist(2013) |> GB2260.prefecture == Fixture.bj_city(2013)
  end

  test "is_prefecture?" do
    assert !GB2260.is_prefecture?(Fixture.beijing)
    assert GB2260.is_prefecture?(Fixture.bj_city)
  end

  test "get a county" do
    dc_dist = Fixture.dc_dist

    assert Fixture.beijing |> GB2260.county == nil
    assert Fixture.bj_city |> GB2260.county == nil
    assert Fixture.dc_dist |> GB2260.county == dc_dist

    assert Fixture.beijing(2013) |> GB2260.county == nil
    assert Fixture.bj_city(2013) |> GB2260.county == nil
    assert Fixture.dc_dist(2013) |> GB2260.county == Fixture.dc_dist(2013)
  end
end
