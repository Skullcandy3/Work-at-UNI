/**
 * Assignment 7 - Music Album Collection
 */

document.addEventListener("DOMContentLoaded", function () {
    loadAlbums();
});

/** Load and display the list of albums */
async function loadAlbums() {
    try {
        const response = await fetch("/albums");
        const albums = await response.json();

        const albumsList = document.getElementById("albums_list");
        albumsList.innerHTML = ""; // Clear old albums

        albums.forEach(album => {
            const li = document.createElement("li");
            li.textContent = `${album.album_id}. ${album.artist} - ${album.title}`;
            li.setAttribute("data-album-id", album.album_id);
            li.onclick = () => loadAlbumInfo(album.album_id); // Attach event
            albumsList.appendChild(li);
        });

        if (albums.length > 0) {
            loadAlbumInfo(albums[0].album_id); // Auto-load first album
        }
    } catch (error) {
        console.error("Error loading albums:", error);
    }
}

/** Load and display details of a given album */
async function loadAlbumInfo(album_id) {
    console.log("Clicked album ID:", album_id); // Debugging

    try {
        const response = await fetch(`/albuminfo?album_id=${album_id}`);
        const data = await response.json();
        console.log("Album data received:", data); // Debugging

        if (data.error) {
            console.error("Error fetching album:", data.error);
            return;
        }

        // Set album cover, title, and artist
        document.getElementById("cover_img").src = `static/images/${data.cover}`;
        document.getElementById("album_title").textContent = data.title;
        document.getElementById("album_artist").textContent = data.artist;

        // Display track listing
        const tracksList = document.getElementById("tracks_list");
        tracksList.innerHTML = ""; // Clear old tracks

        let totalDuration = 0;
        data.tracks.forEach((track) => {
            let li = document.createElement("li");
            li.textContent = ` ${track.title} (${track.duration})`;
            tracksList.appendChild(li);

            // Convert duration (mm:ss) to seconds
            let [mins, secs] = track.duration.split(":").map(Number);
            totalDuration += mins * 60 + secs;
        });

        // Display total album duration
        let totalMins = Math.floor(totalDuration / 60);
        let totalSecs = totalDuration % 60;
        document.getElementById("total_duration").textContent = 
            `Total Duration: ${totalMins}:${totalSecs.toString().padStart(2, "0")}`;

        // Make album info section visible
        document.getElementById("album_info").style.display = "block";
    } catch (error) {
        console.error("Failed to load album:", error);
    }
}
