defmodule Naughtygram.Crypto do
  @moduledoc """
  Handles some very basic crypto functionality
  """
  @key "b4a23f5e39b5929e0666ac5de94c89d1618a2916"

  @doc """
  Takes some data which is to be sent as the body, and returns a signed body
  which is ready to send to the server.
  """
  def signed_body(data) do
    signature = sign(data)
    data = URI.encode(data, &(URI.char_unreserved?/1))
    "ig_sig_key_version=4&signed_body=#{signature}.#{data}" # &src=single&d=0
  end

  defp sign(data) do
    :crypto.hmac(:sha256, @key, data) |> Base.encode16 |> String.downcase
  end
end
