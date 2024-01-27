defmodule Bittorrent.Bencode.DecoderTest do
  use ExUnit.Case

  alias Bittorrent.Bencode.Decoder

  describe "decode dictionary" do
    test "with empty dictionary" do
      assert {:ok, %{}, ""} == Decoder.decode("de")
    end

    test "with simple dictionary" do
      assert {:ok, %{"foo" => "bar", "hello" => 52}, ""} ==
               Decoder.decode("d3:foo3:bar5:helloi52ee")
    end

    test "with nested dictionary" do
      assert {:ok, %{"bar" => %{"foo" => 52}}, ""} ==
               Decoder.decode("d3:bard3:fooi52eee")
    end
  end

  describe "decode list" do
    test "with empty list" do
      assert {:ok, [], ""} == Decoder.decode("le")
    end

    test "with simple list" do
      assert {:ok, ["hello", 52], ""} == Decoder.decode("l5:helloi52ee")
    end

    test "with nested list" do
      assert {:ok, [[52], [[]]], ""} == Decoder.decode("lli52eelleee")
    end
  end

  describe "decode string" do
    test "with simple string" do
      assert {:ok, "spam", ""} == Decoder.decode("4:spam")
    end

    test "that contains ':'" do
      assert {:ok, "http://bittorrent-test-tracker.codecrafters.io/announce", ""} ==
               Decoder.decode("55:http://bittorrent-test-tracker.codecrafters.io/announce")
    end
  end

  describe "decode integers" do
    test "positive integers" do
      assert {:ok, 123, ""} == Decoder.decode("i123e")
    end

    test "negative integers" do
      assert {:ok, -123, ""} == Decoder.decode("i-123e")
    end
  end
end
