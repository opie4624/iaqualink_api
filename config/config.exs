import Config

config :iaqualink_api,
  login_url: "https://prod.zodiac-io.com/users/v1/login",
  api_url: "https://prm.iaqualink.net/v2",
  p_api_url: "https://p-api.iaqualink.net/v1/mobile",
  r_api_url: "https://r-api.iaqualink.net",
  api_key: "EOOEMOW4YR6QNB07",
  language: "en"

import_config "config.secret.exs"
