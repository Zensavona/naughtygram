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
  Takes a media id, identity, cookies and optional proxy url
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
  Takes a media id, identity, cookies and optional proxy url
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
  Takes a user id, identity, cookies and optional proxy url
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
  Takes a user id, identity, cookies and optional proxy url
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
  Takes a media id, comment text, identity, cookies and optional proxy url
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
  Takes a photo filepath, caption text, identity, cookies and optional proxy url
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

  defp configure(media_id, caption, identity, cookies, proxy_url) do
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

  @doc """
  This is for getting the user's recent notifications, which appear in the "you" tab of the "activity" section in Instagram's app and will be sent to the user as push notifications if they have them enabled.
  """
  def activity_inbox(identity, cookies, proxy_url \\ :none) do
    url = @url <> "/news/inbox/?"

    options = [hackney: [cookie: cookies, follow_redirect: true]]

    headers = [
      {"User-Agent", identity.user_agent},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    HTTPoison.start

    options = if proxy_url == :none, do: options, else: Dict.put(options, :proxy, proxy_url)
    response = HTTPoison.get!(url, headers, options).body

    response
    |> String.replace("\n", "")
    |> Floki.find("ul")
    |> Floki.find("li")
    |> Enum.map(&parse_inbox_item/1)
  end

  defp parse_inbox_item(item) do
    {_el, _attrs, children} = item

    [time] = Floki.find(children, "span.timestamp")
    [avatar] = Floki.find(children, "span.avatar")
    [description] = Floki.find(children, "span.description")

    %{time: parse_item_time(time), user: parse_item_user(avatar), description: parse_item_description(description)}
  end

  defp parse_item_time(time) do
    {_el, _attrs, [words]} = time
    [timestamp] = Floki.attribute(time, "data-timestamp")
    %{timestamp: timestamp, words: words}
  end

  defp parse_item_user(avatar) do
    username = avatar |> Floki.find("a") |> List.first |> Floki.attribute("href") |> List.first |> String.replace("instagram://user?username=", "")
    [photo] = avatar |> Floki.find("img") |> Floki.attribute("src")
    %{username: username, profile_photo: photo}
  end

  defp parse_item_description(description) do
    {_, _, text} = description
    case text |> List.last |> String.strip do
      "liked your photo." = text ->
        %{type: "like", text: text}
      "liked your video." = text ->
        %{type: "like", text: text}
      "left a comment on your photo:" = text ->
        %{type: "comment", text: text}
      "started following you." = text ->
        %{type: "follow", text: text}
      "mentioned you in a comment:" = text ->
        %{type: "mention", text: text}
    end
  end
end
