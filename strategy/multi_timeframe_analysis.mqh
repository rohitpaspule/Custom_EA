#include "../indicators/bollinger_band.mqh"
#include "../indicators/hilega_milega.mqh"
#include "../indicators/moving_average.mqh"
#include "../timeframe_settings/timeframe_settings.mqh"
#include "../utility/utility.mqh"

TRADE_DIRECTION multi_timeframe_analysis() {

   HilegaMilegaAnalysisResult HM_Current = Hilega_Milega(PERIOD_CURRENT);

   HilegaMilegaAnalysisResult HM_12M = Hilega_Milega( PERIOD_M12);
   HilegaMilegaAnalysisResult HM_1H = Hilega_Milega( PERIOD_H1);
   HilegaMilegaAnalysisResult HM_4H = Hilega_Milega( PERIOD_H4);

   // === HTF Confirmation Checks
   bool HTFBuyConfirmed = true;
   bool HTFSellConfirmed = true;

   // You can enable/disable any TF here
   if (HM_12M.isValid) {
      HTFBuyConfirmed  &= IsHTFBuyConfirmed(PERIOD_M12,HM_12M);
      HTFSellConfirmed &= IsHTFSellConfirmed(PERIOD_M12,HM_12M);
   }
   if (!HM_1H.isValid) {
      HTFBuyConfirmed  &= IsHTFBuyConfirmed(PERIOD_H1,HM_1H);
      HTFSellConfirmed &= IsHTFSellConfirmed(PERIOD_H1,HM_1H);
   }
   if (!HM_4H.isValid) {
      HTFBuyConfirmed  &= IsHTFBuyConfirmed(PERIOD_H4,HM_4H);
      HTFSellConfirmed &= IsHTFSellConfirmed(PERIOD_H4,HM_4H);
   }

   // === Current TF decision
   bool isBuy  = HM_Current.isValid 
                 && IsHTFBuyConfirmed(PERIOD_CURRENT, HM_Current);
   
   bool isSell = HM_Current.isValid 
                 && IsHTFSellConfirmed(PERIOD_CURRENT,HM_Current);

  
    gwma = HM_Current.wma;
    gema = HM_Current.ema;
    grsi = HM_Current.rsi;      
   // === Final Decision: use HTF filtering or not
   bool useHTF = true;  // toggle this to false to trade only on current TF

   if (useHTF) {
       if (isBuy && HTFBuyConfirmed) {
           return BUY;
       }
       if (isSell && HTFSellConfirmed) {
           return SELL;
       }
   } else {
       if (isBuy) {
           return BUY;
       }
       if (isSell) {
           return SELL;
       }
   }

   return NA;
}


bool IsHTFBuyConfirmed(
    ENUM_TIMEFRAMES tf,
    HilegaMilegaAnalysisResult &HM_Data
) {
    
    ThresholdSettings thresholdSettings = GetThresholdSettings(tf);
    RsiRange rsiRange = GetRsiRange(tf);
    
    // Moving Average 
    MAAnalysisResult maResult = AnalyzeMovingAverage(tf,20, MODE_EMA,PRICE_CLOSE,5,5,0.1,0.5,1);
    
    // BB & candle formation 
    BBAnalysisResult bbAnalysisResult = AnalyzeBollingerWithCandle(tf,5,5,1);
    
    // RSI and EMA crossover 
    int lookbackBars = GetLookbackBars(tf);
    int rsiCrossIndex = -1, emaCrossIndex = -1;
    bool rsiCross = DetectCrossOver(HM_Data.rsiBuf, HM_Data.wmaBuf, lookbackBars, CROSS_FROM_BELOW, rsiCrossIndex);
    bool emaCross = DetectCrossOver(HM_Data.emaBuf, HM_Data.wmaBuf, lookbackBars, CROSS_FROM_BELOW, emaCrossIndex);
    CrossConfirmationWindow crossConfirmationWindow = GetCrossConfirmationWindow(tf);

    return (
        HM_Data.rsi >= rsiRange.buyMin && HM_Data.rsi <= rsiRange.buyMax &&
        HM_Data.rsiSlope > thresholdSettings.rsiSlopeThreshold &&
        HM_Data.wmaSlope > thresholdSettings.wmaSlopeThreshold &&
        HM_Data.emaSlope > thresholdSettings.emaSlopeThreshold &&
        emaCross &&
        rsiCross
        && !SafeGet(bbAnalysisResult.isSqueeze, 0, false)
        && rsiCrossIndex <= crossConfirmationWindow.rsiCrossIndex
        && emaCrossIndex <= crossConfirmationWindow.emaCrossIndex
        //&&SafeGet(maResult.isBullishCrossover, 1, false)
        //&& SafeGet(maResult.isMaintainingAboveMA, 0, false)
           
    );
}


bool IsHTFSellConfirmed(
    ENUM_TIMEFRAMES tf,
    HilegaMilegaAnalysisResult &HM_Data
) {
    
    ThresholdSettings thresholdSettings = GetThresholdSettings(tf);
    RsiRange rsiRange = GetRsiRange(tf);
    
    // Moving Average 
    MAAnalysisResult maResult = AnalyzeMovingAverage(tf,20, MODE_EMA,PRICE_CLOSE,5,5,0.1,0.5,1);
    
    // BB & candle formation 
    BBAnalysisResult bbAnalysisResult = AnalyzeBollingerWithCandle(tf,5,5,1);

    // RSI and EMA crossover
    int lookbackBars = GetLookbackBars(tf);
    int rsiCrossIndex = -1, emaCrossIndex = -1;
    bool rsiCross = DetectCrossOver(HM_Data.rsiBuf, HM_Data.wmaBuf, lookbackBars, CROSS_FROM_ABOVE, rsiCrossIndex);
    bool emaCross = DetectCrossOver(HM_Data.emaBuf, HM_Data.wmaBuf, lookbackBars, CROSS_FROM_ABOVE, emaCrossIndex);
    CrossConfirmationWindow crossConfirmationWindow = GetCrossConfirmationWindow(tf);

    return (
        HM_Data.rsi >= rsiRange.sellMin && HM_Data.rsi <= rsiRange.sellMax &&
        HM_Data.rsiSlope < -thresholdSettings.rsiSlopeThreshold &&
        HM_Data.wmaSlope < -thresholdSettings.wmaSlopeThreshold &&
        HM_Data.emaSlope < -thresholdSettings.emaSlopeThreshold &&
        emaCross &&
        rsiCross
        && !SafeGet(bbAnalysisResult.isSqueeze, 0, false)
        && rsiCrossIndex <= crossConfirmationWindow.rsiCrossIndex
        && emaCrossIndex <= crossConfirmationWindow.emaCrossIndex
        //&& SafeGet(maResult.isBearishCrossover,1, false)
        //&& SafeGet(maResult.isMaintainingBelowMA, 0, false)
       
    );
}