// --- FIREBASE CONFIG ---
const firebaseConfig = {
    apiKey: "AIzaSyAt_c_rEU5amO4AWTM7_oOOCHqay2Xq6Pg",
    authDomain: "mindwell-app-18340.firebaseapp.com",
    databaseURL: "https://mindwell-app-18340-default-rtdb.firebaseio.com",
    projectId: "mindwell-app-18340",
    storageBucket: "mindwell-app-18340.firebasestorage.app",
    messagingSenderId: "332757505850",
    appId: "1:332757505850:web:1100abc22a76b289be2203"
};

// INITIALIZE FIREBASE & WIRE UP APP

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.database(); // Using Realtime DB
console.log("app.js: Firebase Initialized");

// AUTHENTICATION CHECK 
let currentUser; // We'll store the user object here

auth.onAuthStateChanged(user => {
    if (user) {
        // User is signed in
        console.log("app.js: User is logged in:", user);
        currentUser = user;
        
        updateUserInfo(user);
        fetchEntries(user.uid); // This will also trigger the chart update

    } else {
        // No user is signed in
        console.log("app.js: No user signed in. Redirecting to login...");
        window.location.href = 'index.html'; // Go back to the clean index.html
    }
});

// --- GET DOM ELEMENTS ---
const logoutButton = document.getElementById('logout-button');
const userEmailDisplay = document.getElementById('user-email');
const userNameDisplay = document.getElementById('user-name');
const saveEntryButton = document.getElementById('save-entry-button');
const journalEntryInput = document.getElementById('journal-entry');
const pastEntriesList = document.getElementById('past-entries-list');
const loadingSpinner = document.getElementById('loading-spinner');
const appMessage = document.getElementById('app-message');
const moodTagsContainer = document.querySelector('.mood-tags-container');
const statTotalEntries = document.getElementById('stat-total-entries');
const statAvgMood = document.getElementById('stat-avg-mood');
const statCommonTag = document.getElementById('stat-common-tag');

console.log("app.js: DOM elements acquired");

//  DYNAMIC MOOD LABEL LOGIC 
const moodLabels = {
    1: "Awful",
    2: "Not Great",
    3: "Okay",
    4: "Good",
    5: "Amazing"
};
const moodLabelSpan = document.getElementById('selected-mood-label');
const moodInputs = document.querySelectorAll('input[name="mood"]');

function updateMoodLabel() {
    const selected = document.querySelector('input[name="mood"]:checked');
    if (selected && moodLabelSpan) {
        moodLabelSpan.style.opacity = '0';
        setTimeout(() => {
            moodLabelSpan.textContent = moodLabels[selected.value];
            moodLabelSpan.style.opacity = '1';
        }, 150);
    }
}
// Initialize Listener
if (moodInputs.length > 0) {
    moodInputs.forEach(input => {
        input.addEventListener('change', updateMoodLabel);
    });
    updateMoodLabel(); // Run once on load
}

// CHART.JS SETUP 
const moodChartCtx = document.getElementById('moodChart').getContext('2d');
let moodChart; 
initializeMoodChart(); 

const tagsChartCtx = document.getElementById('tagsChart').getContext('2d');
let tagsChart;
initializeTagsChart();


// Helper function to get the single text color
function getChartTextColor() {
    return '#1F2937'; 
}

// Chart.js initialization functions
function initializeMoodChart() {
    console.log("Mood Chart.js initialized.");
    if (moodChart) {
        moodChart.destroy();
    }
    
    const textColor = getChartTextColor();

    moodChart = new Chart(moodChartCtx, {
        type: 'line',
        data: { /* ... data ... */ },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true, max: 5, min: 0,
                    ticks: { 
                        stepSize: 1,
                        callback: function(value) {
                            const labels = {1: '😥', 2: '😕', 3: '😐', 4: '😊', 5: '😄'};
                            return labels[value] || value;
                        },
                        color: textColor // Set text color
                    },
                    grid: { color: 'rgba(0, 0, 0, 0.05)' } // Lighter grid lines
                },
                x: {
                    ticks: { color: textColor }, // Set text color
                    grid: { display: false }
                }
            },
            plugins: {
                legend: { display: false },
                tooltip: { /* ... tooltip ... */ }
            }
        }
    });
    // Re-fill data structure
    moodChart.data = {
        labels: [], 
        datasets: [{
            label: 'Your Mood', data: [], 
            fill: true, 
            borderColor: '#4F46E5', 
            backgroundColor: 'rgba(79, 70, 229, 0.1)', 
            tension: 0.2, pointRadius: 5, pointHoverRadius: 8,
            pointBackgroundColor: '#4F46E5' 
        }]
    };
    moodChart.update();
}

function initializeTagsChart() {
    console.log("Tags Chart.js initialized.");
    if (tagsChart) {
        tagsChart.destroy();
    }

    const textColor = getChartTextColor();

    tagsChart = new Chart(tagsChartCtx, {
        type: 'pie',
        data: {
            labels: [], 
            datasets: [{
                label: 'What\'s Affecting Your Mood',
                data: [], 
                backgroundColor: [ 
                    '#4F46E5', 
                    '#E17055', 
                    '#FBBF24', 
                    '#10B981', 
                    '#6366F1', 
                    '#9CA3AF'  
                ],
                borderColor: '#FEFAF6', // Background color
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        color: textColor 
                    }
                }
            }
        }
    });
}


// FUNCTIONS 

function updateUserInfo(user) {
    if (user.email) {
        userEmailDisplay.textContent = user.email;
    }
    if (user.displayName) {
        userNameDisplay.textContent = user.displayName;
    } else if (user.email) {
        userNameDisplay.textContent = user.email.split('@')[0];
    }
}

function showAppMessage(message, type = 'success') {
    appMessage.textContent = message;
    appMessage.classList.remove('hidden', 'success-box', 'error-box');
    appMessage.classList.add(type === 'success' ? 'success-box' : 'error-box');
    
    setTimeout(() => {
        appMessage.classList.add('hidden');
    }, 3000);
}

function saveJournalEntry() {
    if (!currentUser) {
        showAppMessage("You must be logged in to save an entry.", "error");
        return;
    }

    const selectedMood = document.querySelector('input[name="mood"]:checked');
    if (!selectedMood) {
        showAppMessage("Please select a mood.", "error");
        return;
    }
    const moodValue = parseInt(selectedMood.value);
    const journalEntryInput = document.getElementById('journal-entry');
    const journalText = journalEntryInput ? journalEntryInput.value.trim() : '';

    const selectedTags = [];
    document.querySelectorAll('.mood-tag.active').forEach(tagButton => {
        selectedTags.push(tagButton.dataset.tag);
    });

    const newEntry = {
        mood: moodValue,
        text: journalText,
        tags: selectedTags,
        timestamp: firebase.database.ServerValue.TIMESTAMP 
    };

    console.log("Saving new entry:", newEntry);
    saveEntryButton.disabled = true; 

    const userEntriesRef = db.ref('entries/' + currentUser.uid);
    userEntriesRef.push(newEntry)
        .then(() => {
            console.log("Entry saved successfully!");
            showAppMessage("Entry saved!", "success");
            if (journalEntryInput) {
                journalEntryInput.value = '';
            }
            document.getElementById('mood-3').checked = true; 
            document.querySelectorAll('.mood-tag.active').forEach(tagButton => {
                tagButton.classList.remove('active');
            });
            saveEntryButton.disabled = false;
        })
        .catch(error => {
            console.error("Error saving entry:", error);
            showAppMessage(`Error: ${error.message}`, "error");
            saveEntryButton.disabled = false;
        });
}


function fetchEntries(uid) {
    console.log("Fetching entries for user:", uid);
    if(loadingSpinner) loadingSpinner.classList.remove('hidden');
    if(pastEntriesList) pastEntriesList.innerHTML = ''; 

    const userEntriesRef = db.ref('entries/' + uid).orderByChild('timestamp');
    
    userEntriesRef.on('value', snapshot => {
        if(loadingSpinner) loadingSpinner.classList.add('hidden');
        if(pastEntriesList) pastEntriesList.innerHTML = ''; 
        
        if (!snapshot.exists()) {
            console.log("No entries found.");
            if(pastEntriesList) pastEntriesList.innerHTML = '<p>No entries yet. Add one above to get started!</p>';
            updateMoodChart([]); 
            updateAnalytics([]);
            return;
        }

        console.log(`Found entries.`);
        let allEntries = [];

        snapshot.forEach(childSnapshot => {
            const entry = childSnapshot.val();
            entry.key = childSnapshot.key; 
            allEntries.push(entry);
        });

        const entriesForList = [...allEntries].reverse();
        entriesForList.forEach(entry => renderEntry(entry));
        
        updateMoodChart(allEntries);
        updateAnalytics(allEntries);

    }, error => {
        console.error("Error fetching entries:", error);
        if(loadingSpinner) loadingSpinner.classList.add('hidden');
        if(pastEntriesList) pastEntriesList.innerHTML = `<p class="error-box">Error loading entries: ${error.message}</p>`;
    });
}

function getMoodEmoji(moodValue) {
    const emojis = {1: '😥', 2: '😕', 3: '😐', 4: '😊', 5: '😄'};
    return emojis[moodValue] || '❓';
}

function renderEntry(entryData) {
    if (!pastEntriesList) return; // Guard clause
    
    let date = 'Pending...';
    if (entryData.timestamp) {
        date = new Date(entryData.timestamp).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        });
    }

    const mood = getMoodEmoji(entryData.mood);
    const entryDiv = document.createElement('div');
    entryDiv.className = 'entry-item';
    
    let textHTML = '';
    if (entryData.text) {
        const safeText = document.createElement('p');
        safeText.className = 'entry-text';
        safeText.textContent = entryData.text;
        textHTML = safeText.outerHTML;
    }

    let tagsHTML = '';
    if (entryData.tags && entryData.tags.length > 0) {
        tagsHTML = '<div class="entry-tags">';
        entryData.tags.forEach(tag => {
            tagsHTML += `<span class="entry-tag-item">${tag}</span>`;
        });
        tagsHTML += '</div>';
    }

    entryDiv.innerHTML = `
        <div class="entry-header">
            <div>
                <span class="entry-mood">${mood} (${entryData.mood})</span>
                <span class="entry-date">${date}</span>
            </div>
            <button class="btn-delete" data-key="${entryData.key}" title="Delete entry">&times;</button>
        </div>
        ${textHTML}
        ${tagsHTML} 
    `;
    
    pastEntriesList.appendChild(entryDiv);
}

function deleteEntry(key) {
    if (!currentUser || !key) return;
    console.log(`Deleting entry with key: ${key}`);
    const entryRef = db.ref(`entries/${currentUser.uid}/${key}`);
    entryRef.remove()
        .then(() => {
            console.log("Entry deleted.");
            showAppMessage("Entry deleted.", "success");
        })
        .catch(error => {
            console.error("Error deleting entry:", error);
            showAppMessage(error.message, "error");
        });
}

function updateMoodChart(entries) {
    if (!moodChart) {
        initializeMoodChart();
    }
    
    const labels = entries.map(entry => (entry.timestamp ? new Date(entry.timestamp).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : '...'));
    const data = entries.map(entry => entry.mood);
    console.log("Updating mood chart with data:", data);

    const textColor = getChartTextColor();
    moodChart.data.labels = labels;
    moodChart.data.datasets[0].data = data;
    // Updates text colors
    if (moodChart.options.scales.y.ticks) moodChart.options.scales.y.ticks.color = textColor;
    if (moodChart.options.scales.x.ticks) moodChart.options.scales.x.ticks.color = textColor;
    
    moodChart.update();
}

function updateAnalytics(entries) {
    if (entries.length === 0) {
        if (statTotalEntries) statTotalEntries.textContent = '0';
        if (statAvgMood) statAvgMood.textContent = '--';
        if (statCommonTag) statCommonTag.textContent = '--';
        if (tagsChart) {
            tagsChart.data.labels = [];
            tagsChart.data.datasets[0].data = [];
            tagsChart.update();
        }
        return;
    }

    if (statTotalEntries) statTotalEntries.textContent = entries.length;

    const totalMood = entries.reduce((sum, entry) => sum + entry.mood, 0);
    const avgMood = (totalMood / entries.length).toFixed(1);
    const avgMoodEmoji = getMoodEmoji(Math.round(avgMood));
    if (statAvgMood) statAvgMood.innerHTML = `${avgMoodEmoji} (${avgMood})`;

    const tagCounts = {};
    entries.forEach(entry => {
        if (entry.tags && entry.tags.length > 0) {
            entry.tags.forEach(tag => {
                tagCounts[tag] = (tagCounts[tag] || 0) + 1;
            });
        }
    });

    console.log("Calculated Tag Counts:", tagCounts);

    let maxCount = 0;
    let commonTag = '--';
    for (const tag in tagCounts) {
        if (tagCounts[tag] > maxCount) {
            maxCount = tagCounts[tag];
            commonTag = tag;
        }
    }
    if (statCommonTag) statCommonTag.textContent = commonTag;

    const tagLabels = Object.keys(tagCounts);
    const tagData = Object.values(tagCounts);

    if (tagsChart) {
        const textColor = getChartTextColor();
        tagsChart.data.labels = tagLabels;
        tagsChart.data.datasets[0].data = tagData;
        // Updates text color
        if (tagsChart.options.plugins.legend.labels) tagsChart.options.plugins.legend.labels.color = textColor;
        tagsChart.update();
    }
}


function logout() {
    console.log("Logging out...");
    auth.signOut()
        .then(() => {
            console.log("Sign-out successful.");
        })
        .catch(error => {
            console.error("Logout Error:", error);
        });
}


// ADD EVENT LISTENERS 

// We add guard clauses (if (element)) to prevent errors on pages
// where the element doesn't exist.

if (logoutButton) {
    logoutButton.addEventListener('click', logout);
    console.log("app.js: Logout listener attached.");
}

if (saveEntryButton) {
    saveEntryButton.addEventListener('click', saveJournalEntry);
    console.log("app.js: Save entry listener attached.");
}

if (pastEntriesList) {
    pastEntriesList.addEventListener('click', (e) => {
        if (e.target.classList.contains('btn-delete')) {
            const key = e.target.dataset.key; 
            deleteEntry(key);
        }
    });
    console.log("app.js: Delete listener attached to list.");
}

if (moodTagsContainer) {
    moodTagsContainer.addEventListener('click', (e) => {
        if (e.target.classList.contains('mood-tag')) {
            e.target.classList.toggle('active');
        }
    });
    console.log("app.js: Tag button listener attached.");
}