defmodule IaqualinkApi.Auth do
  alias IaqualinkApi.Auth.Session

  def login do
    payload = %{
      "email" => Application.get_env(:iaqualink_api, :email),
      "password" => Application.get_env(:iaqualink_api, :password),
      "language" => "en"
    }

    url = Application.get_env(:iaqualink_api, :login_url)

    headers = [{"content-type", "application/json"}]

    with {:ok, response} <-
           Finch.build(:post, url, headers, Jason.encode!(payload))
           |> Finch.request(ApiFinch),
         {:ok, decoded} <- Jason.decode(response.body),
         do:
           %{
             refresh_url: Map.get(decoded, "cognitoPool") |> Map.get("domain"),
             client_id: Map.get(decoded, "cognitoPool") |> Map.get("appClientId"),
             session_token: Map.get(decoded, "credentials") |> Map.get("SessionToken"),
             access_token: Map.get(decoded, "userPoolOAuth") |> Map.get("AccessToken"),
             refresh_token: Map.get(decoded, "userPoolOAuth") |> Map.get("RefreshToken"),
             id_token: Map.get(decoded, "userPoolOAuth") |> Map.get("IdToken"),
             expires: Map.get(decoded, "userPoolOAuth") |> Map.get("ExpiresIn"),
             auth_token: Map.get(decoded, "authentication_token"),
             session_id: Map.get(decoded, "session_id"),
             user_id: Map.get(decoded, "id")
           }
           |> Session.put_keys()
  end
end
