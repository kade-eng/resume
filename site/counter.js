document.addEventListener("DOMContentLoaded", function() {
    fetch('https://us-central1-sincere-pixel-410716.cloudfunctions.net/get-visitor-count', { method: 'POST' })
        .then(response => response.json())
        .then(data => {
            document.getElementById('visitorCount').textContent = "Total Visitor Count: " + data.count;
        })
        .catch(console.error);
});
