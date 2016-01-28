ExUnit.start()

defmodule Fixture do
  def beijing(revision \\ "2014") do
    %GB2260.Division{ code: "110000", name: "北京市", revision: revision }
  end

  def bj_city(revision \\ "2014") do
    %GB2260.Division{ code: "110100", name: "市辖区", revision: revision }
  end

  def dc_dist(revision \\ "2014") do
    %GB2260.Division{ code: "110101", name: "东城区", revision: revision }
  end
end
