from flask import Flask, request, jsonify, g
import sqlite3

app = Flask(__name__)
DATABASE = "music.db"

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = sqlite3.Row
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

@app.route("/albums")
def albums():
    db = get_db()
    cur = db.execute("SELECT album_id, artist, title FROM albums")
    albums = [dict(row) for row in cur.fetchall()]
    return jsonify(albums)

@app.route("/albuminfo")
def albuminfo():
    album_id = request.args.get("album_id")

    if not album_id:
        return jsonify({"error": "Missing album_id"}), 400

    try:
        album_id = int(album_id)  # Ensure album_id is an integer
    except ValueError:
        return jsonify({"error": "Invalid album_id"}), 400

    db = get_db()
    
    # Get album details
    cur = db.execute("SELECT title, artist, cover_img FROM albums WHERE album_id = ?", (album_id,))
    album = cur.fetchone()

    if not album:
        return jsonify({"error": "Album not found"}), 404

    # Get all tracks from the album
    cur = db.execute("SELECT track_id, title, length FROM tracks WHERE album_id = ? ORDER BY track_id", (album_id,))
    tracks = [{"id": row["track_id"], "title": row["title"], "duration": row["length"]} for row in cur.fetchall()]

    if not tracks:
        print(f"Warning: No tracks found for album_id {album_id}")  # Debugging

    # Convert length format "MM:SS" to total seconds and sum it
    def time_to_seconds(time_str):
        if time_str:
            minutes, seconds = map(int, time_str.split(":"))
            return minutes * 60 + seconds
        return 0

    total_duration_seconds = sum(time_to_seconds(track["duration"]) for track in tracks)

    # Convert total duration back to MM:SS format
    total_duration = f"{total_duration_seconds // 60}:{total_duration_seconds % 60:02d}"

    return jsonify({
        "title": album["title"],
        "artist": album["artist"],
        "cover": album["cover_img"],
        "tracks": tracks,
        "total_duration": total_duration
    })


@app.route("/sample")
def sample():
    return app.send_static_file("index_static.html")

@app.route("/")
def index():
    return app.send_static_file("index.html")

if __name__ == "__main__":
    app.run(debug=True)