let csvData = [];
let chartInstance = null;
let filledCells = [];
let normalizedRows = [];

document.getElementById("toggleTheme").addEventListener("click", function () {
    document.body.classList.toggle("dark-mode");
    document.querySelectorAll(".visualization-section, .analysis-section, .upload-section, .data-preview")
        .forEach(section => section.classList.toggle("dark-mode"));
    document.querySelector("table").classList.toggle("dark-mode");
    document.querySelectorAll("button").forEach(button => {
        button.classList.toggle("dark-mode-button");
    });
});

function loadCSV() {
    const fileInput = document.getElementById("csvFileInput");
    const file = fileInput.files[0];

    if (!file) {
        alert("Please select a CSV file!");
        return;
    }

    const reader = new FileReader();
    reader.onload = function (event) {
        const lines = event.target.result.split("\n");
        csvData = lines.map(line => line.split(","));
        filledCells = [];
        normalizedRows = [];
        displayTable();
    };

    reader.readAsText(file);
}

function displayTable() {
    const tableHeader = document.getElementById("tableHeader");
    const tableBody = document.getElementById("tableBody");

    tableHeader.innerHTML = "";
    tableBody.innerHTML = "";

    csvData.forEach((row, index) => {
        let tr = document.createElement("tr");

        // Check if this row has any filled cells
        const rowHasFilledCells = filledCells.some(fc => fc.row === index);
        if (rowHasFilledCells) {
            tr.classList.add("filled-row");
        }

        // Highlight normalized rows
        if (index > 0 && normalizedRows.includes(index)) {
            tr.classList.add("normalized-row");
        }

        row.forEach((cell, colIndex) => {
            let td = document.createElement(index === 0 ? "th" : "td");
            td.textContent = cell;
            tr.appendChild(td);
        });

        if (index === 0) {
            tableHeader.appendChild(tr);
        } else {
            tableBody.appendChild(tr);
        }
    });
}

function cleanData() {
    if (csvData.length === 0) {
        alert("No data loaded!");
        return;
    }

    csvData = csvData.filter((row, index, self) =>
        index === 0 || self.findIndex(r => JSON.stringify(r) === JSON.stringify(row)) === index
    );

    alert("Data cleaned successfully!");
    displayTable();
}

function fillMissingValues() {
    if (csvData.length < 2) {
        alert("No data loaded!");
        return;
    }

    const method = prompt("Choose method to fill missing values:\n1. Median\n2. Mode\n3. Fill with next value\n4. Fill with last value", "1");
    
    if (!method) return;

    let hasMissing = false;
    
    // Find columns with numeric data
    const numericCols = [];
    for (let col = 0; col < csvData[0].length; col++) {
        let isNumeric = true;
        for (let row = 1; row < csvData.length; row++) {
            if (csvData[row][col] && isNaN(parseFloat(csvData[row][col]))) {
                isNumeric = false;
                break;
            }
        }
        if (isNumeric) numericCols.push(col);
    }

    if (numericCols.length === 0) {
        alert("No numeric columns found for filling missing values!");
        return;
    }

    numericCols.forEach(col => {
        const values = [];
        
        // Collect all numeric values
        for (let row = 1; row < csvData.length; row++) {
            if (csvData[row][col] && !isNaN(parseFloat(csvData[row][col]))) {
                values.push(parseFloat(csvData[row][col]));
            }
        }
        
        if (values.length === 0) return;

        let fillValue;
        
        switch (method) {
            case "1": // Median
                values.sort((a, b) => a - b);
                const mid = Math.floor(values.length / 2);
                fillValue = values.length % 2 !== 0 ? values[mid] : (values[mid - 1] + values[mid]) / 2;
                break;
            case "2": // Mode
                const frequency = {};
                let maxFreq = 0;
                fillValue = values[0];
                
                values.forEach(val => {
                    frequency[val] = (frequency[val] || 0) + 1;
                    if (frequency[val] > maxFreq) {
                        maxFreq = frequency[val];
                        fillValue = val;
                    }
                });
                break;
            case "3": // Next value
                for (let row = 1; row < csvData.length; row++) {
                    if (!csvData[row][col] || isNaN(parseFloat(csvData[row][col]))) {
                        for (let nextRow = row + 1; nextRow < csvData.length; nextRow++) {
                            if (csvData[nextRow][col] && !isNaN(parseFloat(csvData[nextRow][col]))) {
                                csvData[row][col] = csvData[nextRow][col];
                                filledCells.push({row: row, col: col});
                                hasMissing = true;
                                break;
                            }
                        }
                    }
                }
                return; // Skip the rest for this column
            case "4": // Last value
                let lastValid = values[0];
                for (let row = 1; row < csvData.length; row++) {
                    if (csvData[row][col] && !isNaN(parseFloat(csvData[row][col]))) {
                        lastValid = csvData[row][col];
                    } else {
                        csvData[row][col] = lastValid;
                        filledCells.push({row: row, col: col});
                        hasMissing = true;
                    }
                }
                return; // Skip the rest for this column
            default:
                alert("Invalid method selected!");
                return;
        }

        // Fill missing values with calculated value
        for (let row = 1; row < csvData.length; row++) {
            if (!csvData[row][col] || isNaN(parseFloat(csvData[row][col]))) {
                csvData[row][col] = fillValue.toString();
                filledCells.push({row: row, col: col});
                hasMissing = true;
            }
        }
    });

    if (hasMissing) {
        alert("Missing values filled successfully!");
        displayTable();
    } else {
        alert("No missing values found in numeric columns!");
    }
}

function generateStats() {
    if (csvData.length < 2) {
        alert("Not enough data for analysis!");
        return;
    }

    const values = csvData.slice(1).map(row => parseFloat(row[1])).filter(v => !isNaN(v));
    
    if (values.length === 0) {
        alert("Invalid data in numeric column!");
        return;
    }

    const sum = values.reduce((a, b) => a + b, 0);
    const mean = sum / values.length;
    const min = Math.min(...values);
    const max = Math.max(...values);

    alert(`📊 Statistics:\nMean: ${mean.toFixed(2)}\nMin: ${min}\nMax: ${max}`);
}

function detectOutliers() {
    if (csvData.length < 2) {
        alert("Not enough data to detect outliers!");
        return;
    }

    const values = csvData.slice(1).map(row => parseFloat(row[1])).filter(v => !isNaN(v));

    if (values.length === 0) {
        alert("Invalid data in numeric column!");
        return;
    }

    const mean = values.reduce((a, b) => a + b, 0) / values.length;
    const squaredDiffs = values.map(val => Math.pow(val - mean, 2));
    const variance = squaredDiffs.reduce((a, b) => a + b, 0) / values.length;
    const stdDev = Math.sqrt(variance);

    const outliers = csvData.slice(1).filter(row => {
        const value = parseFloat(row[1]);
        return value < mean - 2 * stdDev || value > mean + 2 * stdDev;
    });

    if (outliers.length === 0) {
        alert("No outliers detected!");
    } else {
        alert(`🚨 Outliers Detected:\n${outliers.map(row => row.join(", ")).join("\n")}`);
    }
}

function normalizeData() {
    if (csvData.length < 2) {
        alert("No data to normalize!");
        return;
    }

    const values = csvData.slice(1).map(row => parseFloat(row[1])).filter(v => !isNaN(v));

    if (values.length === 0) {
        alert("Invalid data in numeric column!");
        return;
    }

    const min = Math.min(...values);
    const max = Math.max(...values);

    normalizedRows = [];
    
    csvData = csvData.map((row, index) => {
        if (index === 0) return row;
        const originalValue = parseFloat(row[1]);
        if (!isNaN(originalValue)) {
            row[1] = ((originalValue - min) / (max - min)).toFixed(2);
            normalizedRows.push(index);
        }
        return row;
    });

    alert("Data normalized successfully!");
    displayTable();
}

function plotChart(type) {
    const ctx = document.getElementById("dataChart").getContext("2d");

    if (csvData.length < 2) {
        alert("Not enough data for visualization!");
        return;
    }

    const labels = csvData.slice(1).map(row => row[0]);
    const values = csvData.slice(1).map(row => parseFloat(row[1])).filter(v => !isNaN(v));

    if (values.length === 0) {
        alert("Invalid data in numeric column!");
        return;
    }

    if (chartInstance) {
        chartInstance.destroy();
    }

    // Adjust font size based on chart type
    const fontSize = type === 'pie' ? 12 : 10;
    
    chartInstance = new Chart(ctx, {
        type: type,
        data: {
            labels: labels,
            datasets: [{
                label: "Data Visualization",
                data: values,
                backgroundColor: [
                    'rgba(255, 99, 132, 0.7)',
                    'rgba(54, 162, 235, 0.7)',
                    'rgba(255, 206, 86, 0.7)',
                    'rgba(75, 192, 192, 0.7)',
                    'rgba(153, 102, 255, 0.7)',
                    'rgba(255, 159, 64, 0.7)'
                ],
                borderColor: [
                    'rgba(255, 99, 132, 1)',
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 206, 86, 1)',
                    'rgba(75, 192, 192, 1)',
                    'rgba(153, 102, 255, 1)',
                    'rgba(255, 159, 64, 1)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        font: {
                            size: fontSize
                        }
                    }
                },
                tooltip: {
                    bodyFont: {
                        size: fontSize
                    },
                    titleFont: {
                        size: fontSize
                    }
                }
            },
            scales: type === 'pie' ? undefined : {
                y: {
                    beginAtZero: true,
                    ticks: {
                        font: {
                            size: fontSize
                        }
                    }
                },
                x: {
                    ticks: {
                        font: {
                            size: fontSize
                        }
                    }
                }
            }
        }
    });
}

function plotLineChart() { plotChart('line'); }
function plotBarChart() { plotChart('bar'); }
function plotPieChart() { plotChart('pie'); }