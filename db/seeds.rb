# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create({
    first_name: "John",
    last_name: "Smith",
    email: "john@smith.com",
    password: "john@smith.com",
    password_confirmation: "john@smith.com",
    account_type: "admin",
    mmu_id: ""
  })

User.create({
    first_name: "Bilawal",
    last_name: "Hameed",
    email: "11026592@stu.mmu.ac.uk",
    password: "ODYEaKETAN",
    password_confirmation: "ODYEaKETAN",
    account_type: "student",
    mmu_id: "11026592"
  })