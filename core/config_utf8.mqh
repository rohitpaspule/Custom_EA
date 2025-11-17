//+------------------------------------------------------------------+
//|                                                     config.mqh   |
//|                          Global Configuration & User Inputs      |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "2.00"

#include <Trade\Trade.mqh>
#include <Files\FileTxt.mqh>

CTrade trade;

//+------------------------------------------------------------------+
//| ENUMS - Position Opening & Management                            |
//+------------------------------------------------------------------+

// Lot calculation modes
enum LOT_MODE {
   LOT_FIXED,            // Fixed lot size
   LOT_RISK_PERCENT,     // % of balance at risk (based on SL)
   LOT_BALANCE_PERCENT,  // % of balance as position size
   LOT_ATR_BASED,        // ATR-based position sizing
   LOT_STRATEGY_DEFINED  // Strategy provides lot size
};

// Stop Loss calculation modes
enum SL_MODE {
   SL_FIXED_PIPS,        // Fixed pips
   SL_ATR_MULTIPLE,      // ATR multiplier
   SL_PERCENT_PRICE,     // % of entry price
   SL_BB_WIDTH,          // Bollinger Band width
   SL_STRATEGY_DEFINED,  // Strategy provides SL
   SL_NONE               // No stop loss
};

// Take Profit calculation modes
enum TP_MODE {
   TP_FIXED_PIPS,     // Fixed pips
   TP_RISK_REWARD,    // Risk:Reward ratio
   TP_ATR_MULTIPLE,   // ATR multiplier
   TP_MIRROR_SL,      // Same distance as SL
   TP_STRATEGY_DEFINED,  // Strategy provides TP
   TP_NONE           // No take profit
};

// Break-even modes
enum BREAKEVEN_MODE {
   BE_NONE,           // Disabled
   BE_HALF_TP,        // Move to BE at 50% to TP
   BE_CUSTOM_PERCENT, // Move at custom % to TP
   BE_CUSTOM_PROFIT,  // Move at $ profit amount
   BE_ATR_DISTANCE    // Move after price moves X*ATR
};

// Trailing stop modes
enum TRAILING_MODE {
   TRAIL_NONE,        // Disabled
   TRAIL_FIXED_PIPS,  // Fixed pip distance
   TRAIL_ATR,         // ATR-based distance
   TRAIL_STEP_BASED   // Step-based trailing (every X pips profit)
};

// Partial profit modes
enum PARTIAL_MODE {
   PARTIAL_NONE,      // Disabled
   PARTIAL_FIXED_LEVELS  // Close % at fixed TP levels
};

// Strategy selection enum
enum STRATEGY_SELECTION {
   STRATEGY_VOLUME_HM,       // Volume + HM Divergence
   STRATEGY_MULTI_TIMEFRAME, // Multi-Timeframe Analysis
   STRATEGY_TURTLE_SOUP,     // Turtle Soup Reversal
   STRATEGY_VWAP,            // VWAP Mean Reversion
   STRATEGY_SMART_ENTRY      // Smart Entry Timing
};

//+------------------------------------------------------------------+
//| USER INPUTS                                                       |
//+------------------------------------------------------------------+

//--- Strategy Selection
input group "════════ STRATEGY SELECTION ════════"
input STRATEGY_SELECTION SelectedStrategy = STRATEGY_VOLUME_HM;  // Active Strategy

//--- Position Opening Settings
input group "════════ POSITION OPENING ════════"
sinput string s1="─── Lot Size Calculation ───";
input LOT_MODE LotCalculationMode = LOT_FIXED;      // Lot Calculation Method
input double   FixedLotSize       = 0.1;            // Fixed Lot Size
input double   RiskPercent        = 1.0;            // Risk % (for LOT_RISK_PERCENT mode)
input double   BalancePercent     = 2.0;            // Balance % (for LOT_BALANCE_PERCENT mode)
input int      ATR_Period_Lots    = 14;             // ATR Period (for LOT_ATR_BASED)
input double   ATR_Multiplier_Lots= 1.0;            // ATR Multiplier (for LOT_ATR_BASED)

sinput string s2="─── Stop Loss Calculation ───";
input SL_MODE  StopLossMode       = SL_ATR_MULTIPLE;   // Stop Loss Method
input int      FixedSL_Pips       = 50;             // Fixed SL (pips)
input double   ATR_Multiplier_SL  = 1.5;            // ATR Multiplier for SL
input int      ATR_Period_SL      = 14;             // ATR Period for SL
input double   Percent_SL         = 0.5;            // % of Price for SL

sinput string s3="─── Take Profit Calculation ───";
input TP_MODE  TakeProfitMode     = TP_RISK_REWARD; // Take Profit Method
input int      FixedTP_Pips       = 100;            // Fixed TP (pips)
input double   RiskRewardRatio    = 2.0;            // Risk:Reward Ratio
input double   ATR_Multiplier_TP  = 3.0;            // ATR Multiplier for TP
input int      ATR_Period_TP      = 14;             // ATR Period for TP

//--- Position Management Settings
input group "════════ POSITION MANAGEMENT ════════"
sinput string s4="─── Break-Even Settings ───";
input BREAKEVEN_MODE BreakEvenMode      = BE_HALF_TP;  // Break-Even Method
input double   BE_CustomPercent         = 50.0;     // % to TP (BE_CUSTOM_PERCENT)
input double   BE_CustomProfit          = 20.0;     // $ Profit (BE_CUSTOM_PROFIT)
input double   BE_ATR_Multi             = 1.0;      // ATR Multiple (BE_ATR_DISTANCE)
input int      BE_BufferPips            = 5;        // Pips above entry for BE

sinput string s5="─── Trailing Stop Settings ───";
input TRAILING_MODE TrailingMode        = TRAIL_NONE;  // Trailing Stop Method
input int      Trail_FixedPips          = 20;       // Pips distance (FIXED_PIPS)
input double   Trail_ATR_Multi          = 1.0;      // ATR Multiple (TRAIL_ATR)
input int      Trail_ATR_Period         = 14;       // ATR Period (TRAIL_ATR)
input int      Trail_StepSize           = 10;       // Pips per step (STEP_BASED)
input double   Trail_StartProfit        = 10.0;     // $ Profit to start trailing

sinput string s6="─── Partial Profit Taking ───";
input PARTIAL_MODE PartialProfitMode    = PARTIAL_NONE;  // Partial Profit Method
input double   Partial_Level1_Pips      = 30;       // Level 1 TP (pips)
input double   Partial_Level1_Percent   = 50.0;     // % to close at Level 1
input double   Partial_Level2_Pips      = 60;       // Level 2 TP (pips)
input double   Partial_Level2_Percent   = 30.0;     // % to close at Level 2

sinput string s7="─── Time-Based Exit ───";
input bool     UseMaxHoldingTime        = false;    // Enable Max Hold Time
input int      MaxHoldingHours          = 24;       // Max Hours to Hold
input bool     CloseFridayPositions     = true;     // Close on Friday
input int      FridayCloseHour          = 16;       // Hour to close on Friday

sinput string s8="─── Capital Protection ───";
input bool     UseMaxLossPerTrade       = false;    // Enable Max Loss per Trade
input double   MaxLossPerTrade          = 50.0;     // Max $ Loss per Trade
input bool     UseMaxDailyLoss          = false;    // Enable Daily Loss Limit
input double   MaxDailyLoss             = 100.0;    // Max $ Daily Loss

//--- Panel Display
input group "════════ DISPLAY SETTINGS ════════"
input bool     ShowPanel                = true;     // Show Info Panel
input int      PanelCorner              = 1;        // Panel Corner (0-3)
input int      PanelX                   = 10;       // Panel X Position
input int      PanelY                   = 20;       // Panel Y Position

//+------------------------------------------------------------------+
//| INDICATOR INPUTS (for strategies)                                |
//+------------------------------------------------------------------+
input group "════════ INDICATOR SETTINGS ════════"
input int      rsiPeriod              = 9;          // RSI Period
input int      emaPeriod              = 3;          // EMA Period (on RSI)
input int      wmaPeriod              = 21;         // WMA Period (on RSI)

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                  |
//+------------------------------------------------------------------+
int      atrHandle;
double   atrBuffer[];
double   gwma = 0, gema = 0, grsi = 0;  // For display
ulong    loggedDeals[];
int      fileHandle = 0;

//+------------------------------------------------------------------+
//| LEGACY STRUCTS (keep for existing strategies)                    |
//+------------------------------------------------------------------+
struct SlopeSettings {
   int rsiSlopeLength;
   int wmaSlopeLength;
   int emaSlopeLength;
};

struct ThresholdSettings {
   double rsiValueThreshold;
   double rsiSlopeThreshold;
   double wmaSlopeThreshold;
   double emaSlopeThreshold;
};

struct RsiRange {
   double buyMin;
   double buyMax;
   double sellMin;
   double sellMax;
};

struct BBAnalysisResult {
   double candleOpen[];
   double candleHigh[];
   double candleLow[];
   double candleClose[];
   double candleBody[];
   double upperWickLength[];
   double lowerWickLength[];

   double upperBand[];
   double middleBand[];
   double lowerBand[];
   double bbBandwidth[];

   bool isBullishCandle[];
   bool isBearishCandle[];
   bool lowerWickOutsideBand[];
   bool lowerWickLongerThanBody[];
   bool upperWickOutsideBand[];
   bool upperWickLongerThanBody[];
   bool hasSmallWicks[];

   bool isOpenInLowerZone[];
   bool isHighInLowerZone[];
   bool isLowInLowerZone[];
   bool isCloseInLowerZone[];
   bool isOpenInUpperZone[];
   bool isHighInUpperZone[];
   bool isLowInUpperZone[];
   bool isCloseInUpperZone[];

   bool isSqueeze[];
   bool isBlastUp[];
   bool isBlastDown[];
   bool isDojiOrNeutral[];

   double avgBandwidth;
};

struct MAAnalysisResult {
   double candleOpen[];
   double candleHigh[];
   double candleLow[];
   double candleClose[];
   double candleBody[];
   double upperWickLength[];
   double lowerWickLength[];

   double maValue[];

   bool isBullishCandle[];
   bool isBearishCandle[];
   bool isDojiOrNeutral[];

   bool closeAboveMA[];
   bool closeBelowMA[];
   bool openAboveMA[];
   bool openBelowMA[];

   bool isFullyAboveMA[];
   bool isFullyBelowMA[];
   bool isCrossingMA[];

   bool upperWickTouchesOrCrossesMA[];
   bool lowerWickTouchesOrCrossesMA[];

   bool hasLongUpperWickAboveMA[];
   bool hasLongLowerWickBelowMA[];

   bool isMASlopingUp[];
   bool isMASlopingDown[];
   bool isMASlopingFlat[];

   bool isBullishCrossover[];
   bool isBearishCrossover[];
   bool isPriceBreakingAboveMA[];
   bool isPriceBreakingBelowMA[];

   bool isMaintainingAboveMA[];
   bool isMaintainingBelowMA[];
   bool isCrossingFromAbove[];
   bool isCrossingFromBelow[];

   double avgMASlope;
};

struct HilegaMilegaAnalysisResult {
   double rsi;
   double wma;
   double ema;

   double rsiSlope;
   double wmaSlope;
   double emaSlope;

   double rsiBuf[];
   double wmaBuf[];
   double emaBuf[];

   bool isValid;
};

struct CrossConfirmationWindow {
   int rsiCrossIndex;
   int emaCrossIndex;
};

struct VWAP_SERIES {
   double vwapSeries[];
};

struct ImportantLevelsResult {
   double levels[];
   int count;
};

ImportantLevelsResult importantLevels;

struct VolumeInsights {
   bool   isClimax[];
   bool   isVolumeSpike[];
   bool   isBullishDivergence[];
   bool   isBearishDivergence[];
   bool   isVWAPConfluence[];
   bool   isAccumulating[];
   double obv[];
   double vwap[];
};

enum CROSS_TYPE { CROSS_FROM_BELOW, CROSS_FROM_ABOVE };

enum TRADE_DIRECTION { BUY, SELL, NA };
