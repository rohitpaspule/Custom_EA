//+------------------------------------------------------------------+
//|                                              sl_calculator.mqh   |
//|                                   Stop Loss Calculator           |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"
#include "lot_calculator.mqh"  // For GetATRValue, GetPipFactor

//+------------------------------------------------------------------+
//| Calculate Stop Loss based on selected mode                       |
//| Returns SL in price (not pips)                                   |
//+------------------------------------------------------------------+
double CalculateStopLoss(TRADE_DIRECTION direction, double entryPrice) {
   double slDistance_Pips = 0;
   double sl = 0;

   switch(StopLossMode) {
      case FIXED_PIPS:
         slDistance_Pips = FixedSL_Pips;
         break;

      case ATR_MULTIPLE:
         double atr = GetATRValue(ATR_Period_SL);
         if(atr > 0) {
            slDistance_Pips = (atr / (_Point * GetPipFactor(_Symbol))) * ATR_Multiplier_SL;
         } else {
            slDistance_Pips = FixedSL_Pips;  // Fallback
         }
         break;

      case PERCENT_PRICE:
         slDistance_Pips = (entryPrice * (Percent_SL / 100.0)) / (_Point * GetPipFactor(_Symbol));
         break;

      case BB_WIDTH:
         // Calculate Bollinger Band width as SL
         double bbWidth = GetBBWidth();
         if(bbWidth > 0) {
            slDistance_Pips = bbWidth / (_Point * GetPipFactor(_Symbol));
         } else {
            slDistance_Pips = FixedSL_Pips;  // Fallback
         }
         break;

      case STRATEGY_DEFINED:
         // Will be set by strategy
         slDistance_Pips = FixedSL_Pips;  // Fallback
         break;

      case NONE_SL:
         return 0;  // No stop loss
   }

   // Convert pips to price
   double slDistance_Price = slDistance_Pips * _Point * GetPipFactor(_Symbol);

   if(direction == BUY) {
      sl = entryPrice - slDistance_Price;
   } else if(direction == SELL) {
      sl = entryPrice + slDistance_Price;
   }

   // Normalize price
   sl = NormalizeDouble(sl, _Digits);

   return sl;
}

//+------------------------------------------------------------------+
//| Get SL distance in pips (used by lot calculator)                 |
//+------------------------------------------------------------------+
double GetStopLossDistance_Pips() {
   double slDistance_Pips = 0;

   switch(StopLossMode) {
      case FIXED_PIPS:
         slDistance_Pips = FixedSL_Pips;
         break;

      case ATR_MULTIPLE:
         double atr = GetATRValue(ATR_Period_SL);
         if(atr > 0) {
            slDistance_Pips = (atr / (_Point * GetPipFactor(_Symbol))) * ATR_Multiplier_SL;
         } else {
            slDistance_Pips = FixedSL_Pips;
         }
         break;

      case PERCENT_PRICE:
         double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         slDistance_Pips = (price * (Percent_SL / 100.0)) / (_Point * GetPipFactor(_Symbol));
         break;

      case BB_WIDTH:
         double bbWidth = GetBBWidth();
         if(bbWidth > 0) {
            slDistance_Pips = bbWidth / (_Point * GetPipFactor(_Symbol));
         } else {
            slDistance_Pips = FixedSL_Pips;
         }
         break;

      case STRATEGY_DEFINED:
         slDistance_Pips = FixedSL_Pips;  // Fallback
         break;

      case NONE_SL:
         slDistance_Pips = FixedSL_Pips;  // Use default for risk calc
         break;
   }

   return slDistance_Pips;
}

//+------------------------------------------------------------------+
//| Get Bollinger Band width                                         |
//+------------------------------------------------------------------+
double GetBBWidth() {
   int bbHandle = iBands(_Symbol, _Period, 20, 0, 2.0, PRICE_CLOSE);
   if(bbHandle == INVALID_HANDLE) return 0;

   double upperBand[], lowerBand[];
   ArraySetAsSeries(upperBand, true);
   ArraySetAsSeries(lowerBand, true);

   if(CopyBuffer(bbHandle, 1, 0, 1, upperBand) <= 0 ||
      CopyBuffer(bbHandle, 2, 0, 1, lowerBand) <= 0) {
      IndicatorRelease(bbHandle);
      return 0;
   }

   double width = upperBand[0] - lowerBand[0];
   IndicatorRelease(bbHandle);

   return width;
}
