# Nginx log analyser

# -----------
# | Imports |
# -----------
import os

# -------------
# | Variables |
# -------------

# logs file path
logs_file = os.path.join(os.getcwd(), "nginx-access.log")

# logs file mapped dict
logs_dict={}

# -------------
# | Functions |
# -------------

# Function to save the log file into a dictionnary to the futures manipulations
def save_logs_to_dict():

    try:
        if os.path.exists(logs_file):
            with open(logs_file, "r") as logs:
                for line in logs:

                    line_elements = line.split('"') # We split every log file line with '"' to have a tab

                    lid = len(logs_dict)+1
                    while str(lid) in logs_dict: # This to verify that 2 line don't have the same id
                        lid+=1
                    ip_address = line_elements[0].split(" ")[0]
                    date_time = line_elements[0].split(" ")[3].split("[")[1]
                    request_method = line_elements[1]
                    response_status_code = line_elements[2].split(" ")[1]
                    response_size = line_elements[2].split(" ")[2]
                    referrer = line_elements[3]
                    user_agent = line_elements[5]

                    logs_dict[lid] = {
                        "ip_address" : ip_address,
                        "date_time" : date_time,
                        "request_method" : request_method,
                        "request_status_code" : response_status_code,
                        "request_size" : response_size,
                        "referrer" : referrer,
                        "user_agent" : user_agent,
                    }

            return logs_dict
    except FileNotFoundError:
        print(f"Error: the file {logs_file} was not found")
    except Exception as e:
        print(f"An error occured: {e}")


# Function to get statistics of values in logs dict
def analyze_logs(bucket: dict) -> dict:
    # Statistics dict
    stats = {
        "top_ip": {},
        "top_request_path": {},
        "top_status_code": {},
        "top_user_agent": {}
    }

    # Function to increment occurence of a value in au dict
    def count(bucket: dict, value: str):
        if value in bucket:
            bucket[value] += 1
        else:
            bucket[value] = 1

    # Loop the logs_dict and count the occurence of each category
    for log in logs.values(): # type: ignore
        count(stats["top_ip"], log.get("ip_address", ""))
        count(stats["top_request_path"], log.get("request_method", "").split()[0])
        count(stats["top_status_code"], log.get("request_status_code", ""))
        count(stats["top_user_agent"], log.get("user_agent", ""))

    return stats

# Function to sort stats by desc count
def sort_by_count_desc(stats: dict) -> dict:

    sorted_stats = {}

    for category, bucket in stats.items():
        keys = list(bucket.keys())

        # Bubble sort of each bucket
        for i in range(len(keys)):
            for j in range(i + 1, len(keys)):
                if bucket[keys[j]] > bucket[keys[i]]:
                    keys[i], keys[j] = keys[j], keys[i]

        # keep only the 5 first keys
        keys = keys[:5]

        sorted_stats[category] = {k: bucket[k] for k in keys}

    return sorted_stats


# Function to print the result
def print_statistics(stats: dict):
    for category, bucket in stats.items():
        print(f"\n Top 5 of {category} with the most request")
        for value, count in bucket.items():
            print(f"  {value} - {count} requests")

# -----------------
# | Main function |
# -----------------

# 1. Get the log dict
logs = save_logs_to_dict()

# 2. Analyze the
analyzed_logs = analyze_logs(logs) # type: ignore

# 3. Sort logs and keep onlys the 5th
sorted_logs = sort_by_count_desc(analyzed_logs)

# 4. Print statistics
print_statistics(sorted_logs)