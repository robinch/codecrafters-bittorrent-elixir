defmodule Bittorrent.Bencode.Encoder do
  def encode(string) when is_binary(string) do
    "#{byte_size(string)}:#{string}"
  end
end
