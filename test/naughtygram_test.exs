defmodule NaughtygramTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  @username System.get_env("IG_USERNAME")
  @password System.get_env("IG_PASSWORD")
  @media_id System.get_env("IG_MEDIA")
  @user_id System.get_env("IG_USER")

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "can authenticate with username and password" do
    identity = Naughtygram.Identity.create_random

    {response, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
    assert response == :ok
    assert length(cookies) == 7
  end

  test "returns expected error messages" do
    identity = Naughtygram.Identity.create_random

    {response, reason} = Naughtygram.login_and_return_cookies "nah", "m8", identity
    assert response == :err
    reason = Poison.decode!(reason.body, keys: :atoms)
    assert reason.status == "fail"
  end

  test "can like some media" do
    identity = Naughtygram.Identity.create_random
    {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
    {response, _} = Naughtygram.like_media @media_id, identity, cookies
    assert response == :ok
  end

  test "can unlike some media" do
    identity = Naughtygram.Identity.create_random
    {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
    {response, _} = Naughtygram.unlike_media @media_id, identity, cookies
    assert response == :ok
  end

  test "can follow a user" do
    identity = Naughtygram.Identity.create_random
    {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
    {response, _} = Naughtygram.follow_user @user_id, identity, cookies
    assert response == :ok
  end

  test "can unfollow a user" do
    identity = Naughtygram.Identity.create_random
    {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
    {response, _} = Naughtygram.unfollow_user @user_id, identity, cookies
    assert response == :ok
  end

  test "can comment on a media item" do
    identity = Naughtygram.Identity.create_random
    {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
    text = "notbad/10"
    use_cassette "comment" do
      {response, _} = Naughtygram.add_comment @media_id, text, identity, cookies
      assert response == :ok
    end
  end

end
