//+------------------------------------------------------------------+
//|                                       vwap_strategy.mqh          |
//|                        VWAP Mean Reversion Strategy              |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/strategy_interface.mqh"
#include "../strategy/vwap_testing.mqh"

class VWAPStrategy : public IStrategy {
public:
   VWAPStrategy() {
      name = "VWAP";
      description = "VWAP mean reversion strategy";
      version = "1.0";
      enabled = true;
   }

   virtual StrategySignal GetSignal() override {
      StrategySignal signal;
      TRADE_DIRECTION direction = Anchored_VWAP();

      if(direction == BUY) {
         signal.direction = BUY;
         signal.message = "VWAP BUY";
      } else if(direction == SELL) {
         signal.direction = SELL;
         signal.message = "VWAP SELL";
      }

      return signal;
   }
};
