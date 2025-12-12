const API_URL = 'http://localhost:3000/api';
let currentTable = ''; // Tracks which table is currently being managed

const columnLabels = {
    'Action': 'İşlem',

    'Customer': 'Müşteri',
    'CustomerID': 'Müşteri ID',
    'CustomerName': 'Müşteri Adı',
    'PhoneNumber': 'Telefon Numarası',
    'Email': 'E-posta Adresi',
    'Address': 'Adres',
    'CompanyID': 'Şirket ID',
    
    'Product': 'Ürün',
    'ProductID': 'Ürün ID',
    'ProductName': 'Ürün Adı',
    'Type': 'Kategori',
    'ItemPrice': 'Birim Fiyat',
    'StockQuantity': 'Stok Miktarı',
};

function getLabel(key) {
    return columnLabels[key] || key;
}

// ==========================================
// UI & NAVIGATION LOGIC
// ==========================================

function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('.section').forEach(sec => sec.classList.remove('active'));
    // Reset sidebar buttons
    document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
    
    // Show target section and highlight button
    document.getElementById(sectionId).classList.add('active');
    
    // Highlight the clicked button (safely handling the event)
    if (window.event && window.event.target) {
        window.event.target.classList.add('active');
    }
    
    hideMessage();
}

function showMessage(msg, isError = false) {
    const el = document.getElementById('statusMessage');
    el.textContent = msg;
    el.className = isError ? 'error' : 'success';
    el.style.display = 'block';
}

function hideMessage() {
    document.getElementById('statusMessage').style.display = 'none';
}

// ==========================================
// FEATURE 1: PROCESS SALE
// ==========================================
document.getElementById('saleForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = {
        customerId: document.getElementById('customerId').value,
        productId: document.getElementById('productId').value,
        quantity: document.getElementById('quantity').value
    };

    try {
        const response = await fetch(`${API_URL}/sale`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        
        const result = await response.json();
        
        if (result.success) {
            showMessage(result.message); // Success message from server (assumed TR)
            document.getElementById('saleForm').reset();
        } else {
            showMessage(result.error, true); // Error like "Insufficient Stock"
        }
    } catch (err) {
        console.error(err);
        showMessage('Sunucu Bağlantı Hatası!', true);
    }
});

// ==========================================
// FEATURE 2: SEARCH GARAGE
// ==========================================
async function searchGarage() {
    const name = document.getElementById('searchName').value;
    const tbody = document.getElementById('garageResults');
    
    // Show loading state
    tbody.innerHTML = '<tr><td colspan="4">Yükleniyor...</td></tr>';

    try {
        const response = await fetch(`${API_URL}/garage?customerName=${name}`);
        const vehicles = await response.json();

        tbody.innerHTML = ''; // Clear loading message
        
        if (vehicles.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4">Araç bulunamadı.</td></tr>';
            return;
        }

        // Map data directly to table rows
        vehicles.forEach(v => {
            const row = `<tr>
                <td>${v.CustomerName}</td>
                <td>${v.LicensePlate}</td>
                <td>${v.Brand}</td>
                <td>${v.ModelYear}</td>
            </tr>`;
            tbody.innerHTML += row;
        });
    } catch (err) {
        console.error(err);
        tbody.innerHTML = '<tr><td colspan="4">Veri çekme hatası.</td></tr>';
    }
}

// ==========================================
// FEATURE 3: FINANCIAL REPORT
// ==========================================
async function getRevenue() {
    const start = document.getElementById('startDate').value;
    const end = document.getElementById('endDate').value;
    
    try {
        const response = await fetch(`${API_URL}/revenue?startDate=${start}&endDate=${end}`);
        const data = await response.json();
        
        // Format the currency (Turkish Lira)
        const formatted = new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(data.totalRevenue || 0);
        document.getElementById('revenueDisplay').textContent = formatted;
    } catch (err) {
        console.error(err);
        document.getElementById('revenueDisplay').textContent = "Hata!";
    }
}

// ==========================================
// FEATURE 4: MANUAL RESTOCK
// ==========================================
document.getElementById('restockForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = {
        productId: document.getElementById('restockProductId').value,
        quantity: document.getElementById('restockQuantity').value
    };

    try {
        const res = await fetch(`${API_URL}/restock`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();
        
        if(result.success) {
            showMessage(result.message);
            document.getElementById('restockForm').reset();
        } else {
            showMessage(result.error, true);
        }
    } catch(err) { showMessage("Sunucu Hatası", true); }
});

// ==========================================
// FEATURE 5: UPDATE PRICE
// ==========================================
document.getElementById('priceForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = {
        productId: document.getElementById('priceProductId').value,
        percentage: document.getElementById('pricePercentage').value,
        isIncrease: document.getElementById('priceIsIncrease').value === '1' // Convert to boolean
    };

    try {
        const res = await fetch(`${API_URL}/update-price`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();

        if(result.success) {
            showMessage("Fiyat güncellendi.");
            document.getElementById('priceForm').reset();
        } else {
            showMessage(result.error, true);
        }
    } catch(err) { showMessage("Sunucu Hatası", true); }
});

// ==========================================
// FEATURE 6: DELETE OLD VEHICLES
// ==========================================
document.getElementById('deleteVehicleForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const year = document.getElementById('cutoffYear').value;

    if(!confirm(`${year} yılından eski TÜM araçlar silinecek. Emin misiniz?`)) return;

    try {
        const res = await fetch(`${API_URL}/delete-vehicles`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cutoffYear: year })
        });
        const result = await res.json();

        if(result.success) {
            showMessage(result.message);
            document.getElementById('deleteVehicleForm').reset();
        } else {
            showMessage(result.error, true);
        }
    } catch(err) { showMessage("Sunucu Hatası", true); }
});

// ==========================================
// FEATURE 7: DYNAMIC TABLE MANAGEMENT (CRUD)
// ==========================================

// 1. Client-Side Search / Filtering
function filterTable() {
    const input = document.getElementById('tableSearchInput');
    const filter = input.value.toUpperCase();
    const table = document.getElementById('dynamicTable');
    const tr = table.getElementsByTagName('tr');

    // Loop through all table rows (excluding header)
    for (let i = 1; i < tr.length; i++) {
        let visible = false;
        const tds = tr[i].getElementsByTagName('td');
        
        // Check all cells in the row
        for (let j = 0; j < tds.length; j++) {
            if (tds[j]) {
                const txtValue = tds[j].textContent || tds[j].innerText;
                if (txtValue.toUpperCase().indexOf(filter) > -1) {
                    visible = true;
                    break; // Stop checking if match found
                }
            }
        }
        tr[i].style.display = visible ? "" : "none";
    }
}

// 2. Load Table and Generate Input Fields
async function loadTable(tableName) {
    currentTable = tableName;
    showSection('managementSection');
    
    // Update the title (e.g. Customer -> Customer Management, currently using table name)
    const tableTRNames = {
        'Customer': 'Müşteri',
        'Product': 'Ürün',
    };
    document.getElementById('tableTitle').innerText = (tableTRNames[tableName] || tableName) + " Yönetimi";
    // -----------------------------
    
    const tbody = document.getElementById('tableBody');
    const thead = document.getElementById('tableHeaders');
    const formContainer = document.getElementById('dynamicFormContainer'); 
    
    tbody.innerHTML = '<tr><td>Yükleniyor...</td></tr>';
    thead.innerHTML = '';
    formContainer.innerHTML = ''; 

    try {
        const res = await fetch(`${API_URL}/data/${tableName}`);
        const data = await res.json();

        if (data.length === 0) {
            tbody.innerHTML = '<tr><td>Kayıt bulunamadı.</td></tr>';
            formContainer.innerHTML = '<p>Yapıyı belirlemek için veri yok.</p>';
            return;
        }

        const columns = Object.keys(data[0]);
        
        // --- DYNAMIC FORM GENERATION ---
        columns.forEach((col, index) => {
            if (index === 0) return; // Skip ID column
            
            const div = document.createElement('div');
            div.className = 'dynamic-field';
            
            // CHANGED HERE: Label and Placeholder translated to Turkish using getLabel()
            div.innerHTML = `
                <label>${getLabel(col)}</label>
                <input type="text" name="${col}" class="generated-input" placeholder="${getLabel(col)}">
            `;
            formContainer.appendChild(div);
        });
        // -------------------------------

        // Generate Table Headers
        columns.push('Action'); 
        columns.forEach(col => {
            const th = document.createElement('th');
            th.innerText = getLabel(col); // CHANGED HERE: Header translated to Turkish
            thead.appendChild(th);
        });

        // Populate Rows
        tbody.innerHTML = '';
        data.forEach(row => {
            const tr = document.createElement('tr');
            
            Object.values(row).forEach(val => {
                const td = document.createElement('td');
                td.innerText = val;
                tr.appendChild(td);
            });

            // Delete Button
            const id = Object.values(row)[0]; 
            const tdAction = document.createElement('td');
            const btn = document.createElement('button');
            btn.innerText = 'SİL';
            btn.className = 'action-btn btn-danger';
            btn.style.padding = '5px 20px';
            btn.style.fontSize = '0.9rem';
            btn.onclick = () => deleteRow(id);
            
            tdAction.appendChild(btn);
            tr.appendChild(tdAction);
            tbody.appendChild(tr);
        });

    } catch (err) {
        console.error(err);
        tbody.innerHTML = '<tr><td>Tablo yüklenirken hata oluştu.</td></tr>';
    }
}

// 3. Save Data (Using generated inputs)
async function saveData() {
    // Find all dynamically generated inputs
    const inputs = document.querySelectorAll('.generated-input');
    const bodyData = {};
    let hasData = false;

    // Build the data object
    inputs.forEach(input => {
        if(input.value.trim() !== "") {
            bodyData[input.name] = input.value;
            hasData = true;
        }
    });
    
    if (!hasData) {
        alert("Lütfen en az bir alanı doldurun.");
        return;
    }

    try {
        const res = await fetch(`${API_URL}/data/${currentTable}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(bodyData)
        });

        const result = await res.json();
        if(result.success) {
            alert(result.message);
            loadTable(currentTable); // Refresh table
            
            // Clear inputs
            inputs.forEach(input => input.value = '');
        } else {
            alert("Hata: " + (result.error || result.message));
        }
    } catch (err) {
        alert("Sunucu Hatası!");
        console.error(err);
    }
}

// 4. Update Data (Using generated inputs)
async function updateData() {
    const id = document.getElementById('updateId').value;
    if(!id) { 
        alert("Lütfen güncellenecek ID'yi girin."); 
        return; 
    }

    const inputs = document.querySelectorAll('.generated-input');
    const bodyData = {};
    let hasData = false;

    inputs.forEach(input => {
        if(input.value.trim() !== "") {
            bodyData[input.name] = input.value;
            hasData = true;
        }
    });

    if (!hasData) {
        alert("Lütfen güncellenecek en az bir değer girin.");
        return;
    }

    try {
        const res = await fetch(`${API_URL}/data/${currentTable}/${id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(bodyData)
        });
        
        const result = await res.json();
        if(result.success) {
            alert("Kayıt güncellendi!");
            loadTable(currentTable);
            
            // Clear inputs
            inputs.forEach(input => input.value = '');
            document.getElementById('updateId').value = '';
        } else {
            alert("Hata: " + result.message);
        }
    } catch (err) {
        alert("Hata oluştu.");
    }
}

// 5. Delete Row
async function deleteRow(id) {
    if(!confirm(`ID: ${id} kaydını silmek istediğinize emin misiniz?`)) return;

    try {
        const res = await fetch(`${API_URL}/data/${currentTable}/${id}`, {
            method: 'DELETE'
        });
        
        const result = await res.json();
        
        if (result.success) {
            loadTable(currentTable); // Refresh table
        } else {
            alert("Silinemedi: " + result.message);
        }
    } catch (err) {
        alert("Silme işlemi başarısız.");
    }
}

// ==========================================
// FEATURE 8: ABOUT US PAGE
// ==========================================
async function loadAboutPage() {
    showSection('aboutSection');

    try {
        const res = await fetch(`${API_URL}/data/Company`);
        const data = await res.json();

        if (data.length > 0) {
            const company = data[0];
            
            document.getElementById('compAddress').textContent = company.Address;
            document.getElementById('compPhone').textContent = company.PhoneNumber;
            document.getElementById('compEmail').textContent = company.Email;
            document.getElementById('compTax').textContent = company.TaxNumber;
            document.getElementById('compID').textContent = company.CompanyID;
        } else {
            document.getElementById('compName').textContent = "Şirket Bulunamadı";
        }
    } catch (err) {
        console.error(err);
        alert("Şirket bilgileri yüklenemedi.");
    }
}