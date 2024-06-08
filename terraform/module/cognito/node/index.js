const https = require('https');

exports.handler = async (event) => {
    const data = JSON.stringify({
        username: event.username,
        password: event.password,
        email: event.email
    });

    const options = {
        hostname: 'mokokero.com',
        port: 443,
        path: '/signup',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': data.length
        }
    };

    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            let responseBody = '';

            res.on('data', (chunk) => {
                responseBody += chunk;
            });

            res.on('end', () => {
                resolve({
                    statusCode: res.statusCode,
                    body: responseBody
                });
            });
        });

        req.on('error', (e) => {
            reject({
                statusCode: 500,
                body: JSON.stringify({ error: e.message })
            });
        });

        req.write(data);
        req.end();
    });
};
