require 'test_helper'

class LectureTest < ActiveSupport::TestCase
  test "create a lecture with no data" do
    lecture = Lecture.create()
    assert_not lecture.valid?, "Lecture can be created without any data"
  end

  test "create a lecture with no lecture name" do
    lecture = Lecture.create({
      lecture_type: "lecture",
      lecture_room: "E407",
      unit_id: 1,
      user_id: 2,
      start_time: Time.now.beginning_of_hour,
      end_time: Time.now.beginning_of_hour + 1.hour
      })

    assert lecture.errors.any?, "Lecture can be created without a lecture name"
    assert_equal lecture.errors.full_messages, ["Lecture name can't be blank"], "Errors for creating lecture are not as expected"
  end

  test "create a lecture with no lecture type" do
    lecture = Lecture.create({
      lecture_name: "Example Lecture",
      lecture_room: "E407",
      unit_id: 1,
      user_id: 2,
      start_time: Time.now.beginning_of_hour,
      end_time: Time.now.beginning_of_hour + 1.hour
      })
    
    assert lecture.errors.any?, "Lecture can be created without a lecture type"
    assert_equal lecture.errors.full_messages, ["Lecture type can't be blank"], "Errors for creating lecture are not as expected"
  end

  test "create a lecture with no lecture room" do
    lecture = Lecture.create({
      lecture_name: "Example Lecture",
      lecture_type: "lecture",
      unit_id: 1,
      user_id: 2,
      start_time: Time.now.beginning_of_hour,
      end_time: Time.now.beginning_of_hour + 1.hour
      })
    
    assert lecture.errors.any?, "Lecture can be created without a lecture room"
    assert_equal lecture.errors.full_messages, ["Lecture room can't be blank"], "Errors for creating lecture are not as expected"
  end

  test "create a lecture with no unit ID" do
    lecture = Lecture.create({
      lecture_name: "Example Lecture",
      lecture_type: "lecture",
      lecture_room: "E407",
      user_id: 2,
      start_time: Time.now.beginning_of_hour,
      end_time: Time.now.beginning_of_hour + 1.hour
      })
    
    assert lecture.errors.any?, "Lecture can be created without a unit ID"
    assert_equal lecture.errors.full_messages, ["Unit can't be blank"], "Errors for creating lecture are not as expected"
  end

  test "create a lecture with no lecturer ID" do
    lecture = Lecture.create({
      lecture_name: "Example Lecture",
      lecture_type: "lecture",
      lecture_room: "E407",
      unit_id: 1,
      start_time: Time.now.beginning_of_hour,
      end_time: Time.now.beginning_of_hour + 1.hour
      })
    
    assert lecture.errors.any?, "Lecture can be created without a lecturer ID"
    assert_equal lecture.errors.full_messages, ["User can't be blank"], "Errors for creating lecture are not as expected"
  end

  test "create a lecture with no start time" do
    lecture = Lecture.create({
      lecture_name: "Example Lecture",
      lecture_type: "lecture",
      lecture_room: "E407",
      unit_id: 1,
      user_id: 2,
      end_time: Time.now.beginning_of_hour + 1.hour
      })

    assert_not lecture.valid?, "Lecture can be created without a start time"
  end

  test "create a lecture with no end time" do
    lecture = Lecture.create({
      lecture_name: "Example Lecture",
      lecture_type: "lecture",
      lecture_room: "E407",
      unit_id: 1,
      user_id: 2,
      start_time: Time.now.beginning_of_hour
      })
    
    assert_not lecture.valid?, "Lecture can be created without an end time"
  end

  test "create a lecture on day and find it on that day" do
    time = Time.now + 3.years + 3.days

    lecture = Lecture.create({
      lecture_name: "Example Lecture",
      lecture_type: "lecture",
      lecture_room: "E407",
      unit_id: 1,
      user_id: 2,
      start_time: time.beginning_of_hour,
      end_time: time.beginning_of_hour + 1.hour
      })
    
    assert_equal Lecture.on_day(time), [lecture], "Lecture.on_day(day) does not correctly identify hackathons on that day"
  end

  test "test Lecture.where_unit function" do
    assert_equal Lecture.where_unit(1), [Lecture.find(1)], "Lecture.where_unit(unit_id) is not functioning properly"
  end

  test "test Lecture.where_user function" do
    assert_equal Lecture.where_user(2), Lecture.where(:user_id => 2), "Lecture.where_user(user_id) is not functioning properly"
  end

  test "test Lecture.calculate_attendance_for_student function" do
    user = User.where_type(:student).find(3)
    
    start_time = Time.now
    end_time = start_time + 1.hour

    Lecture.find(1).update_attributes({ start_time: start_time, end_time: end_time })
    Lecture.find(3).update_attributes({ start_time: start_time, end_time: end_time })

    Lecture.find(1).check_in_student!(user)
    Lecture.find(3).check_in_student!(user)

    assert_equal Lecture.calculate_attendance_for_student(Lecture.all, user), 100, "Lecture.calculate_attendance_for_student(array, student) is not functioning properly"
  end

  test "test Lecture.calculate_punctuality_for_student function for 0 minutes" do
    user = User.where_type(:student).find(3)
    
    start_time = Time.now - 0.minutes
    end_time = start_time + 1.hour

    Lecture.find(1).update_attributes({ start_time: start_time, end_time: end_time })
    Lecture.find(3).update_attributes({ start_time: start_time, end_time: end_time })

    Lecture.find(1).check_in_student!(user)
    Lecture.find(3).check_in_student!(user)

    lecture_punctuality = Lecture.all.map{ |lecture| lecture.average_minutes_of_student(user) }.select(&:present?)
    assert_equal Lecture.calculate_punctuality_for_student(lecture_punctuality), 0, "Lecture.calculate_attendance_for_punctuality(array, student) is not functioning properly"
  end

  test "test Lecture.calculate_punctuality_for_student function for 30 minutes" do
    user = User.where_type(:student).find(3)
    
    start_time = Time.now - 30.minutes
    end_time = start_time + 1.hour

    Lecture.find(1).update_attributes({ start_time: start_time, end_time: end_time })
    Lecture.find(3).update_attributes({ start_time: start_time, end_time: end_time })

    Lecture.find(1).check_in_student!(user)
    Lecture.find(3).check_in_student!(user)

    lecture_punctuality = Lecture.all.map{ |lecture| lecture.average_minutes_of_student(user) }.select(&:present?)
    assert_equal Lecture.calculate_punctuality_for_student(lecture_punctuality), 30, "Lecture.calculate_attendance_for_punctuality(array, student) is not functioning properly"
  end

  test "test Lecture.calculate_punctuality_for_student function for n minutes" do
    user = User.where_type(:student).find(3)

    random_mins = 20 + rand(25)
    
    start_time = Time.now - random_mins.minutes
    end_time = start_time + 1.hour

    Lecture.find(1).update_attributes({ start_time: start_time, end_time: end_time })
    Lecture.find(3).update_attributes({ start_time: start_time, end_time: end_time })

    Lecture.find(1).check_in_student!(user)
    Lecture.find(3).check_in_student!(user)

    lecture_punctuality = Lecture.all.map{ |lecture| lecture.average_minutes_of_student(user) }.select(&:present?)
    assert_equal Lecture.calculate_punctuality_for_student(lecture_punctuality), random_mins, "Lecture.calculate_attendance_for_punctuality(array, student) is not functioning properly"
  end
end