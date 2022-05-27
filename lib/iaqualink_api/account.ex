defmodule IaqualinkApi.Account do
  alias IaqualinkApi.Auth.Session

  def get_user_id, do: Session.get(:user_id)

  def get_session_user_id do
    get_session_info()
    |> Map.get("session_user_id")
  end

  def get_session_id do
    get_session_info()
    |> Map.get("session_id")
  end

  def get_locations do
    user_id = get_session_user_id()

    with {:ok, response} <-
           Finch.build(:get, make_url("users/#{user_id}/locations"), make_headers())
           |> Finch.request(ApiFinch),
         {:ok, decoded} <- Jason.decode(response.body),
         do: Map.get(decoded, "locations")
  end

  def get_devices do
    user_id = get_user_id()
    api_key = Application.get_env(:iaqualink_api, :api_key)
    auth_token = Session.get(:auth_token)

    devices =
      with {:ok, response} <-
             Finch.build(
               :get,
               make_url(
                 "devices.json?api_key=#{api_key}&authentication_token=#{auth_token}&user_id=#{user_id}",
                 :r_api_url
               )
             )
             |> Finch.request(ApiFinch),
           {:ok, decoded} = Jason.decode(response.body),
           do: decoded
  end

  defp make_headers do
    id_token = Session.get(:id_token)

    [{"authorization", "Bearer #{id_token}"}]
  end

  defp make_url(destination, url_base \\ :api_url) do
    base_url = Application.get_env(:iaqualink_api, url_base)
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
