import statistics
from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class DataPoint:
    """Example data structure for time series data."""

    timestamp: datetime
    value: float
    label: Optional[str] = None


def calculate_moving_average(
    data: list[DataPoint], window_size: int = 3
) -> list[float]:
    """Calculate moving average of values.

    Args:
        data: List of DataPoint objects
        window_size: Size of moving window

    Returns:
        List of moving averages
    """
    values = [d.value for d in data]
    result = []

    for i in range(len(values)):
        window = values[max(0, i - window_size + 1) : i + 1]
        result.append(statistics.mean(window))

    return result
