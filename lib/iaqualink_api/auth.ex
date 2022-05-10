defmodule IaqualinkApi.Auth do
  def login do
    payload = %{
      "email" => Application.get_env(:iaqualink_api, :email),
      "password" => Application.get_env(:iaqualink_api, :password),
      "language" => "en"
    }

    url = Application.get_env(:iaqualink_api, :login_url)

    headers = [{"content-type", "application/json"}]

    with {:ok, response} = Finch.build(:post, url, headers, Jason.encode!(payload))
         |> Finch.request(ApiFinch),
         {:ok, decoded} = Jason.decode(response.body),
           do: %{
             renewUrl: Map.get(decoded, "cognitoPool") |> Map.get("domain"),
             clientId: Map.get(decoded, "cognitoPool") |> Map.get("appClientId"),
             sessionToken: Map.get(decoded, "credentials") |> Map.get("SessionToken"),
             accessToken: Map.get(decoded, "userPoolOAuth") |> Map.get("AccessToken"),
             refreshToken: Map.get(decoded, "userPoolOAuth") |> Map.get("RefreshToken"),
             idToken: Map.get(decoded, "userPoolOAuth") |> Map.get("IdToken"),
             expires: Map.get(decoded, "userPoolOAuth") |> Map.get("ExpiresIn")
           }
  end
end
