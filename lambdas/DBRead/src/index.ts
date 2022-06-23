import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
import { WizardInstance } from './type';

const readItem = async (key : String, att? : String) : Promise<WizardInstance> => {
    
    const client = new DynamoDBClient({});
    const ddbDocClient = DynamoDBDocumentClient.from(client);
    console.log("received key", key)
    const data = {
        TableName: "WIZARD-RUNTIME",
        Key: {
            "wizard-instance": key
        }
    }

    const resp = await ddbDocClient.send(new GetCommand(data));
    if(!resp.Item || !resp.Item["wizard-instance"])
        return {}

    const result = {
        wizardInstance: resp.Item["wizard-instance"],
        wizardId: resp.Item["wizard-id"]
    }
    return result
};
    

 
export const lambdaHandler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    console.log(`Event: ${JSON.stringify(event, null, 2)}`);
    console.log(`Context: ${JSON.stringify(context, null, 2)}`);
    
    if(!event.pathParameters || !event.pathParameters["wizard-instance"]){
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: "Please specify the item you want to retrieve!",
            }),
        };
    } 

    const obj = event.pathParameters["wizard-instance"]
    const result = await readItem(obj)

    if("wizardInstance" in result)
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: result,
            }),
        };
    else
        return {
            statusCode: 404,
            body: JSON.stringify({
                message: `Object with Key ${event.pathParameters["wizard-instance"]} Not Found!`,
            }),
        }
    

};
