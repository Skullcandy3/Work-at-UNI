# Library imports
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
import sqlite3
from werkzeug.security import generate_password_hash, check_password_hash
# Standard library imports from python
import random
import secrets

# Flask app setup
app = Flask(__name__)
app.secret_key = secrets.token_hex(32) # Generate a random secret key for session management

#--- Setup Flask-Login ---#
login_manager = LoginManager()
login_manager.login_view = 'login'
login_manager.init_app(app)

DATABASE = 'users.db'
HISTORY_DB = 'players_stats.db'

# ---- User Loader for Flask-Login ----#
class User(UserMixin):
    def __init__(self, id, nickname, gmail, password, class_id, points):
        self.id = id
        self.nickname = nickname
        self.gmail = gmail
        self.password = password
        self.class_id = class_id
        self.points = points


@login_manager.user_loader
def load_user(user_id):
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user_data = cursor.fetchone()
    conn.close()
    if user_data:
        return User(*user_data)
    return None

#-----------------#
# ---- Routes ----#
#-----------------#

# ---- Home Route ----
@app.route('/')
@login_required
def index():
    return render_template('index.html', user=current_user)

# ---- History Route ----
@app.route("/get_random_word")
def get_random_word():
    conn = sqlite3.connect("words.db")
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM words")
    total = cursor.fetchone()[0]
    random_id = random.randint(1, total)
    cursor.execute("SELECT word FROM words WHERE id = ?", (random_id,))
    row = cursor.fetchone()
    conn.close()
    if current_user.class_id == 2:
        print(f"Selected random word with ID {random_id}: {row[0] if row else 'CRANE'}")
    return jsonify({"word": row[0] if row else "CRANE"})

# ---- Check Word AJAX CALL ----
@app.route("/check_word")
def check_word():
    word = request.args.get("word")
    if not word:
        return jsonify({"correct": False})
    conn = sqlite3.connect("words.db")
    cursor = conn.cursor()
    cursor.execute("SELECT 1 FROM words WHERE word = ?", (word,))
    result = cursor.fetchone()
    conn.close()

    return jsonify({"correct": result is not None})

# ---- Add Points Route ----
@app.route('/add_points')
@login_required
def add_points():
    points = request.args.get("points", type=int)
    if points is None:
        return jsonify({"error": "Missing or invalid 'points' parameter"}), 400

    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET points = points + ? WHERE id = ?", (points, current_user.id))
    conn.commit()
    conn.close()

    return jsonify({"new_points": current_user.points + points})

# ---- Login Route ----
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        gmail = request.form['gmail']
        password = request.form['password']
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        cursor.execute("SELECT id, nickname, gmail, password, class_id, points FROM users WHERE gmail = ?", (gmail,))
        user_data = cursor.fetchone()
        if user_data and check_password_hash(user_data[3], password):
            user = User(*user_data)
            login_user(user)
            return redirect(url_for('index'))
        else:
            flash("Invalid email or password.")
    return render_template('login-form.html')

# ---- Check Nickname Availability AJAX CALL ----
@app.route("/check_nickname")
def check_nickname():
    nickname = request.args.get("nickname")
    if not nickname:
        return jsonify({"available": False})

    conn = sqlite3.connect("users.db")
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM users WHERE nickname = ?", (nickname,))
    result = cur.fetchone()
    conn.close()

    return jsonify({"available": result is None})

# ---- Register User Route ----
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        nickname = request.form['nickname']
        gmail = request.form['gmail']
        password = request.form['password']
        confirm_password = request.form['confirm_password']

        # Basic validation
        if not nickname or not gmail or not password or password != confirm_password:
            flash("Please fill out all fields correctly.")
            return redirect(url_for('register'))

        hashed_password = generate_password_hash(password)
        try:
            conn = sqlite3.connect(DATABASE)
            cursor = conn.cursor()
            cursor.execute("INSERT INTO users (nickname, gmail, password, class_id) VALUES (?, ?, ?, ?)",
                           (nickname, gmail, hashed_password, 1))
            conn.commit()
            conn.close()
            flash("User registered successfully. Please log in.")
            return redirect(url_for('login'))
        except sqlite3.IntegrityError:
            flash("This Gmail is already registered.")
    return render_template('registeruser-form.html')

# ---- Admin Panel Route ----
@app.route('/admin')
@login_required
def admin_panel():
    if current_user.class_id != 2:
        flash("You are not authorized to view this page.")
        return redirect(url_for('index'))

    conn = sqlite3.connect(DATABASE)
    c = conn.cursor()
    c.execute("SELECT id, nickname, gmail, class_id, points FROM users WHERE id != ?", (current_user.id,))
    users = c.fetchall()
    conn.close()

    return render_template('admin.html', user=current_user, users=users)

# ---- Delete user Route ----
@app.route('/delete_user/<int:user_id>', methods=['POST'])
@login_required
def delete_user(user_id):
    if current_user.class_id != 2:
        flash("Unauthorized action.")
        return redirect(url_for('index'))
    
    if current_user.id == user_id:
        flash("You cannot delete yourself.")
        return redirect(url_for('admin_panel'))

    conn = sqlite3.connect(DATABASE)
    c = conn.cursor()
    c.execute("DELETE FROM users WHERE id = ?", (user_id,))
    conn.commit()
    conn.close()
    flash("User deleted successfully.")
    return redirect(url_for('admin_panel'))

# ---- Logout Route ----
@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

# ---- Show Leaderboard ----
@app.route('/leaderboard')
def leaderboard():
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT nickname, points FROM users WHERE points > 0 ORDER BY points DESC LIMIT 10")
    leaderboard_data = cursor.fetchall()
    data = [{"nickname": row[0], "points": row[1]} for row in leaderboard_data]
    conn.close()
    
    return jsonify(data)

# ---- Run Flask App ----
if __name__ == '__main__':
    app.run(debug=True)

