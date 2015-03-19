require 'test_helper'

class Admin::UserControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    john_smith = User.find_by_email("john.smith@mmu.ac.uk")
    sign_in john_smith
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

end
