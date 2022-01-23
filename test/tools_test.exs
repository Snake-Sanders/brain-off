defmodule ToolsTest do
  use ExUnit.Case
  doctest Tools

  test "greets the world" do
    assert Tools.hello() == :world
  end
end
