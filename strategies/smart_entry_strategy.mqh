//+------------------------------------------------------------------+
//|                                  smart_entry_strategy.mqh        |
//|                            Smart Entry Timing Strategy           |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/strategy_interface.mqh"
#include "../strategy/smart_entry_signal.mqh"

class SmartEntryStrategy : public IStrategy {
public:
   SmartEntryStrategy() {
      name = "Smart_Entry";
      description = "Smart entry timing based on multiple confirmations";
      version = "1.0";
      enabled = true;
   }

   virtual StrategySignal GetSignal() override {
      StrategySignal signal;
      TRADE_DIRECTION direction = smart_entry_signal();

      if(direction == BUY) {
         signal.direction = BUY;
         signal.message = "Smart Entry BUY";
      } else if(direction == SELL) {
         signal.direction = SELL;
         signal.message = "Smart Entry SELL";
      }

      return signal;
   }
};
