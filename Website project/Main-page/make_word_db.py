import sqlite3

# Txt file with all words
txt_path = r'C:\Users\Dan\Documents\University\DAT310\Group-101\valid-wordle-words.txt'

conn = sqlite3.connect('words.db')
c = conn.cursor()

# Create the words table
c.execute('''
    CREATE TABLE IF NOT EXISTS words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL
    )
''')


try:
    with open(txt_path, 'r') as file:
        words = [line.strip() for line in file if line.strip()]
    c.executemany("INSERT INTO words (word) VALUES (?)", [(word,) for word in words])
    print(f"{len(words)} words inserted into the database.")
except FileNotFoundError:
    print(f"File {txt_path} not found.")

conn.commit()
conn.close()