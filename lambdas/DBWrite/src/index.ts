import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";



const insertItem = async (parsed : any): Promise<String> => {
    // TODO controllo che esistano partition key e sort key
    if(!parsed["wizard-instance"])
        return "Error, missing key in request body"

    const client = new DynamoDBClient({});
    const ddbDocClient = DynamoDBDocumentClient.from(client);

    const data = {
        TableName: "WIZARD-RUNTIME",
        Item: {
            "wizard-instance": parsed["wizard-instance"],
            "wizard-id": parsed["wizard-id"]
        },
    };
    console.log("DATA: ", JSON.stringify(data));
    
    const resp = await ddbDocClient.send(new PutCommand(data));
    console.log("RESP LOG: ", resp);

    return "OK"
};

export const lambdaHandler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    console.log(`Event: ${JSON.stringify(event, null, 2)}`);
    console.log(`Context: ${JSON.stringify(context, null, 2)}`);

    if(!event.body){
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: "Empty Request Body Or Check For Typos",
            }),
        };
    } 

    const obj = JSON.parse(event.body)
    const result = await insertItem(obj)
    if(result === "OK")
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: result,
            }),
        };
    else
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: result,
            }),
        };
    


};
