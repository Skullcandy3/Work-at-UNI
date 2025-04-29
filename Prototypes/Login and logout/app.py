from flask import Flask, render_template, request, redirect, url_for, flash
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
import sqlite3
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = 'your-secret-key'

# Setup Flask-Login
login_manager = LoginManager()
login_manager.login_view = 'login'
login_manager.init_app(app)

DATABASE = 'users.db'

# ---- User Loader for Flask-Login ----
class User(UserMixin):
    def __init__(self, id, nickname, gmail, password, class_id):
        self.id = id
        self.nickname = nickname
        self.gmail = gmail
        self.password = password
        self.class_id = class_id

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

# ---- Routes ----

@app.route('/')
@login_required
def index():
    return render_template('index.html', user=current_user)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        gmail = request.form['gmail']
        password = request.form['password']
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE gmail = ?", (gmail,))
        user_data = cursor.fetchone()
        conn.close()
        if user_data and check_password_hash(user_data[3], password):
            user = User(*user_data)
            login_user(user)
            return redirect(url_for('index'))
        else:
            flash("Invalid email or password.")
    return render_template('login-form.html')

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

@app.route('/admin')
@login_required
def admin_panel():
    if current_user.class_id != 2:
        flash("You are not authorized to view this page.")
        return redirect(url_for('index'))

    conn = sqlite3.connect(DATABASE)
    c = conn.cursor()
    c.execute("SELECT id, nickname, gmail, class_id FROM users WHERE id != ?", (current_user.id,))
    users = c.fetchall()
    conn.close()

    return render_template('admin.html', user=current_user, users=users)

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

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

# ---- Run Flask App ----
if __name__ == '__main__':
    app.run(debug=True)
# Note: Make sure to create the database and users table before running this app.
# You can use the provided make_db.py script to create the database and insert an admin user.