defmodule Bittorrent.CLI do
  alias Bittorrent.Bencode
  alias Bittorrent.Metainfo
  alias Bittorrent.Tracker
  alias Bittorrent.Peer

  def main(argv) do
    case argv do
      ["decode", encoded_str | _] ->
        decode(encoded_str)

      ["info", file_path | _] ->
        info(file_path)

      ["peers", file_path | _] ->
        peers(file_path)

      ["handshake", file_path, address | _] ->
        handshake(file_path, address)

      ["download_piece", "-o", output_file_path, torrent_file_path, piece | _] ->
        download_piece(torrent_file_path, String.to_integer(piece), output_file_path)

      ["download", "-o", output_file_path, torrent_file_path | _] ->
        download(torrent_file_path, output_file_path)

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

    piece_hashes =
      metainfo.info.piece_hashes
      |> Enum.map(&to_hex/1)

    IO.puts("Tracker URL: #{metainfo.announce}")

    IO.puts("Length: #{metainfo.info.length}")
    IO.puts("Info Hash: #{to_hex(metainfo.info_hash)}")
    IO.puts("Piece Length: #{metainfo.info.piece_length}")
    IO.puts("Piece Hashes:")
    Enum.each(piece_hashes, &IO.puts/1)
  end

  defp peers(file_path) do
    metainfo = Metainfo.from_file(file_path)

    {:ok, response} = Tracker.Client.get(metainfo)

    peers = Enum.map(response.peers, fn {ip, port} -> "#{ip}:#{port}" end)

    Enum.each(peers, &IO.puts/1)
  end

  defp handshake(file_path, address) do
    metainfo = Metainfo.from_file(file_path)
    {:ok, _socket, peer_id} = Peer.handshake(metainfo, address)
    IO.puts("Peer ID: #{to_hex(peer_id)}")
  end

  defp download_piece(torrent_file_path, piece, output_file_path) do
    metainfo = Metainfo.from_file(torrent_file_path)
    {:ok, downloaded_piece} = Peer.download_piece(metainfo, piece)
    :ok = File.write(output_file_path, downloaded_piece)
    IO.puts("Piece #{piece} downloaded to #{output_file_path}.")
  end

  defp download(torrent_file_path, output_file_path) do
    metainfo = Metainfo.from_file(torrent_file_path)
    {:ok, file} = Peer.download(metainfo)
    :ok = File.write(output_file_path, file)
    IO.puts("Downloaded #{torrent_file_path} to #{output_file_path}.")
  end

  defp to_hex(binary) do
    binary
    |> Base.encode16()
    |> String.downcase()
  end
end
