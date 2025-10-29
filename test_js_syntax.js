// Test file to validate chart initialization syntax
Chart.defaults.color = '#9ca3af';
Chart.defaults.borderColor = '#e5e7eb';

let charts = {};

function initCharts() {
    // Sales Trend Chart
    const salesTrendCtx = document.getElementById('salesTrendChart');
    if (salesTrendCtx) {
        charts.salesTrend = new Chart(salesTrendCtx, {
            type: 'line',
            data: {
                labels: ["Jan", "Feb", "Mar"],
                datasets: [{
                    label: 'Revenue',
                    data: [100, 200, 300],
                    borderColor: '#0088FE',
                    backgroundColor: 'rgba(0, 136, 254, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
}