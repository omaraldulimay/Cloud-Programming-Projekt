const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    // Parse the POST request body
    const body = JSON.parse(event.body);

    // Prepare the parameters for the DynamoDB put operation
    const params = {
        TableName: 'cloudprogramming-table',
        Item: body
    };

    // Insert the contact form data into the DynamoDB table
    try {
        await docClient.put(params).promise();
    } catch (error) {
        console.log('DynamoDB error: ', error);
        return {
            statusCode: 500,
            body: JSON.stringify('Failed to connect to DynamoDB')
        };
    }

    // Return a successful response
    const response = {
        statusCode: 200,
        body: JSON.stringify('Contact form data received!'),
    };
    return response;
};