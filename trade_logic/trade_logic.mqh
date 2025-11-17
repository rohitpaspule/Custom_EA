#include "../strategy/multi_timeframe_analysis.mqh"
#include "../strategy/turtle_soup.mqh"
#include "../strategy/smart_entry_signal.mqh"
#include "../strategy/vwap_testing.mqh"
#include "../strategy/volume_hm.mqh"


TRADE_DIRECTION tradeDirection() {

   TRADE_DIRECTION direction  = Volume_HM();//turtle_soup();//multi_timeframe_analysis();
       if (direction == BUY) {
           return BUY;
       }
       if (direction == SELL) {
           return SELL;
       }
       return NA;
}

