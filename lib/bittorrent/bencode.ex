defmodule Bittorrent.Bencode do
  require Logger

  def decode(<<?i, _rest::binary>> = encoded_value)
      when is_binary(encoded_value) do
    decode_integer(encoded_value)
  end

  def decode(encoded_value) do
    decode_string(encoded_value)
  end

  def decode_integer(<<?i, rest::binary>> = encoded_value) do
    case String.split(rest, "e") do
      [value, _] ->
        {:ok, String.to_integer(value)}

      _ ->
        Logger.error("Incorrect formatted integer #{inspect(encoded_value)}")
        {:error, :could_not_decode}
    end
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
