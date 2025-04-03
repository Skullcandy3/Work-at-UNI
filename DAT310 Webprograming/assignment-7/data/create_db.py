import sqlite3

def create_music_db():
    # Connect to the database (will create it if it doesn't exist)
    conn = sqlite3.connect('music.db')
    cursor = conn.cursor()
    
    # Create albums table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS albums (
        album_id INTEGER PRIMARY KEY,
        artist TEXT NOT NULL,
        title TEXT NOT NULL,
        cover_img TEXT NOT NULL
    )
    """)
    
    # Create tracks table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS tracks (
        track_id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        length TEXT NOT NULL,
        FOREIGN KEY (album_id) REFERENCES albums(album_id)
    )
    """)
    
    # Insert album data
    albums = [
        (1, "Coldplay", "A Rush of Blood to the Head", "Coldplay-ARushofBlood.jpg"),
        (2, "Guns N' Roses", "Use Your Illusion I", "GnR-UseYourIllusion1.jpg"),
        (3, "Guns N' Roses", "Use Your Illusion II", "GnR-UseYourIllusion2.jpg"),
        (4, "Nightwish", "Imaginaerum", "Nightwish-Imaginaerum.jpg"),
        (5, "Radiohead", "In Rainbows", "InRainBows_Radiohead.jpg"),
        (6, "Foo fighters", "The Colur and the Shape", "TheColourAndTheShape.jpg"),
        (7, "Nirvana", "Nevermind (Remastered)", "Nevermind.jpg"),
        (8, "Nirvana", "In Utero", "InUtero.jpg"),
        (9, "Rammstein", "Mutter", "Mutter.jpg"),
        (10, "The Rolling Stones", "Let It Bleed", "Let-it-bleed.jpg"),
    ]
    cursor.executemany("INSERT INTO albums VALUES (?, ?, ?, ?)", albums)
    
    # Insert track data
    tracks = [
        (1, "Politik", "5:18"),
        (1, "In My Place", "3:48"),
        (1, "God Put a Smile upon Your Face", "4:57"),
        (1, "The Scientist", "5:09"),
        (1, "Clocks", "5:07"),
        (1, "Daylight", "5:27"),
        (1, "Green Eyes", "3:43"),
        (1, "Warning Sign", "5:31"),
        (1, "A Whisper", "3:58"),
        (1, "A Rush of Blood to the Head", "5:51"),
        (1, "Amsterdam", "5:19"),
        (2, "Right Next Door to Hell", "3:02"),
        (2, "Dust N' Bones", "4:58"),
        (2, "Live and Let Die", "3:04"),
        (2, "Don't Cry", "4:44"),
        (2, "Perfect Crime", "2:23"),
        (2, "You Ain't the First", "2:36"),
        (2, "Bad Obsession", "5:28"),
        (2, "Back Off Bitch", "5:03"),
        (2, "Double Talkin' Jive", "3:23"),
        (2, "November Rain", "8:57"),
        (2, "The Garden", "5:22"),
        (2, "Garden of Eden", "2:41"),
        (2, "Don't Damn Me", "5:18"),
        (2, "Bad Apples", "4:28"),
        (2, "Dead Horse", "4:17"),
        (2, "Coma", "10:13"),
        (3, "Civil War", "7:42"),
        (3, "14 Years", "4:23"),
        (3, "Yesterdays", "3:14"),
        (3, "Knockin' on Heaven's Door", "5:36"),
        (3, "Get in the Ring", "5:42"),
        (3, "Shotgun Blues", "3:23"),
        (3, "Breakdown", "7:04"),
        (3, "Pretty Tied Up", "4:48"),
        (3, "Locomotive", "8:42"),
        (3, "So Fine", "4:08"),
        (3, "Estranged", "9:23"),
        (3, "You Could Be Mine", "5:43"),
        (3, "Don't Cry", "4:45"),
        (3, "My World", "1:24"),
        (4, "Taikatalvi", "2:35"),
        (4, "Storytime", "5:22"),
        (4, "Ghost River", "5:28"),
        (4, "Slow, Love, Slow", "5:51"),
        (4, "I Want My Tears Back", "5:08"),
        (4, "Scaretale", "7:32"),
        (4, "Arabesque", "2:57"),
        (4, "Turn Loose the Mermaids", "4:20"),
        (4, "Rest Calm", "7:02"),
        (4, "The Crow, the Owl and the Dove", "4:10"),
        (4, "Last Ride of the Day", "4:33"),
        (4, "Song of Myself", "13:38"),
        (4, "Imaginaerum", "6:18"),
        (5, "15 Step", "3:58"),
        (5, "Bodysnatchers", "4:02"),
        (5, "Nude", "4:15"),
        (5, "Weird Fishes / Arpeggi", "5:18"),
        (5, "All i need", "3:49"),
        (5, "Faust Arp", "2:10"),
        (5,"Reckoner", "4:50"),
        (5, "House of Cards", "5:28"),
        (5, "Jigsaw Falling Into Place", "4:09"),
        (5, "Videotape", "4:40"),
        (6, "Doll", "1:23"),
        (6, "Monkey Wrench", "3:51"),
        (6, "Hey, Hohnny Park!", "4:08"),
        (6, "My Poor Brain", "3:33"),
        (6, "Wind Up", "2:32"),
        (6, "Up in Arms", "2:15"),
        (6, "My Hero", "4:20"),
        (6, "See You", "2:26"),
        (6, "Enough Space", "2:37"),
        (6, "February Stars", "4:49"),
        (6, "Everlong", "4:10"),
        (6, "Walking After You", "5:03"),
        (6, "New Way Home", "5:40"),
        (7, "Smells Like Teen Spirit", "5:01"),
        (7, "In Bloom", "4:15"),
        (7, "Come As You Are", "3:38"),
        (7, "Breed", "3:04"),
        (7, "Lithium", "4:17"),
        (7, "Polly", "2:53"),
        (7, "Territorial Pissings", "2:22"),
        (7, "Drain You", "3:43"),
        (7, "Lounge Act", "2:36"),
        (7, "Stay Away", "3:31"),
        (7, "On A Plain", "3:14"),
        (7, "Something In The Way", "3:52"),
        (7, "Endless, Nameless", "6:43"),
        (8, "Serve the Servants", "3:36"),
        (8, "Scentless Apprentice", "3:48"),
        (8, "Heart-Shaped Box", "4:41"),
        (8, "Rape Me", "2:50"),
        (8, "Frances Farmer Will Have Her Revenge on Seattle", "4:09"),
        (8, "Dumb", "2:32"),
        (8, "Very Ape", "1:56"),
        (8, "Milk It", "3:55"),
        (8, "Pennyroyal Tea", "3:37"),
        (8, "Radio Friendly Unit Shifter", "4:51"),
        (8, "Tourettes's", "1:35"),
        (8, "All Apologies", "3:51"),
        (9, "Mein Herz brennt", "4:39"),
        (9, "Links 2 3 4", "3:36"),
        (9,  "Sonne", "4:32"),
        (9, "Ich will", "3:37"),
        (9, "Feuer frei!", "3:11"),
        (9, "Mutter", "4:32"),
        (9, "Spieluhr", "4:46"),
        (9, "Zwitter", "4:17"),
        (9, "Rein raus", "3:09"),
        (9, "Adios", "3:49"),
        (9, "Nebel", "4:54"),
        (10, "Gimme Shelter", "4:31"),
        (10, "Love in Vain", "4:19"),
        (10, "Country Honk", "3:09"),
        (10, "Live with Me", "3:33"),
        (10, "Let It Bleed", "5:26"),
        (10, "Midnights Rambler", "6:52"),
        (10, "You Got the Silver", "2:51"),
        (10, "Monkey Man", "4:12"),
        (10, "You Can't Always Get What You Want", "7:28"),

    ]
    cursor.executemany("INSERT INTO tracks (album_id, title, length) VALUES (?, ?, ?)", tracks)
    
    # Commit changes and close connection
    conn.commit()
    conn.close()
    print("Database 'music.db' created successfully with all data!")

if __name__ == "__main__":
    create_music_db()