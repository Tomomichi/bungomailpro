# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.create(
  id: "37f4e418-227e-485d-ab41-c50f887b9956",
  email: "info@notsobad.jp",
  created_at: Time.zone.parse("2018/4/1"),
  updated_at: Time.zone.parse("2018/4/1"),
  activation_state: "active"
)
