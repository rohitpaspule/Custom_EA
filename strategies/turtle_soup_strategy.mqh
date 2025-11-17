//+------------------------------------------------------------------+
//|                                  turtle_soup_strategy.mqh        |
//|                           Turtle Soup Reversal Strategy          |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/strategy_interface.mqh"
#include "../strategy/turtle_soup.mqh"

class TurtleSoupStrategy : public IStrategy {
public:
   TurtleSoupStrategy() {
      name = "Turtle_Soup";
      description = "Turtle Soup false breakout reversal strategy";
      version = "1.0";
      enabled = true;
   }

   virtual StrategySignal GetSignal() override {
      StrategySignal signal;
      TRADE_DIRECTION direction = turtle_soup();

      if(direction == BUY) {
         signal.direction = BUY;
         signal.message = "Turtle Soup BUY";
      } else if(direction == SELL) {
         signal.direction = SELL;
         signal.message = "Turtle Soup SELL";
      }

      return signal;
   }
};
