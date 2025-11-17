//+------------------------------------------------------------------+
//|                                        breakeven_manager.mqh     |
//|                                   Break-Even Management          |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"
#include "../position_opening/lot_calculator.mqh"  // For GetATRValue

//+------------------------------------------------------------------+
//| Check and apply break-even logic                                 |
//+------------------------------------------------------------------+
void CheckBreakEven() {
   if(BreakEvenMode == BE_NONE) return;
   if(PositionsTotal() == 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double currentPrice = (posType == POSITION_TYPE_BUY) ?
                           SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                           SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      // Skip if already at break-even (within 2 pips of entry)
      double pipFactor = GetPipFactor(_Symbol);
      if(MathAbs(currentSL - entry) < _Point * pipFactor * 2) continue;

      bool shouldMoveToBE = false;
      double targetProfit = 0;  // How much profit needed to trigger BE

      switch(BreakEvenMode) {
         case BE_HALF_TP:
            if(tp != 0) {
               targetProfit = MathAbs(tp - entry) / 2.0;
            }
            break;

         case BE_CUSTOM_PERCENT:
            if(tp != 0) {
               targetProfit = MathAbs(tp - entry) * (BE_CustomPercent / 100.0);
            }
            break;

         case BE_CUSTOM_PROFIT: {
            // Calculate price distance for custom $ profit
            double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
            double lotSize = PositionGetDouble(POSITION_VOLUME);
            if(tickValue > 0 && lotSize > 0) {
               targetProfit = (BE_CustomProfit / (tickValue * lotSize)) * _Point;
            }
            break;
         }

         case BE_ATR_DISTANCE: {
            double atr = GetATRValue(ATR_Period_SL);
            if(atr > 0) {
               targetProfit = atr * BE_ATR_Multi;
            }
            break;
         }
      }

      // Check if price has moved enough to trigger BE
      if(posType == POSITION_TYPE_BUY) {
         if(currentPrice >= entry + targetProfit) {
            shouldMoveToBE = true;
         }
      } else if(posType == POSITION_TYPE_SELL) {
         if(currentPrice <= entry - targetProfit) {
            shouldMoveToBE = true;
         }
      }

      // Move SL to break-even (+ buffer)
      if(shouldMoveToBE) {
         double bufferDistance = BE_BufferPips * _Point * pipFactor;
         double newSL = 0;

         if(posType == POSITION_TYPE_BUY) {
            newSL = entry + bufferDistance;
            if(newSL > currentSL) {  // Only move SL up for BUY
               if(trade.PositionModify(ticket, newSL, tp)) {
                  Print("✅ Break-even set for BUY #", ticket, " at ", newSL);
               }
            }
         } else {
            newSL = entry - bufferDistance;
            if(newSL < currentSL || currentSL == 0) {  // Only move SL down for SELL
               if(trade.PositionModify(ticket, newSL, tp)) {
                  Print("✅ Break-even set for SELL #", ticket, " at ", newSL);
               }
            }
         }
      }
   }
}
