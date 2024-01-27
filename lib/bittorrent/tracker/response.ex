defmodule Bittorrent.Tracker.Response do
  defstruct [:interval, :peers]

  alias Bittorrent.Bencode

  def from_bencode(bencoded_response) do
    {:ok, decoded_response, _} = Bencode.decode(bencoded_response)

    peers = parse_peers(decoded_response["peers"])

    %__MODULE__{
      interval: decoded_response["interval"],
      peers: peers
    }
  end

  defp parse_peers(peers) do
    do_parse_peers(peers, [])
  end

  defp do_parse_peers("", acc), do: Enum.reverse(acc)

  defp do_parse_peers(<<ip::binary-size(4), port::big-16, rest::binary>>, acc) do
    <<ip1::integer, ip2::integer, ip3::integer, ip4::integer>> = ip

    ip_address = "#{ip1}.#{ip2}.#{ip3}.#{ip4}"
    do_parse_peers(rest, [{ip_address, Integer.to_string(port)} | acc])
  end
end

