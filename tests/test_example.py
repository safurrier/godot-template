from datetime import datetime
from src.example import DataPoint, calculate_moving_average

def test_moving_average():
    data = [
        DataPoint(datetime(2024, 1, 1), 1.0, "A"),
        DataPoint(datetime(2024, 1, 2), 2.0, "B"),
        DataPoint(datetime(2024, 1, 3), 3.0, "C"),
        DataPoint(datetime(2024, 1, 4), 4.0, "D"),
    ]
    
    result = calculate_moving_average(data, window_size=2)
    assert result == [1.0, 1.5, 2.5, 3.5]
