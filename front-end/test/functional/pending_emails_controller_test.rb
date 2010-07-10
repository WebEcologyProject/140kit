require 'test_helper'

class PendingEmailsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pending_emails)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pending_email" do
    assert_difference('PendingEmail.count') do
      post :create, :pending_email => { }
    end

    assert_redirected_to pending_email_path(assigns(:pending_email))
  end

  test "should show pending_email" do
    get :show, :id => pending_emails(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pending_emails(:one).to_param
    assert_response :success
  end

  test "should update pending_email" do
    put :update, :id => pending_emails(:one).to_param, :pending_email => { }
    assert_redirected_to pending_email_path(assigns(:pending_email))
  end

  test "should destroy pending_email" do
    assert_difference('PendingEmail.count', -1) do
      delete :destroy, :id => pending_emails(:one).to_param
    end

    assert_redirected_to pending_emails_path
  end
end
