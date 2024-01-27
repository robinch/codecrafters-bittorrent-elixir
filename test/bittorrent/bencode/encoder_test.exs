defmodule Bittorrent.Bencode.EncoderTest do
  use ExUnit.Case

  alias Bittorrent.Bencode.Encoder

  describe "encode string" do
    test "with simple string" do
      assert "5:hello" == Encoder.encode("hello")
    end
  end

  describe "encode integers" do
    test "positive integers" do
      assert "i123e" == Encoder.encode(123)
    end

    test "negative integers" do
      assert "i-123e" == Encoder.encode(-123)
    end
  end

  describe "encode list" do
    test "with empty list" do
      assert "le" == Encoder.encode([])
    end

    test "with simple list" do
      assert "l5:helloi52ee" == Encoder.encode(["hello", 52])
    end


    test "with nested list" do
      assert "lli52eelleee" == Encoder.encode([[52], [[]]])
    end
  end
end
