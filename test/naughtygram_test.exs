defmodule NaughtygramTest do
  use ExUnit.Case

  @username System.get_env("IG_USERNAME")
  @password System.get_env("IG_PASSWORD")
  @media_id System.get_env("IG_MEDIA")
  @user_id System.get_env("IG_USER")

  test "can authenticate with username and password" do
    identity = Naughtygram.Identity.create_random

    {response, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
    assert response == :ok
    assert length(cookies) == 6
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
    text = "Film or digitial? Amazing tones :D"
    {response, _} = Naughtygram.add_comment @media_id, text, identity, cookies
    assert response == :ok
  end

end
