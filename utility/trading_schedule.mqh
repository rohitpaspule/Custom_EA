//+------------------------------------------------------------------+
//|                                         trading_schedule.mqh     |
//|                              Trading Schedule Manager            |
//+------------------------------------------------------------------+
#property copyright "Custom EA Framework"
#property version   "1.00"

#include "../core/config.mqh"

//+------------------------------------------------------------------+
//| Check if current time is within allowed trading schedule         |
//+------------------------------------------------------------------+
bool IsTradingAllowed() {
   datetime currentTime = TimeCurrent();
   MqlDateTime timeStruct;
   TimeToStruct(currentTime, timeStruct);

   int dayOfWeek = timeStruct.day_of_week;  // Sunday=0, Monday=1, ..., Saturday=6
   int currentHour = timeStruct.hour;

   // Restrict trading on weekends and Friday afternoons
   if(IsWeekendOrFridayAfternoon(dayOfWeek, currentHour)) {
      return false;
   }

   // Check user-defined trading hours (if implemented in future)
   // For now, allow all weekday hours
   return true;
}

//+------------------------------------------------------------------+
//| Check if current time is weekend or Friday afternoon             |
//+------------------------------------------------------------------+
bool IsWeekendOrFridayAfternoon(int dayOfWeek, int hour) {
   // Sunday (0) - No trading
   if(dayOfWeek == 0) {
      return true;
   }

   // Saturday (6) - No trading
   if(dayOfWeek == 6) {
      return true;
   }

   // Friday (5) - No trading after 12 PM (noon)
   if(dayOfWeek == 5 && hour >= 12) {
      return true;
   }

   return false;  // Trading allowed
}

//+------------------------------------------------------------------+
//| Get trading schedule status as string (for panel display)        |
//+------------------------------------------------------------------+
string GetTradingScheduleStatus() {
   datetime currentTime = TimeCurrent();
   MqlDateTime timeStruct;
   TimeToStruct(currentTime, timeStruct);

   int dayOfWeek = timeStruct.day_of_week;
   int currentHour = timeStruct.hour;

   if(dayOfWeek == 0) return "Sunday - No Trading";
   if(dayOfWeek == 6) return "Saturday - No Trading";
   if(dayOfWeek == 5 && currentHour >= 12) return "Friday PM - No Trading";

   return "Trading Active";
}
