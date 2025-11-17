//+------------------------------------------------------------------+
//|                                         strategy_manager.mqh     |
//|                            Strategy Selection & Management       |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "config.mqh"
#include "strategy_interface.mqh"

// Forward declarations of strategy classes (will be defined in strategy files)
class VolumeHMStrategy;
class MultiTimeframeStrategy;
class TurtleSoupStrategy;
class VWAPStrategy;
class SmartEntryStrategy;

// Global pointer to active strategy
IStrategy* activeStrategy = NULL;

//+------------------------------------------------------------------+
//| Initialize strategy based on user selection                      |
//+------------------------------------------------------------------+
bool InitializeStrategy() {
   // Clean up existing strategy if any
   if(activeStrategy != NULL) {
      activeStrategy.OnDeinit();
      delete activeStrategy;
      activeStrategy = NULL;
   }

   // Create strategy instance based on selection
   switch(SelectedStrategy) {
      case STRATEGY_VOLUME_HM:
         activeStrategy = new VolumeHMStrategy();
         break;

      case STRATEGY_MULTI_TIMEFRAME:
         activeStrategy = new MultiTimeframeStrategy();
         break;

      case STRATEGY_TURTLE_SOUP:
         activeStrategy = new TurtleSoupStrategy();
         break;

      case STRATEGY_VWAP:
         activeStrategy = new VWAPStrategy();
         break;

      case STRATEGY_SMART_ENTRY:
         activeStrategy = new SmartEntryStrategy();
         break;

      default:
         Print("❌ Unknown strategy selected!");
         return false;
   }

   if(activeStrategy == NULL) {
      Print("❌ Failed to create strategy instance!");
      return false;
   }

   // Initialize strategy
   if(!activeStrategy.OnInit()) {
      Print("❌ Strategy initialization failed: ", activeStrategy.name);
      delete activeStrategy;
      activeStrategy = NULL;
      return false;
   }

   // Validate strategy
   if(!activeStrategy.Validate()) {
      Print("❌ Strategy validation failed: ", activeStrategy.name);
      delete activeStrategy;
      activeStrategy = NULL;
      return false;
   }

   Print("✅ Strategy initialized: ", activeStrategy.name, " v", activeStrategy.version);
   Print("   Description: ", activeStrategy.description);

   return true;
}

//+------------------------------------------------------------------+
//| Cleanup strategy on deinit                                        |
//+------------------------------------------------------------------+
void DeinitializeStrategy() {
   if(activeStrategy != NULL) {
      activeStrategy.OnDeinit();
      delete activeStrategy;
      activeStrategy = NULL;
   }
}

//+------------------------------------------------------------------+
//| Get signal from active strategy                                  |
//+------------------------------------------------------------------+
StrategySignal GetStrategySignal() {
   StrategySignal signal;

   if(activeStrategy == NULL || !activeStrategy.enabled) {
      return signal;  // Returns NA
   }

   signal = activeStrategy.GetSignal();

   return signal;
}

//+------------------------------------------------------------------+
//| Get active strategy name                                          |
//+------------------------------------------------------------------+
string GetActiveStrategyName() {
   if(activeStrategy == NULL) return "None";
   return activeStrategy.name;
}

//+------------------------------------------------------------------+
//| Get active strategy status                                        |
//+------------------------------------------------------------------+
string GetActiveStrategyStatus() {
   if(activeStrategy == NULL) return "Not initialized";
   return activeStrategy.GetStatus();
}
