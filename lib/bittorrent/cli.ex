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

        info_hash =
          decoded_content["info"]
          |> Bencode.encode()
          |> sha1_encode()

        IO.puts("Tracker URL: #{decoded_content["announce"]}")
        IO.puts("Length: #{decoded_content["info"]["length"]}")
        IO.puts("Info Hash: #{info_hash}")

      [command | _] ->
        IO.puts("Unknown command: #{command}")
        System.halt(1)

      [] ->
        IO.puts("Usage: your_bittorrent.sh <command> <args>")
        System.halt(1)
    end
  end

  defp sha1_encode(binary) do
    :crypto.hash(:sha, binary)
    |> Base.encode16()
    |> String.downcase()
  end
end
