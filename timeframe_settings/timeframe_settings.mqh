SlopeSettings GetSlopeSettings(ENUM_TIMEFRAMES tf)
{
   SlopeSettings settings;

   switch(tf)
   {
      case PERIOD_M6:
         settings.rsiSlopeLength = 2;
         settings.wmaSlopeLength = 2;
         settings.emaSlopeLength = 2;
         break;

      case PERIOD_M12:
         settings.rsiSlopeLength = 4;
         settings.wmaSlopeLength = 2;
         settings.emaSlopeLength = 4;
         break;

      case PERIOD_H1:
         settings.rsiSlopeLength = 2;
         settings.wmaSlopeLength = 2;
         settings.emaSlopeLength = 2;
         break;

      case PERIOD_H4:
         settings.rsiSlopeLength = 2;
         settings.wmaSlopeLength = 2;
         settings.emaSlopeLength = 2;
         break;

      case PERIOD_D1:
         settings.rsiSlopeLength = 2;
         settings.wmaSlopeLength = 2;
         settings.emaSlopeLength = 2;
         break;

      default:
         settings.rsiSlopeLength = 10;
         settings.wmaSlopeLength = 5;
         settings.emaSlopeLength = 10;
         break;
   }

   return settings;
}

ThresholdSettings GetThresholdSettings(ENUM_TIMEFRAMES tf)
{
   ThresholdSettings thresholds;

   switch(tf)
   {
      case PERIOD_M6:
         thresholds.rsiSlopeThreshold = 0.08;
         thresholds.wmaSlopeThreshold = 0.10;
         thresholds.emaSlopeThreshold = 0.05;
         break;

      case PERIOD_M12:
         thresholds.rsiSlopeThreshold = 0.10;
         thresholds.wmaSlopeThreshold = 0.08;
         thresholds.emaSlopeThreshold = 0.10;
         break;

      case PERIOD_H1:
         thresholds.rsiSlopeThreshold = 0.04;
         thresholds.wmaSlopeThreshold = 0.06;
         thresholds.emaSlopeThreshold = 0.03;
         break;

      case PERIOD_H4:
         thresholds.rsiSlopeThreshold = 0.025;
         thresholds.wmaSlopeThreshold = 0.04;
         thresholds.emaSlopeThreshold = 0.02;
         break;

      default:
         thresholds.rsiSlopeThreshold = 0.05;
         thresholds.wmaSlopeThreshold = 0.05;
         thresholds.emaSlopeThreshold = 0.03;
         break;
   }

   return thresholds;
}

int GetLookbackBars(ENUM_TIMEFRAMES tf)
{
    switch(tf)
    {
        case PERIOD_M6:
            return 3;  
        case PERIOD_M12:
            return 4;  
        case PERIOD_H1:
            return 10;  
        case PERIOD_H4:
            return 10; 
        default:
            return 5;  
    }
}

RsiRange GetRsiRange(ENUM_TIMEFRAMES tf)
{
    RsiRange range;

    switch(tf)
    {
        case PERIOD_M6:
            range.buyMin  = 50.0;
            range.buyMax  = 100.0;
            range.sellMin = 0.0;
            range.sellMax = 50.0;
            break;

        case PERIOD_M12:
            range.buyMin  = 50.0;
            range.buyMax  = 100.0;
            range.sellMin = 0.0;
            range.sellMax = 50.0;
            break;

        case PERIOD_H1:
            range.buyMin  = 0.0;
            range.buyMax  = 100.0;
            range.sellMin = 0.0;
            range.sellMax = 100.0;
            break;

        case PERIOD_H4:
            range.buyMin  = 53.0;
            range.buyMax  = 58.0;
            range.sellMin = 42.0;
            range.sellMax = 47.0;
            break;

        default:
            range.buyMin  = 50.0;
            range.buyMax  = 55.0;
            range.sellMin = 45.0;
            range.sellMax = 50.0;
            break;
    }

    return range;
}

CrossConfirmationWindow GetCrossConfirmationWindow(ENUM_TIMEFRAMES tf)
{
    CrossConfirmationWindow window;

    switch(tf)
    {
        case PERIOD_M6:
            window.rsiCrossIndex = 2;
            window.emaCrossIndex = 2;
            break;

        case PERIOD_M12:
            window.rsiCrossIndex = 2;
            window.emaCrossIndex = 2;
            break;

        case PERIOD_H1:
            window.rsiCrossIndex = 3;
            window.emaCrossIndex = 4;
            break;

        case PERIOD_H4:
            window.rsiCrossIndex = 2;
            window.emaCrossIndex = 3;
            break;

        default:
            window.rsiCrossIndex = 2;
            window.emaCrossIndex = 2;
            break;
    }

    return window;
}