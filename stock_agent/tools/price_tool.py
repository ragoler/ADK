# NOTE: This tool requires the yfinance and pandas libraries.
# Install them using: pip install yfinance pandas
import yfinance as yf
import pandas as pd
from datetime import datetime

def get_stock_prices(tickers: list[str], start_date: str, end_date: str) -> dict:
    """
    Gets the closing stock prices for a list of tickers on a start and end date.

    Args:
        tickers: A list of stock ticker symbols (e.g., ['GOOGL', 'AAPL']).
        start_date: The start date in 'YYYY-MM-DD' format.
        end_date: The end date in 'YYYY-MM-DD' format (usually today).

    Returns:
        A dictionary where keys are ticker symbols and values are dictionaries
        containing the closing price for the start and end dates.
        Example: {'GOOGL': {'start_date_price': 150.0, 'end_date_price': 170.0}}
    """
    price_data = {}
    for ticker in tickers:
        try:
            stock = yf.Ticker(ticker)
            # Fetch data for a small window around dates to handle non-trading days
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            hist_start = stock.history(start=start_dt, end=start_dt + pd.Timedelta(days=5))

            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            hist_end = stock.history(start=end_dt, end=end_dt + pd.Timedelta(days=5))

            data = {}
            if not hist_start.empty:
                data['start_date_price'] = round(hist_start['Close'].iloc[0], 2)
            else:
                data['start_date_price'] = None

            if not hist_end.empty:
                data['end_date_price'] = round(hist_end['Close'].iloc[0], 2)
            else:
                data['end_date_price'] = None
            
            price_data[ticker] = data

        except Exception as e:
            price_data[ticker] = {"error": f"Could not retrieve data for {ticker}: {e}"}
    return price_data