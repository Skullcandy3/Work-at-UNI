document.addEventListener("DOMContentLoaded", () => {
    const body = document.body;


    // === THEME TOGGLE (Dark/Light mode) ===
    const toggleTheme = () => {
        body.classList.toggle("dark");
        const newTheme = body.classList.contains("dark") ? "dark" : "light";
        localStorage.setItem("theme", newTheme);
    };

    const themeToggleBtn = document.getElementById("theme-toggle");
    if (localStorage.getItem("theme") === "dark") {
        body.classList.add("dark");
    }
    if (themeToggleBtn) {
        themeToggleBtn.addEventListener("click", toggleTheme);
    }


    // === COLORBLIND MODE ===
    const colorblindBtn = document.getElementById("toggle-colorblind");
    if (localStorage.getItem("colorblindMode") === "true") {
        body.classList.add("colorblind");
    }

    if (colorblindBtn) {
        colorblindBtn.addEventListener("click", () => {
            body.classList.toggle("colorblind");
            const enabled = body.classList.contains("colorblind");
            localStorage.setItem("colorblindMode", enabled ? "true" : "false");
        });
    }


    // === LEADERBOARD FUNCTIONS FOR ONCLICK ===
    window.openLeaderboard = function () {
        const leaderboardModal = document.getElementById("leaderboard-modal");
        const leaderboardList = document.getElementById("leaderboard-list");

        fetch("/leaderboard")
            .then(res => res.json())
            .then(data => {
                leaderboardList.innerHTML = "";
                data.forEach((user, index) => {
                    const li = document.createElement("li");
                    li.textContent = `${index + 1}. ${user.nickname} - ${user.points} pts`;
                    leaderboardList.appendChild(li);
                });
                leaderboardModal.classList.remove("hidden");
            })
            .catch(err => {
                leaderboardList.innerHTML = "<p>Error loading leaderboard.</p>";
                leaderboardModal.classList.remove("hidden");
                console.error("Leaderboard fetch failed:", err);
            });
    };

    // Close leaderboard modal when clicking the close button
    const closeLeaderboard = document.getElementById("close-leaderboard");
    if (closeLeaderboard) {
        closeLeaderboard.addEventListener("click", () => {
            document.getElementById("leaderboard-modal").classList.add("hidden");
        });
    }

    // Close leaderboard modal when clicking outside of it
    const leaderboardModal = document.getElementById("leaderboard-modal");
    if (leaderboardModal) {
        leaderboardModal.addEventListener("click", (event) => {
            if (event.target === leaderboardModal) {
                leaderboardModal.classList.add("hidden");
            }
        });
    }


    // === NICKNAME AVAILABILITY CHECK ===
    const nicknameInput = document.getElementById("nickname");
    const nicknameFeedback = document.getElementById("nickname-feedback");

    if (nicknameInput && nicknameFeedback) {
        nicknameInput.addEventListener("input", function () {
            const nickname = this.value;
            if (nickname.length < 3) {
                nicknameFeedback.textContent = "Nickname must be at least 3 characters.";
                nicknameFeedback.style.color = "orange";
                return;
            }

            fetch(`/check_nickname?nickname=${encodeURIComponent(nickname)}`)
                .then(res => res.json())
                .then(data => {
                    if (data.available) {
                        nicknameFeedback.textContent = "✅ Available";
                        nicknameFeedback.style.color = "green";
                    } else {
                        nicknameFeedback.textContent = "❌ Already taken";
                        nicknameFeedback.style.color = "red";
                    }
                })
                .catch(() => {
                    nicknameFeedback.textContent = "Error checking nickname.";
                    nicknameFeedback.style.color = "orange";
                });
        });
    }

    // === WORDLE GAME ===
    function initializeWordleGame(gameBoard, keyboard, resultMessage) {
        let gameOver = false;
        let isProcessing = false;
        const WORD_LENGTH = 5;
        const MAX_GUESSES = 6;
        let currentGuess = "";
        let currentRow = 0;
        let targetWord = "";
        fetch("/get_random_word")
            .then(res => res.json())
            .then(data => targetWord = data.word.toUpperCase())
            .catch(err => console.error("Word fetch failed:", err));

        const updateKeyboard = (letter, status) => {
            const keys = keyboard.querySelectorAll(".key");
            keys.forEach(key => {
                if (key.textContent === letter) {
                    key.classList.add(status);
                }
            });
        };

        for (let i = 0; i < WORD_LENGTH * MAX_GUESSES; i++) {
            const tile = document.createElement("div");
            tile.classList.add("tile");
            tile.setAttribute("id", `tile-${i}`);
            gameBoard.appendChild(tile);
        }

        // Create keyboard buttons
        "QWERTYUIOPASDFGHJKLZXCVBNM".split('').forEach(letter => {
            const btn = document.createElement("button");
            btn.textContent = letter;
            btn.classList.add("key");
            btn.addEventListener("click", () => handleKey(letter));
            keyboard.appendChild(btn);
        });

        const addSpecialKey = (label, action) => {
            const btn = document.createElement("button");
            btn.textContent = label;
            btn.classList.add("key");
            btn.style.width = "100px";
            btn.addEventListener("click", action);
            keyboard.appendChild(btn);
        };
        // Add special keys
        addSpecialKey("Enter", handleEnter);
        addSpecialKey("⌫", handleDelete);

        document.addEventListener("keydown", (event) => {
            if (event.key === "Enter") {
                handleEnter();
            } else if (event.key === "Backspace" || event.key === "Delete") {
                handleDelete();
            } else if (/^[a-zA-Z]$/.test(event.key)) {
                handleKey(event.key.toUpperCase());
            }
        });

        function handleKey(letter) {
            if (gameOver || isProcessing) return;
            if (currentGuess.length < WORD_LENGTH) {
                currentGuess += letter;
                const tile = document.getElementById(`tile-${currentRow * WORD_LENGTH + currentGuess.length - 1}`);
                if (tile) tile.textContent = letter;
            }
        }

        function handleDelete() {
            if (gameOver || isProcessing) return;
            if (currentGuess.length > 0) {
                const tile = document.getElementById(`tile-${currentRow * WORD_LENGTH + currentGuess.length - 1}`);
                if (tile) tile.textContent = "";
                currentGuess = currentGuess.slice(0, -1);
            }
        }

        function handleEnter() {
            if (gameOver) return;
            if (currentGuess.length !== WORD_LENGTH) return;
            
            isProcessing = true; // Block input during processing 

            fetch(`/check_word?word=${currentGuess.toLowerCase()}`)
                .then(res => res.json())
                .then(data => {
                    if (!data.correct) {
                        resultMessage.textContent = "❌ Not a valid word.";
                        resultMessage.style.color = "red";
                        isProcessing = false; 
                        return;
                    }
            const result = Array(WORD_LENGTH).fill('absent');
            const solutionLetters = targetWord.split('');
            const guessLetters = currentGuess.split('');
            
            // Green check
            for (let i = 0; i < WORD_LENGTH; i++) {
                if (guessLetters[i] === solutionLetters[i]) {
                    result[i] = 'correct';
                    solutionLetters[i] = null;
                }
            }

            // Yellow/grey check
            for (let i = 0; i < WORD_LENGTH; i++) {
                if (result[i] === 'absent') {
                    const idx = solutionLetters.indexOf(guessLetters[i]);
                    if (idx !== -1) {
                        result[i] = 'present';
                        solutionLetters[idx] = null; 
                    }
                }
            }

            // Reveal tiles with delay for animation
            for (let i = 0; i < WORD_LENGTH; i++) {
                const delay = i * 300;
                setTimeout(() => {
                    const tileIndex = currentRow * WORD_LENGTH + i;
                    const tile = document.getElementById(`tile-${tileIndex}`);
                    const letter = guessLetters[i];

                    if (!tile) return;

                    tile.classList.add(result[i]);
                    updateKeyboard(letter, result[i]);
                }, delay);
            }

            // Check win/lose after animations
            setTimeout(() => {
                if (currentGuess === targetWord) {
                    resultMessage.textContent = "🎉 You guessed it!";
                    resultMessage.style.color = "yellow";
                    gameOver = true;
                    let points = MAX_GUESSES - currentRow
                    fetch(`/add_points?points=${points}`)
                        .then(res => res.json())
                        .then(data => {
                            console.log("Points updated:", data.new_points);
                            resultMessage.textContent += ` You earned ${points} points!`;
                            resultMessage.style.color = "yellow";
                    })
                    .catch(err => {
                        console.error("Failed to update points:", err);
                    });
                } else if (currentRow === MAX_GUESSES - 1) {
                    resultMessage.textContent = `Game over! Word was ${targetWord}.`;
                    resultMessage.style.color = "yellow";
                    gameOver = true;
                }
                currentGuess = "";
                currentRow++;
                isProcessing = false;
            }, WORD_LENGTH * 300);
        })
            .catch(err => {
                console.error("Word check failed:", err);
                resultMessage.textContent = "⚠️ Server error.";
                resultMessage.style.color = "orange";
                isProcessing = false;
            });
        }
    }


    // Initialize Wordle game elements
    const gameBoard = document.getElementById("game-board");
    const keyboard = document.getElementById("keyboard");
    const resultMessage = document.getElementById("result-message");

    if (gameBoard && keyboard && resultMessage) {
        initializeWordleGame(gameBoard, keyboard, resultMessage);
    }

    
    // === SEARCH AND SORT FOR ADMIN USER TABLE === 
    const searchInput = document.getElementById("search-input");
    const userTable = document.getElementById("user-table");

    if (searchInput && userTable) {
        searchInput.addEventListener("input", function () {
            const filter = this.value.toLowerCase();
            const rows = userTable.querySelectorAll("tr");
            rows.forEach(row => {
                const nickname = row.children[1].textContent.toLowerCase();
                const gmail = row.children[2].textContent.toLowerCase();
                row.style.display = nickname.includes(filter) || gmail.includes(filter) ? "" : "none";
            });
        });
        
        let sortDirection = true;

        window.sortTable = function (columnIndex) {
            const tbody = userTable.querySelector("tbody");
            const rows = Array.from(tbody.querySelectorAll("tr"));

            rows.sort((a, b) => {
                const cellA = a.children[columnIndex].textContent.trim();
                const cellB = b.children[columnIndex].textContent.trim();
                return isNaN(cellA) ? 
                    (sortDirection ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA)) :
                    (sortDirection ? cellA - cellB : cellB - cellA);
            });

            rows.forEach(row => tbody.appendChild(row));
            sortDirection = !sortDirection;
        };
    }
});
