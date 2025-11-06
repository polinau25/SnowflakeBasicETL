import json
import random
import datetime
from datetime import timedelta

initial_date = datetime.date(2023, 1, 15)

for i in range(5):
     fasting_glucose = round(random.uniform(80, 100), 2)
     hemoglobinA1c = round(random.uniform(3, 5.7), 2)
     tsh = round(random.uniform(0.3, 4.6), 3)
     # Specify the filename for the JSON output
     output_filename = "output_data" + str(i) + ".json"
     current_date = initial_date + timedelta(days=10*i)
     # Prepare the data as a Python dictionary or list
     data = {
            "date": current_date.isoformat(),
            "tests": [
                {
                    "type": "fasting_glucose",
                    "value": fasting_glucose
                },
                {
                    "type": "hemoglobinA1c",
                    "value": hemoglobinA1c
                },
                {
                    "type": "tsh",
                    "value": tsh
                }
            ]
     }
     # 3. Write the data to the JSON file
     with open(output_filename, 'w') as json_file:
        json.dump(data, json_file, indent=4)