## App Idea and Description
In this Wordle-style app, you'll have 6{n} attempts to solve a 5-letter word, with the solution randomized each game (based on this app: https://www.nytimes.com/games/wordle/index.html).

You can either log in to save your score or play as a guest without earning points. You'll earn extra points for solving words in fewer attempts. You can change your nickname up to {n} times!
Registered users will appear on a leaderboard and earn points for solving words. The leaderboard can be sorted by total points.

As an admin, you'll have access to other users, defined by your class_id. An additional admin menu lists all users by name, email, and points. You can search the list, edit user names and points, or delete accounts.

The site would feature light/dark mode and colorblind options for accessibility.

Data stored:

- Word list    
    List of all words that can be used in the game
    
- User
    Includes: Name, email, password, points, class_id (1 - users, 2 - admins)

- Game history
    List of all previous games, includes: name, used_words, final_word 