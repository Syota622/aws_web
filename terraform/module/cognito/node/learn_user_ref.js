const https = require('https');

exports.handler = async (event, context) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    const data = JSON.stringify({
        username: event.request.userAttributes.email,
        password: event.request.userAttributes.password,
        email: event.request.userAttributes.email
    });

    const options = {
        hostname: 'api.mokokero.com',
        port: 443,
        path: '/signup',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': data.length
        }
    };

    try {
        const response = await new Promise((resolve, reject) => {
            const req = https.request(options, (res) => {
                let responseBody = '';

                res.on('data', (chunk) => {
                    responseBody += chunk;
                });

                res.on('end', () => {
                    if (res.statusCode < 200 || res.statusCode >= 300) {
                        reject(new Error(`HTTP status code ${res.statusCode}`));
                    } else {
                        resolve({
                            statusCode: res.statusCode,
                            body: responseBody
                        });
                    }
                });
            });

            req.on('error', (e) => {
                reject(new Error(`Request error: ${e.message}`));
            });

            req.write(data);
            req.end();
        });

        console.log('Response from signup:', response);

        // Cognitoに成功を通知する
        event.response.autoConfirmUser = true;
        return event;

    } catch (error) {
        console.error('Error in signup request:', error.message);
        throw new Error(`Signup request failed: ${error.message}`);
    }
};
