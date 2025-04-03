from flask import Flask, render_template, request, redirect, url_for
import sqlite3
import re

app = Flask(__name__)

DATABASE = 'database.db'

def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row  # Enables name-based access to columns
    return conn

# Predefined grade order for sorting grades (A first, then B, etc.)
grade_order = {'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6}

# --------------------------------------------------
# / route: Overview page
@app.route("/")
def index():
    conn = get_db_connection()
    courses = conn.execute("SELECT * FROM courses ORDER BY id").fetchall()
    students = conn.execute("SELECT * FROM students ORDER BY student_no").fetchall()
    conn.close()
    return render_template("index.html", courses=courses, students=students)

# --------------------------------------------------
# /student/{student_no} route: Shows a student profile and all their grades
@app.route("/student/<int:student_no>")
def student_profile(student_no):
    conn = get_db_connection()
    
    # Fetch student details
    student = conn.execute("SELECT * FROM students WHERE student_no = ?", (student_no,)).fetchone()

    # Fetch grades and join with courses to get course names
    grades = conn.execute("""
        SELECT grades.course_id, courses.name AS course_name, grades.grade 
        FROM grades 
        JOIN courses ON grades.course_id = courses.Id  
        WHERE grades.student_no = ?
    """, (student_no,)).fetchall()

    conn.close()

    if student is None:
        return "Student not found", 404

    return render_template("student.html", student=student, grades=grades)

# --------------------------------------------------
# /course/{course_id} route: Shows a course with all its grades and a grade summary
@app.route("/course/<course_id>")
def course_page(course_id):
    conn = get_db_connection()
    course = conn.execute("SELECT * FROM courses WHERE id = ?", (course_id,)).fetchone() 
    if not course:
        conn.close()
        return f"Emne med kode {course_id} ikke funnet", 404

    # Join grades with student info to get student names
    course_grades = conn.execute(
        "SELECT g.student_no, g.grade, s.name as student_name "
        "FROM grades g LEFT JOIN students s ON g.student_no = s.student_no "
        "WHERE g.course_id = ?",  # Correct the column name here as well
        (course_id,)
    ).fetchall()

    # Convert to list for sorting
    course_grades = list(course_grades)
    
    # Sort by predefined grade order
    course_grades.sort(key=lambda x: grade_order.get(x['grade'], 99))
    
    # Build a summary: count of each grade given (only include grades with count > 0)
    summary = {}
    for g in course_grades:
        grade = g['grade']
        summary[grade] = summary.get(grade, 0) + 1

    conn.close()
    return render_template("course.html", course=course, grades=course_grades, summary=summary)

# --------------------------------------------------
# /add_student route: Form to add a new student
@app.route("/add_student", methods=["GET", "POST"])
def add_student():
    if request.method == "POST":
        name = request.form.get("name", "").strip()
        
        # Check if name is empty
        if not name:
            return render_template("student_form_error.html", error="Studentnavnet kan ikke være tomt")
        
        # Check if name contains only letters and spaces
        if not re.match(r"^[A-Za-zÆØÅæøå\s]+$", name):
            return render_template("student_form_error.html", error="Studentnavnet kan bare inneholde bokstaver og mellomrom")
        
        conn = get_db_connection()
        # Determine new student number: use max(student_no) + 1 or start at 100000
        row = conn.execute("SELECT MAX(student_no) as max_no FROM students").fetchone()
        new_student_no = row["max_no"] + 1 if row["max_no"] is not None else 100000
        
        if new_student_no > 999999:
            conn.close()
            return "Ingen ledige studentnumre", 500
        
        conn.execute("INSERT INTO students (student_no, name) VALUES (?, ?)", (new_student_no, name))
        conn.commit()
        conn.close()
        return redirect(url_for("index"))
    else:
        return render_template("add_student.html")
# --------------------------------------------------
# /delete_student: Remove students that i added myself!
@app.route("/delete_student/<int:student_no>", methods=["POST"])
def delete_student(student_no):
    conn = get_db_connection()
    conn.execute("DELETE FROM students WHERE student_no = ?", (student_no,))
    conn.commit()
    conn.close()
    return redirect(url_for("index"))

# --------------------------------------------------
# /add_grade route: Form to add a new grade for a course and student
@app.route("/add_grade", methods=["GET", "POST"])
def add_grade():
    if request.method == "POST":
        # Get form values and strip whitespace
        student_no = request.form.get("student_no", "").strip()
        course_id = request.form.get("course_id", "").strip()
        grade = request.form.get("grade", "").strip()
        
        # Check if any field is still "Select" or empty
        if (not student_no or not course_id or not grade or
            student_no == "Select" or course_id == "Select" or grade == "Select"):
            conn = get_db_connection()
            students = conn.execute("SELECT * FROM students ORDER BY student_no").fetchall()
            courses = conn.execute("SELECT * FROM courses ORDER BY id").fetchall()
            conn.close()
            return render_template("add_grade_error.html", 
                                   error="Alle felt må fylles ut", 
                                   students=students, courses=courses)
        
        # Attempt to convert student_no and course_id to integers
        try:
            student_no_int = int(student_no)
            course_id_str = str(course_id)
            grade_str = str(grade)
        except ValueError:
            conn = get_db_connection()
            students = conn.execute("SELECT * FROM students ORDER BY student_no").fetchall()
            courses = conn.execute("SELECT * FROM courses ORDER BY id").fetchall()
            conn.close()
            return render_template("add_grade_error.html", 
                                   error="Feil datatype for studentnummer eller emnekode", 
                                   students=students, courses=courses)
        
        # Insert into grades table using the proper column names
        try:
            conn = get_db_connection()
            conn.execute("INSERT INTO grades (student_no, course_id, grade) VALUES (?, ?, ?)",
                         (student_no_int, course_id_str, grade_str))
            conn.commit()
            conn.close()
            return render_template("add_grade_succed.html")
        except sqlite3.IntegrityError as e:
            conn.close()
            return render_template("add_grade_error.html", error=f"Database error: {e}")
    else:
        conn = get_db_connection()
        students = conn.execute("SELECT * FROM students ORDER BY student_no").fetchall()
        courses = conn.execute("SELECT * FROM courses ORDER BY id").fetchall()
        conn.close()
        return render_template("add_grade.html", students=students, courses=courses)

if __name__ == "__main__":
    app.run(debug=True)
    