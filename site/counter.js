document.addEventListener("DOMContentLoaded", function() {
    fetch('https://us-central1-divine-precinct-431401-s5.cloudfunctions.net/get-visitor-count', { method: 'GET' })
        .then(response => response.json())
        .then(data => {
            document.getElementById('visitorCount').textContent = "Total Visitor Count: " + data.count;
        })
        .catch(console.error);
});
