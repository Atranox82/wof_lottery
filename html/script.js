let currentData = {};

function openUI(data) {
    currentData = data;
    document.getElementById('lottery-container').classList.remove('hidden');
    updateDisplay();
}

function updateDisplay() {
    document.getElementById('jackpot').innerText = '$' + parseFloat(currentData.jackpot).toFixed(2);
    document.getElementById('drawTime').innerText = currentData.drawTime + ' Uhr';
    document.getElementById('myTickets').innerText = currentData.myTickets + ' / ' + currentData.maxTickets;
    document.getElementById('ticketPrice').innerText = '$' + parseFloat(currentData.ticketPrice).toFixed(2);
}

function closeUI() {
    document.getElementById('lottery-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function buyTicket() {
    fetch(`https://${GetParentResourceName()}/buyTicket`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function claimWinnings() {
    fetch(`https://${GetParentResourceName()}/claim`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'open') {
        openUI(data.data);
    } else if (data.action === 'close') {
        document.getElementById('lottery-container').classList.add('hidden');
    } else if (data.action === 'update') {
        if (currentData) {
            currentData.jackpot = data.jackpot;
            currentData.myTickets = data.tickets;
            updateDisplay();
        }
    }
});

// ESC close
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});