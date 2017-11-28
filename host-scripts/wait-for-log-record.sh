#!/bin/bash

# Arguments
timeoutInSeconds=$1
checkIntervalInSeconds=$2
containerIdentifier=$3
successPattern=$4
failurePattern=$5

# Definitions

function updateTimestamp {
    timestamp=$(date +%s)
}

function updateTimeDeltas {
    updateTimestamp
    secondsSinceStart=$((timestamp-startTimestamp))
}

function readContainerLogs {
    logContents=$(docker logs $containerIdentifier --since $lastLogRecordTimestamp --timestamps)
    successMatch=$(echo "$logContents" | grep "$successPattern")

    if [ ! -z "$failurePattern" ]; then
        failureMatch=$(echo "$logContents" | grep "$failurePattern")
    fi

    lastLine=$(echo "$logContents" | grep ".* " | tail -n 1)
    lastLogRecordTimestamp=$(echo "$lastLine" | cut -f1 -d\ )
}

# Initialization
updateTimestamp
startTimestamp=$timestamp
updateTimeDeltas

lastLogRecordTimestamp=0

# Main

while [[ $secondsSinceStart -lt $timeoutInSeconds ]]; do

    secondsLeft=$((timeoutInSeconds-secondsSinceStart))
    echo "Checking logs, $secondsLeft seconds left until timeout"

    readContainerLogs

    if [[ ! -z $successMatch ]]; then
        echo "Found a success match: $successMatch"
        exit 0
    fi

    if [[ ! -z $failureMatch ]]; then
        echo "Found a failure match: $failureMatch" >&2
        exit 1
    fi

    sleep $checkIntervalInSeconds

    updateTimeDeltas
done

echo "Failed due to timeout" >&2
exit 2