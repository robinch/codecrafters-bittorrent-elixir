defmodule Bittorrent.CLI do
  alias Bittorrent.Bencode

  def main(argv) do
    case argv do
      ["decode", encoded_str | _] ->
        {:ok, decoded_str} = Bencode.decode(encoded_str)
        IO.puts(Jason.encode!(decoded_str))

      [command | _] ->
        IO.puts("Unknown command: #{command}")
        System.halt(1)

      [] ->
        IO.puts("Usage: your_bittorrent.sh <command> <args>")
        System.halt(1)
    end
  end
end
