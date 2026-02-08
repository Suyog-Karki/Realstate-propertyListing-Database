// Statistics Page

// Load statistics
async function loadStatistics() {
    const spinner = document.getElementById('loadingSpinner');
    const content = document.getElementById('statsContent');

    spinner.style.display = 'block';
    content.style.display = 'none';

    try {
        const response = await fetch(`${API_ENDPOINTS.search}/statistics`);
        const data = await response.json();

        displayOverviewStats(data.overview);
        displayTopCities(data.topCities);
        displayPropertyTypes(data.propertyTypes);

        spinner.style.display = 'none';
        content.style.display = 'block';
    } catch (error) {
        spinner.style.display = 'none';
        showError('Failed to load statistics');
        console.error(error);
    }
}

// Display overview statistics
function displayOverviewStats(overview) {
    document.getElementById('totalListings').textContent = overview.total_listings || 0;
    document.getElementById('activeListings').textContent = overview.active_listings || 0;
    document.getElementById('avgPrice').textContent = formatCurrency(overview.avg_price || 0);
    document.getElementById('soldListings').textContent = overview.sold_listings || 0;
    document.getElementById('minPrice').textContent = formatCurrency(overview.min_price || 0);
    document.getElementById('maxPrice').textContent = formatCurrency(overview.max_price || 0);
}

// Display top cities
function displayTopCities(cities) {
    const container = document.getElementById('topCities');
    
    if (!cities || cities.length === 0) {
        container.innerHTML = '<p style="color: #7f8c8d;">No data available</p>';
        return;
    }

    container.innerHTML = `
        <div class="stats-row" style="background: #ecf0f1; font-weight: bold;">
            <div>City</div>
            <div>Listings</div>
            <div>Avg Price</div>
        </div>
        ${cities.map(city => `
            <div class="stats-row">
                <div><strong>${city.city}</strong></div>
                <div>${city.listing_count}</div>
                <div>${formatCurrency(city.avg_price || 0)}</div>
            </div>
        `).join('')}
    `;
}

// Display property types
function displayPropertyTypes(types) {
    const container = document.getElementById('propertyTypes');
    
    if (!types || types.length === 0) {
        container.innerHTML = '<p style="color: #7f8c8d;">No data available</p>';
        return;
    }

    container.innerHTML = `
        <div class="stats-row" style="background: #ecf0f1; font-weight: bold;">
            <div>Property Type</div>
            <div>Listings</div>
            <div>Avg Price</div>
        </div>
        ${types.map(type => `
            <div class="stats-row">
                <div><strong>${type.type}</strong></div>
                <div>${type.listing_count}</div>
                <div>${formatCurrency(type.avg_price || 0)}</div>
            </div>
        `).join('')}
    `;
}

// Load statistics on page load
document.addEventListener('DOMContentLoaded', loadStatistics);
