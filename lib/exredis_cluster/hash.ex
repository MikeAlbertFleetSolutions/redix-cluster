defmodule RedisCluster.Hash do
  @moduledoc false

  use Bitwise

  @redis_cluster_hash_slots 16384
  @crcdef <<0x00,0x00,0x10,0x21,0x20,0x42,0x30,0x63,0x40,0x84,0x50,0xa5,0x60,0xc6,0x70,0xe7,
            0x81,0x08,0x91,0x29,0xa1,0x4a,0xb1,0x6b,0xc1,0x8c,0xd1,0xad,0xe1,0xce,0xf1,0xef,
            0x12,0x31,0x02,0x10,0x32,0x73,0x22,0x52,0x52,0xb5,0x42,0x94,0x72,0xf7,0x62,0xd6,
            0x93,0x39,0x83,0x18,0xb3,0x7b,0xa3,0x5a,0xd3,0xbd,0xc3,0x9c,0xf3,0xff,0xe3,0xde,
            0x24,0x62,0x34,0x43,0x04,0x20,0x14,0x01,0x64,0xe6,0x74,0xc7,0x44,0xa4,0x54,0x85,
            0xa5,0x6a,0xb5,0x4b,0x85,0x28,0x95,0x09,0xe5,0xee,0xf5,0xcf,0xc5,0xac,0xd5,0x8d,
            0x36,0x53,0x26,0x72,0x16,0x11,0x06,0x30,0x76,0xd7,0x66,0xf6,0x56,0x95,0x46,0xb4,
            0xb7,0x5b,0xa7,0x7a,0x97,0x19,0x87,0x38,0xf7,0xdf,0xe7,0xfe,0xd7,0x9d,0xc7,0xbc,
            0x48,0xc4,0x58,0xe5,0x68,0x86,0x78,0xa7,0x08,0x40,0x18,0x61,0x28,0x02,0x38,0x23,
            0xc9,0xcc,0xd9,0xed,0xe9,0x8e,0xf9,0xaf,0x89,0x48,0x99,0x69,0xa9,0x0a,0xb9,0x2b,
            0x5a,0xf5,0x4a,0xd4,0x7a,0xb7,0x6a,0x96,0x1a,0x71,0x0a,0x50,0x3a,0x33,0x2a,0x12,
            0xdb,0xfd,0xcb,0xdc,0xfb,0xbf,0xeb,0x9e,0x9b,0x79,0x8b,0x58,0xbb,0x3b,0xab,0x1a,
            0x6c,0xa6,0x7c,0x87,0x4c,0xe4,0x5c,0xc5,0x2c,0x22,0x3c,0x03,0x0c,0x60,0x1c,0x41,
            0xed,0xae,0xfd,0x8f,0xcd,0xec,0xdd,0xcd,0xad,0x2a,0xbd,0x0b,0x8d,0x68,0x9d,0x49,
            0x7e,0x97,0x6e,0xb6,0x5e,0xd5,0x4e,0xf4,0x3e,0x13,0x2e,0x32,0x1e,0x51,0x0e,0x70,
            0xff,0x9f,0xef,0xbe,0xdf,0xdd,0xcf,0xfc,0xbf,0x1b,0xaf,0x3a,0x9f,0x59,0x8f,0x78,
            0x91,0x88,0x81,0xa9,0xb1,0xca,0xa1,0xeb,0xd1,0x0c,0xc1,0x2d,0xf1,0x4e,0xe1,0x6f,
            0x10,0x80,0x00,0xa1,0x30,0xc2,0x20,0xe3,0x50,0x04,0x40,0x25,0x70,0x46,0x60,0x67,
            0x83,0xb9,0x93,0x98,0xa3,0xfb,0xb3,0xda,0xc3,0x3d,0xd3,0x1c,0xe3,0x7f,0xf3,0x5e,
            0x02,0xb1,0x12,0x90,0x22,0xf3,0x32,0xd2,0x42,0x35,0x52,0x14,0x62,0x77,0x72,0x56,
            0xb5,0xea,0xa5,0xcb,0x95,0xa8,0x85,0x89,0xf5,0x6e,0xe5,0x4f,0xd5,0x2c,0xc5,0x0d,
            0x34,0xe2,0x24,0xc3,0x14,0xa0,0x04,0x81,0x74,0x66,0x64,0x47,0x54,0x24,0x44,0x05,
            0xa7,0xdb,0xb7,0xfa,0x87,0x99,0x97,0xb8,0xe7,0x5f,0xf7,0x7e,0xc7,0x1d,0xd7,0x3c,
            0x26,0xd3,0x36,0xf2,0x06,0x91,0x16,0xb0,0x66,0x57,0x76,0x76,0x46,0x15,0x56,0x34,
            0xd9,0x4c,0xc9,0x6d,0xf9,0x0e,0xe9,0x2f,0x99,0xc8,0x89,0xe9,0xb9,0x8a,0xa9,0xab,
            0x58,0x44,0x48,0x65,0x78,0x06,0x68,0x27,0x18,0xc0,0x08,0xe1,0x38,0x82,0x28,0xa3,
            0xcb,0x7d,0xdb,0x5c,0xeb,0x3f,0xfb,0x1e,0x8b,0xf9,0x9b,0xd8,0xab,0xbb,0xbb,0x9a,
            0x4a,0x75,0x5a,0x54,0x6a,0x37,0x7a,0x16,0x0a,0xf1,0x1a,0xd0,0x2a,0xb3,0x3a,0x92,
            0xfd,0x2e,0xed,0x0f,0xdd,0x6c,0xcd,0x4d,0xbd,0xaa,0xad,0x8b,0x9d,0xe8,0x8d,0xc9,
            0x7c,0x26,0x6c,0x07,0x5c,0x64,0x4c,0x45,0x3c,0xa2,0x2c,0x83,0x1c,0xe0,0x0c,0xc1,
            0xef,0x1f,0xff,0x3e,0xcf,0x5d,0xdf,0x7c,0xaf,0x9b,0xbf,0xba,0x8f,0xd9,0x9f,0xf8,
            0x6e,0x17,0x7e,0x36,0x4e,0x55,0x5e,0x74,0x2e,0x93,0x3e,0xb2,0x0e,0xd1,0x1e,0xf0>>

  def hash(key) when is_binary(key), do: to_char_list(key) |> hash
  def hash(key), do: crc16(0, key) |>rem @redis_cluster_hash_slots

  defp crc16(crc, []), do: crc
  defp crc16(crc, [b | rest]) do
    index = bsr(crc, 8)|> bxor(b) |> band(0xff)
    bsl(crc, 8)|> band(0xffff) |> bxor(crc_index(index)) |> crc16(rest)
  end

  defp crc_index(n) do
    <<crc::16>> = :binary.part(@crcdef, n*2, 2)
    crc
  end

end