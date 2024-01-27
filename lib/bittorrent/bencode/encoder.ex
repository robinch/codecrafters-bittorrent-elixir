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

  def encode(map) when is_map(map) do
    do_encode_dictionary(map)
  end

  defp do_encode_list([], acc) do
    "l#{acc}e"
  end

  defp do_encode_list([value | rest], acc) do
    do_encode_list(rest, "#{acc}#{encode(value)}")
  end

  defp do_encode_dictionary(map) do
    content =
      Enum.reduce(map, "", fn {key, value}, acc ->
        "#{acc}#{encode(key)}#{encode(value)}"
      end)

    "d#{content}e"
  end
end
