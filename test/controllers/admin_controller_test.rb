require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    john_smith = User.find_by_email("john.smith@mmu.ac.uk")
    sign_in john_smith
  end
  
  test "should get index" do
    get :index
    assert_response :success, "Could not access admin index page."
  end

end
