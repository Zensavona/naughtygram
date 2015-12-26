defmodule NaughtygramTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  @username System.get_env("IG_USERNAME")
  @password System.get_env("IG_PASSWORD")
  @media_id System.get_env("IG_MEDIA")
  @user_id System.get_env("IG_USER")
  @proxy_url System.get_env("PROXY_URL")

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")

    # clean the sensitive data out
    ExVCR.Config.filter_sensitive_data("signed_body=[^\"]+", "<REMOVED>")
    ExVCR.Config.filter_sensitive_data("ds_user=[^;]+", "ds_user=placeholder")
    ExVCR.Config.filter_sensitive_data("username\":\"[^\",]+", "username\":\"placeholder")
    ExVCR.Config.filter_sensitive_data("profile_pic_url\":\"[^\",]+", "profile_pic_url\":\"https:\\/\\/placeholdit.imgix.net\\/~text?txtsize=33&txt=300x300&w=300&h=300")
    ExVCR.Config.filter_sensitive_data("full_name\":\"[^\",]+", "full_name\":\"Naughty Gram")
    ExVCR.Config.filter_sensitive_data("pk\":\"[^\",]+", "pk\":\"placeholder")
    ExVCR.Config.filter_sensitive_data("fbuid\":\"[^\",]+", "fbuid\":\"placeholder")
    ExVCR.Config.filter_sensitive_data("csrftoken=[^;]+", "csrftoken=placeholder")
    
    :ok
  end

  test "can authenticate with username and password" do
    identity = Naughtygram.Identity.create_random

    use_cassette "authenticate" do
      {response, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
      assert response == :ok
      assert length(cookies) == 2
    end
  end

  test "can authenticate with username and password (proxified)" do
    identity = Naughtygram.Identity.create_random

    use_cassette "authenticate_proxy" do
      {response, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity, @proxy_url
      assert response == :ok
      assert length(cookies) == 2
    end
  end

  test "returns expected error messages" do
    identity = Naughtygram.Identity.create_random

    use_cassette "authenticate_error" do
      {response, reason} = Naughtygram.login_and_return_cookies "nah", "m8", identity
      assert response == :err
      reason = Poison.decode!(reason.body, keys: :atoms)
      assert reason.status == "fail"
    end
  end

  test "can like some media" do
    identity = Naughtygram.Identity.create_random

    use_cassette "like_media" do
      {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
      {response, _} = Naughtygram.like_media @media_id, identity, cookies
      assert response == :ok
    end
  end

  test "can like some media (proxified)" do
    identity = Naughtygram.Identity.create_random

    use_cassette "like_media_proxy" do
      {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity, @proxy_url
      {response, _} = Naughtygram.like_media @media_id, identity, cookies, @proxy_url
      assert response == :ok
    end
  end

  test "can unlike some media" do
    identity = Naughtygram.Identity.create_random

    use_cassette "unlike_media" do
      {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
      {response, _} = Naughtygram.unlike_media @media_id, identity, cookies
      assert response == :ok
    end
  end

  test "can unlike some media (proxified)" do
    identity = Naughtygram.Identity.create_random

    use_cassette "unlike_media_proxy" do
      {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity, @proxy_url
      {response, _} = Naughtygram.unlike_media @media_id, identity, cookies, @proxy_url
      assert response == :ok
    end
  end

  test "can follow a user" do
    identity = Naughtygram.Identity.create_random

    use_cassette "follow_user" do
      {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
      {response, _} = Naughtygram.follow_user @user_id, identity, cookies
      assert response == :ok
    end
  end

  test "can follow a user (proxified)" do
    identity = Naughtygram.Identity.create_random

    use_cassette "follow_user_proxy" do
      {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity, @proxy_url
      {response, _} = Naughtygram.follow_user @user_id, identity, cookies, @proxy_url
      assert response == :ok
    end
  end

  test "can unfollow a user" do
    identity = Naughtygram.Identity.create_random

    use_cassette "unfollow_user" do
      {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
      {response, _} = Naughtygram.unfollow_user @user_id, identity, cookies
      assert response == :ok
    end
  end

  test "can unfollow a user (proxified)" do
    identity = Naughtygram.Identity.create_random

    use_cassette "unfollow_user_proxy" do
      {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity, @proxy_url
      {response, _} = Naughtygram.unfollow_user @user_id, identity, cookies, @proxy_url
      assert response == :ok
    end
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

  test "can comment on a media item (proxified)" do
    identity = Naughtygram.Identity.create_random
    {_, cookies} = Naughtygram.login_and_return_cookies @username, @password, identity
    text = "notbad/10"
    use_cassette "comment_proxy" do
      {response, _} = Naughtygram.add_comment @media_id, text, identity, cookies, @proxy_url
      assert response == :ok, @proxy_url
    end
  end

end
