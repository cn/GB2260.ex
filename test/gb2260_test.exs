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

  test "all prefectures" do
    assert !Enum.member?(GB2260.prefectures, Fixture.beijing)
    assert Enum.member?(GB2260.prefectures, Fixture.bj_city)
    assert !Enum.member?(GB2260.prefectures, Fixture.dc_dist)

    assert !Enum.member?(GB2260.prefectures(2013), Fixture.beijing(2013))
    assert Enum.member?(GB2260.prefectures(2013), Fixture.bj_city(2013))
    assert !Enum.member?(GB2260.prefectures(2013), Fixture.dc_dist(2013))
  end

  test "all counties" do
    assert !Enum.member?(GB2260.counties, Fixture.beijing)
    assert !Enum.member?(GB2260.counties, Fixture.bj_city)
    assert Enum.member?(GB2260.counties, Fixture.dc_dist)

    assert !Enum.member?(GB2260.counties(2013), Fixture.beijing(2013))
    assert !Enum.member?(GB2260.counties(2013), Fixture.bj_city(2013))
    assert Enum.member?(GB2260.counties(2013), Fixture.dc_dist(2013))
  end
end
