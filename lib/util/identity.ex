defmodule Naughtygram.Identity do
  @moduledoc """
  Creates identities for users, which are basically a set
  of bullshit device identifiers to send to the API.
  """

  @doc """
  Creates a pseudorandom set of device identifiers, run this once
  the first time a user makes a request, and save the identifiers
  for further reqests. I don't know exactly how forensic Instagram's
  security measures are, but it looks pretty odd if a different "device"
  makes each request over a single session... 
  """
  def create_random do
    user_agent = generate_random_user_agent
    guid = generate_guid
    device_id = generate_device_id(guid)

    %{user_agent: user_agent, guid: guid, device_id: device_id}
  end

  defp generate_random_user_agent do
    resolution = ['720x1280', '320x480', '480x800', '1024x768', '1280x720', '768x1024', '480x320'] |> Enum.random

    version = ['GT-N7000', 'SM-N9000', 'GT-I9220', 'GT-I9100'] |> Enum.random
    dpi = ['120', '160', '320', '240'] |> Enum.random

    "Instagram 4.1.1 Android (10/2.4.4; #{dpi}; #{resolution}; samsung; #{version}; #{version}; smdkc210; en_US)"
  end

  defp generate_guid do
    random_vals = [
                    Enum.random(0..65535),
                    Enum.random(0..65535),
                    Enum.random(0..65535),
                    Enum.random(16384..20479),
                    Enum.random(32768..49151),
                    Enum.random(0..65535),
                    Enum.random(0..65535),
                    Enum.random(0..65535)
                  ]

    ExPrintf.sprintf("%04x%04x-%04x-%04x-%04x-%04x%04x%04x", random_vals)
  end

  defp generate_device_id(guid) do
    "android-#{guid}"
  end
end
