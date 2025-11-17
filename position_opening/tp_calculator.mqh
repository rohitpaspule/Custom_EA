//+------------------------------------------------------------------+
//|                                              tp_calculator.mqh   |
//|                                   Take Profit Calculator         |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"
#include "sl_calculator.mqh"  // For GetStopLossDistance_Pips

//+------------------------------------------------------------------+
//| Calculate Take Profit based on selected mode                     |
//| Returns TP in price (not pips)                                   |
//+------------------------------------------------------------------+
double CalculateTakeProfit(TRADE_DIRECTION direction, double entryPrice, double slPrice) {
   double tpDistance_Pips = 0;
   double tp = 0;

   switch(TakeProfitMode) {
      case TP_FIXED_PIPS:
         tpDistance_Pips = FixedTP_Pips;
         break;

      case TP_RISK_REWARD:
         // Calculate based on SL distance
         double slDistance_Pips = GetStopLossDistance_Pips();
         tpDistance_Pips = slDistance_Pips * RiskRewardRatio;
         break;

      case TP_ATR_MULTIPLE:
         double atr = GetATRValue(ATR_Period_TP);
         if(atr > 0) {
            tpDistance_Pips = (atr / (_Point * GetPipFactor(_Symbol))) * ATR_Multiplier_TP;
         } else {
            tpDistance_Pips = FixedTP_Pips;  // Fallback
         }
         break;

      case TP_MIRROR_SL:
         // Same distance as SL
         double slDistance = MathAbs(entryPrice - slPrice);
         tpDistance_Pips = slDistance / (_Point * GetPipFactor(_Symbol));
         break;

      case TP_STRATEGY_DEFINED:
         // Will be set by strategy
         tpDistance_Pips = FixedTP_Pips;  // Fallback
         break;

      case TP_NONE:
         return 0;  // No take profit
   }

   // Convert pips to price
   double tpDistance_Price = tpDistance_Pips * _Point * GetPipFactor(_Symbol);

   if(direction == BUY) {
      tp = entryPrice + tpDistance_Price;
   } else if(direction == SELL) {
      tp = entryPrice - tpDistance_Price;
   }

   // Normalize price
   tp = NormalizeDouble(tp, _Digits);

   return tp;
}
