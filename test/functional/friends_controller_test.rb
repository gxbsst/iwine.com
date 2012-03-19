require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get invite" do
    get :invite
    assert_response :success
  end

  test "should get follow" do
    get :follow
    assert_response :success
  end

  test "should get follow_cancel" do
    get :follow_cancel
    assert_response :success
  end

end
