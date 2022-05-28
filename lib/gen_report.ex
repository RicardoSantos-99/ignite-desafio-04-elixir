defmodule GenReport do
  alias GenReport.Parser

  @available_names [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @available_months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  def build do
    {:error, "Insira o nome de um arquivo"}
  end

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> IO.inspect()
    |> Enum.reduce(
      report_acc(),
      fn line, report -> sum_values(line, report) end
    )
  end

  defp sum_values(
         [name, hour, _day, month, year],
         %{
           "all_hours" => hours,
           "hours_per_month" => months,
           "hours_per_year" => years
         }
       ) do
    hours = Map.put(hours, name, hours[name] + hour)
    months_per_user = Map.put(months[name], month, months[name][month] + hour)
    years_per_user = Map.put(years[name], year, years[name][year] + hour)

    months = Map.put(months, name, months_per_user)
    years = Map.put(years, name, years_per_user)

    build_report(hours, months, years)
  end

  def report_acc do
    hours = Enum.into(@available_names, %{}, &{&1, 0})
    months = Enum.into(@available_months, %{}, &{&1, 0})
    years = Enum.into(2016..2020, %{}, &{&1, 0})

    build_report(
      hours,
      Enum.into(@available_names, %{}, &{&1, months}),
      Enum.into(@available_names, %{}, &{&1, years})
    )
  end

  defp build_report(hours, months, years),
    do: %{
      "all_hours" => hours,
      "hours_per_month" => months,
      "hours_per_year" => years
    }
end
