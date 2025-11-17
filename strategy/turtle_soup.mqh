#include "../indicators/bollinger_band.mqh"
#include "../indicators/hilega_milega.mqh"
#include "../indicators/moving_average.mqh"
#include "../timeframe_settings/timeframe_settings.mqh"

sinput int        TurtlePeriod           = 20;       // Periods for Turtle High/Low (e.g., 20 days)
sinput int        PriorBreakoutLookback  = 4;        // Lookback for the 'prior' high/low 

sinput bool       UseTrendFilter         = false;     // Enable/Disable Higher Timeframe Trend Filter
sinput ENUM_TIMEFRAMES TrendTimeframe    = PERIOD_M12; // Timeframe for trend analysis (e.g., Weekly)
sinput int        TrendMAPeriod          = 20;       // MA period for trend filter (e.g., 20 SMA)
sinput double     MinRejectionWickRatio  = 0.3;      // Minimum ratio of rejection wick to total candle range (0.0-1.0)
sinput double     MinBodyToRangeRatio    = 0.2;      // Minimum body size relative to range for reversal candle (0.0-1.0)
sinput double     MaxBodyToRangeRatio    = 0.8;      // Maximum body size relative to range (avoids continuation candles)
sinput double     MinBreakoutPips        = 5.0;      // Minimum pips the new high/low must penetrate beyond the prior high/low

TRADE_DIRECTION turtle_soup() {

    // Ensure sufficient bars are available for calculation
    // We need at least TurtlePeriod + PriorBreakoutLookback + 1 bars
    // Add a small buffer for safety in CopyBuffer functions.
    const int num_bars_needed = MathMax(TurtlePeriod, PriorBreakoutLookback) + 5; // Simplified to ensure enough bars for both periods
    
    // Check if the symbol and timeframe have enough bars
    if (Bars(_Symbol, PERIOD_CURRENT) < num_bars_needed)
    {
        // Print("turtle_soup: Not enough historical data on ", EnumToString(PERIOD_CURRENT), " timeframe (", Bars(_Symbol, PERIOD_CURRENT), " bars available, ", num_bars_needed, " needed).");
        return NA;
    }

    double open_prices[], high_prices[], low_prices[], close_prices[];
    
    // Copy price data for the SignalTimeframe
    // Copy from shift 1 to get the data for the last CLOSED bar (index 0 in the array)
    if (CopyOpen(_Symbol, PERIOD_CURRENT, 1, num_bars_needed, open_prices) != num_bars_needed ||
        CopyHigh(_Symbol, PERIOD_CURRENT, 1, num_bars_needed, high_prices) != num_bars_needed ||
        CopyLow(_Symbol, PERIOD_CURRENT, 1, num_bars_needed, low_prices) != num_bars_needed ||
        CopyClose(_Symbol, PERIOD_CURRENT, 1, num_bars_needed, close_prices) != num_bars_needed)
    {
        // Print("turtle_soup: Error copying price data for PERIOD_CURRENT.");
        return NA;
    }
    
    // Set arrays as series (most recent bar at index 0 of array corresponds to shift 1 from current live bar)
    ArraySetAsSeries(open_prices, true);
    ArraySetAsSeries(high_prices, true);
    ArraySetAsSeries(low_prices, true);
    ArraySetAsSeries(close_prices, true);
    
    // Ensure we have access to the 'PriorBreakoutLookback' bar
    if (PriorBreakoutLookback >= ArraySize(low_prices) || PriorBreakoutLookback >= ArraySize(high_prices))
    {
        // Print("turtle_soup: PriorBreakoutLookback index out of bounds after copying.");
        return NA;
    }
    
    // Get current (last closed) bar's price data for calculations
    double currentOpen = open_prices[0];
    double currentHigh = high_prices[0];
    double currentLow = low_prices[0];
    double currentClose = close_prices[0];

    // --- Turtle Soup Long Setup (Buy Signal) ---
    // Conditions:
    // 1. Current bar (array index 0) makes a new 'TurtlePeriod' Low.
    // 2. The low 'PriorBreakoutLookback' bars ago (array index PriorBreakoutLookback) was ALSO a 'TurtlePeriod' Low.
    // 3. Current bar (array index 0) closes ABOVE that 'PriorBreakoutLookback' low.
    
    bool isCurrentBarNewTurtleLow = IsNewPeriodLow(low_prices, 0, TurtlePeriod);
    bool wasPriorBarNewTurtleLow = IsNewPeriodLow(low_prices, PriorBreakoutLookback, TurtlePeriod);
    
    double priorBreakoutLow = low_prices[PriorBreakoutLookback];

    if (isCurrentBarNewTurtleLow && wasPriorBarNewTurtleLow && currentClose > priorBreakoutLow)
    {
        // --- Apply BUY Filters ---
        bool filters_passed = true;

        // 1. Higher Timeframe Trend Filter (Uptrend)
        if (UseTrendFilter)
        {
            if (!IsUptrend(TrendTimeframe, TrendMAPeriod))
            {
                // Print("DEBUG: BUY - Trend filter failed.");
                filters_passed = false;
            }
        }

        // 2. Wick Confirmation & Body Size for Long Reversal Candle (Current Bar)
        if (filters_passed)
        {
            double candleRange = currentHigh - currentLow;
            if (candleRange <= 0) { filters_passed = false; } // Avoid division by zero for Doji or flat bars
            else
            {
                double lowerWick = MathMin(currentOpen, currentClose) - currentLow; // Distance from lowest body to lowest price
                double bodySize = MathAbs(currentClose - currentOpen);
                
                if (lowerWick / candleRange < MinRejectionWickRatio)
                {
                    // Print("DEBUG: BUY - Lower wick too small (", NormalizeDouble(lowerWick / candleRange, 2), ").");
                    filters_passed = false; // Insufficient lower wick for strong rejection
                }
                else if (bodySize / candleRange < MinBodyToRangeRatio || bodySize / candleRange > MaxBodyToRangeRatio)
                {
                    // Print("DEBUG: BUY - Body size ratio out of range (", NormalizeDouble(bodySize / candleRange, 2), ").");
                    filters_passed = false; // Body too small (doji-like) or too large (continuation-like)
                }
            }
        }

        // 3. Minimum Breakout Distance (how far did it "false" break)
        if (filters_passed)
        {
            double breakoutDistance = MathAbs(priorBreakoutLow - currentLow); // Distance from prior low to new low
            if (breakoutDistance / _Point < MinBreakoutPips)
            {
                // Print("DEBUG: BUY - Breakout distance too small (", NormalizeDouble(breakoutDistance/_Point, 1), ").");
                filters_passed = false;
            }
        }
        
        if (filters_passed)
        {
            // Print("DEBUG: Turtle Soup BUY signal with filters passed.");
            return BUY;
        }
    }

    // --- Turtle Soup Short Setup (Sell Signal) ---
    // Conditions:
    // 1. Current bar (array index 0) makes a new 'TurtlePeriod' High.
    // 2. The high 'PriorBreakoutLookback' bars ago (array index PriorBreakoutLookback) was ALSO a 'TurtlePeriod' High.
    // 3. Current bar (array index 0) closes BELOW that 'PriorBreakoutLookback' high.

    bool isCurrentBarNewTurtleHigh = IsNewPeriodHigh(high_prices, 0, TurtlePeriod);
    bool wasPriorBarNewTurtleHigh = IsNewPeriodHigh(high_prices, PriorBreakoutLookback, TurtlePeriod);
    
    double priorBreakoutHigh = high_prices[PriorBreakoutLookback];

    if (isCurrentBarNewTurtleHigh && wasPriorBarNewTurtleHigh && currentClose < priorBreakoutHigh)
    {
        // --- Apply SELL Filters ---
        bool filters_passed = true;

        // 1. Higher Timeframe Trend Filter (Downtrend)
        if (UseTrendFilter)
        {
            if (!IsDowntrend(TrendTimeframe, TrendMAPeriod))
            {
                // Print("DEBUG: SELL - Trend filter failed.");
                filters_passed = false;
            }
        }

        // 2. Wick Confirmation & Body Size for Short Reversal Candle (Current Bar)
        if (filters_passed)
        {
            double candleRange = currentHigh - currentLow;
            if (candleRange <= 0) { filters_passed = false; }
            else
            {
                double upperWick = currentHigh - MathMax(currentOpen, currentClose); // Distance from highest body to highest price
                double bodySize = MathAbs(currentClose - currentOpen);

                if (upperWick / candleRange < MinRejectionWickRatio)
                {
                    // Print("DEBUG: SELL - Upper wick too small (", NormalizeDouble(upperWick / candleRange, 2), ").");
                    filters_passed = false; // Insufficient upper wick for strong rejection
                }
                else if (bodySize / candleRange < MinBodyToRangeRatio || bodySize / candleRange > MaxBodyToRangeRatio)
                {
                    // Print("DEBUG: SELL - Body size ratio out of range (", NormalizeDouble(bodySize / candleRange, 2), ").");
                    filters_passed = false; // Body too small (doji-like) or too large (continuation-like)
                }
            }
        }

        // 3. Minimum Breakout Distance
        if (filters_passed)
        {
            double breakoutDistance = MathAbs(currentHigh - priorBreakoutHigh); // Distance from new high to prior high
            if (breakoutDistance / _Point < MinBreakoutPips)
            {
                // Print("DEBUG: SELL - Breakout distance too small (", NormalizeDouble(breakoutDistance/_Point, 1), ").");
                filters_passed = false;
            }
        }

        if (filters_passed)
        {
            // Print("DEBUG: Turtle Soup SELL signal with filters passed.");
            return SELL;
        }
    }

    // If no signal found
    return NA;
}

//+------------------------------------------------------------------+
//| Helper Function: IsNewPeriodHigh                                 |
//| Checks if the bar at 'shift' index is the highest of 'period' bars.|
//| 'high_prices' array should be set as series (index 0 is current).|
//+------------------------------------------------------------------+
bool IsNewPeriodHigh(const double& high_prices[], int shift, int period)
{
    // Ensure we have enough data to look back 'shift + period' bars
    if (shift < 0 || period <= 0 || (shift + period) > ArraySize(high_prices))
    {
        // Print("DEBUG: IsNewPeriodHigh - Insufficient data or invalid parameters.");
        return false;
    }

    double current_high = high_prices[shift];
    for (int i = 1; i < period; i++)
    {
        // Check if there's any bar within the 'period' (excluding the 'shift' bar itself)
        // that has a high greater than or equal to the 'shift' bar's high.
        if (high_prices[shift + i] >= current_high)
            return false; // Not a new high
    }
    return true; // It is a new high
}

//+------------------------------------------------------------------+
//| Helper Function: IsNewPeriodLow                                  |
//| Checks if the bar at 'shift' index is the lowest of 'period' bars.|
//| 'low_prices' array should be set as series (index 0 is current).|
//+------------------------------------------------------------------+
bool IsNewPeriodLow(const double& low_prices[], int shift, int period)
{
    // Ensure we have enough data to look back 'shift + period' bars
    if (shift < 0 || period <= 0 || (shift + period) > ArraySize(low_prices))
    {
        // Print("DEBUG: IsNewPeriodLow - Insufficient data or invalid parameters.");
        return false;
    }

    double current_low = low_prices[shift];
    for (int i = 1; i < period; i++)
    {
        // Check if there's any bar within the 'period' (excluding the 'shift' bar itself)
        // that has a low less than or equal to the 'shift' bar's low.
        if (low_prices[shift + i] <= current_low)
            return false; // Not a new low
    }
    return true; // It is a new low
}

//+------------------------------------------------------------------+
//| Helper Function: IsUptrend (using MA)                            |
//| Checks if the market is in an uptrend on a given timeframe.      |
//| Uses closing prices with Simple Moving Average (SMA).            |
//+------------------------------------------------------------------+
bool IsUptrend(ENUM_TIMEFRAMES tf, int maPeriod)
{
    // Ensure enough bars for MA calculation. Needs at least maPeriod + 1 bars.
    if (Bars(_Symbol, tf) < maPeriod + 1)
    {
        // Print("DEBUG: IsUptrend - Not enough bars for MA calculation on ", EnumToString(tf));
        return false;
    }

    // Get MA values for the current and previous bar on the specified timeframe
    int maHandle = iMA(_Symbol, tf, maPeriod, 1 , MODE_SMA, PRICE_CLOSE);
    double maBuffer[];  // To hold current and previous MA
    ArrayResize(maBuffer, 2);
    CopyBuffer(maHandle, 0, 0, 2, maBuffer);
    ArraySetAsSeries(maBuffer, true);
    double ma_current = maBuffer[0]; // MA at bar 0 (latest/forming candle)
    double ma_prev = maBuffer[1];    // MA at bar 1 (last closed candle)
    double close_current = iClose(_Symbol, tf, 1);


    // Trend definition: Current close is above MA AND MA is sloping upwards
    if (close_current > ma_current && ma_current > ma_prev)
    {
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Helper Function: IsDowntrend (using MA)                          |
//| Checks if the market is in a downtrend on a given timeframe.     |
//| Uses closing prices with Simple Moving Average (SMA).            |
//+------------------------------------------------------------------+
bool IsDowntrend(ENUM_TIMEFRAMES tf, int maPeriod)
{
    // Ensure enough bars for MA calculation. Needs at least maPeriod + 1 bars.
    if (Bars(_Symbol, tf) < maPeriod + 1)
    {
        // Print("DEBUG: IsDowntrend - Not enough bars for MA calculation on ", EnumToString(tf));
        return false;
    }

    // Get MA values for the current and previous bar on the specified timeframe
    int maHandle = iMA(_Symbol, tf, maPeriod, 1 , MODE_SMA, PRICE_CLOSE);
    double maBuffer[];  // To hold current and previous MA
    ArrayResize(maBuffer, 2);
    CopyBuffer(maHandle, 0, 0, 2, maBuffer);
    ArraySetAsSeries(maBuffer, true);
    double ma_current = maBuffer[0]; // MA at bar 0 (latest/forming candle)
    double ma_prev = maBuffer[1];    // MA at bar 1 (last closed candle)
    double close_current = iClose(_Symbol, tf, 1);

    // Trend definition: Current close is below MA AND MA is sloping downwards
    if (close_current < ma_current && ma_current < ma_prev)
    {
        return true;
    }
    return false;
}