# EA Architecture Overview

## 🏗️ 3-Layer Modular Design

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: SIGNAL GENERATION (Your Strategy)                 │
│  • Returns: BUY / SELL / NA                                  │
│  • Only focuses on: "Should I trade?"                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  LAYER 2: POSITION OPENING (User Configurable)              │
│  • Lot Calculator: Fixed, % Risk, ATR-based, etc.           │
│  • SL Calculator: Fixed pips, ATR, BB width, etc.           │
│  • TP Calculator: Fixed pips, R:R ratio, ATR, etc.          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  LAYER 3: POSITION MANAGEMENT (User Configurable)           │
│  • Break-Even: At 50% TP, custom %, ATR distance            │
│  • Trailing Stop: Fixed pips, ATR-based, step-based         │
│  • Partial Profits: Close % at levels                       │
│  • Time Exits: Max hold time, Friday close                  │
│  • Capital Protection: Max loss limits                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Directory Structure

```
Custom_EA/
├── Custom_MTF_Analyzer.mq5          # Main EA entry point
│
├── core/                             # Core framework
│   ├── config.mqh                    # User inputs & enums
│   ├── strategy_interface.mqh        # Base strategy class
│   ├── strategy_manager.mqh          # Strategy selection
│   ├── process_engine.mqh            # Main execution loop
│   └── init_deinit.mqh               # Initialization
│
├── strategies/                       # Trading strategies (Layer 1)
│   ├── volume_hm_strategy.mqh        # Volume + HM strategy
│   ├── multi_timeframe_strategy.mqh  # Multi-TF analysis
│   ├── turtle_soup_strategy.mqh      # Turtle soup reversal
│   ├── vwap_strategy.mqh             # VWAP mean reversion
│   └── smart_entry_strategy.mqh      # Smart entry timing
│
├── position_opening/                 # Layer 2 modules
│   ├── lot_calculator.mqh            # Lot sizing
│   ├── sl_calculator.mqh             # Stop loss calculation
│   ├── tp_calculator.mqh             # Take profit calculation
│   └── position_opener.mqh           # Coordinates opening
│
├── position_management/              # Layer 3 modules
│   ├── breakeven_manager.mqh         # Break-even logic
│   ├── trailing_manager.mqh          # Trailing stops
│   ├── partial_profit_manager.mqh    # Partial profit taking
│   ├── time_exit_manager.mqh         # Time-based exits
│   ├── capital_protection.mqh        # Risk limits
│   └── position_manager_master.mqh   # Coordinates all managers
│
├── Indicators/                       # Reusable indicators
│   ├── bollinger_band.mqh
│   ├── hilega_milega.mqh
│   ├── moving_average.mqh
│   ├── vwap.mqh
│   └── volume_insights.mqh
│
├── utility/                          # Utility functions
│   ├── info_panel.mqh                # Chart panel display
│   └── utility.mqh                   # Helper functions
│
├── logging/                          # Deal tracking & logging
│   ├── deal_tracker.mqh
│   └── logging_helpers.mqh
│
├── timeframe_settings/               # Timeframe configurations
│   └── timeframe_settings.mqh
│
├── trade_logic/                      # Legacy trade routing
│   └── trade_logic.mqh
│
└── docs/                             # Documentation
    ├── ARCHITECTURE.md               # This file
    └── ADDING_NEW_STRATEGY.md        # Strategy dev guide
```

---

## 🔄 Execution Flow

### OnInit()
```
1. Initialize logging
2. Set timer (60 seconds)
3. Initialize ATR indicator
4. Initialize selected strategy
5. Create info panel
```

### OnTimer() (Every 60 seconds)
```
1. Track closed deals (logging)
2. Manage open positions:
   • Capital protection
   • Time-based exits
   • Break-even
   • Trailing stops
   • Partial profits
3. Update info panel
4. If no positions open:
   • Get signal from strategy
   • If signal valid → Open position
```

### OnDeinit()
```
1. Kill timer
2. Release indicators
3. Close log files
4. Deinitialize strategy
5. Delete panel
```

---

## 🎯 Key Design Principles

1. **Separation of Concerns**
   - Strategies only generate signals
   - Position opening is user-configurable
   - Position management is modular

2. **Plug-and-Play Strategies**
   - Add new strategy in 3 steps
   - No need to modify core framework
   - Strategies are independent

3. **User-Friendly Configuration**
   - Dropdown menus for all settings
   - Clear parameter descriptions
   - Grouped inputs for organization

4. **Extensibility**
   - Easy to add new lot calculation methods
   - Easy to add new SL/TP modes
   - Easy to add new position management modules

5. **Future-Proof**
   - Architecture supports multi-strategy (not yet implemented)
   - Can add strategy weighting/voting
   - Can add per-strategy risk profiles

---

## 🔌 Adding New Components

### Add New Lot Calculation Method
1. Add enum to `LOT_MODE` in `config.mqh`
2. Add case in `CalculateLotSize()` in `lot_calculator.mqh`
3. Add input parameters to `config.mqh`

### Add New SL Calculation Method
1. Add enum to `SL_MODE` in `config.mqh`
2. Add case in `CalculateStopLoss()` in `sl_calculator.mqh`
3. Add input parameters to `config.mqh`

### Add New Position Management Module
1. Create `new_module_manager.mqh` in `position_management/`
2. Include in `position_manager_master.mqh`
3. Call in `ManageOpenPositions()` function
4. Add enum and inputs to `config.mqh`

---

## 📊 User Input Organization

Inputs are organized into clear groups:

1. **Strategy Selection** - Which strategy to use
2. **Position Opening** - Lot, SL, TP settings
3. **Position Management** - BE, Trailing, Partial, Time, Capital
4. **Display Settings** - Panel configuration
5. **Indicator Settings** - Shared indicator parameters

---

## 🚀 Benefits

✅ **For Strategy Developers:**
- Focus only on signal generation
- Reuse existing indicators
- Add strategy in 3 simple steps

✅ **For Users:**
- Mix and match strategies with risk settings
- Test different position management approaches
- Easy-to-understand parameters

✅ **For Maintainability:**
- Modular code, easy to debug
- Clear separation of responsibilities
- Extensible architecture
