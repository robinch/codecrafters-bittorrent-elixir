defmodule Bittorrent.Bencode do
  require Logger

  def decode(encoded_value) do
    case String.split(encoded_value, ":") do
      [_length, value] ->
        {:ok, value}

      _ ->
        Logger.error("Incorrect formatted string #{inspect(encoded_value)}")
        {:error, :could_not_decode}
    end
  end
end
