// API Configuration
const API_BASE_URL = 'http://localhost:3000/api';

const API_ENDPOINTS = {
    listings: `${API_BASE_URL}/listings`,
    users: `${API_BASE_URL}/users`,
    favorites: `${API_BASE_URL}/favorites`,
    inquiries: `${API_BASE_URL}/inquiries`,
    search: `${API_BASE_URL}/search`,
};

// Helper function to format currency
function formatCurrency(amount) {
    return new Intl.NumberFormat('ne-NP', {
        style: 'currency',
        currency: 'NPR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(amount);
}

// Helper function to format date
function formatDate(dateString) {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(dateString).toLocaleDateString('en-US', options);
}

// Helper function to show error
function showError(message) {
    alert(`Error: ${message}`);
    console.error(message);
}

// Helper function to show success
function showSuccess(message) {
    alert(`Success: ${message}`);
}
