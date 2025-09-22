from werkzeug.security import generate_password_hash
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
        class_id INTEGER NOT NULL,
        points INTEGER DEFAULT 0
    )
''')

# Admin user and example users 
users = [
    ("admin", "admin@gmail.com", generate_password_hash("admin123"), 2, 100000),
    ("Donald Duck", "donald@gmail.com", generate_password_hash("donald123"), 1, 26),
    ("Mickey Mouse", "mickey@gmail.com", generate_password_hash("mickey123"), 1, 10),
    ("Goofy", "goofy@gmail.com", generate_password_hash("goofy123"), 1, 2),
    ("Minnie Mouse", "minnie@gmail.com", generate_password_hash("minnie123"), 1, 5),
]

# Insert users in db
for user in users:
    try:
        c.execute("INSERT INTO users (nickname, gmail, password, class_id, points) VALUES (?, ?, ?, ?, ?)", user)
        print(f"User {user[0]} added successfully.")
    except sqlite3.IntegrityError:
        print(f"User {user[0]} already exists.")

conn.commit()
conn.close()