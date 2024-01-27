defmodule Bittorrent.Metainfo.Info do
  defstruct [:name, :length, :piece_length, :pieces, :piece_hashes]
  @pieces_split_size 20

  @type t :: %__MODULE__{
          name: String.t(),
          length: integer(),
          piece_length: integer(),
          pieces: binary(),
          piece_hashes: [binary()]
        }

  def from_info_map(info) do
    %__MODULE__{
      name: info["name"],
      length: info["length"],
      piece_length: info["piece length"],
      pieces: info["pieces"],
      piece_hashes: info["pieces"] |> split_pieces()
    }
  end

  def split_pieces(pieces), do: do_split_pieces(pieces, [])

  defp do_split_pieces("", acc), do: Enum.reverse(acc)

  defp do_split_pieces(binary, acc) do
    <<chunk::binary-size(@pieces_split_size), rest::binary>> = binary

    do_split_pieces(rest, [chunk | acc])
  end
end
