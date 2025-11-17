#include "../logging/logging_helpers.mqh"
#include "../utility/utility.mqh"

int InitializeEA() {
    LogHeadersInCSV();
    int seconds = TimeframeToSeconds(PERIOD_CURRENT);
    EventSetTimer(60);
    atrHandle = iATR(_Symbol, PERIOD_CURRENT, atrPeriod);
    if (atrHandle == INVALID_HANDLE)
        return INIT_FAILED;

    return INIT_SUCCEEDED;
}

void CleanupEA() {
    EventKillTimer();
    IndicatorRelease(atrHandle);
    FileClose(fileHandle);
}
