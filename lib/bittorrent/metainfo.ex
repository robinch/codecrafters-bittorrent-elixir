defmodule Bittorrent.Metainfo do
  defstruct [:announce, :created_by, :info_hash, :info]

  alias Bittorrent.Metainfo.Info
  alias Bittorrent.Bencode

  @type t :: %__MODULE__{
          announce: String.t(),
          created_by: String.t(),
          info_hash: binary(),
          info: Info.t()
        }

  def from_file(file_path) do
    {:ok, binary} = File.read(file_path)
    content = IO.iodata_to_binary(binary)

    {:ok, decoded_content, _} = Bencode.decode(content)
    bencoded_info = decoded_content["info"] |> Bencode.encode()
    info_hash = :crypto.hash(:sha, bencoded_info)

    %__MODULE__{
      announce: decoded_content["announce"],
      created_by: decoded_content["created by"],
      info_hash: info_hash,
      info: Info.from_info_map(decoded_content["info"])
    }
  end
end
