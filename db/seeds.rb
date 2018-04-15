# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'upload'
User.create(email: "hal.eichsteadt@gmail.com", password: "password")
User.create(email: "shawnzum@icloud.com", password: "password")
Upload.csv('040518.csv', 1)
Upload.csv('shawn033118.csv', 2)
