//+------------------------------------------------------------------+
//|                                       volume_hm_strategy.mqh     |
//|                    Volume Divergence + Hilega-Milega Strategy    |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/strategy_interface.mqh"
#include "../Indicators/bollinger_band.mqh"
#include "../Indicators/hilega_milega.mqh"
#include "../Indicators/volume_insights.mqh"
#include "../utility/utility.mqh"

//+------------------------------------------------------------------+
//| Volume HM Strategy Class                                          |
//+------------------------------------------------------------------+
class VolumeHMStrategy : public IStrategy {
public:
   // Constructor
   VolumeHMStrategy() {
      name = "Volume_HM";
      description = "Volume divergence with Hilega-Milega (RSI/EMA/WMA) indicators";
      version = "1.0";
      enabled = true;
   }

   // Destructor
   ~VolumeHMStrategy() {}

   // Initialize strategy (optional)
   virtual bool OnInit() override {
      Print("   Volume HM Strategy: Analyzing volume divergences with BB and HM indicators");
      return true;
   }

   // Main signal generation
   virtual StrategySignal GetSignal() override {
      StrategySignal signal;

      // Get indicator data
      BBAnalysisResult bbResult = AnalyzeBollingerWithCandle(PERIOD_CURRENT, 5, 5, 1, 15);
      HilegaMilegaAnalysisResult hmData = Hilega_Milega(PERIOD_CURRENT);
      VolumeInsights volumeData = AnalyzeVolumeSignals();

      // Store current indicator values for display
      gwma = hmData.wma;
      gema = hmData.ema;
      grsi = hmData.rsi;

      // === BUY SIGNAL ===
      if(SafeGet(volumeData.isBullishDivergence, 0, false) &&
         SafeGet(bbResult.isCloseInUpperZone, 0, false) &&
         SafeGet(bbResult.isBullishCandle, 0, false) &&
         hmData.rsi > hmData.ema) {

         signal.direction = BUY;
         signal.confidence = 75;
         signal.message = StringFormat("Vol_HM BUY | RSI:%.1f EMA:%.1f", hmData.rsi, hmData.ema);

         // Strategy does not provide custom SL/TP/Lot
         // User settings will be used
         signal.hasCustomSL = false;
         signal.hasCustomTP = false;
         signal.hasCustomLotSize = false;

         return signal;
      }

      // === SELL SIGNAL ===
      if(SafeGet(volumeData.isBearishDivergence, 0, false) &&
         SafeGet(bbResult.isCloseInLowerZone, 0, false) &&
         SafeGet(bbResult.isBearishCandle, 0, false) &&
         hmData.rsi < hmData.ema) {

         signal.direction = SELL;
         signal.confidence = 75;
         signal.message = StringFormat("Vol_HM SELL | RSI:%.1f EMA:%.1f", hmData.rsi, hmData.ema);

         signal.hasCustomSL = false;
         signal.hasCustomTP = false;
         signal.hasCustomLotSize = false;

         return signal;
      }

      // No signal
      return signal;
   }

   // Get current status for panel display
   virtual string GetStatus() override {
      HilegaMilegaAnalysisResult hmData = Hilega_Milega(PERIOD_CURRENT);
      return StringFormat("RSI:%.1f | EMA:%.1f | WMA:%.1f",
                          hmData.rsi, hmData.ema, hmData.wma);
   }
};
