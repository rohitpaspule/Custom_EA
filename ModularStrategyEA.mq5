//+------------------------------------------------------------------+
//|                                            ModularStrategyEA.mq5 |
//|                           Universal Modular Trading Framework    |
//|                                       Version 2.0                |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property link      ""
#property version   "2.00"
#property description "Modular EA with pluggable strategies and risk management"
#property description "Supports multiple strategies, position opening methods, and position management modules"

#include "core/config.mqh"
#include "core/init_deinit.mqh"
#include "core/process_engine.mqh"
#include "utility/trading_schedule.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit() {
   return InitializeEA();
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   CleanupEA();
}

//+------------------------------------------------------------------+
//| Expert tick function (not used - timer-based execution)          |
//+------------------------------------------------------------------+
void OnTick() {
   // All logic is timer-based for efficiency
   // OnTick is intentionally left empty
}

//+------------------------------------------------------------------+
//| Expert timer function (main execution every 60 seconds)          |
//+------------------------------------------------------------------+
void OnTimer() {
   ExecuteMainLogic();
}

//+------------------------------------------------------------------+
//| Main execution logic with trading schedule validation            |
//+------------------------------------------------------------------+
void ExecuteMainLogic() {
   // Check if trading is allowed based on schedule
   if(!IsTradingAllowed()) {
      return;  // Outside allowed trading hours
   }

   // Execute main processing engine
   ProcessEngine();
}
