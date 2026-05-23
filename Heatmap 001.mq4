//+------------------------------------------------------------------+
//|                       ArbitrageTrading.mq4                       |
//|  Detects price discrepancies for arbitrage opportunities         |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input string Instrument1 = "EURUSD";     // First instrument
input string Instrument2 = "GBPUSD";     // Second instrument
input double Threshold = 0.0002;         // Minimum price difference to trigger arbitrage
input double LotSize = 0.1;              // Lot size for trades
input double Slippage = 3;               // Slippage in points for orders
input bool EnableHedge = true;           // Enable hedging on discrepancies

//+------------------------------------------------------------------+
//| Main Function                                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("Arbitrage Trading Script Started.");

   // Validate instruments
   if (!CheckInstrument(Instrument1) || !CheckInstrument(Instrument2)) {
      Print("Invalid instruments. Ensure both symbols are available.");
      return;
   }

   // Monitor price discrepancies
   while (!IsStopped()) {
      double bid1 = MarketInfo(Instrument1, MODE_BID);
      double ask1 = MarketInfo(Instrument1, MODE_ASK);
      double bid2 = MarketInfo(Instrument2, MODE_BID);
      double ask2 = MarketInfo(Instrument2, MODE_ASK);

      // Check for arbitrage opportunities
      if ((ask1 - bid2) > Threshold) {
         Print("Arbitrage Opportunity: Buy ", Instrument2, " and Sell ", Instrument1);
         ExecuteTrade(Instrument2, OP_BUY, LotSize);
         ExecuteTrade(Instrument1, OP_SELL, LotSize);
      } else if ((ask2 - bid1) > Threshold) {
         Print("Arbitrage Opportunity: Buy ", Instrument1, " and Sell ", Instrument2);
         ExecuteTrade(Instrument1, OP_BUY, LotSize);
         ExecuteTrade(Instrument2, OP_SELL, LotSize);
      }

      Sleep(100); // Reduce CPU usage
   }
}

//+------------------------------------------------------------------+
//| Check if the instrument is available                            |
//+------------------------------------------------------------------+
bool CheckInstrument(string instrument)
{
   if (MarketInfo(instrument, MODE_BID) <= 0) {
      Print("Instrument not available: ", instrument);
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Execute a trade                                                 |
//+------------------------------------------------------------------+
void ExecuteTrade(string instrument, int orderType, double lotSize)
{
   double price = (orderType == OP_BUY) 
                  ? MarketInfo(instrument, MODE_ASK) 
                  : MarketInfo(instrument, MODE_BID);
   price = NormalizeDouble(price, MarketInfo(instrument, MODE_DIGITS)); // Ensure precision

   int ticket = OrderSend(
      instrument,          // Symbol
      orderType,           // Order type (OP_BUY or OP_SELL)
      lotSize,             // Lot size
      price,               // Price
      (int)Slippage,       // Slippage (explicit casting to int)
      0,                   // Stop Loss (optional)
      0,                   // Take Profit (optional)
      "Arbitrage Trade",   // Comment
      0,                   // Magic number
      0,                   // Expiration
      clrBlue              // Color
   );

   if (ticket < 0) {
      Print("Trade failed for ", instrument, ". Error: ", GetLastError());
   } else {
      Print("Trade executed. Ticket: ", ticket, " | Instrument: ", instrument);
   }
}

