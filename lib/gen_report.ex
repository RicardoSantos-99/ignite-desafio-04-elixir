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

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(
        report_acc(),
        fn {:ok, result}, report -> sum_reports(report, result) end
      )

    {:ok, result}
  end

  defp sum_reports(
         %{"all_hours" => hours1, "hours_per_month" => months1, "hours_per_year" => years1},
         %{"all_hours" => hours2, "hours_per_month" => months2, "hours_per_year" => years2}
       ) do
    months = Enum.map(months1, fn {key, elem} -> %{key => merge_maps(elem, months2[key])} end)
    years = Enum.map(years1, fn {key, elem} -> %{key => merge_maps(elem, years2[key])} end)

    hours = merge_maps(hours1, hours2)

    build_report(hours, months, years)
  end

  def merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
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

  defp report_acc do
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
