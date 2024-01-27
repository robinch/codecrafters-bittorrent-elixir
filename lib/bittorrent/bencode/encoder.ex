defmodule Bittorrent.Bencode.Encoder do
  def encode(string) when is_binary(string) do
    "#{byte_size(string)}:#{string}"
  end

  def encode(integer) when is_integer(integer) do
    "i#{integer}e"
  end

  def encode(list) when is_list(list) do
    do_encode_list(list, "")
  end

  defp do_encode_list([], acc) do
    "l#{acc}e"
  end

  defp do_encode_list([value | rest], acc) do
    do_encode_list(rest, "#{acc}#{encode(value)}")
  end
end
