defmodule Naughtygram do
  @moduledoc """
  Main functionality for interacting with the private Instagram API
  """
  @url "http://instagram.com/api/v1"
  alias Naughtygram.Identity
  alias Naughtygram.Crypto
  alias Naughtygram.Cookie

  @doc """
  Log the user in and return a cookieset which should be sent with further
  requests to identify the session to IG.

  Takes a username, password and identity generated with
  `Naughtygram.Identity.create_random`.

  These identities contain the user agent, device guid, etc.. So should ideally be
  created once per user and stored for later use.
  """
  def login_and_return_cookies(username, password, identity) do
    data = Poison.encode!(%{
      username: username,
      password: password,
      guid: identity.guid,
      device_id: identity.device_id,
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
    })

    body = Crypto.signed_body(data)

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start
    resp = HTTPoison.post!(@url<>"accounts/login/", body, headers)

    cookies = Enum.filter_map(resp.headers,
                              fn(x) -> Cookie.parse(x) != :nah end,
                              &(Cookie.parse/1))
    List.insert_at(cookies, -1, {"igfl", username})
  end

  @doc """
  Likes a media item as the user asociated with passed cookie and identity.
  """
  def like_media(id, identity, cookies) do
    url = @url <> "media/#{id}/like/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"media_id\":\"#{id}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start
    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        :err
    end
  end

  @doc """
  Unlikes a media item as the user asociated with passed cookie and identity.
  """
  def unlike_media(id, identity, cookies) do
    url = @url <> "media/#{id}/unlike/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"media_id\":\"#{id}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start
    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        :err
    end
  end

  @doc """
  Follows a user as the user asociated with passed cookie and identity.
  """
  def follow_user(id, identity, cookies) do
    url = @url <> "/friendships/create/#{id}/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"user_id\":\"#{id}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start
    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        :err
    end
  end

  @doc """
  Unfollows a user as the user asociated with passed cookie and identity.
  """
  def unfollow_user(id, identity, cookies) do
    url = @url <> "/friendships/destroy/#{id}/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"user_id\":\"#{id}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start
    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        :err
    end
  end

end
