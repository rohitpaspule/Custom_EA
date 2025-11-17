//+------------------------------------------------------------------+
//| SmartEntrySignal - Returns "BUY", "SELL", or "NA" based on SMC  |
//+------------------------------------------------------------------+
TRADE_DIRECTION SmartEntrySignal(ENUM_TIMEFRAMES entryTF = PERIOD_CURRENT, ENUM_TIMEFRAMES trendTF = PERIOD_H1, int lookback = 20, double minBodyRatio = 0.6)
{
   int shift = 2;
   int shiftOfConfirmation = 1;    
   if(Bars(_Symbol, entryTF) < lookback + 5) return NA;

   // --- HTF Trend Filter---
   int fastMAHandle = iMA(_Symbol, trendTF, 6, shift, MODE_EMA, PRICE_CLOSE);
   int slowMAHandle = iMA(_Symbol, trendTF, 24 ,shift, MODE_EMA, PRICE_CLOSE);
   
   if(fastMAHandle == INVALID_HANDLE || slowMAHandle == INVALID_HANDLE)
      return NA;
   
   double fastMA[], slowMA[];
   if(CopyBuffer(fastMAHandle, 0, 0, 1, fastMA) < 1 || CopyBuffer(slowMAHandle, 0, 0, 1, slowMA) < 1)
      return NA;
   ArraySetAsSeries(fastMA,true);
   ArraySetAsSeries(slowMA,true);
   bool bullishTrend = fastMA[0] > slowMA[0];
   bool bearishTrend = fastMA[0] < slowMA[0];

   // --- Current Candle Data ---
   double highCurr = iHigh(_Symbol, entryTF, shift);
   double lowCurr  = iLow(_Symbol, entryTF, shift);
   double openCurr = iOpen(_Symbol, entryTF, shift);
   double closeCurr = iClose(_Symbol, entryTF, shift);
   double bodySize = MathAbs(closeCurr - openCurr);
   double candleRange = highCurr - lowCurr;
   double closelatest = iClose(_Symbol, entryTF, shiftOfConfirmation);

   if(candleRange == 0 || bodySize / candleRange < minBodyRatio) return NA; // weak candle

   bool isBullish = closeCurr > openCurr;
   bool isBearish = closeCurr < openCurr;

   // --- Previous Candle High/Low ---
   double highPrev = iHigh(_Symbol, entryTF, shift + 1);
   double lowPrev  = iLow(_Symbol, entryTF, shift + 1);

   // --- Step 1: Liquidity Grab Detection ---
   bool liquidityGrabBuy  = (lowCurr < lowPrev)  && isBullish && (closeCurr > lowPrev);
   bool liquidityGrabSell = (highCurr > highPrev) && isBearish && (closeCurr < highPrev);

   // --- Step 2: Break of Structure Detection ---
   bool bosBuy  = false;
   bool bosSell = false;

   for(int i = 2; i <= lookback + 2; i++)
   {
      double swingHigh = iHigh(_Symbol, entryTF, shift + i);
      double swingLow  = iLow(_Symbol, entryTF, shift + i);

      if(liquidityGrabBuy && closeCurr > swingHigh) bosBuy = true;
      if(liquidityGrabSell && closeCurr < swingLow) bosSell = true;
   }
  
   // --- Step 3: Confluence & Decision ---
   if(liquidityGrabBuy && bosBuy && bullishTrend && (closelatest > closeCurr)){
      return BUY;
      }

   if(liquidityGrabSell && bosSell && bearishTrend && (closelatest < closeCurr)){
      return SELL;
      }

   return NA;
}
