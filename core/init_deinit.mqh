//+------------------------------------------------------------------+
//|                                            init_deinit.mqh       |
//|                          EA Initialization & Cleanup             |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "2.00"

#include "../logging/logging_helpers.mqh"
#include "../utility/utility.mqh"
#include "../utility/info_panel.mqh"
#include "../utility/chart_manager.mqh"
#include "../core/strategy_manager.mqh"

//+------------------------------------------------------------------+
//| Initialize EA                                                     |
//+------------------------------------------------------------------+
int InitializeEA() {
   Print("═══════════════════════════════════════════════════");
   Print("  Custom EA Framework v2.0 - Initializing...");
   Print("═══════════════════════════════════════════════════");

   // Initialize logging
   LogHeadersInCSV();

   // Set timer (60 seconds)
   EventSetTimer(60);
   Print("✅ Timer set to 60 seconds");

   // Initialize ATR handle
   atrHandle = iATR(_Symbol, PERIOD_CURRENT, ATR_Period_SL);
   if(atrHandle == INVALID_HANDLE) {
      Print("❌ Failed to initialize ATR indicator");
      return INIT_FAILED;
   }
   Print("✅ ATR indicator initialized");

   // Initialize strategy
   if(!InitializeStrategy()) {
      Print("❌ Strategy initialization failed");
      return INIT_FAILED;
   }

   // Create info panel
   if(ShowPanel) {
      CreatePanel();
      Print("✅ Info panel created");
   }

   // Manage chart indicators visibility
   ManageChartIndicators();
   if(ShowIndicatorsOnChart) {
      Print("✅ Chart indicators enabled and displayed");
   } else {
      Print("✅ Chart indicators hidden (as per user setting)");
   }

   Print("═══════════════════════════════════════════════════");
   Print("  EA Initialized Successfully!");
   Print("  Strategy: ", GetActiveStrategyName());
   Print("  Symbol: ", _Symbol);
   Print("  Timeframe: ", EnumToString(_Period));
   Print("═══════════════════════════════════════════════════");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Cleanup EA                                                        |
//+------------------------------------------------------------------+
void CleanupEA() {
   Print("Cleaning up EA...");

   // Kill timer
   EventKillTimer();

   // Release indicators
   if(atrHandle != INVALID_HANDLE) {
      IndicatorRelease(atrHandle);
   }

   // Close log file
   if(fileHandle != 0) {
      FileClose(fileHandle);
   }

   // Deinitialize strategy
   DeinitializeStrategy();

   // Cleanup chart indicators
   CleanupChartIndicators();

   // Delete panel
   if(ShowPanel) {
      DeletePanel();
   }

   Print("EA cleanup complete.");
}
