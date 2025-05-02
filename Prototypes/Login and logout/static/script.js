document.addEventListener('DOMContentLoaded', () => {
    const toggleBtn = document.getElementById('theme-toggle');
    const body = document.body;

    document.addEventListener("DOMContentLoaded", () => {
        const toggleBtn = document.getElementById("theme-toggle");
    
        // Load theme preference on page load
        const savedTheme = localStorage.getItem("theme");
        if (savedTheme === "dark") {
            document.body.classList.add("dark");
        }
    
        // Theme toggle button click
        toggleBtn.addEventListener("click", () => {
            document.body.classList.toggle("dark");
            const newTheme = document.body.classList.contains("dark") ? "dark" : "light";
            localStorage.setItem("theme", newTheme);
        });
    });
    
    // Load saved theme
    if (localStorage.getItem('theme') === 'dark') {
        body.classList.add('dark');
    }

    toggleBtn.addEventListener('click', () => {
        body.classList.toggle('dark');
        localStorage.setItem('theme', body.classList.contains('dark') ? 'dark' : 'light');
    });
});

document.addEventListener("DOMContentLoaded", () => {
    const word = "CRANE"; // Replace with dynamic word from backend later
    let currentRow = 0;
    let currentCol = 0;
    let guesses = Array.from({ length: 6 }, () => ["", "", "", "", ""]);

    const board = document.getElementById("game-board");
    const keyboard = document.getElementById("keyboard");

    function createBoard() {
        board.innerHTML = '';
        for (let i = 0; i < 6; i++) {
            for (let j = 0; j < 5; j++) {
                const tile = document.createElement("div");
                tile.classList.add("tile");
                tile.id = `tile-${i}-${j}`;
                board.appendChild(tile);
            }
        }
    }

    function createKeyboard() {
        const rows = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"];
        rows.forEach((row) => {
            const rowDiv = document.createElement("div");
            for (let letter of row) {
                const key = document.createElement("button");
                key.textContent = letter;
                key.classList.add("key");
                key.addEventListener("click", () => handleKey(letter));
                rowDiv.appendChild(key);
            }
            keyboard.appendChild(rowDiv);
        });

        const enter = document.createElement("button");
        enter.textContent = "Enter";
        enter.classList.add("key");
        enter.addEventListener("click", () => handleKey("Enter"));
        keyboard.appendChild(enter);

        const del = document.createElement("button");
        del.textContent = "⌫";
        del.classList.add("key");
        del.addEventListener("click", () => handleKey("Backspace"));
        keyboard.appendChild(del);
    }

    function handleKey(key) {
        if (currentRow >= 6) return;

        if (key === "Backspace") {
            if (currentCol > 0) {
                currentCol--;
                guesses[currentRow][currentCol] = "";
                updateTile(currentRow, currentCol, "");
            }
        } else if (key === "Enter") {
            if (currentCol === 5) {
                checkWord();
            }
        } else if (/^[A-Z]$/.test(key)) {
            if (currentCol < 5) {
                guesses[currentRow][currentCol] = key;
                updateTile(currentRow, currentCol, key);
                currentCol++;
            }
        }
    }

    function updateTile(row, col, letter) {
        const tile = document.getElementById(`tile-${row}-${col}`);
        tile.textContent = letter;
    }

    function checkWord() {
        const guess = guesses[currentRow].join("");
        const result = Array(5).fill("absent");

        const targetLetters = word.split("");

        // First pass: correct letters
        for (let i = 0; i < 5; i++) {
            if (guesses[currentRow][i] === word[i]) {
                result[i] = "correct";
                targetLetters[i] = null; // Mark matched
            }
        }

        // Second pass: present letters
        for (let i = 0; i < 5; i++) {
            if (result[i] !== "correct" && targetLetters.includes(guesses[currentRow][i])) {
                result[i] = "present";
                targetLetters[targetLetters.indexOf(guesses[currentRow][i])] = null;
            }
        }

        // Update tiles
        for (let i = 0; i < 5; i++) {
            const tile = document.getElementById(`tile-${currentRow}-${i}`);
            tile.classList.add(result[i]);
        }

        if (guess === word) {
            document.getElementById("message").textContent = "🎉 You guessed it!";
        } else if (currentRow === 5) {
            document.getElementById("message").textContent = `❌ The word was: ${word}`;
        } else {
            currentRow++;
            currentCol = 0;
        }
    }

    // Handle physical keyboard input
    document.addEventListener("keydown", (e) => {
        const key = e.key.toUpperCase();
        if (key === "BACKSPACE" || key === "ENTER" || /^[A-Z]$/.test(key)) {
            handleKey(key);
        }
    });

    // Initialize
    createBoard();
    createKeyboard();
});
