# Arbitrage Price Discrepancy Alert — MQL4 Script

A MetaTrader 4 script that monitors **real-time bid/ask price discrepancies** between two correlated instruments and automatically executes simultaneous offsetting buy and sell orders when the cross-instrument spread exceeds a configurable threshold — implementing a two-leg arbitrage workflow with instrument availability validation, direction-aware execution, and a high-frequency 100ms polling loop for low-latency opportunity capture.

---

## Overview

Statistical arbitrage exploits transient pricing inefficiencies between correlated instruments — moments when the ask price of one instrument falls below the bid price of another, creating a theoretically risk-free profit window before the market corrects. In practice on MT4, such windows are measured in milliseconds and are heavily impacted by execution slippage, spread, and broker requote policies. This script provides a framework for monitoring and acting on these discrepancies: it validates both instruments on startup via `CheckInstrument()`, enters a high-frequency monitoring loop polling bid and ask prices via `MarketInfo()` every 100ms, evaluates both directional spread combinations simultaneously, and when `EnableHedge = true` dispatches simultaneous `OP_BUY` and `OP_SELL` orders across both instruments via `ExecuteTrade()` — capturing the discrepancy before the market closes it.

> **Note on file naming:** This file is distributed as `Heatmap_001.mq4` but implements a two-instrument arbitrage trading script. The README documents the actual implemented logic.

---

## Features

- **`CheckInstrument()` startup validation** — calls `MarketInfo(instrument, MODE_BID) <= 0` for both instruments before entering the loop; aborts with a descriptive log message if either symbol is unavailable in Market Watch
- **Dual-direction discrepancy detection** — evaluates `(ask1 − bid2) > Threshold` (buy Instrument2, sell Instrument1) AND `(ask2 − bid1) > Threshold` (buy Instrument1, sell Instrument2) each cycle
- **`ExecuteTrade()` simultaneous dual-leg dispatch** — fetches current bid/ask via `MarketInfo(MODE_ASK)` / `MarketInfo(MODE_BID)`, normalizes prices via `NormalizeDouble()` with `MODE_DIGITS`, and dispatches both `OrderSend()` calls with configurable slippage
- **`EnableHedge` flag** — when `true`, both legs of the arbitrage execute; when `false`, only the alert/log fires and no orders are placed, enabling monitoring-only mode
- **High-frequency loop** — polls every 100ms (`Sleep(100)`) rather than the standard 60 seconds used in alert scripts, significantly improving discrepancy detection latency
- **Per-order error reporting** — `OrderSend()` return value checked; failures print `GetLastError()` code and price to the Experts tab for each individual leg
- All discrepancy detections and trade results logged to the MT4 **Experts** tab

---

## How It Works

1. `CheckInstrument()` validates both symbols; aborts if either returns `MODE_BID <= 0`
2. Every 100ms, live bid/ask fetched for both instruments via `MarketInfo(MODE_BID)` and `MarketInfo(MODE_ASK)`
3. Two spread conditions evaluated:
   - `ask1 − bid2 > Threshold` → Buy Instrument2, Sell Instrument1
   - `ask2 − bid1 > Threshold` → Buy Instrument1, Sell Instrument2
4. If `EnableHedge = true`, `ExecuteTrade()` dispatches `OrderSend()` for both legs with `NormalizeDouble()` pricing

---

## Input Parameters

| Parameter     | Type   | Default  | Description                                                   |
|---------------|--------|----------|---------------------------------------------------------------|
| `Instrument1` | string | `EURUSD` | First instrument symbol                                       |
| `Instrument2` | string | `GBPUSD` | Second instrument symbol                                      |
| `Threshold`   | double | `0.0002` | Minimum bid/ask spread discrepancy to trigger arbitrage       |
| `LotSize`     | double | `0.1`    | Lot size for each leg of the arbitrage trade                  |
| `Slippage`    | double | `3.0`    | Maximum slippage in points for order execution                |
| `EnableHedge` | bool   | `true`   | Execute both arbitrage legs; false = monitoring only          |

---

## Installation

1. Copy `Heatmap_001.mq4` to `MQL4/Scripts/` in your MT4 data folder
2. Compile in MetaEditor (F7)
3. Drag onto any chart from Navigator → Scripts
4. Configure inputs and click **OK**

> **Warning:** This script places real orders. Always test on a **demo account** first. True arbitrage requires a DMA broker with minimal latency; slippage and requotes will erode or eliminate the profit window on standard retail accounts.

---

## Requirements

- MetaTrader 4 (`#property strict` compatible build)
- MQL4 compiler (MetaEditor)
- Both instruments available and streaming in Market Watch

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
