defmodule Bittorrent.Bencode do
  require Logger
  alias Bittorrent.Bencode.Decoder

  def decode(encoded_value), do: Decoder.decode(encoded_value)
end
