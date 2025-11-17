void TrackClosedDeals() {
    if (!HistorySelect(0, TimeCurrent())) return;
    int totalDeals = HistoryDealsTotal();
    for (int i = totalDeals - 1; i >= 0; i--) {
        ulong dealTicket = HistoryDealGetTicket(i);
        if (IsDealAlreadyLogged(dealTicket)) continue;
        ENUM_DEAL_TYPE type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealTicket, DEAL_TYPE);
        if (type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;

        double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
        double entryPrice = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
        ulong closeTime = HistoryDealGetInteger(dealTicket, DEAL_TIME);

        string message = StringFormat("%s,%.2f,%.2f,%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f",
            (type == DEAL_TYPE_BUY ? "Buy" : "Sell"), entryPrice, profit,
            TimeToString(closeTime, TIME_DATE | TIME_MINUTES),
            gwma, gema, grsi, MathAbs(gwma - gema), MathAbs(gwma - grsi), MathAbs(grsi - gema));
        Print(message);
        LogToCSV(message);

        ArrayResize(loggedDeals, ArraySize(loggedDeals) + 1);
        loggedDeals[ArraySize(loggedDeals) - 1] = dealTicket;
    }
}

bool IsDealAlreadyLogged(ulong ticket) {
    for (int i = 0; i < ArraySize(loggedDeals); i++)
        if (loggedDeals[i] == ticket) return true;
    return false;
}