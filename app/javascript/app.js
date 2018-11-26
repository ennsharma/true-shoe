function deploy () {
    $("#auction-button").addClass("hidden");
    $("#new-auction").removeClass("hidden");
    $("#bid-form").removeClass("hidden");
}

$(document).ready(function () {
    $('#bid-form').on('submit', function(e) {
        e.preventDefault();
        updateBid (this.form);
    });
});

var minimumBid = 0.0
var highestBid = minimumBid;
var biddingOpen = true;
function updateBid (form) {
    if (!biddingOpen) {
        alert("Sorry, bidding is closed");
        return;
    }

    var name = form.name.value;
    var bid = form.bid.value;
    var address = form.address.value;

    // TODO: Replace with Smart Contract call to update functionality
    if (bid > highestBid) {
        highestBid = bid;

        document.getElementById("highest-bid").innerHTML = highestBid + " ETH";
    } else {
        alert("Sorry, your bid must exeed the current highest bid of " + highestBid + ".");
    }
}

function showMinimumBid (_minimumBid) {
    minimumBid = _minimumBid
    document.getElementById("highest-bid").innerHTML = minimumBid + " ETH";
}

function closeBidding () {
    biddingOpen = false;

    document.getElementById("bidding-status").innerHTML = "Closed.";
}