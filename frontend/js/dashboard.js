// Dashboard Page

// Load all users
async function loadUsers() {
    try {
        const response = await fetch(API_ENDPOINTS.users);
        const users = await response.json();

        const userSelect = document.getElementById('userSelect');
        users.forEach(user => {
            const option = document.createElement('option');
            option.value = user.id;
            option.textContent = `${user.name} (${user.email}) - ${user.role}`;
            userSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading users:', error);
    }
}

// Load user dashboard
async function loadUserDashboard() {
    const userId = document.getElementById('userSelect').value;
    const spinner = document.getElementById('loadingSpinner');
    const content = document.getElementById('dashboardContent');
    const noUser = document.getElementById('noUserSelected');

    if (!userId) {
        content.style.display = 'none';
        noUser.style.display = 'block';
        return;
    }

    spinner.style.display = 'block';
    content.style.display = 'none';
    noUser.style.display = 'none';

    try {
        const response = await fetch(`${API_ENDPOINTS.users}/${userId}/activity`);
        const data = await response.json();

        displayUserInfo(data);
        displayFavorites(data.favorites);
        displayInquiries(data.inquiries);
        displayProperties(data.properties, data.user.role);

        spinner.style.display = 'none';
        content.style.display = 'block';
    } catch (error) {
        spinner.style.display = 'none';
        showError('Failed to load user dashboard');
        console.error(error);
    }
}

// Display user information
function displayUserInfo(data) {
    document.getElementById('userName').textContent = data.user.name;
    document.getElementById('userEmail').textContent = data.user.email;
    document.getElementById('userRole').textContent = data.user.role;
    document.getElementById('userRole').className = 'role-badge';

    document.getElementById('favCount').textContent = data.stats.favorite_count;
    document.getElementById('inqCount').textContent = data.stats.inquiry_count;
    document.getElementById('propCount').textContent = data.stats.property_count;
}

// Display favorites
function displayFavorites(favorites) {
    const list = document.getElementById('favoritesList');
    
    if (favorites.length === 0) {
        list.innerHTML = '<p style="color: #7f8c8d;">No favorites yet.</p>';
        return;
    }

    list.innerHTML = favorites.map(fav => `
        <div class="dashboard-item" onclick="window.location.href='listing-detail.html?id=${fav.id}'">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem;">
                <div style="flex: 1;">
                    <strong>${fav.type} in ${fav.city}</strong>
                    <p style="color: #7f8c8d; margin: 0.25rem 0; font-size: 0.9rem;">${fav.area}</p>
                </div>
                <span class="status-badge ${fav.status}">${fav.status}</span>
            </div>
            <div style="padding: 0.75rem 0; border-top: 1px solid #ecf0f1; padding-top: 0.75rem;">
                <p style="color: #3498db; font-weight: bold; font-size: 1.2rem; margin: 0;">${formatCurrency(fav.price)}</p>
            </div>
            <small style="color: #7f8c8d; font-size: 0.85rem;">Added on ${formatDate(fav.favorited_at)}</small>
        </div>
    `).join('');
}

// Display inquiries
function displayInquiries(inquiries) {
    const list = document.getElementById('inquiriesList');
    
    if (inquiries.length === 0) {
        list.innerHTML = '<p style="color: #7f8c8d;">No inquiries yet.</p>';
        return;
    }

    list.innerHTML = inquiries.map(inquiry => `
        <div class="dashboard-item" onclick="window.location.href='listing-detail.html?id=${inquiry.listing_id}'">
            <div style="margin-bottom: 0.75rem;">
                <strong>${inquiry.type} in ${inquiry.city}</strong>
                <small style="color: #7f8c8d; font-size: 0.85rem; display: block; margin-top: 0.25rem;">${formatDate(inquiry.created_at)}</small>
            </div>
            <p style="color: #2c3e50; margin: 0.75rem 0; font-size: 0.95rem;">${inquiry.message}</p>
            <div style="padding: 0.75rem 0; border-top: 1px solid #ecf0f1; padding-top: 0.75rem;">
                <p style="color: #3498db; font-weight: bold; font-size: 1.2rem; margin: 0;">${formatCurrency(inquiry.price)}</p>
            </div>
        </div>
    `).join('');
}

// Display properties
function displayProperties(properties, role) {
    const section = document.getElementById('propertiesSection');
    const list = document.getElementById('propertiesList');

    if (role !== 'seller' || properties.length === 0) {
        section.style.display = 'none';
        return;
    }

    section.style.display = 'block';
    list.innerHTML = properties.map(prop => `
        <div class="dashboard-item">
            <div>
                <strong>${prop.type}</strong>
                <p style="color: #7f8c8d; margin: 0.5rem 0;">${prop.description || 'No description'}</p>
                <p style="color: #3498db; font-weight: bold;">
                    ${prop.listing_count} ${prop.listing_count === 1 ? 'listing' : 'listings'}
                </p>
            </div>
        </div>
    `).join('');
}

// Load users on page load
document.addEventListener('DOMContentLoaded', loadUsers);
