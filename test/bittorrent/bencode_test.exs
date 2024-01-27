defmodule Bittorrent.BencodeTest do
  use ExUnit.Case

  alias Bittorrent.Bencode

  describe "decode string" do
    test "with simple string" do
      assert {:ok, "spam"} == Bencode.decode("4:spam")
    end

    test "that contains ':'" do
      assert {:ok, "http://bittorrent-test-tracker.codecrafters.io/announce"} ==
               Bencode.decode("55:http://bittorrent-test-tracker.codecrafters.io/announce")
    end
  end
  end
end
