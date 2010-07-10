require 'test_helper'

class TrendsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trends)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trend" do
    assert_difference('Trend.count') do
      post :create, :trend => { }
    end

    assert_redirected_to trend_path(assigns(:trend))
  end

  test "should show trend" do
    get :show, :id => trends(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => trends(:one).to_param
    assert_response :success
  end

  test "should update trend" do
    put :update, :id => trends(:one).to_param, :trend => { }
    assert_redirected_to trend_path(assigns(:trend))
  end

  test "should destroy trend" do
    assert_difference('Trend.count', -1) do
      delete :destroy, :id => trends(:one).to_param
    end

    assert_redirected_to trends_path
  end
end
