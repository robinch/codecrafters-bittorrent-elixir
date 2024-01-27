defmodule Bittorrent.Bencode do
  require Logger

  def decode(<<?d, _rest::binary>> = encoded_value)
      when is_binary(encoded_value) do
    decode_dictionary(encoded_value)
  end

  def decode(<<?l, _rest::binary>> = encoded_value)
      when is_binary(encoded_value) do
    decode_list(encoded_value)
  end

  def decode(<<?i, _rest::binary>> = encoded_value)
      when is_binary(encoded_value) do
    decode_integer(encoded_value)
  end

  def decode(encoded_value) do
    decode_string(encoded_value)
  end

  def decode_list(<<?l, rest::binary>>) do
    do_decode_list(rest, [])
  end

  def decode_dictionary(<<?d, rest::binary>>) do
    do_decode_dictionary(rest, %{})
  end

  def decode_integer(<<?i, rest::binary>> = encoded_value) do
    case String.split(rest, "e", parts: 2) do
      [value, rest] ->
        {:ok, String.to_integer(value), rest}

      _ ->
        Logger.error("Incorrect formatted integer #{inspect(encoded_value)}")

        {:error, :could_not_decode}
    end
  end

  def decode_string(encoded_value) do
    case String.split(encoded_value, ":", parts: 2) do
      [length, value] ->
        value_length = String.to_integer(length)
        <<value::binary-size(value_length), rest::binary>> = value
        {:ok, value, rest}

      _ ->
        Logger.error("Incorrect formatted string #{inspect(encoded_value)}")
        {:error, :could_not_decode}
    end
  end

  defp do_decode_dictionary(<<?e, rest::binary>>, acc) do
    {:ok, acc, rest}
  end

  defp do_decode_dictionary(values, acc) do
    {:ok, key, rest} = decode_string(values)
    {:ok, value, rest} = decode(rest)

    do_decode_dictionary(rest, Map.put(acc, key, value))
  end

  defp do_decode_list(<<?e, rest::binary>>, acc) do
    {:ok, Enum.reverse(acc), rest}
  end

  defp do_decode_list(values, acc) do
    case decode(values) do
      {:ok, value, rest} ->
        do_decode_list(rest, [value | acc])

      {:error, _} ->
        Logger.error("Incorrect formatted list #{inspect(values)}")
        {:error, :could_not_decode}
    end
  end
end
