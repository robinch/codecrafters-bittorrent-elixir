defmodule Bittorrent.Bencode.EncoderTest do
  use ExUnit.Case

  alias Bittorrent.Bencode.Encoder

  describe "encode string" do
    test "with simple string" do
      assert "5:hello" == Encoder.encode("hello")
    end
  end
end
