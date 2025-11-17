
ImportantLevelsResult GetImportantLevels(int _num_candles = 100 , ENUM_TIMEFRAMES _timeframe = PERIOD_CURRENT)
{
   string _symbol = _Symbol;
   ImportantLevelsResult result;
   ArrayResize(result.levels, 0); // Initialize with an empty array
   result.count = 0;

   if (_num_candles < 50) // Minimum candles for some calculations like EMA
   {
      _num_candles = 50;
      Print("GetImportantLevels: _num_candles adjusted to minimum 50 for calculations.");
   }

   MqlRates rates[];
   int copied = CopyRates(_symbol, _timeframe, 0, _num_candles, rates);

   if (copied <= 0)
   {
      return result; // Return struct with empty array
   }

   // Temporary dynamic array to build the list of levels
   double temp_levels[];
   int temp_level_count = 0;



   // --- 1. Traditional Support and Resistance (Swing Highs/Lows) ---
   int lookback_swing = 2; // Look 2 candles before and after

   for (int i = lookback_swing; i < copied - lookback_swing; i++)
   {
      // Potential Swing High
      bool is_swing_high = true;
      for (int j = 1; j <= lookback_swing; j++)
      {
         if (rates[i].high <= rates[i - j].high || rates[i].high <= rates[i + j].high)
         {
            is_swing_high = false;
            break;
         }
      }
      if (is_swing_high)
      {
         AddLevelInternal(rates[i].high, temp_levels, temp_level_count);
      }

      // Potential Swing Low
      bool is_swing_low = true;
      for (int j = 1; j <= lookback_swing; j++)
      {
         if (rates[i].low >= rates[i - j].low || rates[i].low >= rates[i + j].low)
         {
            is_swing_low = false;
            break;
         }
      }
      if (is_swing_low)
      {
         AddLevelInternal(rates[i].low, temp_levels, temp_level_count);
      }
   }

   // --- 2. Pivot Points (Classic, using the last full day's data if timeframe is intraday) ---
   MqlRates daily_rates[];
   if (CopyRates(_symbol, PERIOD_D1, 1, 1, daily_rates) > 0) // Get previous day's data
   {
      double prev_day_high = daily_rates[0].high;
      double prev_day_low = daily_rates[0].low;
      double prev_day_close = daily_rates[0].close;

      double P = (prev_day_high + prev_day_low + prev_day_close) / 3.0;
      double R1 = (2 * P) - prev_day_low;
      double S1 = (2 * P) - prev_day_high;
      double R2 = P + (R1 - S1);
      double S2 = P - (R1 - S1);
      double R3 = prev_day_high + (2 * (P - prev_day_low));
      double S3 = prev_day_low - (2 * (prev_day_high - P));

      AddLevelInternal(P, temp_levels, temp_level_count);
      AddLevelInternal(R1, temp_levels, temp_level_count);
      AddLevelInternal(S1, temp_levels, temp_level_count);
      AddLevelInternal(R2, temp_levels, temp_level_count);
      AddLevelInternal(S2, temp_levels, temp_level_count);
      AddLevelInternal(R3, temp_levels, temp_level_count);
      AddLevelInternal(S3, temp_levels, temp_level_count);
   }

   // --- 3. Moving Averages (as Dynamic S/R) ---
   int ema50_handle = iMA(_symbol, _timeframe, 50, 0, MODE_EMA, PRICE_CLOSE);
   int ema200_handle = iMA(_symbol, _timeframe, 200, 0, MODE_EMA, PRICE_CLOSE);

   double ema_val[1];

   if (ema50_handle != INVALID_HANDLE)
   {
      if (CopyBuffer(ema50_handle, 0, 0, 1, ema_val) > 0)
      {
         AddLevelInternal(ema_val[0], temp_levels, temp_level_count);
      }
      IndicatorRelease(ema50_handle);
   }

   if (ema200_handle != INVALID_HANDLE)
   {
      if (CopyBuffer(ema200_handle, 0, 0, 1, ema_val) > 0)
      {
         AddLevelInternal(ema_val[0], temp_levels, temp_level_count);
      }
      IndicatorRelease(ema200_handle);
   }

   // --- 4. Liquidity Sweeps / Previous High/Low (Proxies) ---
   double period_high = rates[0].high;
   double period_low = rates[0].low;

   for (int i = 1; i < copied; i++)
   {
      if (rates[i].high > period_high) period_high = rates[i].high;
      if (rates[i].low < period_low) period_low = rates[i].low;
   }
   AddLevelInternal(period_high, temp_levels, temp_level_count);
   AddLevelInternal(period_low, temp_levels, temp_level_count);

   if (copied > 1)
   {
      AddLevelInternal(rates[1].high, temp_levels, temp_level_count);
      AddLevelInternal(rates[1].low, temp_levels, temp_level_count);
   }
   
   AddLevelInternal(rates[0].high, temp_levels, temp_level_count);
   AddLevelInternal(rates[0].low, temp_levels, temp_level_count);


   // --- 5. Reaction Levels / Psychological Numbers ---
   double current_price = rates[0].close;
   double range_start = current_price - 5.0;
   double range_end = current_price + 5.0;

   for (double p = MathFloor(range_start); p <= MathCeil(range_end); p += 0.01)
   {
       if (fmod(p, 1.0) < _Point * 0.5)
       {
           AddLevelInternal(MathRound(p / _Point) * _Point, temp_levels, temp_level_count);
       }
       else if (MathAbs(fmod(p, 1.0) - 0.5) < _Point * 0.5)
       {
           AddLevelInternal(MathRound(p / _Point / 0.5) * _Point * 0.5, temp_levels, temp_level_count);
       }
   }
   
   // --- 6. Fibonacci Retracement/Extension Levels ---
   double fib_high = rates[0].high;
   double fib_low = rates[0].low;
   int fib_lookback = MathMin(copied, 50);

   for (int i = 0; i < fib_lookback; i++)
   {
       if (rates[i].high > fib_high) fib_high = rates[i].high;
       if (rates[i].low < fib_low) fib_low = rates[i].low;
   }

   double fib_range = fib_high - fib_low;

   if (fib_range > _Point)
   {
      double fib_levels[] = {0.236, 0.382, 0.5, 0.618, 0.786};
      double fib_extensions[] = {1.272, 1.618, 2.0};

      for (int i = 0; i < ArraySize(fib_levels); i++)
      {
         AddLevelInternal(fib_high - (fib_range * fib_levels[i]), temp_levels, temp_level_count);
      }

      for (int i = 0; i < ArraySize(fib_extensions); i++)
      {
          AddLevelInternal(fib_high + (fib_range * fib_extensions[i]), temp_levels, temp_level_count);
      }
      for (int i = 0; i < ArraySize(fib_extensions); i++)
      {
          AddLevelInternal(fib_low - (fib_range * fib_extensions[i]), temp_levels, temp_level_count);
      }
   }
   
   // --- Sort the temporary array ---
   ArraySort(temp_levels);

   // --- Copy sorted levels to the struct's array and set count ---
   ArrayResize(result.levels, temp_level_count);
   ArrayCopy(result.levels, temp_levels, 0, 0, temp_level_count);
   result.count = temp_level_count;

   return result;
}


   // Helper function to add a level if it's not already close to an existing one
   // This helper is internal to the function's scope
   void AddLevelInternal(double level ,double &temp_levels[], int &temp_level_count)
   {
      bool found = false;
      for (int i = 0; i < temp_level_count; i++)
      {
         // Adjust tolerance based on symbol's tick size or desired granularity
         if (MathAbs(temp_levels[i] - level) < _Point * 5) // Within 5 points (0.05 for XAUUSD)
         {
            found = true;
            break;
         }
      }
      if (!found)
      {
         ArrayResize(temp_levels, temp_level_count + 1);
         temp_levels[temp_level_count] = NormalizeDouble(level, _Digits); // Normalize to symbol's digits
         temp_level_count++;
      }
   }