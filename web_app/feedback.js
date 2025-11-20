//  FIREBASE CONFIG 
const firebaseConfig = {
    apiKey: "AIzaSyAt_c_rEU5amO4AWTM7_oOOCHqay2Xq6Pg",
    authDomain: "mindwell-app-18340.firebaseapp.com",
    databaseURL: "https://mindwell-app-18340-default-rtdb.firebaseio.com",
    projectId: "mindwell-app-18340",
    storageBucket: "mindwell-app-18340.firebasestorage.app",
    messagingSenderId: "332757505850",
    appId: "1:332757505850:web:1100abc22a76b289be2203"
};

// --- INITIALIZE FIREBASE ---
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.database();
console.log("feedback.js: Firebase Initialized");

let currentUser = null;

// --- GET DOM ELEMENTS ---
const messageInput = document.getElementById('feedback-message');
const submitButton = document.getElementById('submit-feedback-button');
const appMessage = document.getElementById('app-message');

//  AUTH CHECK 
auth.onAuthStateChanged(user => {
    if (user) {
        currentUser = user;
        console.log("Feedback page: User is logged in:", user.uid);
        messageInput.disabled = false;
        submitButton.disabled = false;
    } else {
        console.log("Feedback page: No user signed in.");
        messageInput.value = "Please log in on the main page to submit feedback.";
        messageInput.disabled = true;
        submitButton.disabled = true;
    }
});

// FUNCTIONS 
function showAppMessage(message, type = 'success') {
    appMessage.textContent = message;
    appMessage.classList.remove('hidden', 'success-box', 'error-box');
    appMessage.classList.add(type === 'success' ? 'success-box' : 'error-box');
    
    setTimeout(() => {
        appMessage.classList.add('hidden');
    }, 4000);
}

function handleSubmit() {
    if (!currentUser) {
        showAppMessage("You must be logged in to submit feedback.", "error");
        return;
    }

    const message = messageInput.value.trim();
    if (message.length < 10) {
        showAppMessage("Please provide a bit more detail in your feedback!", "error");
        return;
    }

    console.log("Submitting feedback...");
    submitButton.disabled = true;
    submitButton.textContent = "Submitting...";

    const feedbackData = {
        uid: currentUser.uid,
        email: currentUser.email || 'N/A',
        message: message,
        timestamp: firebase.database.ServerValue.TIMESTAMP
    };

    // Push to the feedback collection
    db.ref('feedback').push(feedbackData)
        .then(() => {
            console.log("Feedback submitted!");
            showAppMessage("Thank you! Your feedback has been submitted successfully.", "success");
            messageInput.value = '';
            submitButton.disabled = false;
            submitButton.textContent = "Submit Feedback";
        })
        .catch(error => {
            console.error("Error submitting feedback:", error);
            showAppMessage(`Error: ${error.message}`, "error");
            submitButton.disabled = false;
            submitButton.textContent = "Submit Feedback";
        });
}

// EVENT LISTENERS 
if (submitButton) {
    submitButton.addEventListener('click', handleSubmit);
    console.log("feedback.js: Submit listener attached.");
}