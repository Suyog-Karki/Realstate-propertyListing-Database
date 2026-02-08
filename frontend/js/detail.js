// Listing Detail Page

let currentListing = null;

// Get listing ID from URL
function getListingId() {
    const params = new URLSearchParams(window.location.search);
    return params.get('id');
}

// Load listing details
async function loadListingDetail() {
    const listingId = getListingId();
    if (!listingId) {
        window.location.href = 'index.html';
        return;
    }

    const spinner = document.getElementById('loadingSpinner');
    const content = document.getElementById('detailContent');

    spinner.style.display = 'block';
    content.style.display = 'none';

    try {
        const response = await fetch(`${API_ENDPOINTS.listings}/${listingId}`);
        if (!response.ok) throw new Error('Listing not found');
        
        currentListing = await response.json();
        displayListingDetail(currentListing);

        // Load inquiries
        loadInquiries(listingId);

        spinner.style.display = 'none';
        content.style.display = 'block';
    } catch (error) {
        spinner.style.display = 'none';
        showError('Failed to load listing details');
        setTimeout(() => window.location.href = 'index.html', 2000);
    }
}

// Display listing details
function displayListingDetail(listing) {
    document.getElementById('propertyType').textContent = listing.property_type;
    document.getElementById('propertyStatus').textContent = listing.status;
    document.getElementById('propertyStatus').className = `status-badge ${listing.status}`;
    document.getElementById('propertyTitle').textContent = `${listing.property_type} in ${listing.city}`;
    document.getElementById('propertyLocation').textContent = `📍 ${listing.city}, ${listing.area}`;
    document.getElementById('propertyPrice').textContent = formatCurrency(listing.price);
    document.getElementById('propertyDescription').textContent = listing.description || 'No description available';
    document.getElementById('propertyAddress').textContent = listing.address;
    document.getElementById('ownerName').textContent = listing.owner_name;
    document.getElementById('ownerEmail').textContent = listing.owner_email;
    document.getElementById('favoriteCount').textContent = listing.favorite_count || 0;
    document.getElementById('inquiryCount').textContent = listing.inquiry_count || 0;
    document.getElementById('imageCount').textContent = listing.images?.length || 0;
    document.getElementById('createdDate').textContent = formatDate(listing.created_at);

    // Display images
    if (listing.images && listing.images.length > 0) {
        const mainImage = document.getElementById('mainImage');
        mainImage.innerHTML = `<img src="${listing.images[0].image_url}" alt="Property" onerror="this.parentElement.innerHTML='🏠'">`;

        const gallery = document.getElementById('imageGallery');
        gallery.innerHTML = listing.images.map(img => 
            `<img src="${img.image_url}" class="gallery-thumb" onclick="changeMainImage('${img.image_url}')" onerror="this.style.display='none'">`
        ).join('');
    }
}

// Change main image
function changeMainImage(url) {
    const mainImage = document.getElementById('mainImage');
    mainImage.innerHTML = `<img src="${url}" alt="Property" onerror="this.parentElement.innerHTML='🏠'">`;
}

// Load inquiries
async function loadInquiries(listingId) {
    try {
        const response = await fetch(`${API_ENDPOINTS.inquiries}/listing/${listingId}`);
        const inquiries = await response.json();

        const list = document.getElementById('inquiriesList');
        
        if (inquiries.length === 0) {
            list.innerHTML = '<p style="color: #7f8c8d;">No inquiries yet.</p>';
            return;
        }

        list.innerHTML = inquiries.slice(0, 5).map(inquiry => `
            <div class="inquiry-item">
                <div class="inquiry-header">
                    <span class="inquiry-user">${inquiry.user_name}</span>
                    <span class="inquiry-date">${formatDate(inquiry.created_at)}</span>
                </div>
                <div class="inquiry-message">${inquiry.message}</div>
            </div>
        `).join('');
    } catch (error) {
        console.error('Error loading inquiries:', error);
    }
}

// Favorite button handler
document.getElementById('favoriteBtn')?.addEventListener('click', async () => {
    const userId = prompt('Enter your user ID (for demo purposes):');
    if (!userId) return;

    try {
        const response = await fetch(API_ENDPOINTS.favorites, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: parseInt(userId),
                listing_id: currentListing.id
            })
        });

        const data = await response.json();
        
        if (response.ok) {
            showSuccess('Added to favorites!');
            loadListingDetail(); // Reload to update count
        } else {
            showError(data.error || 'Failed to add to favorites');
        }
    } catch (error) {
        showError('Failed to add to favorites');
    }
});

// Inquiry modal
const modal = document.getElementById('inquiryModal');
const inquiryBtn = document.getElementById('inquiryBtn');
const closeBtn = document.querySelector('.close');

inquiryBtn?.addEventListener('click', () => {
    modal.style.display = 'block';
});

closeBtn?.addEventListener('click', () => {
    modal.style.display = 'none';
});

window.addEventListener('click', (e) => {
    if (e.target === modal) {
        modal.style.display = 'none';
    }
});

// Inquiry form submission
document.getElementById('inquiryForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const userId = document.getElementById('inquiryUserId').value;
    const message = document.getElementById('inquiryMessage').value;

    try {
        const response = await fetch(API_ENDPOINTS.inquiries, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: parseInt(userId),
                listing_id: currentListing.id,
                message: message
            })
        });

        const data = await response.json();
        
        if (response.ok) {
            showSuccess('Inquiry sent successfully!');
            modal.style.display = 'none';
            document.getElementById('inquiryForm').reset();
            loadInquiries(currentListing.id); // Reload inquiries
        } else {
            showError(data.error || 'Failed to send inquiry');
        }
    } catch (error) {
        showError('Failed to send inquiry');
    }
});

// Load on page load
document.addEventListener('DOMContentLoaded', loadListingDetail);
