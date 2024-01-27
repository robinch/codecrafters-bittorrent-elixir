defmodule Bittorrent.BencodeTest do
  use ExUnit.Case

  alias Bittorrent.Bencode

  test "decode/1 returns the decoded value" do
    assert {:ok, "spam"} == Bencode.decode("4:spam")
  end
end
