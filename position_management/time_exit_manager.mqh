//+------------------------------------------------------------------+
//|                                        time_exit_manager.mqh     |
//|                                  Time-Based Exit Management      |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"

//+------------------------------------------------------------------+
//| Check and close positions based on time rules                    |
//+------------------------------------------------------------------+
void CheckTimeBasedExit() {
   if(!UseMaxHoldingTime && !CloseFridayPositions) return;
   if(PositionsTotal() == 0) return;

   datetime currentTime = TimeCurrent();
   MqlDateTime tm;
   TimeToStruct(currentTime, tm);

   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);

      bool shouldClose = false;
      string closeReason = "";

      // Check max holding time
      if(UseMaxHoldingTime) {
         int hoursHeld = (int)((currentTime - openTime) / 3600);
         if(hoursHeld >= MaxHoldingHours) {
            shouldClose = true;
            closeReason = StringFormat("Max hold time (%d hours)", MaxHoldingHours);
         }
      }

      // Check Friday close
      if(CloseFridayPositions && tm.day_of_week == 5 && tm.hour >= FridayCloseHour) {
         shouldClose = true;
         closeReason = "Friday close";
      }

      // Close position
      if(shouldClose) {
         if(trade.PositionClose(ticket)) {
            Print("✅ Position #", ticket, " closed by ", closeReason);
         }
      }
   }
}
