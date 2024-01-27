defmodule Bittorrent.CLI do
  alias Bittorrent.Bencode
  alias Bittorrent.Metainfo
  alias Bittorrent.Tracker

  def main(argv) do
    case argv do
      ["decode", encoded_str | _] ->
        decode(encoded_str)

      ["info", file_path | _] ->
        info(file_path)

      ["peers", file_path | _] ->
        peers(file_path)

      [command | _] ->
        IO.puts("Unknown command: #{command}")
        System.halt(1)

      [] ->
        IO.puts("Usage: your_bittorrent.sh <command> <args>")
        System.halt(1)
    end
  end

  defp decode(encoded_str) do
    {:ok, decoded_str, _} = Bencode.decode(encoded_str)

    decoded_str
    |> Jason.encode!()
    |> IO.puts()
  end

  defp info(file_path) do
    metainfo = Metainfo.from_file(file_path)

    info_hash =
      metainfo.info_hash
      |> Base.encode16()
      |> String.downcase()

    piece_hashes =
      metainfo.info.piece_hashes
      |> Enum.map(&Base.encode16/1)
      |> Enum.map(&String.downcase/1)

    IO.puts("Tracker URL: #{metainfo.announce}")

    IO.puts("Length: #{metainfo.info.length}")
    IO.puts("Info Hash: #{info_hash}")
    IO.puts("Piece Length: #{metainfo.info.piece_length}")
    IO.puts("Piece Hashes:")
    Enum.each(piece_hashes, &IO.puts/1)
  end

  defp peers(file_path) do
    metainfo = Metainfo.from_file(file_path)

    response = Tracker.Client.get(metainfo)

    peers = Enum.map(response.peers, fn {ip, port} -> "#{ip}:#{port}" end)

    Enum.each(peers, &IO.puts/1)
  end
end
