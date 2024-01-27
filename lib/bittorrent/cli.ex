defmodule Bittorrent.CLI do
  alias Bittorrent.Bencode

  def main(argv) do
    case argv do
      ["decode", encoded_str | _] ->
        {:ok, decoded_str, _} = Bencode.decode(encoded_str)

        decoded_str
        |> Jason.encode!()
        |> IO.puts()

      ["info", file_path | _] ->
        {:ok, binary} = File.read(file_path)
        content = IO.iodata_to_binary(binary)

        {:ok, decoded_content, _} = Bencode.decode(content)
        IO.puts("Tracker URL: #{decoded_content["announce"]}")
        IO.puts("Length: #{decoded_content["info"]["length"]}")

      [command | _] ->
        IO.puts("Unknown command: #{command}")
        System.halt(1)

      [] ->
        IO.puts("Usage: your_bittorrent.sh <command> <args>")
        System.halt(1)
    end
  end
end
