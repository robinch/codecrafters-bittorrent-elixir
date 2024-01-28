import Config

config :bittorrent,
  port: System.get_env("PORT", "6881") |> String.to_integer(),
  peer_id: System.get_env("PEER_ID", "00112233445566778899")
