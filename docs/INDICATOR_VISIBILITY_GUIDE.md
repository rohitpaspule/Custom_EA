# Indicator Visibility Control in Strategy Tester

## Quick Guide

This EA has a built-in setting to control whether indicators (RSI, Bollinger Bands, ATR, etc.) are displayed on the chart during Strategy Tester visualization.

---

## How to Control Indicator Visibility

### Step 1: Open EA Settings
When you attach the EA to a chart or run it in the Strategy Tester:
1. Go to the **"DISPLAY SETTINGS"** section in the EA inputs
2. Find the parameter: **"Show Indicators on Chart"**

### Step 2: Choose Your Preference

**Option A: Hide Indicators (Default - Recommended)**
```
Show Indicators on Chart = false
```
- ✅ Clean chart with only price action
- ✅ No indicator clutter during backtesting
- ✅ Faster visual processing
- ✅ EA still uses all indicators internally for calculations

**Option B: Show Indicators**
```
Show Indicators on Chart = true
```
- ✅ All indicators visible on chart
- ✅ Useful for debugging strategy logic
- ✅ See RSI, Bollinger Bands, ATR, etc. in real-time
- ⚠️ May clutter the chart during visualization

---

## Where to Find This Setting

### In MetaTrader 5 Strategy Tester:
1. Open Strategy Tester (Ctrl + R)
2. Select "ModularStrategyEA" as the Expert
3. Click "Settings" button (or press F7)
4. Navigate to **"DISPLAY SETTINGS"** section
5. Find **"Show Indicators on Chart"** checkbox
6. Set to `false` to hide or `true` to show
7. Click OK

### When Attaching to Live Chart:
1. Drag EA to chart
2. In the popup window, go to "Inputs" tab
3. Scroll to **"DISPLAY SETTINGS"** section
4. Change **"Show Indicators on Chart"** as needed

---

## Technical Details

The EA uses the MQL5 built-in function `TesterHideIndicators()` which:
- Must be called BEFORE creating any indicator handles
- Is called automatically at EA initialization
- Controls ALL indicators created by the EA
- Does NOT affect EA calculations (indicators still work internally)

**Code reference:** `core/init_deinit.mqh` line 23
```cpp
TesterHideIndicators(!ShowIndicatorsOnChart);
```

---

## Verification

To verify the setting is working:

1. **Check the Experts log** when EA initializes:
   - If `Show Indicators on Chart = false`, you'll see:
     ```
     ✅ Strategy Tester: Indicators will be hidden on chart
     ```
   - If `Show Indicators on Chart = true`, you'll see:
     ```
     ✅ Strategy Tester: Indicators will be visible on chart
     ```

2. **Visual confirmation** in Strategy Tester:
   - Start visual backtesting
   - If setting is `false`: Chart shows only price candles (no indicator windows)
   - If setting is `true`: Chart shows RSI sub-window, ATR sub-window, BB on main chart

---

## Troubleshooting

### "I changed the setting but still see indicators"

**Solution 1: Recompile the EA**
1. Open MetaEditor (F4)
2. Open `ModularStrategyEA.mq5`
3. Click Compile (F7)
4. Go back to MT5 and reload the EA

**Solution 2: Restart Strategy Tester**
1. Close Strategy Tester
2. Reopen it (Ctrl + R)
3. Reselect the EA
4. Check settings again

**Solution 3: Check Input Value**
1. Press F7 in Strategy Tester
2. Go to Inputs tab
3. Verify **"Show Indicators on Chart"** is set to desired value
4. Make sure you clicked OK (not Cancel)

### "I want to see ONLY specific indicators"

Currently, it's all-or-nothing. The setting controls all indicators.

For granular control, you would need to modify `core/init_deinit.mqh` and call `TesterHideIndicators()` selectively before creating specific indicator handles.

---

## Default Behavior

By default, **ShowIndicatorsOnChart = false**, meaning:
- Indicators are HIDDEN in Strategy Tester
- Clean chart visualization
- Professional backtest reports
- No visual clutter

This is the recommended setting for most users.

---

## Related Settings

In the same **"DISPLAY SETTINGS"** section, you'll also find:
- `Show Info Panel` - Displays EA status panel on chart
- `Panel Corner` - Position of info panel (0-3)
- `Panel X/Y Position` - Fine-tune panel placement

---

## Summary

| Setting | Effect | Use Case |
|---------|--------|----------|
| **false** (default) | Indicators hidden | Clean backtesting, strategy analysis |
| **true** | Indicators visible | Debugging, learning strategy logic |

**Recommendation:** Keep it at `false` for cleaner charts. Only enable when you need to see how indicators behave.
