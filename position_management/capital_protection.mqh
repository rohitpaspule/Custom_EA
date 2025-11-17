//+------------------------------------------------------------------+
//|                                      capital_protection.mqh      |
//|                              Capital Protection & Risk Limits    |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"

//+------------------------------------------------------------------+
//| Check capital protection rules                                   |
//+------------------------------------------------------------------+
void CheckCapitalProtection() {
   if(!UseMaxLossPerTrade && !UseMaxDailyLoss) return;
   if(PositionsTotal() == 0) return;

   // Track daily loss
   static datetime lastResetDate = 0;
   static double dailyLoss = 0;

   datetime currentTime = TimeCurrent();
   MqlDateTime tm;
   TimeToStruct(currentTime, tm);

   // Reset daily loss counter at start of new day
   datetime currentDate = StringToTime(StringFormat("%04d.%02d.%02d", tm.year, tm.mon, tm.day));
   if(currentDate != lastResetDate) {
      dailyLoss = 0;
      lastResetDate = currentDate;
   }

   // Check each position
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double profit = PositionGetDouble(POSITION_PROFIT);
      double swap = PositionGetDouble(POSITION_SWAP);
      // Note: Commission is now retrieved from deal history, not position properties
      double totalPL = profit + swap;  // Commission removed (deprecated in MT5)

      bool shouldClose = false;
      string closeReason = "";

      // Check max loss per trade
      if(UseMaxLossPerTrade && totalPL < 0) {
         if(MathAbs(totalPL) >= MaxLossPerTrade) {
            shouldClose = true;
            closeReason = StringFormat("Max loss per trade ($%.2f)", MaxLossPerTrade);
         }
      }

      // Close position if needed
      if(shouldClose) {
         if(trade.PositionClose(ticket)) {
            Print("⚠️ Position #", ticket, " closed by ", closeReason);
            dailyLoss += MathAbs(totalPL);
         }
      }
   }

   // Check daily loss limit (close all positions if exceeded)
   if(UseMaxDailyLoss && dailyLoss >= MaxDailyLoss) {
      Print("⚠️ Daily loss limit reached ($", dailyLoss, "). Closing all positions.");
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

         ulong ticket = PositionGetInteger(POSITION_TICKET);
         trade.PositionClose(ticket);
      }
   }
}
