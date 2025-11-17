//+------------------------------------------------------------------+
//|                                          strategy_interface.mqh  |
//|                                      Base Interface for Strategies|
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "config.mqh"

//+------------------------------------------------------------------+
//| Strategy Signal Structure                                        |
//+------------------------------------------------------------------+
struct StrategySignal {
   TRADE_DIRECTION direction;      // BUY, SELL, or NA

   // Optional: Strategy can provide custom values (overrides user settings)
   bool   hasCustomSL;
   double customSL_Pips;           // In pips

   bool   hasCustomTP;
   double customTP_Pips;           // In pips

   bool   hasCustomLotSize;
   double customLotSize;

   // Signal metadata
   double confidence;              // 0-100 (optional, for future multi-strategy)
   string message;                 // Description of signal

   // Constructor
   StrategySignal() {
      direction = NA;
      hasCustomSL = false;
      customSL_Pips = 0;
      hasCustomTP = false;
      customTP_Pips = 0;
      hasCustomLotSize = false;
      customLotSize = 0;
      confidence = 0;
      message = "";
   }
};

//+------------------------------------------------------------------+
//| Base Strategy Interface                                          |
//| All strategies must inherit from this and implement GetSignal()  |
//+------------------------------------------------------------------+
class IStrategy {
public:
   string name;                    // Strategy name (e.g., "Volume_HM")
   string description;             // Brief description
   string version;                 // Version number
   bool   enabled;                 // Is strategy active?

   // Constructor
   IStrategy() {
      name = "BaseStrategy";
      description = "Base strategy interface";
      version = "1.0";
      enabled = false;
   }

   // Destructor
   virtual ~IStrategy() {}

   // MUST IMPLEMENT: Main signal generation
   virtual StrategySignal GetSignal() {
      StrategySignal signal;
      return signal;  // Default: NA
   }

   // OPTIONAL: Initialize strategy (called once in OnInit)
   virtual bool OnInit() {
      return true;
   }

   // OPTIONAL: Cleanup (called in OnDeinit)
   virtual void OnDeinit() {}

   // OPTIONAL: Get current status for panel display
   virtual string GetStatus() {
      return enabled ? "Active" : "Inactive";
   }

   // OPTIONAL: Validate strategy can run
   virtual bool Validate() {
      return enabled;
   }
};
