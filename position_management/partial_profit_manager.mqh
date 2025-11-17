//+------------------------------------------------------------------+
//|                                   partial_profit_manager.mqh     |
//|                              Partial Profit Taking Management    |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"

// Track which positions have hit partial profit levels
struct PartialLevelTracker {
   ulong ticket;
   bool level1Hit;
   bool level2Hit;
};

PartialLevelTracker partialTrackers[];

//+------------------------------------------------------------------+
//| Get or create tracker for position                               |
//+------------------------------------------------------------------+
int GetTrackerIndex(ulong ticket) {
   for(int i = 0; i < ArraySize(partialTrackers); i++) {
      if(partialTrackers[i].ticket == ticket) return i;
   }

   // Create new tracker
   int newSize = ArraySize(partialTrackers) + 1;
   ArrayResize(partialTrackers, newSize);
   int newIndex = newSize - 1;

   partialTrackers[newIndex].ticket = ticket;
   partialTrackers[newIndex].level1Hit = false;
   partialTrackers[newIndex].level2Hit = false;

   return newIndex;
}

//+------------------------------------------------------------------+
//| Remove tracker when position is closed                           |
//+------------------------------------------------------------------+
void RemoveTracker(ulong ticket) {
   for(int i = 0; i < ArraySize(partialTrackers); i++) {
      if(partialTrackers[i].ticket == ticket) {
         // Shift array
         for(int j = i; j < ArraySize(partialTrackers) - 1; j++) {
            partialTrackers[j] = partialTrackers[j + 1];
         }
         ArrayResize(partialTrackers, ArraySize(partialTrackers) - 1);
         return;
      }
   }
}

//+------------------------------------------------------------------+
//| Check and apply partial profit taking                            |
//+------------------------------------------------------------------+
void CheckPartialProfit() {
   if(PartialProfitMode == PARTIAL_NONE) return;
   if(PositionsTotal() == 0) return;

   double pipFactor = GetPipFactor(_Symbol);

   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double currentPrice = (posType == POSITION_TYPE_BUY) ?
                           SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                           SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      // Calculate profit in pips
      double profitPips = 0;
      if(posType == POSITION_TYPE_BUY) {
         profitPips = (currentPrice - entry) / (_Point * pipFactor);
      } else {
         profitPips = (entry - currentPrice) / (_Point * pipFactor);
      }

      // Get tracker for this position
      int trackerIdx = GetTrackerIndex(ticket);

      // Check Level 1
      if(!partialTrackers[trackerIdx].level1Hit && profitPips >= Partial_Level1_Pips) {
         double closeVolume = NormalizeDouble(volume * (Partial_Level1_Percent / 100.0), 2);
         if(closeVolume >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) {
            if(trade.PositionClosePartial(ticket, closeVolume)) {
               Print("✅ Partial profit Level 1: Closed ", Partial_Level1_Percent,
                     "% at +", profitPips, " pips");
               partialTrackers[trackerIdx].level1Hit = true;
            }
         }
      }

      // Check Level 2
      if(!partialTrackers[trackerIdx].level2Hit && profitPips >= Partial_Level2_Pips) {
         // Refresh position data
         if(!PositionSelectByTicket(ticket)) continue;
         double remainingVolume = PositionGetDouble(POSITION_VOLUME);

         double closeVolume = NormalizeDouble(remainingVolume * (Partial_Level2_Percent / 100.0), 2);
         if(closeVolume >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) {
            if(trade.PositionClosePartial(ticket, closeVolume)) {
               Print("✅ Partial profit Level 2: Closed ", Partial_Level2_Percent,
                     "% at +", profitPips, " pips");
               partialTrackers[trackerIdx].level2Hit = true;
            }
         }
      }
   }

   // Clean up trackers for closed positions
   for(int i = ArraySize(partialTrackers) - 1; i >= 0; i--) {
      if(!PositionSelectByTicket(partialTrackers[i].ticket)) {
         RemoveTracker(partialTrackers[i].ticket);
      }
   }
}
