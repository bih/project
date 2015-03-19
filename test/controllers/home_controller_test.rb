require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get index logged out" do
    get :index
    assert_response :success, "Did not render index page for non-logged in guests"
  end

  test "should get index logged in for non-students" do
    john_smith = User.find_by_email("john.smith@mmu.ac.uk")
    sign_in john_smith

    get :index
    assert_response :success, "Did not render index page for non-students"
  end

  test "should get student index logged in for students" do
    bilawal_hameed = User.find_by_email("11026592@stu.mmu.ac.uk")
    sign_in bilawal_hameed

    get :index
    assert_response :success, "Did not render student-index page for students"
  end

  test "should get about" do
    get :about
    assert_response :success, "Did not render about page"
  end

end
