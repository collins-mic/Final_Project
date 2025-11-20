console.log("resources.js loaded.");

/* Fade-in on Scroll Animation */
document.addEventListener("DOMContentLoaded", () => {
    // Select all elements that have the "animated-fade-in" class
    const animatedElements = document.querySelectorAll(".animated-fade-in");

    if ("IntersectionObserver" in window) {
        // Create a new observer
        const observer = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                // When the element is in view
                if (entry.isIntersecting) {
                    entry.target.classList.add("is-visible");
                    // Stop observing it once it's visible
                    observer.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.1 // Trigger when 10% of the element is visible
        });

        // Attach the observer to each animated element
        animatedElements.forEach(element => {
            observer.observe(element);
        });
    } else {
        // Fallback for very old browsers (just show everything)
        animatedElements.forEach(element => {
            element.classList.add("is-visible");
        });
    }
});