//William Ditlev Hanssen
// app.js

const app = Vue.createApp({
  data() {
      return {
          gridSize: { rows: 4, cols: 5 }, // 4x5 grid = 20 cards
          cards: [],
          flippedCards: [],
          matchedCards: new Set(),
          currentPlayer: 1,
          scores: { 1: 0, 2: 0 },
          totalFlips: 0,
      };
  },
  created() {
      this.initializeGame();
  },
  methods: {
      initializeGame() {
          const symbols = ['♠', '♣', '♦', '♥', '7', '8', '9', '10', 'J', 'Q']; // 10 pairs
          let deck = [...symbols, ...symbols]; // Duplicate for pairs
          deck = this.shuffle(deck);
          this.cards = deck.map((symbol, index) => ({
              id: index,
              symbol,
              flipped: false,
              matched: false
          }));
      },
      shuffle(array) {
          return array.sort(() => Math.random() - 0.5);
      },
      flipCard(index) {
          let card = this.cards[index];

          if (card.flipped || this.flippedCards.length === 2) return;

          card.flipped = true;
          this.flippedCards.push(card);
          this.totalFlips++;

          if (this.flippedCards.length === 2) {
              setTimeout(this.checkMatch, 1000);
          }
      },
      checkMatch() {
          const [card1, card2] = this.flippedCards;

          if (card1.symbol === card2.symbol) {
              card1.matched = card2.matched = true;
              this.matchedCards.add(card1.id);
              this.matchedCards.add(card2.id);
              this.scores[this.currentPlayer]++;
          } else {
              card1.flipped = card2.flipped = false;
              this.currentPlayer = this.currentPlayer === 1 ? 2 : 1;
          }
          this.flippedCards = [];
      },
      restartGame() {
          this.flippedCards = [];
          this.matchedCards.clear();
          this.scores = { 1: 0, 2: 0 };
          this.totalFlips = 0;
          this.initializeGame();
      }
  }
});

app.mount('#app');
