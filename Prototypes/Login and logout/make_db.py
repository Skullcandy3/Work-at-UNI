import sqlite3

conn = sqlite3.connect('users.db')
c = conn.cursor()

# Create the users table
c.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT NOT NULL,
        gmail TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        class_id INTEGER NOT NULL
    )
''')

# Create an admin user with class_id = 2
from werkzeug.security import generate_password_hash
admin_nickname = "admin"
admin_gmail = "admin@gmail.com"
admin_password = generate_password_hash("admin123")
admin_class_id = 2

try:
    c.execute("INSERT INTO users (nickname, gmail, password, class_id) VALUES (?, ?, ?, ?)",
              (admin_nickname, admin_gmail, admin_password, admin_class_id))
    print("Admin user created.")
except sqlite3.IntegrityError:
    print("Admin user already exists.")

conn.commit()
conn.close()
