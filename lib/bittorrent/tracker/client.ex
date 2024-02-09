defmodule Bittorrent.Tracker.Client do
  alias Bittorrent.{Metainfo, Tracker}
  require Logger

  def get(metainfo = %Metainfo{}) do
    port = Application.get_env(:bittorrent, :port)
    peer_id = Application.get_env(:bittorrent, :peer_id)

    Req.get(metainfo.announce,
      params: [
        info_hash: metainfo.info_hash,
        peer_id: peer_id,
        port: port,
        uploaded: 0,
        downloaded: 0,
        left: metainfo.info.length,
        compact: 1
      ]
    )
    |> case do
      {:ok, %{status: 200, body: body}} ->
        {:ok, Tracker.Response.from_bencode(body)}

      error ->
        Logger.error("Tracker request failed: #{inspect(error)}")
        {:error, error}
    end
  end
end
