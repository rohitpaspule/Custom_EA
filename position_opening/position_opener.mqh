//+------------------------------------------------------------------+
//|                                          position_opener.mqh     |
//|                           Coordinates Position Opening           |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"
#include "../core/strategy_interface.mqh"
#include "lot_calculator.mqh"
#include "sl_calculator.mqh"
#include "tp_calculator.mqh"

//+------------------------------------------------------------------+
//| Open position based on strategy signal and user settings         |
//+------------------------------------------------------------------+
bool OpenPosition(StrategySignal &signal) {
   if(signal.direction == NA) return false;

   // Determine order type
   ENUM_ORDER_TYPE orderType = (signal.direction == BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;

   // Get entry price
   double price = (signal.direction == BUY) ?
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) :
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // Calculate SL
   double sl = 0;
   if(signal.hasCustomSL) {
      // Strategy provided custom SL
      double slDistance_Price = signal.customSL_Pips * _Point * GetPipFactor(_Symbol);
      if(signal.direction == BUY) {
         sl = price - slDistance_Price;
      } else {
         sl = price + slDistance_Price;
      }
   } else {
      // Use calculator
      sl = CalculateStopLoss(signal.direction, price);
   }

   // Calculate TP
   double tp = 0;
   if(signal.hasCustomTP) {
      // Strategy provided custom TP
      double tpDistance_Price = signal.customTP_Pips * _Point * GetPipFactor(_Symbol);
      if(signal.direction == BUY) {
         tp = price + tpDistance_Price;
      } else {
         tp = price - tpDistance_Price;
      }
   } else {
      // Use calculator
      tp = CalculateTakeProfit(signal.direction, price, sl);
   }

   // Calculate lot size
   double lotSize = 0;
   if(signal.hasCustomLotSize) {
      // Strategy provided custom lot size
      lotSize = NormalizeLotSize(signal.customLotSize);
   } else {
      // Use calculator
      double slDistance_Pips = (sl != 0) ? GetStopLossDistance_Pips() : 50;  // Default for risk calc
      lotSize = CalculateLotSize(signal.direction, slDistance_Pips);
   }

   // Build comment
   string comment = StringFormat("%s | %s", signal.message, TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES));
   if(StringLen(comment) > 31) comment = StringSubstr(comment, 0, 31);  // MQL5 comment limit

   // Place order
   bool result = false;
   if(signal.direction == BUY) {
      result = trade.Buy(lotSize, _Symbol, price, sl, tp, comment);
   } else {
      result = trade.Sell(lotSize, _Symbol, price, sl, tp, comment);
   }

   if(!result) {
      Print("❌ Order failed: ", trade.ResultRetcodeDescription());
      return false;
   } else {
      Print("✅ Order placed successfully | ",
            (signal.direction == BUY ? "BUY" : "SELL"),
            " | Lot: ", lotSize,
            " | SL: ", sl,
            " | TP: ", tp);
      return true;
   }
}
