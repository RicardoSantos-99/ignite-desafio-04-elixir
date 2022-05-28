defmodule GenReport.Parser do
  def parse_file(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> convert_list()
    |> List.update_at(3, &convert_date/1)
  end

  defp convert_list([hd | tail]), do: [String.downcase(hd) | Enum.map(tail, &String.to_integer/1)]

  def convert_date(num) do
    case num do
      1 -> "janeiro"
      2 -> "fevereiro"
      3 -> "março"
      4 -> "abril"
      5 -> "maio"
      6 -> "junho"
      7 -> "julho"
      8 -> "agosto"
      9 -> "setembro"
      10 -> "outubro"
      11 -> "novembro"
      12 -> "dezembro"
    end
  end
end
