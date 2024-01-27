defmodule Bittorrent.Bencode do
  require Logger

  def decode(encoded_value) do
    decode_string(encoded_value)
  end

  def decode_string(encoded_value) do
    case String.split(encoded_value, ":", parts: 2) do
      [_length, value] ->
        {:ok, value}

      _ ->
        Logger.error("Incorrect formatted string #{inspect(encoded_value)}")
        {:error, :could_not_decode}
    end
  end
end
