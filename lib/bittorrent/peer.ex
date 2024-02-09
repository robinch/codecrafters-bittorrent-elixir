defmodule Bittorrent.Peer do
  # The handshake is a message consisting of the following parts as described in the peer [peer protocol](https://www.bittorrent.org/beps/bep_0003.html#peer-protocol)
  # length of the protocol string (BitTorrent protocol) which is 19 (1 byte)
  # the string BitTorrent protocol (19 bytes)
  # eight reserved bytes, which are all set to zero (8 bytes)
  # sha1 infohash (20 bytes) (NOT the hexadecimal representation, which is 40 bytes long)
  # peer id (20 bytes) (you can use 00112233445566778899 for this challenge)

  alias Bittorrent.Tracker
  require Logger

  @handshake_length 1 + 19 + 8 + 20 + 20
  @unchoked 1
  @interested 2
  @bitfield 5
  @request 6
  @piece 7
  @block_size 2 ** 14

  def handshake(metainfo, address) do
    [ip, port] = String.split(address, ":")
    port = String.to_integer(port)

    ip =
      ip
      |> String.split(".")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary, active: false])
    info_hash = metainfo.info_hash

    handshake =
      <<19::size(8), "BitTorrent protocol", 0::size(64)>> <>
        info_hash <> <<peer_id()::binary-size(20)>>

    :gen_tcp.send(socket, handshake)

    {:ok, data} = :gen_tcp.recv(socket, @handshake_length)

    <<19::size(8), "BitTorrent protocol", _::size(64), received_info_hash::binary-size(20),
      received_peer_id::binary-size(20), _::binary>> = data

    case received_info_hash == info_hash do
      true -> {:ok, socket, received_peer_id}
      false -> {:error, :non_matching_info_hash}
    end
  end

  def download_piece(metainfo, piece_index) do
    {:ok, %{peers: peers}} = Tracker.Client.get(metainfo)
    {ip, port} = Enum.random(peers)
    {:ok, socket, _} = handshake(metainfo, "#{ip}:#{port}")
    {:ok, @bitfield, _} = receive_message(socket)
    :ok = send_message(socket, @interested)
    {:ok, @unchoked, _} = receive_message(socket)
    get_piece(socket, metainfo, piece_index)
  end

  defp get_piece(socket, metainfo, piece_index) do
    total_length = metainfo.info.length
    piece_length = metainfo.info.piece_length

    nr_of_pieces = ceil(total_length / piece_length)

    even_pieces? = rem(total_length, piece_length) == 0

    piece_length =
      if piece_index == nr_of_pieces - 1 && not even_pieces? do
        rem(total_length, piece_length)
      else
        piece_length
      end

    piece =
      split_piece_to_blocks(piece_length, @block_size)
      |> Enum.map(fn %{block_offset: block_offset, block_length: block_length} ->
        :ok =
          send_message(
            socket,
            @request,
            <<piece_index::big-size(32), block_offset::big-size(32), block_length::big-size(32)>>
          )

        {:ok, @piece, piece_block} = receive_message(socket)
        piece_block
      end)
      |> Enum.map(fn block_payload ->
        <<_index::big-size(32), _begin::big-size(32), block::binary>> = block_payload
        block
      end)
      |> Enum.join()

    piece_hash = :crypto.hash(:sha, piece)

    torrent_file_piece_hash = Enum.at(metainfo.info.piece_hashes, piece_index)

    case piece_hash == torrent_file_piece_hash do
      true ->
        {:ok, piece}

      false ->
        Logger.error("Piece hash mismatch")
        {:error, :piece_hash_mismatch}
    end
  end

  defp split_piece_to_blocks(piece_length, block_size) do
    blocks = ceil(piece_length / @block_size)

    even_blocks? = rem(piece_length, block_size) == 0

    for block_index <- 0..(blocks - 1) do
      block_offset = block_index * block_size

      block_length =
        if block_index == blocks - 1 && not even_blocks? do
          rem(piece_length, block_size)
        else
          block_size
        end

      %{block_offset: block_offset, block_length: block_length}
    end
  end

  defp receive_message(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)

    <<length::integer-big-size(32), _id::8, payload::binary>> = data

    additional_payload =
      if length > 1 + byte_size(payload) do
        {:ok, additional_payload} = :gen_tcp.recv(socket, length - 1 - byte_size(payload))

        additional_payload
      else
        <<>>
      end

    data = <<data::binary, additional_payload::binary>>

    {id, payload} = decode_message(data)
    {:ok, id, payload}
  end

  defp send_message(socket, id, payload \\ <<>>) do
    message = encode_message(id, payload)

    case :gen_tcp.send(socket, message) do
      :ok ->
        :ok

      error ->
        Logger.error("Failed to send interested message: #{inspect(error)}")
        {:error, error}
    end
  end

  defp encode_message(id, payload) do
    length = 1 + byte_size(payload)
    <<length::integer-big-size(32), id::8, payload::binary-size(length - 1)>>
  end

  defp decode_message(data) do
    <<length::integer-big-size(32), rest::binary>> = data
    <<id::8, payload::binary-size(length - 1), rest::binary>> = rest

    if byte_size(rest) > 0 do
      Logger.error("Received message with trailing data: #{inspect(data)}")
    end

    {id, payload}
  end

  defp peer_id(), do: Application.get_env(:bittorrent, :peer_id)
end
