defmodule Bittorrent.Tracker.Client do
  alias Bittorrent.{Metainfo, Tracker}

  @peer_id "00112233445566778899"
  @port 6881

  def get(metainfo = %Metainfo{}) do
    %{status: 200, body: body} =
      Req.get!(metainfo.announce,
        params: [
          info_hash: metainfo.info_hash,
          peer_id: @peer_id,
          port: @port,
          uploaded: 0,
          downloaded: 0,
          left: metainfo.info.length,
          compact: 1
        ]
      )

    Tracker.Response.from_bencode(body)
  end
end
