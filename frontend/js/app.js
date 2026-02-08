// Homepage - Listings and Statistics

// Load statistics
async function loadStatistics() {
    try {
        const response = await fetch(`${API_ENDPOINTS.search}/statistics`);
        const data = await response.json();

        const overview = data.overview;
        document.getElementById('totalListings').textContent = overview.total_listings || 0;
        document.getElementById('activeListings').textContent = overview.active_listings || 0;
        document.getElementById('avgPrice').textContent = formatCurrency(overview.avg_price || 0);
        document.getElementById('soldListings').textContent = overview.sold_listings || 0;
    } catch (error) {
        console.error('Error loading statistics:', error);
    }
}

// Load listings
async function loadListings(status = null) {
    const spinner = document.getElementById('loadingSpinner');
    const grid = document.getElementById('listingsGrid');
    const noResults = document.getElementById('noResults');

    spinner.style.display = 'block';
    grid.innerHTML = '';
    noResults.style.display = 'none';

    try {
        let url = API_ENDPOINTS.listings;
        if (status) {
            url = `${API_ENDPOINTS.listings}/status/${status}`;
        }

        const response = await fetch(url);
        const listings = await response.json();

        spinner.style.display = 'none';

        if (listings.length === 0) {
            noResults.style.display = 'block';
            return;
        }

        listings.forEach(listing => {
            const card = createListingCard(listing);
            grid.appendChild(card);
        });
    } catch (error) {
        spinner.style.display = 'none';
        showError('Failed to load listings');
        console.error(error);
    }
}

// Create listing card
function createListingCard(listing) {
    const card = document.createElement('div');
    card.className = 'listing-card';
    card.onclick = () => window.location.href = `listing-detail.html?id=${listing.id}`;

    const imageHTML = listing.image_url 
        ? `<img src="${listing.image_url}" alt="${listing.property_type}" style="width: 100%; height: 100%; object-fit: cover;">` 
        : '<div style="display: flex; align-items: center; justify-content: center; height: 100%;">🏠</div>';

    card.innerHTML = `
        <div class="listing-image">${imageHTML}</div>
        <div class="listing-content">
            <div class="listing-header">
                <span class="property-badge">${listing.property_type}</span>
                <span class="status-badge ${listing.status}">${listing.status}</span>
            </div>
            <div class="listing-price">${formatCurrency(listing.price)}</div>
            <div class="listing-location">📍 ${listing.city}, ${listing.area || ''}</div>
            <div class="listing-description">${listing.description || 'No description available'}</div>
            <div class="listing-footer">
                <span>Owner: ${listing.owner_name}</span>
                <div class="listing-stats">
                    <span>❤️ ${listing.favorite_count || 0}</span>
                    <span>📷 ${listing.image_count || 0}</span>
                </div>
            </div>
        </div>
    `;

    return card;
}
