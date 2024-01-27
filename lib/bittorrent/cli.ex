defmodule Bittorrent.CLI do
  alias Bittorrent.Bencode

  def main(argv) do
    case argv do
      ["decode", encoded_str | _] ->
        {:ok, decoded_str, _} = Bencode.decode(encoded_str)

        decoded_str
        |> Jason.encode!()
        |> IO.puts()

      ["info", file_path | _] ->
        info(file_path)

      [command | _] ->
        IO.puts("Unknown command: #{command}")
        System.halt(1)

      [] ->
        IO.puts("Usage: your_bittorrent.sh <command> <args>")
        System.halt(1)
    end
  end

  defp info(file_path) do
    {:ok, binary} = File.read(file_path)
    content = IO.iodata_to_binary(binary)

    {:ok, decoded_content, _} = Bencode.decode(content)

    info_hash =
      decoded_content["info"]
      |> Bencode.encode()
      |> sha1_encode()

    pieces =
      decoded_content["info"]["pieces"]
      |> split_every_n_bytes(20)
      |> Enum.map(&Base.encode16/1)
      |> Enum.map(&String.downcase/1)

    IO.puts("Tracker URL: #{decoded_content["announce"]}")

    IO.puts("Length: #{decoded_content["info"]["length"]}")
    IO.puts("Info Hash: #{info_hash}")
    IO.puts("Piece Length: #{decoded_content["info"]["piece length"]}")
    IO.puts("Piece Hashes:")
    Enum.each(pieces, &IO.puts/1)
  end

  defp sha1_encode(binary) do
    :crypto.hash(:sha, binary)
    |> Base.encode16()
    |> String.downcase()
  end

  defp split_every_n_bytes(binary, n) do
    do_split(binary, n, [])
  end

  defp do_split(<<>>, _n, acc), do: Enum.reverse(acc)

  defp do_split(binary, n, acc) do
    <<chunk::binary-size(n), rest::binary>> = binary
    do_split(rest, n, [chunk | acc])
  end
end
