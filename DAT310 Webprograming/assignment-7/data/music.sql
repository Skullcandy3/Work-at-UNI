-- Create the table
CREATE TABLE albums (
    album_id INTEGER PRIMARY KEY,
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    cover_img TEXT NOT NULL
);

-- Insert data into the table
INSERT INTO albums (album_id, artist, title, cover_img) VALUES
(1, "Coldplay", "A Rush of Blood to the Head", "Coldplay-ARushofBlood.jpg"),
(2, "Guns N' Roses", "Use Your Illusion I", "GnR-UseYourIllusion1.jpg"),
(3, "Guns N' Roses", "Use Your Illusion II", "GnR-UseYourIllusion2.jpg"),
(4, "Nightwish", "Imaginaerum", "Nightwish-Imaginaerum.jpg");

-- Create the table
CREATE TABLE tracks (
    track_id INTEGER PRIMARY KEY AUTOINCREMENT,
    album_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    length TEXT NOT NULL,
    FOREIGN KEY (album_id) REFERENCES albums(album_id)
);

-- Insert data into the table
INSERT INTO tracks (album_id, title, length) VALUES
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
(4, "Imaginaerum", "6:18");