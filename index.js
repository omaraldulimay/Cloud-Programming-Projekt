const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();

// Diese Datei enthält den Lambda-Handler für das Verarbeiten von Kontaktformular-Daten und das Speichern in einer DynamoDB-Tabelle.

exports.handler = async (event) => {
    // Analysiere den POST-Anfragekörper
    const body = JSON.parse(event.body);

    // Bereite die Parameter für die DynamoDB-Put-Operation vor
    const params = {
        TableName: 'cloudprogramming-table',
        Item: body
    };

    // Füge die Kontaktformulardaten in die DynamoDB-Tabelle ein
    try {
        await docClient.put(params).promise();
    } catch (error) {
        console.log('DynamoDB-Fehler: ', error);
        return {
            statusCode: 500,
            body: JSON.stringify('Verbindung zu DynamoDB fehlgeschlagen')
        };
    }

    // Gib eine erfolgreiche Antwort zurück
    const response = {
        statusCode: 200,
        body: JSON.stringify('Kontaktformulardaten erhalten!'),
    };
    return response;
};
