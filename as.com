<!DOCTYPE html>
<html lang="hi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>बच्चे की ग्रोथ चेकर - 0-6 साल</title>
    <link rel="stylesheet" href="style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Devanagari:wght@400;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <header>
            <h1>👶 बच्चे की ग्रोथ चेकर</h1>
            <p>0-6 साल के बच्चों की हाइट और वजन चेक करें</p>
        </header>

        <div class="input-section">
            <div class="input-group">
                <label>बच्चे की उम्र (महीने में):</label>
                <input type="number" id="age" min="0" max="72" placeholder="0-72 महीने">
            </div>
            
            <div class="input-group">
                <label>लिंग:</label>
                <select id="gender">
                    <option value="boy">लड़का 👦</option>
                    <option value="girl">लड़की 👧</option>
                </select>
            </div>
            
            <div class="input-group">
                <label>हाइट (सेमी में):</label>
                <input type="number" id="height" step="0.1" placeholder="उदाहरण: 75.5">
            </div>
            
            <div class="input-group">
                <label>वजन (किलो में):</label>
                <input type="number" id="weight" step="0.1" placeholder="उदाहरण: 10.2">
            </div>
            
            <button onclick="checkGrowth()">ग्रोथ चेक करें ✅</button>
        </div>

        <div id="result" class="result-section" style="display: none;">
            <h2>परिणाम</h2>
            <div id="height-result"></div>
            <div id="weight-result"></div>
            <div id="overall"></div>
            <canvas id="chart" width="300" height="200"></canvas>
        </div>

        <div class="info">
            <h3>ℹ️ जानकारी:</h3>
            <ul>
                <li>WHO Growth Standards के अनुसार चेक किया जाता है</li>
                <li>हर महीने सही माप लें</li>
                <li>डॉक्टर से सलाह जरूर लें</li>
            </ul>
        </div>
    </div>

    <script src="script.js"></script>
</body>
</html>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Noto Sans Devanagari', sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    padding: 20px;
}

.container {
    max-width: 500px;
    margin: 0 auto;
    background: white;
    border-radius: 20px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.1);
    overflow: hidden;
}

header {
    background: linear-gradient(45deg, #ff6b6b, #feca57);
    color: white;
    text-align: center;
    padding: 30px;
}

header h1 {
    font-size: 2em;
    margin-bottom: 10px;
}

.input-section {
    padding: 30px;
}

.input-group {
    margin-bottom: 20px;
}

label {
    display: block;
    margin-bottom: 8px;
    font-weight: bold;
    color: #333;
}

input, select {
    width: 100%;
    padding: 15px;
    border: 2px solid #e1e5e9;
    border-radius: 12px;
    font-size: 16px;
    transition: border-color 0.3s;
}

input:focus, select:focus {
    outline: none;
    border-color: #667eea;
}

button {
    width: 100%;
    padding: 18px;
    background: linear-gradient(45deg, #667eea, #764ba2);
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 18px;
    font-weight: bold;
    cursor: pointer;
    transition: transform 0.3s;
}

button:hover {
    transform: translateY(-2px);
}

.result-section {
    background: #f8f9ff;
    padding: 30px;
    border-top: 1px solid #e1e5e9;
}

.result-card {
    background: white;
    padding: 20px;
    border-radius: 12px;
    margin-bottom: 15px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.08);
}

.normal { border-left: 5px solid #4CAF50; }
.under { border-left: 5px solid #FF9800; }
.over { border-left: 5px solid #f44336; }

#chart {
    margin-top: 20px;
    border-radius: 12px;
}

.info {
    padding: 20px 30px 30px;
    background: #f0f4ff;
}

.info h3 {
    color: #667eea;
    margin-bottom: 15px;
}

.info ul {
    list-style: none;
}

.info li {
    padding: 8px 0;
    position: relative;
    padding-left: 25px;
}

.info li:before {
    content: "✓";
    position: absolute;
    left: 0;
    color: #4CAF50;
    font-weight: bold;
}

@media (max-width: 480px) {
    .container {
        margin: 10px;
        border-radius: 15px;
    }
    
    header h1 {
        font-size: 1.5em;
    }
}
// WHO Growth Standards Data (simplified percentiles)
const growthData = {
    boy: {
        height: [
            // [age_months, p3, p15, p50, p85, p97]
            [0, 49.1, 49.9, 50.8, 51.7, 52.5],
            [1, 53.7, 54.7, 55.8, 56.9, 57.9],
            [3, 59.8, 61.1, 62.5, 63.9, 65.3],
            [6, 65.7, 67.3, 69.2, 71.1, 72.8],
            [12, 74.0, 76.0, 78.2, 80.4, 82.5],
            [18, 80.1, 82.4, 84.9, 87.3, 89.6],
            [24, 85.1, 87.6, 90.3, 93.0, 95.5],
            [36, 92.6, 95.4, 98.4, 101.4, 104.2],
            [48, 99.1, 102.2, 105.4, 108.6, 111.6],
            [60, 104.6, 107.9, 111.3, 114.7, 117.9]
        ],
        weight: [
            [0, 2.4, 2.7, 3.2, 3.8, 4.4],
            [1, 3.4, 3.9, 4.5, 5.2, 6.0],
            [3, 4.7, 5.4, 6.4, 7.4, 8.6],
            [6, 6.4, 7.3, 8.4, 9.7, 11.2],
            [12, 8.4, 9.6, 11.0, 12.7, 14.6],
            [18, 9.6, 11.0, 12.7, 14.6, 16.8],
            [24, 10.6, 12.2, 14.1, 16.3, 18.8],
            [36, 12.3, 14.2, 16.5, 19.1, 22.1],
            [48, 13.9, 16.1, 18.7, 21.7, 25.1],
            [60, 15.3, 17.8, 20.7, 24.0, 27.8]
        ]
    },
    girl: {
        height: [
            [0, 48.6, 49.4, 50.2, 51.1, 51.9],
            [1, 53.2, 54.2, 55.3, 56.4, 57.4],
            [3, 59.4, 60.7, 62.1, 63.5, 64.9],
            [6, 65.4, 67.0, 68.9, 70.8, 72.5],
            [12, 73.7, 75.7, 77.9, 80.1, 82.2],
            [18, 79.9, 82.2, 84.7, 87.1, 89.4],
            [24, 85.0, 87.5, 90.2, 92.9, 95.4],
            [36, 92.5, 95.3, 98.3, 101.3, 104.1],
            [48, 99.0, 102.1, 105.3, 108.5, 111.5],
            [60, 104.5, 107.8, 111.2, 114.6, 117.8]
        ],
        weight: [
            [0, 2.3, 2.6, 3.0, 3.6, 4.2],
            [1, 3.3, 3.8, 4.4, 5.1, 5.9],
            [3, 4.5, 5.2, 6.2, 7.2, 8.4],
            [6, 6.2, 7.1, 8.2, 9.5, 11.0],
            [12, 8.2, 9.4, 10.8, 12.5, 14.4],
            [18, 9.4, 10.8, 12.5, 14.4, 16.6],
            [24, 10.4, 12.0, 13.9, 16.1, 18.6],
            [36, 12.1, 14.0, 16.3, 18.9, 21.9],
            [48, 13.7, 15.9, 18.5, 21.5, 24.9],
            [60, 15.1, 17.6, 20.5, 23.8, 27.6]
        ]
    }
};

function checkGrowth() {
    const age = parseFloat(document.getElementById('age').value);
    const gender = document.getElementById('gender').value;
    const height = parseFloat(document.getElementById('height').value);
    const weight = parseFloat(document.getElementById('weight').value);

    if (!age || !height || !weight || age > 72 || age < 0) {
        alert('सभी फील्ड सही भरें! उम्र 0-72 महीने होनी चाहिए।');
        return;
    }

    const data = growthData[gender];
    const heightRow = findAgeRow(data.height, age);
    const weightRow = findAgeRow(data.weight, age);

    const heightStatus = getStatus(height, heightRow);
    const weightStatus = getStatus(weight, weightRow);

    showResult(heightStatus, weightStatus, heightRow, weightRow, age, gender);
    drawChart(heightStatus, weightRow);
}

function findAgeRow(data, age) {
    return data[Math.min(Math.floor(age / 6), data.length - 1)];
}

function getStatus(value, row) {
    const [, p15, p50, p85, p97] = row;
    
    if (value < p15 * 0.9) return { status: 'under', text: 'बहुत कम (Severe Underweight)', percent: 'P3' };
    if (value < p50) return { status: 'under', text: 'कम (Underweight)', percent: 'P15-P50' };
    if (value <= p85) return { status: 'normal', text: 'सामान्य (Normal)', percent: 'P50-P85' };
    if (value <= p97) return { status: 'over', text: 'ज्यादा (Overweight)', percent: 'P85-P97' };
    return { status: 'over', text: 'बहुत ज्यादा (Obese)', percent: '>P97' };
}

function showResult(heightStatus, weightStatus, heightRow, weightRow, age, gender) {
    const resultDiv = document.getElementById('result');
    const heightResult = document.getElementById('height-result');
    const weightResult = document.getElementById('weight-result');
    const overall = document.getElementById('overall');

    heightResult.innerHTML = `
        <div class="result-card ${heightStatus.status}">
            <h3>📏 हाइट (${age} महीने, ${gender === 'boy' ? 'लड़का' : 'लड़की'})</h3>
            <p><strong>${heightStatus.text}</strong></p>
            <p>आपका माप: <strong>${document.getElementById('height').value} cm</strong></p>
            <p>सामान्य रेंज: ${heightRow[2].toFixed(1)} - ${heightRow[3].toFixed(1)} cm</p>
        </div>
    `;

    weightResult.innerHTML = `
        <div class="result-card ${weightStatus.status}">
            <h3>⚖️ वजन</h3>
            <p><strong>${weightStatus.text}</strong></p>
            <p>आपका माप: <strong>${document.getElementById('weight').value} kg</strong></p>
            <p>सामान्य रेंज: ${weightRow[2].toFixed(1)} - ${weightRow[3].toFixed(1)} kg</p>
        </div>
    `;

    const overallStatus = heightStatus.status === 'normal' && weightStatus.status === 'normal' ? 'normal' : 'under';
    overall.innerHTML = `
        <div class="result-card ${overallStatus}">
            <h3>🎯 समग्र स्थिति</h3>
            <p>${overallStatus === 'normal' ? 'बच्चा पूरी तरह स्वस्थ है! 👏' : 'डॉक्टर से सलाह लें ⚠️'}</p>
        </div>
    `;

    resultDiv.style.display = 'block';
    resultDiv.scrollIntoView({ behavior: 'smooth' });
}

function drawChart(status, weightRow) {
    const canvas = document.getElementById('chart');
    const ctx = canvas.getContext('2d');
    
    // Clear canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw chart background
    ctx.fillStyle = '#f8f9ff';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Draw bars
    const barWidth = 60;
    const barSpacing = 20;
    const maxHeight = 150;
    
    const normalMax = weightRow[3];
    const userWeight = parseFloat(document.getElementById('weight').value);
    
    // Normal range bar
    ctx.fillStyle = '#4CAF50';
    ctx.fillRect(20, canvas.height - (normalMax * 10), barWidth, normalMax * 10);
    
    // User weight bar
    const userBarHeight = Math.min(userWeight * 10, maxHeight);
    ctx.fillStyle = status.status === 'normal' ? '#4CAF50' : 
                   status.status === 'under' ? '#FF9800' : '#f44336';
    ctx.fillRect(110, canvas.height - userBarHeight, barWidth, userBarHeight);
    
    // Labels
    ctx.fillStyle = '#333';
    ctx.font = '14px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('सामान्य', 50, canvas.height - 5);
    ctx.fillText('आपका बच्चा', 140, canvas.height - 5);
    
    ctx.fillText(`${normalMax.toFixed(1)}kg`, 50, canvas.height - (normalMax * 10) - 5);
    ctx.fillText(`${userWeight.toFixed(1)}kg`, 140, canvas.height - userBarHeight - 5);
}

// Auto-focus first input
document.getElementById('age').focus();
     