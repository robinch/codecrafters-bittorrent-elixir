defmodule Bittorrent.MetainfoTest do
  use ExUnit.Case

  alias Bittorrent.Metainfo

  test "from_file" do
    assert %Bittorrent.Metainfo{
             announce: "http://bittorrent-test-tracker.codecrafters.io/announce",
             created_by: "mktorrent 1.1",
             info_hash:
               <<214, 159, 145, 230, 178, 174, 76, 84, 36, 104, 209, 7, 58, 113, 212, 234, 19,
                 135, 154, 127>>,
             info: %Bittorrent.Metainfo.Info{
               name: "sample.txt",
               length: 92063,
               piece_length: 32768,
               pieces:
                 <<232, 118, 246, 122, 42, 136, 134, 232, 243, 107, 19, 103, 38, 195, 15, 162,
                   151, 3, 2, 45, 110, 34, 117, 230, 4, 160, 118, 102, 86, 115, 110, 129, 255, 16,
                   181, 82, 4, 173, 141, 53, 240, 13, 147, 122, 2, 19, 223, 25, 130, 188, 141, 9,
                   114, 39, 173, 158, 144, 154, 204, 23>>,
               piece_hashes: [
                 <<232, 118, 246, 122, 42, 136, 134, 232, 243, 107, 19, 103, 38, 195, 15, 162,
                   151, 3, 2, 45>>,
                 <<110, 34, 117, 230, 4, 160, 118, 102, 86, 115, 110, 129, 255, 16, 181, 82, 4,
                   173, 141, 53>>,
                 <<240, 13, 147, 122, 2, 19, 223, 25, 130, 188, 141, 9, 114, 39, 173, 158, 144,
                   154, 204, 23>>
               ]
             }
           } = Metainfo.from_file("test/support/sample.torrent")
  end
end
