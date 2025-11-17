# Modular Strategy EA - Universal Trading Framework for MT5

**Version 2.0** - The only EA you'll ever need for strategy development and testing.

[![MQL5](https://img.shields.io/badge/MQL5-Framework-blue)]()
[![Version](https://img.shields.io/badge/version-2.0-green)]()
[![License](https://img.shields.io/badge/license-Custom-orange)]()

---

## 🎯 Overview

**Modular Strategy EA** is a revolutionary MetaTrader 5 Expert Advisor framework that separates trading into three independent, configurable layers:

1. **Strategy Layer** - What signals to trade (BUY/SELL/NA)
2. **Position Opening** - How to open trades (lot size, SL, TP)
3. **Position Management** - How to manage trades (break-even, trailing, partials)

This architecture allows you to:
- ✅ Switch between strategies with a dropdown menu
- ✅ Test different risk management approaches without changing strategy code
- ✅ Add new strategies in just 3 simple steps
- ✅ Mix and match any strategy with any risk settings

---

## ✨ Key Features

### 🎲 Multiple Built-In Strategies
- **Volume_HM** - Volume divergence with Hilega-Milega indicators
- **Multi_Timeframe** - RSI/EMA/WMA analysis across M12/H1/H4
- **Turtle_Soup** - False breakout reversal strategy
- **VWAP** - Volume-Weighted Average Price mean reversion
- **Smart_Entry** - Multi-confirmation entry timing

### 💰 Flexible Position Opening (5 Lot Modes)
- Fixed lot size
- % of balance at risk (based on SL distance)
- % of balance as position size
- ATR-based sizing (inverse volatility)
- Strategy-defined (let strategy decide)

### 🎯 Smart Stop Loss (6 Modes)
- Fixed pips
- ATR multiple (dynamic)
- % of entry price
- Bollinger Band width
- Strategy-defined
- None (no SL)

### 🎖️ Intelligent Take Profit (6 Modes)
- Fixed pips
- Risk:Reward ratio (e.g., 1:2)
- ATR multiple
- Mirror SL (same distance)
- Strategy-defined
- None (no TP)

### 🛡️ Advanced Position Management
- **Break-Even**: Move SL to entry at 50% TP, custom %, $ profit, or ATR distance
- **Trailing Stop**: Fixed pips, ATR-based, or step-based trailing
- **Partial Profits**: Close % of position at defined TP levels
- **Time-Based Exits**: Max holding time, Friday close
- **Capital Protection**: Max loss per trade, daily loss limits

### 📊 Real-Time Info Panel
- Compact 250x140px panel on chart
- Shows strategy status, P/L, active settings
- Color-coded profit/loss display
- Customizable position and corner

---

## 🚀 Quick Start

### Installation

1. **Copy EA to MT5**
   ```
   Copy /Custom_EA/ folder to:
   C:\Users\[YourName]\AppData\Roaming\MetaQuotes\Terminal\[Instance]\MQL5\Experts\
   ```

2. **Compile EA**
   - Open MetaEditor (F4 in MT5)
   - Navigate to `Experts/Custom_EA/ModularStrategyEA.mq5`
   - Click Compile (F7)

3. **Attach to Chart**
   - Drag `ModularStrategyEA` onto desired chart
   - Configure settings (see below)
   - Enable AutoTrading

### Basic Configuration

**Step 1: Select Strategy**
```
Strategy Selection → Volume_HM (or your preferred strategy)
```

**Step 2: Configure Position Opening**
```
Lot Calculation Method → FIXED_LOT or RISK_PERCENT
Fixed Lot Size → 0.1

Stop Loss Method → ATR_MULTIPLE
ATR Multiplier for SL → 1.5

Take Profit Method → TP_RISK_REWARD
Risk:Reward Ratio → 2.0
```

**Step 3: Enable Position Management (Optional)**
```
Break-Even Method → BE_HALF_TP
Trailing Stop Method → TRAIL_NONE (or TRAIL_ATR)
Partial Profit Method → PARTIAL_NONE
```

**Step 4: Set Display**
```
Show Info Panel → true
Panel Corner → 1 (Top Right)
```

---

## 📁 Project Structure

```
Custom_EA/
├── ModularStrategyEA.mq5        # Main EA file (compile this)
├── README.md                     # This file
│
├── core/                         # Core framework
│   ├── config.mqh                # User inputs & configuration
│   ├── strategy_interface.mqh    # Base strategy interface
│   ├── strategy_manager.mqh      # Strategy selection & management
│   ├── process_engine.mqh        # Main execution engine
│   └── init_deinit.mqh           # Initialization & cleanup
│
├── strategies/                   # Trading strategies (Layer 1)
│   ├── volume_hm_strategy.mqh
│   ├── multi_timeframe_strategy.mqh
│   ├── turtle_soup_strategy.mqh
│   ├── vwap_strategy.mqh
│   └── smart_entry_strategy.mqh
│
├── position_opening/             # Position opening (Layer 2)
│   ├── lot_calculator.mqh
│   ├── sl_calculator.mqh
│   ├── tp_calculator.mqh
│   └── position_opener.mqh
│
├── position_management/          # Position management (Layer 3)
│   ├── breakeven_manager.mqh
│   ├── trailing_manager.mqh
│   ├── partial_profit_manager.mqh
│   ├── time_exit_manager.mqh
│   ├── capital_protection.mqh
│   └── position_manager_master.mqh
│
├── Indicators/                   # Reusable technical indicators
│   ├── bollinger_band.mqh
│   ├── hilega_milega.mqh
│   ├── moving_average.mqh
│   ├── vwap.mqh
│   └── volume_insights.mqh
│
├── utility/                      # Utility functions
│   ├── info_panel.mqh            # Chart panel display
│   ├── trading_schedule.mqh      # Trading hours management
│   └── utility.mqh               # Helper functions
│
├── logging/                      # Deal tracking & logging
│   ├── deal_tracker.mqh
│   └── logging_helpers.mqh
│
└── docs/                         # Documentation
    ├── ARCHITECTURE.md           # System architecture overview
    ├── ADDING_NEW_STRATEGY.md    # How to add strategies
    └── WHATS_NEW_V2.md          # Version 2.0 changelog
```

---

## 🎓 For Strategy Developers

### Adding Your Own Strategy (3 Simple Steps)

**Step 1: Create Strategy File**

Create `/strategies/my_strategy.mqh`:

```cpp
#include "../core/strategy_interface.mqh"

class MyStrategy : public IStrategy {
public:
   MyStrategy() {
      name = "My_Strategy";
      description = "What my strategy does";
      enabled = true;
   }

   virtual StrategySignal GetSignal() override {
      StrategySignal signal;

      // Your logic here
      if(buyCondition) {
         signal.direction = BUY;
         signal.message = "My buy signal";
      }
      else if(sellCondition) {
         signal.direction = SELL;
         signal.message = "My sell signal";
      }

      return signal;
   }
};
```

**Step 2: Register in Strategy Manager**

Edit `/core/strategy_manager.mqh`:
```cpp
// Add forward declaration
class MyStrategy;

// Add case in InitializeStrategy()
case STRATEGY_MY_STRATEGY:
   activeStrategy = new MyStrategy();
   break;
```

**Step 3: Add to Config**

Edit `/core/config.mqh`:
```cpp
enum STRATEGY_SELECTION {
   // ... existing strategies ...
   STRATEGY_MY_STRATEGY  // Add this
};
```

**Done!** Your strategy now appears in the EA dropdown menu.

See `docs/ADDING_NEW_STRATEGY.md` for detailed guide.

---

## 📖 Documentation

- **[Architecture Overview](docs/ARCHITECTURE.md)** - Understanding the 3-layer design
- **[Adding Strategies](docs/ADDING_NEW_STRATEGY.md)** - Step-by-step developer guide
- **[What's New in V2](docs/WHATS_NEW_V2.md)** - Version 2.0 changelog

---

## 🎛️ Configuration Examples

### Conservative Scalping
```
Strategy: Volume_HM
Lot Mode: RISK_PERCENT (1%)
SL Mode: FIXED_PIPS (20 pips)
TP Mode: TP_RISK_REWARD (1:1.5)
Break-Even: BE_HALF_TP
Trailing: TRAIL_FIXED_PIPS (10 pips)
```

### Aggressive Swing Trading
```
Strategy: Multi_Timeframe
Lot Mode: FIXED_LOT (0.2)
SL Mode: ATR_MULTIPLE (2.0x)
TP Mode: TP_ATR_MULTIPLE (4.0x)
Break-Even: BE_ATR_DISTANCE (1.0x)
Partial: Level1 50% @ 30 pips, Level2 30% @ 60 pips
```

### Conservative Position Trading
```
Strategy: VWAP
Lot Mode: BALANCE_PERCENT (1%)
SL Mode: BB_WIDTH
TP Mode: TP_MIRROR_SL
Break-Even: BE_CUSTOM_PROFIT ($20)
Time Exit: Max 48 hours
```

---

## ⚠️ Important Notes

### Trading Schedule
- **No trading:** Sundays, Saturdays
- **No trading:** Fridays after 12:00 PM
- **Trading allowed:** Monday-Friday before noon
- Schedule can be customized in `/utility/trading_schedule.mqh`

### Position Limits
- Only **1 position** open at a time (single strategy mode)
- Each new signal requires previous position to be closed
- Multi-strategy mode (multiple simultaneous positions) planned for future

### Timer-Based Execution
- EA runs on **60-second timer** (not every tick)
- More efficient than tick-based execution
- Reduces server load and slippage

---

## 🐛 Troubleshooting

### EA not trading?
1. Check AutoTrading is enabled (green button in toolbar)
2. Verify it's not weekend/Friday afternoon
3. Check Experts log for error messages
4. Ensure strategy is selected in inputs

### Positions not opening?
1. Check account has sufficient margin
2. Verify lot size is within broker limits
3. Check SL/TP are valid distances from entry
4. Review strategy logic in log

### Panel not showing?
1. Ensure "Show Panel" is true
2. Try different Panel Corner (0-3)
3. Check if panel is outside visible area

---

## 📊 Performance Tips

1. **Backtest First** - Always backtest strategies before live trading
2. **Demo Account** - Test new configurations on demo
3. **Risk Management** - Start with small lot sizes
4. **Monitor Logs** - Check Experts log regularly
5. **One Strategy** - Master one strategy before switching

---

## 🔮 Roadmap

- [ ] Multi-strategy concurrent execution
- [ ] Strategy performance tracking & analytics
- [ ] Web dashboard for remote monitoring
- [ ] Machine learning strategy optimization
- [ ] Additional position management modules
- [ ] Advanced indicator library expansion

---

## 📄 License

Custom EA Framework - Proprietary

---

## 🙏 Support

- **Documentation**: See `/docs/` folder
- **Issues**: Check existing strategies for examples
- **Updates**: Pull latest version from repository

---

## 🏆 Credits

Developed with a vision for modular, maintainable, and extensible trading automation.

**Version 2.0** - *The Ultimate Modular EA Framework*

---

**Happy Trading! 📈**
