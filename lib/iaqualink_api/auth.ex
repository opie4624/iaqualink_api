defmodule IaqualinkApi.Auth do
  def login do
    payload = %{
      email: Application.get_env(:iaqualink_api, :email),
      password: Application.get_env(:iaqualink_api, :password),
      language: "en"
    }

    url = Application.get_env(:iaqualink_api, :login_url)

    headers = [{"content-type", "application/json"}]

    request = Finch.build(
      :post,
      url,
      headers,
      payload
    )

    request
  end
end
