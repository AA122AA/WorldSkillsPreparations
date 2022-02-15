from datetime import datetime

timestamp = datetime.strptime("05-10-2018", "%m-%d-%Y")
print("timestamp =", timestamp.timestamp())
