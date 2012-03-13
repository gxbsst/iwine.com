require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  test "should get basic" do
    get :basic
    assert_response :success
  end

  test "should get privacy" do
    get :privacy
    assert_response :success
  end

  test "should get invite" do
    get :invite
    assert_response :success
  end

  test "should get sync" do
    get :sync
    assert_response :success
  end

  test "should get account" do
    get :account
    assert_response :success
  end

end
