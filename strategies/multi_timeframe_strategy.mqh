//+------------------------------------------------------------------+
//|                                multi_timeframe_strategy.mqh      |
//|                        Multi-Timeframe Analysis Strategy         |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/strategy_interface.mqh"
#include "../strategy/multi_timeframe_analysis.mqh"

//+------------------------------------------------------------------+
//| Multi-Timeframe Strategy Class                                   |
//+------------------------------------------------------------------+
class MultiTimeframeStrategy : public IStrategy {
public:
   MultiTimeframeStrategy() {
      name = "Multi_Timeframe";
      description = "Analyzes RSI/EMA/WMA across multiple timeframes";
      version = "1.0";
      enabled = true;
   }

   virtual bool OnInit() override {
      Print("   Multi-Timeframe Strategy: Analyzing M12, H1, H4 timeframes");
      return true;
   }

   virtual StrategySignal GetSignal() override {
      StrategySignal signal;

      TRADE_DIRECTION direction = multi_timeframe_analysis();

      if(direction == BUY) {
         signal.direction = BUY;
         signal.confidence = 80;
         signal.message = "MTF BUY | HTF confirmed";
      } else if(direction == SELL) {
         signal.direction = SELL;
         signal.confidence = 80;
         signal.message = "MTF SELL | HTF confirmed";
      }

      return signal;
   }

   virtual string GetStatus() override {
      return StringFormat("RSI:%.1f | EMA:%.1f | WMA:%.1f", grsi, gema, gwma);
   }
};
