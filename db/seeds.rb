require 'upload'
User.create(email: "hal.eichsteadt@gmail.com", password: "momentsnotice1")
User.create(email: "shawnzum@icloud.com", password: "zum5514")
User.create(email: "mark.colburn@sbcglobal.net", password: "965777")
User.create(email: "amastaton@aol.com ", password: "Amanda")

Upload.csv([
  {csv: 'hal_init.csv', user_id: 1},
  {csv: 'hal_083118.csv', user_id: 1},
  {csv: 'hal093018.csv', user_id: 1}
])
# Upload.csv([
#   {csv: 'shawn_init.csv', user_id: 2},
#   {csv: 'shawn083118.csv', user_id: 2},
#   {csv: 'shawn093018.csv', user_id: 2}
# ])
# Upload.csv([
#   {csv: 'mark_init.csv', user_id: 3},
#   {csv: 'mark083118.csv', user_id: 3},
#   {csv: 'mark093018.csv', user_id: 3}
# ])
# Upload.csv([
#   {csv: 'amanda_init.csv', user_id: 4},
#   {csv: 'amanda093018.csv', user_id: 4}
# ])

# Upload.csv('hal093018.csv', 1)
# Upload.csv('shawn_init.csv', 2)
# Upload.csv('mark_init.csv', 3)
# Upload.csv('amanda_init.csv', 4)
# Upload.csv('shawn093018.csv', 2)
# Upload.csv('mark093018.csv', 3)
# Upload.csv('amanda093018.csv', 4)
# Upload.csv('test_data.csv', 1)
