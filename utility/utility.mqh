int TimeframeToSeconds(ENUM_TIMEFRAMES tf)
{
    switch (tf)
    {
        case PERIOD_M1:   return 60;
        case PERIOD_M5:   return 300;
        case PERIOD_M15:  return 900;
        case PERIOD_M30:  return 1800;
        case PERIOD_H1:   return 3600;
        case PERIOD_H4:   return 14400;
        case PERIOD_D1:   return 86400;
        case PERIOD_W1:   return 604800;
        case PERIOD_MN1:  return 2592000;
        default:          return 60;
    }
}


//+------------------------------------------------------------------+
//| Draw Candle Marker                                               |
//+------------------------------------------------------------------+
void DrawPerfectCandleMarker(string candleType, int shift)
{
    string name = "PerfectCandle_" + TimeToString(iTime(_Symbol, PERIOD_CURRENT, shift), TIME_DATE | TIME_MINUTES);

    color markerColor = (candleType == "Perfect Buy Candle") ? clrAqua : clrPink;
    int arrowSymbol = (candleType == "Perfect Buy Candle") ? 233 : 234;

    double candleHigh = iHigh(_Symbol, PERIOD_CURRENT, shift);
    double candleLow  = iLow(_Symbol, PERIOD_CURRENT, shift);
    double candleMid  = (candleHigh + candleLow) / 2.0;

    // Create arrow
    if (ObjectFind(0, name) < 0) // Avoid duplicate
    {
        ObjectCreate(0, name, OBJ_ARROW, 0, iTime(_Symbol, PERIOD_CURRENT, shift), candleMid);
        ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrowSymbol);
        ObjectSetInteger(0, name, OBJPROP_COLOR, markerColor);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
    }
}

template<typename T>
T SafeGet(const T &arr[], int index, T fallback)
{
   if (index >= 0 && index < ArraySize(arr))
      return arr[index];
   return fallback;
}