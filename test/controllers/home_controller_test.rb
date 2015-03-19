require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get index logged out" do
    get :index
    assert_response :success
  end

  test "should get index logged in" do
    john_smith = User.find_by_email("john.smith@mmu.ac.uk")
    sign_in john_smith

    get :index
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

end
