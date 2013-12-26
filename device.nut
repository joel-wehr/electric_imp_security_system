//Home Security System
// Set local variables

smsArmed <- "off";
sirenArmed <- "off";
sirenState <- "off";
pinAState <- 0;
pinBState <- 0;
pinCState <- 0;
pinDState <- 0;
pinEState <- 0;
sensorState <- "unset";
// Set up the functions
function soundSiren() {
    hardware.pin1.write(1);
    server.log("Sounding Siren!")
}
function silenceSiren() {
    hardware.pin1.write(0);
    server.log("Siren silenced.")
}
function sendAlert(sensor) {
    server.log("Sending alerts")
    agent.send("Alert", sensor);
}
function pinAchanged() {
    if (hardware.pinA.read() == 1 && pinAState == 0) {
        server.log("The Front Door has been opened.");
        pinAState = 1;
        checkSensorState();
        if (smsArmed == "on") {
            sendAlert("Front zone door open!");
            if (sirenArmed == "on") {
                soundSiren();
            }
        }
    }
    else if (hardware.pinA.read() == 0 && pinAState == 1) {
        server.log("The Front Door has been closed.")
        pinAState = 0;
        checkSensorState();
    }        
}
function pinBchanged() {
    if (hardware.pinB.read() == 1 && pinBState == 0) {
        server.log("The Bedroom Door has been opened.");
        pinBState = 1;
        checkSensorState();
        if (smsArmed == "on") {
            sendAlert("Bedroom door opened!");
            if (sirenArmed == "on") {
                soundSiren();
            }
        }
    }
    else if (hardware.pinB.read() == 0 && pinBState == 1) {
        server.log("The Bedroom Door has been closed.")
        pinBState = 0;
        checkSensorState();
    }        
}
function pinCchanged() {
    if (hardware.pinC.read() == 1 && pinCState == 0) {
        server.log("The Fireplace Room Door has been opened.");
        pinCState = 1;
        checkSensorState();
        if (smsArmed == "on") {
            sendAlert("Fireplace Room door opened!");
            if (sirenArmed == "on") {
                soundSiren();
            }
        }
    }
    else if (hardware.pinC.read() == 0 && pinCState == 1) {
        server.log("The Fireplace Room Door has been closed.")
        pinCState = 0;
        checkSensorState();
    }        
}
function pinDchanged() {
    if (hardware.pinD.read() == 1 && pinDState == 0) {
        server.log("A Basement Window has been opened.");
        pinDState = 1;
        checkSensorState();
        if (smsArmed == "on") {
            sendAlert("A Basement Window has been opened");
            if (sirenArmed == "on") {
                soundSiren();
            }
        }
    }
    else if (hardware.pinD.read() == 0 && pinDState == 1) {
        server.log("The Basement windows are closed.")
        pinDState = 0;
        checkSensorState();
    }        
}
function pinEchanged() {
    if (hardware.pinE.read() == 1 && pinEState == 0) {
        server.log("The Sunroom Door has been opened.");
        pinEState = 1;
        checkSensorState();
        if (smsArmed == "on") {
            sendAlert("A Sunroom Door has been opened!");
            if (sirenArmed == "on") {
                soundSiren();
            }
        }
    }
    else if (hardware.pinE.read() == 0 && pinEState == 1) {
        server.log("The Sunroom Door has been closed.")
        pinEState = 0;
        checkSensorState();
    }        
}
function checkSensorState() {
    local status = "Open zones:";
    pinAState = hardware.pinA.read();
    pinBState = hardware.pinB.read();
    pinCState = hardware.pinC.read();
    pinDState = hardware.pinD.read();
    pinEState = hardware.pinE.read();
    if (pinAState == 1) {
        status += " Front";
    }
    else if (pinBState == 1) {
        status += " Bedroom";
    }
    else if (pinCState == 1) {
        status += " Fireplace Room";
    }
    else if (pinDState == 1) {
        status += " Basement window";
    }
    else if (pinEState == 1) {
        status += " Sunroom Door";
    }   
    if (pinAState == 0 && pinBState == 0 && pinCState == 0
    && pinDState == 0 && pinEState == 0) {
        status += " none";
    }
    sensorState = status
    agent.send("sensorState", sensorState);
    return status;
}

agent.on ("setStatus", function(data) {
    smsArmed = (data.smsArmed);
    sirenArmed = (data.sirenArmed);
    sirenState = (data.sirenState);
    if (sirenState == "on") {
        hardware.pin1.write(1);
    }
    else if (sirenState == "off") {
        hardware.pin1.write(0);
    }
    local json = "{ \"status\" : { \"auth\" : \"yes\" , \"smsArmed\" : \"" + smsArmed + "\" , \"sirenArmed\" : \"" + sirenArmed + "\" , \"sirenState\" : \"" + sirenState + "\", \"sensorState\" : \"" + sensorState + "\" }}";
    server.log(json);
    agent.send("statusResponse", json);
});
function stateResponse(data); {
    
}
// Configure pins
hardware.pin1.configure(DIGITAL_OUT);
hardware.pinA.configure(DIGITAL_IN_PULLUP, pinAchanged);
hardware.pinB.configure(DIGITAL_IN_PULLUP, pinBchanged);
hardware.pinC.configure(DIGITAL_IN_PULLUP, pinCchanged);
hardware.pinD.configure(DIGITAL_IN_PULLUP, pinDchanged);
hardware.pinE.configure(DIGITAL_IN_PULLUP, pinEchanged);

server.log("Home Security System Online");
server.log(checkSensorState());
