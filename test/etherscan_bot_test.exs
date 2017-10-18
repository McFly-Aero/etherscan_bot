defmodule EtherscanBotTest do
  use ExUnit.Case
  doctest EtherscanBot

  test "greets the world" do
    assert EtherscanBot.hello() == :world
  end
end
