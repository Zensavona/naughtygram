defmodule Naughtygram do
  @moduledoc """
  Main functionality for interacting with the private Instagram API
  """
  @url "https://instagram.com/api/v1"
  alias Naughtygram.Crypto
  alias Naughtygram.Cookie

  @doc """
  Log the user in and return a cookieset which should be sent with further
  requests to identify the session to IG.

  Takes a username, password, identity generated with
  `Naughtygram.Identity.create_random` and an optional proxy url.

  These identities contain the user agent, device guid, etc.. So should ideally be
  created once per user and stored for later use.

  ## Example
    iex(1)> identity = Naughtygram.Identity.create_random
    %{device_id: "android-c2c1eac1-df83-496a-aaa6-dc5f4c001aa6", guid: "c2c1eac1-df83-496a-aaa6-dc5f4c001aa6", user_agent: "Instagram 4.1.1 Android (10/2.4.4; 320; 720x1280; samsung; GT-I9100; GT-I9100; smdkc210; en_US)"}
    iex(2)> Naughtygram.login_and_return_cookies("username", "password", identity, "127.0.0.1:8888")
    {:ok, ...}
  """
  def login_and_return_cookies(username, password, identity, proxy_url \\ :none) do
    url = @url <> "/accounts/login/"
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
    resp = if proxy_url == :none do
      HTTPoison.post!(url, body, headers)
    else
      HTTPoison.post!(url, body, headers, proxy: proxy_url)
    end

    case resp do
      %{status_code: 200} ->
        cookies = Enum.filter_map(resp.headers,
                                  fn(x) -> Cookie.parse(x) != :nah end,
                                  &(Cookie.parse/1))
        cookies = List.insert_at(cookies, -1, {"igfl", username})
        {:ok, cookies}
      _ ->
        {:err, resp}
    end
  end

  @doc """
  Likes a media item as the user asociated with passed cookie and identity.
  """
  def like_media(id, identity, cookies, proxy_url \\ :none) do
    url = @url <> "/media/#{id}/like/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"media_id\":\"#{id}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start

    # add proxy option
    options = if proxy_url == :none, do: options, else: Dict.put(options, :proxy, proxy_url)

    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        {:err, "reason"}
    end
  end

  @doc """
  Unlikes a media item as the user asociated with passed cookie and identity.
  """
  def unlike_media(id, identity, cookies, proxy_url \\ :none) do
    url = @url <> "/media/#{id}/unlike/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"media_id\":\"#{id}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start

    # add proxy option
    options = if proxy_url == :none, do: options, else: Dict.put(options, :proxy, proxy_url)

    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        {:err, "reason"}
    end
  end

  @doc """
  Follows a user as the user asociated with passed cookie and identity.
  """
  def follow_user(id, identity, cookies, proxy_url \\ :none) do
    url = @url <> "/friendships/create/#{id}/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"user_id\":\"#{id}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start

    # add proxy option
    options = if proxy_url == :none, do: options, else: Dict.put(options, :proxy, proxy_url)

    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        {:err, "reason"}
    end
  end

  @doc """
  Unfollows a user as the user asociated with passed cookie and identity.
  """
  def unfollow_user(id, identity, cookies, proxy_url \\ :none) do
    url = @url <> "/friendships/destroy/#{id}/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"user_id\":\"#{id}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start

    # add proxy option
    options = if proxy_url == :none, do: options, else: Dict.put(options, :proxy, proxy_url)

    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        {:err, "reason"}
    end
  end

  @doc """
  Comment on some media
  """
  def add_comment(id, text, identity, cookies, proxy_url \\ :none) do
    url = @url <> "/media/#{id}/comment/"
    options = [hackney: [cookie: cookies, follow_redirect: true]]
    body = Crypto.signed_body("{\"comment_text\":\"#{text}\"}")

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start

    # add proxy option
    options = if proxy_url == :none, do: options, else: Dict.put(options, :proxy, proxy_url)

    response = Poison.decode! HTTPoison.post!(url, body, headers, options).body
    case response do
      %{"status" => "ok"} ->
        {:ok, "new_csrf_token"}
      _ ->
        {:err, "reason"}
    end
  end

  @doc """
  Upload a picture from the filesystem
  """
  def upload_media(photo, caption, identity, cookies, proxy_url \\ :none) do
    url = @url <> "/media/upload/"
    options = [hackney: [cookie: cookies, follow_redirect: true]]
    timestamp = to_string(:os.system_time(:seconds))

    headers = [
      {"User-Agent", identity.user_agent}
    ]

    HTTPoison.start

    # add proxy option
    options = if proxy_url == :none, do: options, else: Dict.put(options, :proxy, proxy_url)

    request = HTTPoison.post!(url, {:multipart, [{"device_timestamp", timestamp}, {:file, photo, { ["form-data"], [name: "\"photo\"", filename: "\"#{photo}\""]},[]}]}, headers, options)
    response = Poison.decode! request.body

    case response do
      %{"media_id" => media_id, "status" => "ok"} ->
        configure(media_id, caption, identity, cookies, proxy_url)
        # {:ok, media_id}
      %{"status" => "fail"} ->
        {:err, response.message}
      _ ->
        {:err, response}
    end
  end

  defp configure(media_id, caption, identity, cookies, proxy_url \\ :none) do
    url = @url <> "/media/configure/"

    options = [hackney: [cookie: cookies, follow_redirect: true]]
    timestamp = to_string(:os.system_time(:seconds))
    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    data = Poison.encode!(%{
      guid: identity.guid,
      device_id: "android-#{identity.guid}",
      device_timestamp: timestamp,
      media_id: media_id,
      caption: caption,
      source_type: "5",
      filter_type: "0",
      extra: "{}",
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
    })

    body = Crypto.signed_body(data)

    HTTPoison.start

    # add proxy option
    options = if proxy_url == :none, do: options, else: Dict.put(options, :proxy, proxy_url)

    request = HTTPoison.post!(url, body, headers, options)
    response = Poison.decode! request.body

    case response do
      %{"status" => "ok", "media" => %{"id" => media_id}} ->
        {:ok, media_id}
      _ ->
        {:err, request}
    end
  end
end
