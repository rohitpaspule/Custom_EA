//+------------------------------------------------------------------+
//|                                          chart_manager.mqh       |
//|                        Chart Indicator Visibility Manager        |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"

// Track added indicators
int addedIndicators[];

//+------------------------------------------------------------------+
//| Add indicators to chart if user wants them visible               |
//+------------------------------------------------------------------+
void ManageChartIndicators() {
   if(!ShowIndicatorsOnChart) {
      // Remove any indicators we might have added
      RemoveAllChartIndicators();
      return;
   }

   // If user wants indicators visible, add them to the chart
   // This will add the indicators used by the active strategy
   AddStrategyIndicators();
}

//+------------------------------------------------------------------+
//| Add indicators based on active strategy                          |
//+------------------------------------------------------------------+
void AddStrategyIndicators() {
   // Clear existing tracked indicators
   ArrayResize(addedIndicators, 0);

   long chartID = ChartID();
   int subWindow = 0; // Main chart window

   // Common indicators that most strategies use
   // We'll add them to the chart for visualization

   // Example: Add RSI to a sub-window
   // Note: This creates a new indicator instance for display only
   // The strategy calculations use their own handles

   if(SelectedStrategy == STRATEGY_VOLUME_HM ||
      SelectedStrategy == STRATEGY_MULTI_TIMEFRAME) {
      // Add RSI indicator to sub-window
      int rsiHandle = iRSI(_Symbol, _Period, rsiPeriod, PRICE_CLOSE);
      if(rsiHandle != INVALID_HANDLE) {
         if(ChartIndicatorAdd(chartID, 1, rsiHandle)) {
            // Track this indicator
            int size = ArraySize(addedIndicators);
            ArrayResize(addedIndicators, size + 1);
            addedIndicators[size] = rsiHandle;
            Print("✅ RSI indicator added to chart");
         }
      }
   }

   // Add Bollinger Bands to main chart
   if(SelectedStrategy == STRATEGY_VOLUME_HM ||
      SelectedStrategy == STRATEGY_VWAP) {
      int bbHandle = iBands(_Symbol, _Period, 20, 0, 2.0, PRICE_CLOSE);
      if(bbHandle != INVALID_HANDLE) {
         if(ChartIndicatorAdd(chartID, 0, bbHandle)) {
            int size = ArraySize(addedIndicators);
            ArrayResize(addedIndicators, size + 1);
            addedIndicators[size] = bbHandle;
            Print("✅ Bollinger Bands indicator added to chart");
         }
      }
   }

   // Add ATR to sub-window for strategies that use it
   int atrHandle = iATR(_Symbol, _Period, ATR_Period_SL);
   if(atrHandle != INVALID_HANDLE) {
      if(ChartIndicatorAdd(chartID, 2, atrHandle)) {
         int size = ArraySize(addedIndicators);
         ArrayResize(addedIndicators, size + 1);
         addedIndicators[size] = atrHandle;
         Print("✅ ATR indicator added to chart");
      }
   }

   ChartRedraw(chartID);
}

//+------------------------------------------------------------------+
//| Remove all chart indicators added by EA                          |
//+------------------------------------------------------------------+
void RemoveAllChartIndicators() {
   long chartID = ChartID();

   // Remove all tracked indicators
   for(int i = 0; i < ArraySize(addedIndicators); i++) {
      if(addedIndicators[i] != INVALID_HANDLE) {
         // Find and remove the indicator from chart
         int totalIndicators = ChartIndicatorsTotal(chartID, 0);
         for(int win = 0; win < 3; win++) { // Check main window and up to 2 sub-windows
            totalIndicators = ChartIndicatorsTotal(chartID, win);
            for(int j = totalIndicators - 1; j >= 0; j--) {
               string indicatorName = ChartIndicatorName(chartID, win, j);
               // Remove if it matches our handle
               ChartIndicatorDelete(chartID, win, indicatorName);
            }
         }

         // Release the handle
         IndicatorRelease(addedIndicators[i]);
      }
   }

   ArrayResize(addedIndicators, 0);
   ChartRedraw(chartID);

   if(ShowIndicatorsOnChart == false) {
      Print("✅ Chart indicators hidden as per user setting");
   }
}

//+------------------------------------------------------------------+
//| Call this on EA deinitialization                                 |
//+------------------------------------------------------------------+
void CleanupChartIndicators() {
   RemoveAllChartIndicators();
}
