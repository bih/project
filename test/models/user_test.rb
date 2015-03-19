require 'test_helper'

class UserTest < ActiveSupport::TestCase

  [:student, :lecturer, :admin].each do |type|
    test "try to create a #{type} without a first name" do
      user = User.create({
        last_name: (last_name = Faker::Name.last_name),
        email: Faker::Internet.user_name("John #{last_name}") + "@mmu.ac.uk",
        password: "abc1234567",
        password_confirmation: "abc1234567",
        account_type: type,
        course_name: "Computer Science"
        })

      assert user.errors.any?, "Wrongly created a #{type} when not entering a first name"
    end

    test "try to create a #{type} without a last name" do
      user = User.create({
        first_name: (first_name = Faker::Name.first_name),
        email: Faker::Internet.user_name("#{first_name} Doe") + "@mmu.ac.uk",
        password: "abc1234567",
        password_confirmation: "abc1234567",
        account_type: type,
        course_name: "Computer Science"
        })

      assert user.errors.any?, "Wrongly created a #{type} when not entering a last name"
    end

    test "try to create a #{type} without an email" do
      user = User.create({
        first_name: (first_name = Faker::Name.first_name),
        last_name: (last_name = Faker::Name.last_name),
        account_type: type,
        course_name: "Computer Science"
        })

      assert user.errors.any?, "Wrongly created a #{type} when not entering an email"
    end

    test "try to create a #{type} without a valid email" do
      user = User.create({
        first_name: (first_name = Faker::Name.first_name),
        last_name: (last_name = Faker::Name.last_name),
        email: "thisis;aninvalidemailacuk",
        password: "abc1234567",
        password_confirmation: "abc1234567",
        account_type: type,
        course_name: "Computer Science"
        })

      assert user.errors.any?, "Wrongly created a #{type} when not entering a valid email"
    end

  end

  test "try to create a user without a valid account type (admin, lecturer, student)" do
    user = User.create({
      first_name: (first_name = Faker::Name.first_name),
      last_name: (last_name = Faker::Name.last_name),
      email: Faker::Internet.user_name("#{first_name} #{last_name}") + "@mmu.ac.uk",
      password: "abc1234567",
      password_confirmation: "abc1234567",
      account_type: nil
      })

    assert user.errors.any?, "Wrongly created a user with no type"
  end

  test "try to create a student without a MMU ID" do
    user = User.create({
      first_name: (first_name = Faker::Name.first_name),
      last_name: (last_name = Faker::Name.last_name),
      email: Faker::Internet.user_name("#{first_name} #{last_name}") + "@mmu.ac.uk",
      password: "abc1234567",
      password_confirmation: "abc1234567",
      account_type: :student,
      course_name: ""
      })

    assert user.errors.any?, "Wrongly created a student when not entering a MMU ID"
  end

  test "try to create a student without a course name" do
    user = User.create({
      first_name: (first_name = Faker::Name.first_name),
      last_name: (last_name = Faker::Name.last_name),
      email: Faker::Internet.user_name("#{first_name} #{last_name}") + "@mmu.ac.uk",
      password: "abc1234567",
      password_confirmation: "abc1234567",
      account_type: :student,
      mmu_id: "12356789"
      })

    assert user.errors.any?, "Wrongly created a student when not entering a course name"
  end

  def create_valid_student
    @create_valid_student ||= User.create({
      first_name: (first_name = Faker::Name.first_name),
      last_name: (last_name = Faker::Name.last_name),
      email: Faker::Internet.user_name("#{first_name} #{last_name}") + "@mmu.ac.uk",
      password: "abc1234567",
      password_confirmation: "abc1234567",
      account_type: :student,
      course_name: "Computer Science",
      mmu_id: "12356789"
      })
  end

  test "try to create a valid student" do
    user = create_valid_student()
    assert_not user.errors.any?, "Wrongly not created a student when all fields are valid"
  end

  test "try to make a student into different user types" do
    user = create_valid_student()
    assert user.student?, "User not a student when created as a student"

    user.make_admin!
    assert user.admin?, "User not a admin when changed to admin"

    user.make_lecturer!
    assert user.lecturer?, "User not a lecturer when changed to lecturer"

    user.make_student!
    assert user.student?, "User not a student when changed to student"

    # Try a type that doesn't exist.
    user.update_attributes(:account_type => "president")
    assert user.errors.any?, "User was able to change type to president (valid options are only admin, lecturer and student)"
  end

  test "try to set MMU ID for student to invalid" do
    user = User.where_type(:student).first

    user.update_attributes(:mmu_id => "100") # too short - can only be 8 characters
    assert user.errors.any?, "Student was able to set MMU ID to 100 - too short"

    user.update_attributes(:mmu_id => "100000000") # too long - can only be 8 characters
    assert user.errors.any?, "Student was able to set MMU ID to 100000000 - too long (it is 9 characters)"

    user.update_attributes(:mmu_id => "11000900") # valid
    assert_not user.errors.any?, "Student was not able to set MMU ID to valid ID (which is 8 characters)"

    user2 = User.where_type(:student).second
    user2.update_attributes(:mmu_id => "11000900") # valid but already being used
    assert user2.errors.any?, "Student was able to set MMU ID that has already been used by another student in the system"
  end
end
