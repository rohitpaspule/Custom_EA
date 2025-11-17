#include "../indicators/bollinger_band.mqh"
#include "../indicators/hilega_milega.mqh"
#include "../indicators/moving_average.mqh"
#include "../indicators/vwap.mqh"
#include "../timeframe_settings/timeframe_settings.mqh"

TRADE_DIRECTION Anchored_VWAP() {
       
       int shift = 1; 
       
       VWAP_SERIES vwap_series = GetAnchoredVWAP();
       double ma = GetEMAFromVWAP(vwap_series, 3);
       BBAnalysisResult bbAnalysisResult = AnalyzeBollingerWithCandle(PERIOD_CURRENT,5,5,1,15);
       HilegaMilegaAnalysisResult HM_Data = Hilega_Milega(PERIOD_CURRENT);

       
       

      if (
          SafeGet(vwap_series.vwapSeries, 0, 0.0) > ma &&
          SafeGet(bbAnalysisResult.isCloseInUpperZone, 0, false) &&
          SafeGet(bbAnalysisResult.isBullishCandle, 0, false) &&
          SafeGet(bbAnalysisResult.candleClose, 0, 0.0) < SafeGet(bbAnalysisResult.upperBand, 0, 0.0) &&
          SafeGet(bbAnalysisResult.candleHigh, 0, 0.0) < SafeGet(bbAnalysisResult.upperBand, 0, 0.0) &&
          !SafeGet(bbAnalysisResult.isDojiOrNeutral, 0, false) &&
          SafeGet(bbAnalysisResult.bbBandwidth, 0, 0.0) > bbAnalysisResult.avgBandwidth &&
          HM_Data.rsi > HM_Data.ema
      )
      {
          return BUY;
      }
      
      if (
          SafeGet(vwap_series.vwapSeries, 0, 0.0) < ma &&
          SafeGet(bbAnalysisResult.isCloseInLowerZone, 0, false) &&
          SafeGet(bbAnalysisResult.isBearishCandle, 0, false) &&
          SafeGet(bbAnalysisResult.candleClose, 0, 0.0) > SafeGet(bbAnalysisResult.lowerBand, 0, 0.0) &&
          SafeGet(bbAnalysisResult.candleLow, 0, 0.0) > SafeGet(bbAnalysisResult.lowerBand, 0, 0.0) &&
          !SafeGet(bbAnalysisResult.isDojiOrNeutral, 0, false) &&
          HM_Data.rsi < HM_Data.ema
      )
      {
          return SELL;
      }

   return NA;
}


double GetMovingAverageFromVWAP(const VWAP_SERIES &series, int count = 5)
{
    double sum = 0.0;
    int total = ArraySize(series.vwapSeries);

    if (total < count || count <= 0)
        return 0.0; // Not enough data

    for (int i = 0; i < count; i++)
    {
        sum += series.vwapSeries[i];
    }

    return sum / count;
}


double GetEMAFromVWAP(const VWAP_SERIES &series, int count = 3)
{
    int total = ArraySize(series.vwapSeries);
    if (total < count || count <= 0)
        return 0.0; // Not enough data

    double ema = series.vwapSeries[count - 1]; // Start with the oldest of the last N
    double multiplier = 2.0 / (count + 1);

    // Loop from oldest to newest within the last N values
    for (int i = count - 2; i >= 0; i--)
    {
        ema = (series.vwapSeries[i] - ema) * multiplier + ema;
    }

    return ema;
}

double GetWMAFromVWAP(const VWAP_SERIES &series, int count = 21)
{
    int total = ArraySize(series.vwapSeries);
    if (total < count || count <= 0)
        return 0.0; // Not enough data

    double weightedSum = 0.0;
    int weightTotal = 0;

    for (int i = 0; i < count; i++)
    {
        int weight = count - i; // Higher weight to more recent values
        weightedSum += series.vwapSeries[i] * weight;
        weightTotal += weight;
    }

    return weightedSum / weightTotal;
}

