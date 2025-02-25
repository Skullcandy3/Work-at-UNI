// Author: William Ditlev Hanssen

// Sample initial data
const entries = [
    { name: "John Doe", tel: "123-456-7890", email: "john.doe@example.com" },
    { name: "Jane Smith", tel: "987-654-3210", email: "jane.smith@example.com" },
    { name: "Alice Brown", tel: "555-123-4567", email: "alice.brown@example.com" },
    {name: "Jonas Gahr Støre", tel:"98545610", email: "jonas.støre@gmail.com"},
    {name: "Luke Skywalker", tel:"1919191919", email: "luke.skywalker@gmail.com"}
];

// DOM elements
const contactList = document.getElementById("contact-list");
const searchInput = document.getElementById("search");
const addEntryForm = document.getElementById("add-entry-form");
const nameInput = document.getElementById("name");
const telInput = document.getElementById("tel");
const emailInput = document.getElementById("email");
const sortCriteriaSelect = document.getElementById("sort-criteria");

// Render entries to the contact list
function renderEntries(filteredEntries = entries) {
    contactList.innerHTML = "";
    filteredEntries.forEach((entry, index) => {
        const li = document.createElement("li");
        li.innerHTML = `
            <span>${entry.name} - ${entry.tel} - <a href="mailto:${entry.email}">${entry.email}</a></span>
            <button onclick="deleteEntry(${index})">Delete</button>
        `;
        contactList.appendChild(li);
    });
}

// Add a new entry
addEntryForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const name = nameInput.value.trim();
    const tel = telInput.value.trim();
    const email = emailInput.value.trim();

    // Input validation
    if (!name) {
        alert("Name is required!");
        return;
    }
    if (!validateName(name)) {
        alert("Name must contain only letters and spaces!");
        return;
    }
    if (!tel && !email) {
        alert("Either telephone or email must be provided!");
        return;
    }
    if (tel && !validateTel(tel)) {
        alert("Telephone must contain only numbers, spaces, hyphens, or parentheses!");
        return;
    }
    if (email && !validateEmail(email)) {
        alert("Please enter a valid email address!");
        return;
    }

    // Add new entry to the list
    entries.push({ name, tel, email });
    renderEntries();

    // Clear form inputs
    nameInput.value = "";
    telInput.value = "";
    emailInput.value = "";
});

// Validate name format
function validateName(name) {
    const re = /^[a-zA-Z\s]+$/;
    return re.test(name);
}

// Validate telephone format
function validateTel(tel) {
    const re = /^[0-9\s\-()]+$/;
    return re.test(tel);
}

// Validate email format
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

// Delete an entry
function deleteEntry(index) {
    if (confirm("Are you sure you want to delete this entry?")) {
        entries.splice(index, 1);
        renderEntries();
    }
}

// Search entries
searchInput.addEventListener("input", () => {
    const searchTerm = searchInput.value.toLowerCase();
    const filteredEntries = entries.filter(entry =>
        entry.name.toLowerCase().includes(searchTerm) ||
        entry.tel.toLowerCase().includes(searchTerm) ||
        entry.email.toLowerCase().includes(searchTerm)
    );
    renderEntries(filteredEntries);
});

// Sort entries by selected criteria
sortCriteriaSelect.addEventListener("change", () => {
    const criteria = sortCriteriaSelect.value;
    entries.sort((a, b) => {
        if (criteria === "name") {
            return a.name.localeCompare(b.name);
        } else if (criteria === "tel") {
            return a.tel.localeCompare(b.tel);
        } else if (criteria === "email") {
            return a.email.localeCompare(b.email);
        }
    });
    renderEntries();
});

// Initial render
renderEntries();
