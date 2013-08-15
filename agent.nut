//*************************TWILIO***********************************************
const TWILIO_ACCOUNT_SID = "YOUR SID"  // your SID goes here
const TWILIO_AUTH_TOKEN = "YOUR TOKEN" // your token goes here
const TWILIO_FROM_NUMBER = "+19195551212" // your phone no goes here
const TWILIO_TO_NUMBER = "+19195551212" // destination phone no

function send_sms(number, message) {
    local twilio_url = format("https://api.twilio.com/2010-04-01/Accounts/%s/SMS/Messages.json", TWILIO_ACCOUNT_SID);
    local auth = "Basic " + http.base64encode(TWILIO_ACCOUNT_SID+":"+TWILIO_AUTH_TOKEN);
    local body = http.urlencode({From=TWILIO_FROM_NUMBER, To=number, Body=message});
    local req = http.post(twilio_url, {Authorization=auth}, body);
    local res = req.sendsync();
    if(res.statuscode != 201) {
        server.log("error sending message: "+res.body);
    }
}

device.on("Alert", function(v) {
    send_sms(TWILIO_TO_NUMBER, v)
});
//*****************************END TWILIO***************************************
smsArmed <- "off";
sirenArmed <- "off";
sirenState <- "off";
sensorState <- "unset";
// Respond to incoming HTTP commands
http.onrequest(function(request, response) { 
  try {
    local data = http.jsondecode(request.body);
    server.log(request.body);
    if (data.action == "get") {
        local json = "{ \"status\" : { \"smsArmed\" : \"" + smsArmed + "\" , \"sirenArmed\" : \"" + sirenArmed + "\" , \"sirenState\" : \"" + sirenState + "\" , \"sensorState\" : \"" + sensorState + "\" }}";
        response.send(200, json);      
    } 
    else if (data.action == "set") {
        server.log(data);
        smsArmed = (data.smsArmed);
        sirenArmed = (data.sirenArmed);
        sirenState = (data.sirenState);
        device.send("setStatus", data);
        device.on("statusResponse", function(data) {
        response.send(200, data);
        });       
    }
   else {
       server.log(request.body);
        response.send(500, "Missing Data in Body");
   }     
  }
  catch (ex) {
    response.send(500, "Internal Server Error: " + ex);
  }
});
device.on("sensorState", function (v) {
    sensorState = v;
});
