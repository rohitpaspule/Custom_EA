//+------------------------------------------------------------------+
//|                                              info_panel.mqh      |
//|                              Compact Chart Information Panel     |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"
#include "../core/strategy_manager.mqh"

#define PANEL_NAME "EA_InfoPanel"

//+------------------------------------------------------------------+
//| Create compact info panel                                        |
//+------------------------------------------------------------------+
void CreatePanel() {
   if(!ShowPanel) return;

   int x = PanelX;
   int y = PanelY;
   int lineHeight = 16;
   int currentY = y;

   // Background
   CreateLabel(PANEL_NAME + "_BG", "", x - 5, y - 5, clrNONE, 10, CORNER_LEFT_UPPER, "");
   ObjectSetInteger(0, PANEL_NAME + "_BG", OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, PANEL_NAME + "_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, PANEL_NAME + "_BG", OBJPROP_CORNER, PanelCorner);
   ObjectSetInteger(0, PANEL_NAME + "_BG", OBJPROP_XSIZE, 250);
   ObjectSetInteger(0, PANEL_NAME + "_BG", OBJPROP_YSIZE, 140);

   // Title
   CreateLabel(PANEL_NAME + "_Title", "═══ EA STATUS ═══", x, currentY, clrGold, 9, PanelCorner, "Arial Bold");
   currentY += lineHeight + 3;

   // Strategy name
   CreateLabel(PANEL_NAME + "_Strategy", "Strategy: ", x, currentY, clrWhite, 8, PanelCorner);
   currentY += lineHeight;

   // Strategy status
   CreateLabel(PANEL_NAME + "_Status", "Status: ", x, currentY, clrSilver, 8, PanelCorner);
   currentY += lineHeight;

   // Position info
   CreateLabel(PANEL_NAME + "_Positions", "Positions: ", x, currentY, clrWhite, 8, PanelCorner);
   currentY += lineHeight;

   // Lot settings
   CreateLabel(PANEL_NAME + "_LotMode", "Lot Mode: ", x, currentY, clrSilver, 8, PanelCorner);
   currentY += lineHeight;

   // SL/TP settings
   CreateLabel(PANEL_NAME + "_SLTP", "SL/TP: ", x, currentY, clrSilver, 8, PanelCorner);
   currentY += lineHeight;

   // Position management
   CreateLabel(PANEL_NAME + "_PM", "Mgmt: ", x, currentY, clrSilver, 8, PanelCorner);
   currentY += lineHeight;

   // Account info
   CreateLabel(PANEL_NAME + "_Account", "Balance: ", x, currentY, clrLime, 8, PanelCorner);
}

//+------------------------------------------------------------------+
//| Update panel information                                          |
//+------------------------------------------------------------------+
void UpdatePanel() {
   if(!ShowPanel) return;

   // Strategy name
   string strategyName = GetActiveStrategyName();
   ObjectSetString(0, PANEL_NAME + "_Strategy", OBJPROP_TEXT,
                   "Strategy: " + strategyName);

   // Strategy status
   string strategyStatus = GetActiveStrategyStatus();
   ObjectSetString(0, PANEL_NAME + "_Status", OBJPROP_TEXT,
                   "Status: " + strategyStatus);

   // Positions
   int posCount = PositionsTotal();
   double totalProfit = 0;
   for(int i = 0; i < posCount; i++) {
      if(PositionSelectByTicket(PositionGetTicket(i))) {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol) {
            totalProfit += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }

   color profitColor = (totalProfit > 0) ? clrLime : (totalProfit < 0) ? clrRed : clrWhite;
   ObjectSetString(0, PANEL_NAME + "_Positions", OBJPROP_TEXT,
                   StringFormat("Positions: %d | P/L: $%.2f", posCount, totalProfit));
   ObjectSetInteger(0, PANEL_NAME + "_Positions", OBJPROP_COLOR, profitColor);

   // Lot mode
   string lotMode = EnumToString(LotCalculationMode);
   StringReplace(lotMode, "LOT_MODE_", "");
   if(LotCalculationMode == LOT_FIXED) {
      lotMode += StringFormat(" (%.2f)", FixedLotSize);
   } else if(LotCalculationMode == LOT_RISK_PERCENT) {
      lotMode += StringFormat(" (%.1f%%)", RiskPercent);
   }
   ObjectSetString(0, PANEL_NAME + "_LotMode", OBJPROP_TEXT, "Lot: " + lotMode);

   // SL/TP modes
   string slMode = EnumToString(StopLossMode);
   StringReplace(slMode, "SL_MODE_", "");
   string tpMode = EnumToString(TakeProfitMode);
   StringReplace(tpMode, "TP_MODE_", "");
   ObjectSetString(0, PANEL_NAME + "_SLTP", OBJPROP_TEXT,
                   StringFormat("SL: %s | TP: %s", slMode, tpMode));

   // Position management
   string pmStatus = "";
   if(BreakEvenMode != BE_NONE) pmStatus += "BE ";
   if(TrailingMode != TRAIL_NONE) pmStatus += "TRAIL ";
   if(PartialProfitMode != PARTIAL_NONE) pmStatus += "PARTIAL ";
   if(pmStatus == "") pmStatus = "None";
   ObjectSetString(0, PANEL_NAME + "_PM", OBJPROP_TEXT, "Mgmt: " + pmStatus);

   // Account balance
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   ObjectSetString(0, PANEL_NAME + "_Account", OBJPROP_TEXT,
                   StringFormat("Balance: $%.2f | Equity: $%.2f", balance, equity));
}

//+------------------------------------------------------------------+
//| Delete panel                                                      |
//+------------------------------------------------------------------+
void DeletePanel() {
   ObjectsDeleteAll(0, PANEL_NAME);
}

//+------------------------------------------------------------------+
//| Helper: Create label                                             |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr, int fontSize,
                 int corner, string font = "Arial") {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
}
