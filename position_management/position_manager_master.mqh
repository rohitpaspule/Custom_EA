//+------------------------------------------------------------------+
//|                                  position_manager_master.mqh     |
//|                       Master Position Management Coordinator     |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"
#include "breakeven_manager.mqh"
#include "trailing_manager.mqh"
#include "partial_profit_manager.mqh"
#include "time_exit_manager.mqh"
#include "capital_protection.mqh"

//+------------------------------------------------------------------+
//| Main position management function - Called every timer tick      |
//+------------------------------------------------------------------+
void ManageOpenPositions() {
   if(PositionsTotal() == 0) return;

   // Execute all position management modules
   // Order matters: Capital protection first (safety), then exits, then optimizations

   CheckCapitalProtection();   // Highest priority - risk management
   CheckTimeBasedExit();        // Time-based rules
   CheckBreakEven();            // Move SL to break-even
   CheckTrailingStop();         // Trail stop loss
   CheckPartialProfit();        // Take partial profits
}
