#include "../indicators/bollinger_band.mqh"
#include "../indicators/hilega_milega.mqh"
#include "../indicators/moving_average.mqh"
#include "../indicators/vwap.mqh"
#include "../indicators/volume_insights.mqh"
#include "../timeframe_settings/timeframe_settings.mqh"
#include "../utility/utility.mqh"

TRADE_DIRECTION Volume_HM () {

       int shift = 1;
       BBAnalysisResult bbAnalysisResult = AnalyzeBollingerWithCandle(PERIOD_CURRENT,5,5,1,15);
       HilegaMilegaAnalysisResult HM_Data = Hilega_Milega(PERIOD_CURRENT);
       VolumeInsights volumeData = AnalyzeVolumeSignals();




      if (
          SafeGet(volumeData.isBullishDivergence, 0, false)
          && SafeGet(bbAnalysisResult.isCloseInUpperZone, 0, false)
          && SafeGet(bbAnalysisResult.isBullishCandle, 0, false)
          //SafeGet(bbAnalysisResult.candleClose, 0, 0.0) < SafeGet(bbAnalysisResult.upperBand, 0, 0.0) &&
          //SafeGet(bbAnalysisResult.candleHigh, 0, 0.0) < SafeGet(bbAnalysisResult.upperBand, 0, 0.0) &&
          //!SafeGet(bbAnalysisResult.isDojiOrNeutral, 0, false) &&
          //SafeGet(bbAnalysisResult.bbBandwidth, 0, 0.0) > bbAnalysisResult.avgBandwidth
          && HM_Data.rsi > HM_Data.ema
      )
      {
          return BUY;
      }

      if (
          SafeGet(volumeData.isBearishDivergence, 0, false)
          && SafeGet(bbAnalysisResult.isCloseInLowerZone, 0, false)
          && SafeGet(bbAnalysisResult.isBearishCandle, 0, false)
          //SafeGet(bbAnalysisResult.candleClose, 0, 0.0) > SafeGet(bbAnalysisResult.lowerBand, 0, 0.0) &&
          //SafeGet(bbAnalysisResult.candleLow, 0, 0.0) > SafeGet(bbAnalysisResult.lowerBand, 0, 0.0) &&
          //!SafeGet(bbAnalysisResult.isDojiOrNeutral, 0, false)
          && HM_Data.rsi < HM_Data.ema
      )
      {
          return SELL;
      }

   return NA;
}


