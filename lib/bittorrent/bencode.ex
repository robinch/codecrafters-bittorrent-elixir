defmodule Bittorrent.Bencode do
  require Logger
  alias Bittorrent.Bencode.{Decoder, Encoder}

  def decode(encoded_value), do: Decoder.decode(encoded_value)

  def encode(value), do: Encoder.encode(value)
end
