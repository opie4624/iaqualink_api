defmodule IaqualinkApi.Account do
  alias IaqualinkApi.Auth.Session

  def get_user_id do
    get_session_info()
    |> Map.get("session_user_id")
  end

  def get_session_id do
    get_session_info()
    |> Map.get("session_id")
  end

  def get_locations do
    user_id = get_user_id()

    with {:ok, response} <-
           Finch.build(:get, make_url("users/#{user_id}/locations"), make_headers())
           |> Finch.request(ApiFinch),
         {:ok, decoded} <- Jason.decode(response.body),
         do: Map.get(decoded, "locations")
  end

  defp make_headers do
    id_token = Session.get(:id_token)

    [{"authorization", "Bearer #{id_token}"}]
  end

  defp make_url(destination) do
    base_url = Application.get_env(:iaqualink_api, :api_url)
    "#{base_url}/#{destination}"
  end

  defp get_session_info do
    with {:ok, response} <-
           Finch.build(:get, make_url("userId"), make_headers())
           |> Finch.request(ApiFinch),
         {:ok, decoded} <- Jason.decode(response.body),
         do: decoded
  end
end
