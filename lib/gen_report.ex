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

  def build do
    {:error, "Insira o nome de um arquivo"}
  end

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please provide a list of strings!"}
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
         %{"all_hours" => all_hours1, "hours_per_month" => months1, "hours_per_year" => years1},
         %{"all_hours" => all_hours2, "hours_per_month" => months2, "hours_per_year" => years2}
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_maps(months1, months2)
    hours_per_year = merge_maps(years1, years2)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> calc_merge_maps(value1, value2) end)
  end

  defp calc_merge_maps(value1, value2) when is_map(value1) and is_map(value2) do
    merge_maps(value1, value2)
  end

  defp calc_merge_maps(value1, value2) when is_integer(value1) and is_integer(value2) do
    value1 + value2
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
    build_report(
      report_hours_acc(),
      Enum.into(@available_names, %{}, &{&1, report_months_acc()}),
      Enum.into(@available_names, %{}, &{&1, report_years_acc()})
    )
  end

  defp build_report(hours, months, years),
    do: %{
      "all_hours" => hours,
      "hours_per_month" => months,
      "hours_per_year" => years
    }

  defp report_years_acc, do: Enum.into(2016..2020, %{}, &{&1, 0})
  defp report_months_acc, do: Enum.into(@available_months, %{}, &{&1, 0})
  defp report_hours_acc, do: Enum.into(@available_names, %{}, &{&1, 0})
end
