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
    {:ok, result} = Jason.decode(response.body),
    do: {:ok, result}
  end
end
