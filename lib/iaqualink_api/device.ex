defmodule IaqualinkApi.Device do
  alias IaqualinkApi.Account

  def get_home(serial) do
    send_command("get_home", serial) |> Map.get("home_screen")
  end

  def extract_temps(home_page) do
    temps =
      %{}
      |> maybe_add(home_page, "spa_temp")
      |> maybe_add(home_page, "pool_temp")
      |> maybe_add(home_page, "air_temp")
  end

  def send_command(command, serial) do
    session_id = Account.get_session_id()

    url_string =
      "session.json?sessionID=#{session_id}&serial=#{serial}&actionID=command&command=#{command}"

    base_url = Application.get_env(:iaqualink_api, :p_api_url)
    url = "#{base_url}/#{url_string}"

    with {:ok, response} <- Finch.build(:get, url) |> Finch.request(ApiFinch),
         {:ok, decoded} = Jason.decode(response.body),
         do: decoded
  end

  defp extract_element(list, element) do
    IO.puts(element)
    for %{^element => value} <- list, do: value |> List.first()
  end

  defp maybe_add(map, data, element) do
    data_element = extract_element(data, element)

    case data_element do
      "" ->
        map

      _ ->
        Map.put(map, element, String.to_integer(data))
    end
  end
end
