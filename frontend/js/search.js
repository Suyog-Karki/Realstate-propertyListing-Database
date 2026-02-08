// Search Page

// Load filter options
async function loadFilterOptions() {
    try {
        // Load cities
        const citiesResponse = await fetch(`${API_ENDPOINTS.search}/cities`);
        const cities = await citiesResponse.json();
        const citySelect = document.getElementById('citySelect');
        cities.forEach(city => {
            const option = document.createElement('option');
            option.value = city;
            option.textContent = city;
            citySelect.appendChild(option);
        });

        // Load property types
        const typesResponse = await fetch(`${API_ENDPOINTS.search}/property-types`);
        const types = await typesResponse.json();
        const typeSelect = document.getElementById('typeSelect');
        types.forEach(type => {
            const option = document.createElement('option');
            option.value = type;
            option.textContent = type;
            typeSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading filter options:', error);
    }
}

// Search form submission
document.getElementById('searchForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    await performSearch();
});

// Perform search
async function performSearch() {
    const spinner = document.getElementById('loadingSpinner');
    const grid = document.getElementById('resultsGrid');
    const noResults = document.getElementById('noResults');
    const resultCount = document.getElementById('resultCount');

    spinner.style.display = 'block';
    grid.innerHTML = '';
    noResults.style.display = 'none';

    const searchParams = {
        city: document.getElementById('citySelect').value,
        propertyType: document.getElementById('typeSelect').value,
        minPrice: document.getElementById('minPrice').value,
        maxPrice: document.getElementById('maxPrice').value,
        status: 'active'
    };

    // Remove empty parameters
    Object.keys(searchParams).forEach(key => {
        if (!searchParams[key]) delete searchParams[key];
    });

    try {
        const response = await fetch(`${API_ENDPOINTS.search}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(searchParams)
        });

        const listings = await response.json();
        spinner.style.display = 'none';

        resultCount.textContent = `${listings.length} ${listings.length === 1 ? 'property' : 'properties'} found`;

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
        showError('Search failed');
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
            </div>
        </div>
    `;

    return card;
}

// Reset search
function resetSearch() {
    document.getElementById('searchForm').reset();
    document.getElementById('resultsGrid').innerHTML = '';
    document.getElementById('noResults').style.display = 'none';
    document.getElementById('resultCount').textContent = '0 properties found';
}

document.getElementById('resetBtn').addEventListener('click', resetSearch);

// Load on page load
document.addEventListener('DOMContentLoaded', () => {
    loadFilterOptions();
    performSearch(); // Show all active listings initially
});
