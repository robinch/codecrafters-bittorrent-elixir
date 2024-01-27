defmodule Bittorrent.Bencode do
  def decode(encoded_value) when is_binary(encoded_value) do
    binary_data = :binary.bin_to_list(encoded_value)

    case Enum.find_index(binary_data, fn char -> char == 58 end) do
      nil ->
        IO.puts("The ':' character is not found in the binary")

      index ->
        rest = Enum.slice(binary_data, (index + 1)..-1)
        List.to_string(rest)
    end
  end

  def decode(_), do: "Invalid encoded value: not binary"
end
