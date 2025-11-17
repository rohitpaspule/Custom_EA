//+------------------------------------------------------------------+
//|                                             lot_calculator.mqh   |
//|                                   Position Size Calculator       |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"

//+------------------------------------------------------------------+
//| Calculate lot size based on selected mode                        |
//+------------------------------------------------------------------+
double CalculateLotSize(TRADE_DIRECTION direction, double slDistance_Pips = 0) {
   double lotSize = 0.01;  // Minimum lot

   switch(LotCalculationMode) {
      case FIXED_LOT:
         lotSize = FixedLotSize;
         break;

      case RISK_PERCENT:
         // Risk % of balance based on SL distance
         if(slDistance_Pips > 0) {
            double balance = AccountInfoDouble(ACCOUNT_BALANCE);
            double riskAmount = balance * (RiskPercent / 100.0);
            double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
            double pipValue = tickValue * GetPipFactor(_Symbol);

            lotSize = riskAmount / (slDistance_Pips * pipValue);
         } else {
            lotSize = FixedLotSize;  // Fallback if no SL
         }
         break;

      case BALANCE_PERCENT:
         // % of balance as position size
         double balance = AccountInfoDouble(ACCOUNT_BALANCE);
         double positionValue = balance * (BalancePercent / 100.0);
         double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
         double price = (direction == BUY) ?
                        SymbolInfoDouble(_Symbol, SYMBOL_ASK) :
                        SymbolInfoDouble(_Symbol, SYMBOL_BID);

         lotSize = positionValue / (contractSize * price);
         break;

      case ATR_BASED:
         // Inverse volatility sizing (lower ATR = larger position)
         double atrValue = GetATRValue(ATR_Period_Lots);
         if(atrValue > 0) {
            double atrPips = atrValue / (_Point * GetPipFactor(_Symbol));
            double baseRisk = AccountInfoDouble(ACCOUNT_BALANCE) * (RiskPercent / 100.0);
            double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
            double pipValue = tickValue * GetPipFactor(_Symbol);

            lotSize = baseRisk / ((atrPips * ATR_Multiplier_Lots) * pipValue);
         } else {
            lotSize = FixedLotSize;
         }
         break;

      case STRATEGY_DEFINED:
         // Will be set by strategy (caller should check signal.hasCustomLotSize)
         lotSize = FixedLotSize;  // Fallback
         break;
   }

   // Normalize and validate
   lotSize = NormalizeLotSize(lotSize);

   return lotSize;
}

//+------------------------------------------------------------------+
//| Normalize lot size to broker requirements                        |
//+------------------------------------------------------------------+
double NormalizeLotSize(double lotSize) {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   // Ensure within min/max
   if(lotSize < minLot) lotSize = minLot;
   if(lotSize > maxLot) lotSize = maxLot;

   // Round to lot step
   lotSize = MathFloor(lotSize / lotStep) * lotStep;

   // Final validation
   if(lotSize < minLot) lotSize = minLot;

   return lotSize;
}

//+------------------------------------------------------------------+
//| Get ATR value                                                     |
//+------------------------------------------------------------------+
double GetATRValue(int period) {
   int atrHandle = iATR(_Symbol, _Period, period);
   if(atrHandle == INVALID_HANDLE) return 0;

   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);

   if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) <= 0) {
      IndicatorRelease(atrHandle);
      return 0;
   }

   double atr = atrBuffer[0];
   IndicatorRelease(atrHandle);

   return atr;
}

//+------------------------------------------------------------------+
//| Get pip factor (already exists in position_manager but duplicate)|
//+------------------------------------------------------------------+
double GetPipFactor(string symbol) {
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

   if(point == 0.00001) return 10.0;      // 5-digit forex
   else if(point == 0.0001) return 10.0;  // 4-digit forex
   else if(point == 0.001) return 10.0;   // 3-digit JPY
   else if(point == 0.01) return 100.0;   // 2-digit or gold

   return 10.0;  // Default
}
