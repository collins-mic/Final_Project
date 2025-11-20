// FIREBASE CONFIG 
const firebaseConfig = {
    apiKey: "AIzaSyAt_c_rEU5amO4AWTM7_oOOCHqay2Xq6Pg",
    authDomain: "mindwell-app-18340.firebaseapp.com",
    databaseURL: "https://mindwell-app-18340-default-rtdb.firebaseio.com",
    projectId: "mindwell-app-18340",
    storageBucket: "mindwell-app-18340.firebasestorage.app",
    messagingSenderId: "332757505850",
    appId: "1:332757505850:web:1100abc22a76b289be2203"
};

//  INITIALIZING FIREBASE & WIRE UP AUTH 

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.database(); // Using Realtime DB
const googleProvider = new firebase.auth.GoogleAuthProvider();
console.log("auth.js: Firebase Initialized");

// Get DOM Elements
const loginButton = document.getElementById('login-button');
const signupButton = document.getElementById('signup-button');
const googleSigninButton = document.getElementById('google-signin-button');
const emailInput = document.getElementById('email');
const passwordInput = document.getElementById('password');
const authError = document.getElementById('auth-error');
console.log("auth.js: DOM elements acquired");

// Function to show error messages
function showAuthError(message) {
    authError.textContent = message;
    authError.classList.remove('hidden');
}

// Function to clear error messages
function clearAuthError() {
    authError.textContent = '';
    authError.classList.add('hidden');
}

// Function to handle login/signup success
function handleAuthSuccess(userCredential) {
    console.log("Authentication successful:", userCredential.user);
    // Redirect to the dashboard
    window.location.href = 'dashboard.html';
}

// --- Add Event Listeners  ---

// Login Button Click
if (loginButton) {
    loginButton.addEventListener('click', () => {
        clearAuthError();
        const email = emailInput.value;
        const password = passwordInput.value;

        if (!email || !password) {
            showAuthError("Please enter both email and password.");
            return;
        }

        console.log("Attempting login...");
        auth.signInWithEmailAndPassword(email, password)
            .then(handleAuthSuccess)
            .catch((error) => {
                console.error("Login Error:", error.message);
                showAuthError(error.message);
            });
    });
    console.log("auth.js: Login listener attached.");
}

// Signup Button Click
if (signupButton) {
    signupButton.addEventListener('click', () => {
        clearAuthError();
        const email = emailInput.value;
        const password = passwordInput.value;

        if (!email || !password) {
            showAuthError("Please enter both email and password.");
            return;
        }
        
        console.log("Attempting signup...");
        auth.createUserWithEmailAndPassword(email, password)
            .then(handleAuthSuccess)
            .catch((error) => {
                console.error("Signup Error:", error.message);
                showAuthError(error.message);
            });
    });
    console.log("auth.js: Signup listener attached.");
}

// Google Sign-in Button Click
if (googleSigninButton) {
    googleSigninButton.addEventListener('click', () => {
        clearAuthError();
        console.log("Attempting Google sign-in...");
        auth.signInWithPopup(googleProvider)
            .then(handleAuthSuccess)
            .catch((error) => {
                console.error("Google Sign-in Error:", error.message);
                showAuthError(error.message);
            });
    });
    console.log("auth.js: Google listener attached.");
}