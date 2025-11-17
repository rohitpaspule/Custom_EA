# How to Add a New Strategy

This guide shows you how to add a new trading strategy to the modular EA framework in just **3 simple steps**.

---

## Overview

The EA architecture separates concerns into 3 independent layers:

1. **Signal Generation (Strategy)** → Returns BUY/SELL/NA
2. **Position Opening** → User configures lot size, SL, TP
3. **Position Management** → User configures breakeven, trailing, partial profits

**You only need to implement Layer 1 (Strategy)**. Layers 2 and 3 are handled by the framework!

---

## Step 1: Create Your Strategy File

Create a new file in `/strategies/` folder (e.g., `my_awesome_strategy.mqh`):

```cpp
//+------------------------------------------------------------------+
//|                                    my_awesome_strategy.mqh       |
//|                          My Awesome Trading Strategy             |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property version   "1.00"

#include "../core/strategy_interface.mqh"
// Include any indicators you need
#include "../Indicators/bollinger_band.mqh"
#include "../Indicators/moving_average.mqh"

//+------------------------------------------------------------------+
//| My Awesome Strategy Class                                        |
//+------------------------------------------------------------------+
class MyAwesomeStrategy : public IStrategy {
public:
   // Constructor - Set strategy metadata
   MyAwesomeStrategy() {
      name = "My_Awesome";
      description = "Brief description of what your strategy does";
      version = "1.0";
      enabled = true;
   }

   // REQUIRED: Implement signal generation logic
   virtual StrategySignal GetSignal() override {
      StrategySignal signal;  // Default: NA (no signal)

      // ===== YOUR LOGIC HERE =====

      // Get indicator data
      // Example: BB, MA, RSI, etc.

      // BUY condition
      if(/* your buy conditions */) {
         signal.direction = BUY;
         signal.confidence = 80;  // Optional: 0-100
         signal.message = "My Awesome BUY signal";

         // Optional: Provide custom SL/TP/Lot (overrides user settings)
         // signal.hasCustomSL = true;
         // signal.customSL_Pips = 50;

         return signal;
      }

      // SELL condition
      if(/* your sell conditions */) {
         signal.direction = SELL;
         signal.confidence = 80;
         signal.message = "My Awesome SELL signal";
         return signal;
      }

      // No signal
      return signal;
   }

   // OPTIONAL: Initialize strategy (called once in OnInit)
   virtual bool OnInit() override {
      Print("   My Awesome Strategy initialized");
      return true;
   }

   // OPTIONAL: Get status for panel display
   virtual string GetStatus() override {
      return "Status: Active";
   }
};
```

---

## Step 2: Register Strategy in Strategy Manager

Open `/core/strategy_manager.mqh` and add:

### 2a. Add forward declaration (top of file):
```cpp
class MyAwesomeStrategy;  // Add this line
```

### 2b. Add case in `InitializeStrategy()` function:
```cpp
switch(SelectedStrategy) {
   // ... existing cases ...

   case STRATEGY_MY_AWESOME:  // Add this case
      activeStrategy = new MyAwesomeStrategy();
      break;

   // ... rest of cases ...
}
```

---

## Step 3: Add Strategy to Config

Open `/core/config.mqh` and add:

### 3a. Add to `STRATEGY_SELECTION` enum:
```cpp
enum STRATEGY_SELECTION {
   STRATEGY_VOLUME_HM,
   STRATEGY_MULTI_TIMEFRAME,
   STRATEGY_TURTLE_SOUP,
   STRATEGY_VWAP,
   STRATEGY_SMART_ENTRY,
   STRATEGY_MY_AWESOME      // Add this line
};
```

### 3b. Include your strategy file in `/core/process_engine.mqh`:
```cpp
// Include all strategy files
#include "../strategies/volume_hm_strategy.mqh"
#include "../strategies/multi_timeframe_strategy.mqh"
#include "../strategies/turtle_soup_strategy.mqh"
#include "../strategies/vwap_strategy.mqh"
#include "../strategies/smart_entry_strategy.mqh"
#include "../strategies/my_awesome_strategy.mqh"  // Add this line
```

---

## Done! 🎉

Your strategy is now available in the EA. Users can select it from the input parameter dropdown:

**Strategy Selection** → `My_Awesome`

---

## Advanced: Providing Custom SL/TP/Lot Size

If your strategy needs to override user settings for SL/TP/Lot:

```cpp
virtual StrategySignal GetSignal() override {
   StrategySignal signal;

   if(/* buy condition */) {
      signal.direction = BUY;

      // Custom stop loss (in pips)
      signal.hasCustomSL = true;
      signal.customSL_Pips = 100;  // 100 pips SL

      // Custom take profit (in pips)
      signal.hasCustomTP = true;
      signal.customTP_Pips = 200;  // 200 pips TP

      // Custom lot size
      signal.hasCustomLotSize = true;
      signal.customLotSize = 0.5;  // 0.5 lots
   }

   return signal;
}
```

If `hasCustom*` is `false`, the framework uses user settings from the EA inputs.

---

## Tips

1. **Keep it simple**: Your strategy only needs to return BUY/SELL/NA
2. **Use existing indicators**: Reuse indicators from `/Indicators/` folder
3. **Test independently**: Test your signal logic before integrating
4. **Add comments**: Explain your logic for future reference

---

## Example Strategies

See these files for complete examples:
- `/strategies/volume_hm_strategy.mqh` - Simple strategy
- `/strategies/multi_timeframe_strategy.mqh` - Multi-TF analysis
- `/strategies/turtle_soup_strategy.mqh` - Reversal strategy

---

**Questions?** Check the existing strategy implementations for guidance!
