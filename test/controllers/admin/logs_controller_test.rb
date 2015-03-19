require 'test_helper'

class Admin::LogsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    john_smith = User.find_by_email("john.smith@mmu.ac.uk")
    sign_in john_smith
  end
  
  test "should get index" do
    get :index
    assert_response :success, "Could not render show all logs page"
  end

end
