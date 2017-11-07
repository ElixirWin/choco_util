defmodule ChocoUtilTest do
  use ExUnit.Case
  doctest ChocoUtil

  test "greets the world" do
    assert ChocoUtil.hello() == :world
  end
end
