//+------------------------------------------------------------------+
//|                                         trailing_manager.mqh     |
//|                                   Trailing Stop Management       |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"
#include "../position_opening/lot_calculator.mqh"  // For GetATRValue

//+------------------------------------------------------------------+
//| Check and apply trailing stop logic                              |
//+------------------------------------------------------------------+
void CheckTrailingStop() {
   if(TrailingMode == TRAIL_NONE) return;
   if(PositionsTotal() == 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      double profit = PositionGetDouble(POSITION_PROFIT);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double currentPrice = (posType == POSITION_TYPE_BUY) ?
                           SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                           SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      // Check if profit threshold met to start trailing
      if(Trail_StartProfit > 0 && profit < Trail_StartProfit) continue;

      double trailDistance = 0;
      double pipFactor = GetPipFactor(_Symbol);

      switch(TrailingMode) {
         case TRAIL_FIXED_PIPS:
            trailDistance = Trail_FixedPips * _Point * pipFactor;
            break;

         case TRAIL_ATR: {
            double atr = GetATRValue(Trail_ATR_Period);
            if(atr > 0) {
               trailDistance = atr * Trail_ATR_Multi;
            } else {
               trailDistance = Trail_FixedPips * _Point * pipFactor;  // Fallback
            }
            break;
         }

         case TRAIL_STEP_BASED: {
            // Calculate how many steps of profit we've made
            double profitPips = 0;
            if(posType == POSITION_TYPE_BUY) {
               profitPips = (currentPrice - entry) / (_Point * pipFactor);
            } else {
               profitPips = (entry - currentPrice) / (_Point * pipFactor);
            }

            int steps = (int)MathFloor(profitPips / Trail_StepSize);
            if(steps > 0) {
               trailDistance = (profitPips - (steps * Trail_StepSize)) * _Point * pipFactor;
            }
            break;
         }
      }

      if(trailDistance <= 0) continue;

      // Calculate new SL based on trailing distance
      double newSL = 0;
      bool shouldUpdate = false;

      if(posType == POSITION_TYPE_BUY) {
         newSL = currentPrice - trailDistance;
         // Only trail upwards
         if(newSL > currentSL && newSL < currentPrice) {
            shouldUpdate = true;
         }
      } else if(posType == POSITION_TYPE_SELL) {
         newSL = currentPrice + trailDistance;
         // Only trail downwards
         if((newSL < currentSL || currentSL == 0) && newSL > currentPrice) {
            shouldUpdate = true;
         }
      }

      // Apply trailing stop
      if(shouldUpdate) {
         newSL = NormalizeDouble(newSL, _Digits);
         if(trade.PositionModify(ticket, newSL, tp)) {
            Print("✅ Trailing stop updated for ",
                  (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                  " #", ticket, " | New SL: ", newSL);
         }
      }
   }
}
