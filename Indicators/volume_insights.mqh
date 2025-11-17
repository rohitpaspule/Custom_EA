VolumeInsights AnalyzeVolumeSignals(int candles = 20, ENUM_TIMEFRAMES tf = PERIOD_CURRENT) {
   int shift = 1;
   VolumeInsights result;

   ArrayResize(result.isClimax, candles);
   ArrayResize(result.isVolumeSpike, candles);
   ArrayResize(result.isBullishDivergence, candles);
   ArrayResize(result.isBearishDivergence, candles);
   ArrayResize(result.isVWAPConfluence, candles);
   ArrayResize(result.isAccumulating, candles);
   ArrayResize(result.obv, candles);
   ArrayResize(result.vwap, candles);

   ArraySetAsSeries(result.isClimax, true);
   ArraySetAsSeries(result.isVolumeSpike, true);
   ArraySetAsSeries(result.isBullishDivergence, true);
   ArraySetAsSeries(result.isBearishDivergence, true);
   ArraySetAsSeries(result.isVWAPConfluence, true);
   ArraySetAsSeries(result.isAccumulating, true);
   ArraySetAsSeries(result.obv, true);
   ArraySetAsSeries(result.vwap, true);

   double prevOBV = 0;

   for (int i = shift; i < candles; i++) {
      double close     = iClose(_Symbol, tf, i);
      double prevClose = iClose(_Symbol, tf, i + 1);
      long   vol       = iVolume(_Symbol, tf, i);
      long   prevVol   = iVolume(_Symbol, tf, i + 1);

      // VWAP from past 20 candles
      double vwap = CalculateVWAP(i, 20, tf);
      result.vwap[i] = vwap;

      // OBV
      if (close > prevClose)
          prevOBV += (double)vol;
      else if (close < prevClose)
          prevOBV -= (double)vol;
      result.obv[i] = prevOBV;
      
      // Volume Climax (vol > 1.5x SMA 20)
      double volSMA = 0;
      int period = 20;
      for (int j = i; j < i + period && j < candles; j++) {
          volSMA += (double)iVolume(_Symbol, tf, j);
      }

      volSMA /= period;
      
      result.isClimax[i] = vol > 1.5 * volSMA;

      // Volume Spike
      result.isVolumeSpike[i] = vol > prevVol * 1.8;

      // Volume/Price Divergences
      result.isBullishDivergence[i] = (close < prevClose) && (vol > prevVol);
      result.isBearishDivergence[i] = (close > prevClose) && (vol < prevVol);

      // VWAP Confluence
      result.isVWAPConfluence[i] = MathAbs(close - vwap) < (SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10);

      // Accumulation (simple: OBV rising over 3 candles)
      if (i + 3 < candles) {
         result.isAccumulating[i] = result.obv[i] > result.obv[i + 1] && result.obv[i + 1] > result.obv[i + 2];
      }
   }

   return result;
}

double CalculateVWAP(int startShift, int count, ENUM_TIMEFRAMES tf) {
   double cumulativeTPV = 0, cumulativeVolume = 0;
   for (int i = startShift; i < startShift + count; i++) {
      double high = iHigh(_Symbol, tf, i);
      double low = iLow(_Symbol, tf, i);
      double close = iClose(_Symbol, tf, i);
      long vol = iVolume(_Symbol, tf, i);
      double tp = (high + low + close) / 3.0;
      cumulativeTPV += tp * (double)vol;
      cumulativeVolume += (double)vol;
   }
   return (cumulativeVolume > 0) ? cumulativeTPV / cumulativeVolume : 0;
}