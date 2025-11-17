void LogToCSV(string data) {
    if (fileHandle != INVALID_HANDLE) {
        FileSeek(fileHandle, 0, SEEK_END);
        FileWrite(fileHandle, data);
    }
}

void LogHeadersInCSV() {
    datetime currentTime = TimeLocal();
    string id = IntegerToString(MathRand());
    string filename = "Custom_MTF_Analyzer_" + id + ".csv";
    fileHandle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON | FILE_ANSI);
    string message = "Type, Entry, Profit, Time, WMA(21), EMA(3), RSI, WMA-EMA, WMA-RSI, RSI-EMA";
    if (fileHandle != INVALID_HANDLE) {
        FileSeek(fileHandle, 0, SEEK_END);
        FileWrite(fileHandle, message);
    }
}