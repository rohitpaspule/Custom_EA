/*
Session        Anchor hour   Anchor Minute   Timezone   Notes
Tokyo (Asia)	  00	             00	         UTC	 Low volatility; early session
London	        07	             00	         UTC	 High liquidity starts
New York	        12	             30	         UTC	 Overlap with London = best volume
Full Day	        00	             00	         UTC	 Anchored at start of the trading day (server time)
*/
input int        AnchorHour  = 00;
input int        AnchorMin   = 00;

VWAP_SERIES GetAnchoredVWAP( ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT, int count = 10 ,int shift = 1)
{
    datetime anchorTime = GetTodayAnchor();
        
    VWAP_SERIES result;
    ArrayResize(result.vwapSeries, count);
    ArraySetAsSeries(result.vwapSeries, true);

    int anchorBar = iBarShift(_Symbol, timeframe, anchorTime, false);
    if (anchorBar == -1) return result;
    
    int startBar = anchorBar - shift;  
    if (startBar < count - 1) return result;
                    
    for (int i = 0; i < count; i++)
       {
           int barIndex = startBar - i;
           if (barIndex < 0) break;
   
           // Reset cumulative values for each bar
           double cumulativeTPV = 0.0;
           double cumulativeVolume = 0.0;
   
           for (int j = anchorBar; j >= barIndex; j--)
           {
               double high = iHigh(_Symbol, timeframe, j);
               double low  = iLow(_Symbol, timeframe, j);
               double close= iClose(_Symbol, timeframe, j);
               long   vol  = (long)iVolume(_Symbol, timeframe, j);
   
               double tp = (high + low + close) / 3.0;
               
               cumulativeTPV     += tp * (double)vol;   // explicit cast
               cumulativeVolume  += (double)vol;
           }
   
           result.vwapSeries[i] = (cumulativeVolume > 0.0) ? (cumulativeTPV / cumulativeVolume) : 0.0;
       }
       return result;
}

datetime GetTodayAnchor()
{
    datetime now = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(now, dt);
    dt.hour = AnchorHour;
    dt.min  = AnchorMin;
    dt.sec  = 0;
    return StructToTime(dt);
}