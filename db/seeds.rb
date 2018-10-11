require 'upload'
User.create(email: "hal.eichsteadt@gmail.com", password: "momentsnotice1")
User.create(email: "shawnzum@icloud.com", password: "zum5514")
User.create(email: "mark.colburn@sbcglobal.net", password: "965777")
User.create(email: "amastaton@aol.com ", password: "Amanda")
Upload.csv('hal_init.csv', 1)
Upload.csv('shawn_init.csv', 2)
# Upload.csv('mark_init.csv', 3, true)
