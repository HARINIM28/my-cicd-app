const express = require('express');
const app = express();
const port = 3000;


const APP_VERSION = process.env.APP_VERSION || 'BLUE';


let bgColor, cardColor, textColor, ringColor, versionColor;

if (APP_VERSION.toLowerCase() === 'green') {
  bgColor = 'bg-green-50'; 
  cardColor = 'bg-white';
  textColor = 'text-green-800';
  ringColor = 'ring-green-500';
  versionColor = 'text-green-600';
} else {
  bgColor = 'bg-blue-50'; 
  cardColor = 'bg-white';
  textColor = 'text-blue-800';
  ringColor = 'ring-blue-500';
  versionColor = 'text-blue-600';
}


const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deployment Successful</title>
    <!-- Load Tailwind CSS from CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap');
        body {
            font-family: 'Inter', sans-serif;
        }
    </style>
</head>
<body class="${bgColor} flex items-center justify-center min-h-screen">

    <div class="${cardColor} rounded-xl shadow-2xl overflow-hidden max-w-lg w-full ring-2 ${ringColor}/20">
        <div class="px-8 py-10 md:p-12">
            
            <!-- Header -->
            <div class="flex items-center space-x-3">
                <svg class="w-12 h-12 ${versionColor}" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                </svg>
                <h1 class="text-3xl font-bold ${textColor}">Deployment Successful</h1>
            </div>

            <!-- Content -->
            <div class="mt-8">
                <p class="text-lg ${textColor}/80">
                    Your application was successfully deployed by the CI/CD pipeline.
                </p>
                <p class="mt-4 text-lg ${textColor}/80">
                    You are currently viewing the
                    <span class="font-bold text-2xl ${versionColor} bg-opacity-10 px-2 py-1 rounded-md">
                        ${APP_VERSION.toUpperCase()}
                    </span>
                    environment.
                </p>
            </div>

            <!-- Footer -->
            <div class="mt-10 pt-6 border-t ${ringColor}/20">
                <p class="text-sm ${textColor}/60">
                    This page is being served by a Node.js & Express server running inside a Docker container.
                </p>
            </div>
        </div>
    </div>

</body>
</html>
`;


app.get('/', (req, res) => {
  res.send(htmlContent);
});


app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`App listening on port ${port} as ${APP_VERSION.toUpperCase()}`);
});
