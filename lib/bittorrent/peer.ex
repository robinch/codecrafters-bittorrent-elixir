defmodule Bittorrent.Peer do
  # The handshake is a message consisting of the following parts as described in the peer [peer protocol](https://www.bittorrent.org/beps/bep_0003.html#peer-protocol)
  # length of the protocol string (BitTorrent protocol) which is 19 (1 byte)
  # the string BitTorrent protocol (19 bytes)
  # eight reserved bytes, which are all set to zero (8 bytes)
  # sha1 infohash (20 bytes) (NOT the hexadecimal representation, which is 40 bytes long)
  # peer id (20 bytes) (you can use 00112233445566778899 for this challenge)
  @handshake_length 1 + 19 + 8 + 20 + 20

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
      true -> {:ok, received_peer_id}
      false -> {:error, :non_matching_info_hash}
    end
  end

  defp peer_id(), do: Application.get_env(:bittorrent, :peer_id)
end
