defmodule Bittorrent.Bencode.Encoder do
  def encode(string) when is_binary(string) do
    "#{byte_size(string)}:#{string}"
  end

  def encode(integer) when is_integer(integer) do
    "i#{integer}e"
  end
end
