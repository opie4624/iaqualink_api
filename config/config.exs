import Config

config :iaqualink_api,
  login_url: "https://prod.zodiac-io.com/users/v1/login",
  api_url: "https://prm.iaqualink.net/v2",
  language: "en"

import_config "config.secret.exs"
