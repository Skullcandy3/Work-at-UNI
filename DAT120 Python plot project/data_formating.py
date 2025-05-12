from datetime import datetime

""""
Create a txt file with all needed information, with interval in 1h (time, temperature, pressure)
"""


def nor_list(path, dataset_name):
    # file_path = path+"\\"+file_name
    with open(path, "r", encoding='utf-8') as file:
        lines = file.readlines()[1:-1]
        time_list = []
        temp_list = []
        pressure_list = []
        for line in lines:
            try:
                parts = line.split(';')  # Split each line by ';'
                time = datetime.strptime(parts[2], "%d.%m.%Y %H:%M")  # Time is in the 3rd position
                temp = float(parts[3].replace(',', '.'))  # Air temperature is in the 4th position
                pressure = float(parts[4].replace("\n", "").replace(',', '.'))  # Pressure is in the 5th position

                time_list.append(time)
                temp_list.append(temp)
                pressure_list.append(pressure)
            except:
                continue
        dataset_name.append((time_list, temp_list, pressure_list))


def UiS_list(path, dataset_name):
    # file_path = path+"\\"+file_name
    with open(path, "r", encoding='utf-8') as file:
        lines = file.readlines()[1:]
        time_list = []
        temp_list = []
        pressure_list = []
        for line in lines:
            try:
                parts = line.split(';')  # Split each line by ';'
                time = parts[0]  # Time is in the 3rd position
                # Reformat time
                if switch_time_format_to_nor(time, ".") == None:
                    time = switch_time_format_to_nor(time, "/", True)
                else:
                    time = switch_time_format_to_nor(time, ".")

                temp = parts[4].replace("\n", "")  # Air temperature is in the 4th position
                temp = float(temp.replace(',', '.'))
                pressure = float(parts[3].replace(',', '.'))
                time_list.append(time)
                temp_list.append(temp)
                pressure_list.append(pressure)

            except:
                print("Something went wrong in UiS converting")
                continue
            dataset_name.append((time_list, temp_list, pressure_list))


def switch_time_format_to_nor(old_time_format, character, text_time=False):
    try:
        buffer = old_time_format.split(character, 2)
        new_time_format = buffer[1] + "." + buffer[0] + "." + buffer[2]
        if text_time:
            time_part_1 = buffer[2].split(" ", 1)
            time_part_2 = time_part_1[1].split(":", 1)
            if time_part_2[0] == "00":
                new_time_format = buffer[1] + "." + buffer[0] + "." + time_part_1[0] + " 12:" + time_part_2[1]
            # Parse the string to a datetime object using 12-hour format
            new_dt = datetime.strptime(new_time_format, "%d.%m.%Y %I:%M:%S %p")
            new_time_format = new_dt.strftime("%d.%m.%Y %H:%M")
        return new_time_format
    except IndexError:
        return None


def average_temp(dataset, compression_n, new_set_name):
    time_list = []
    temp_list = []
    pressure_list = []
    amount_iterations = len(dataset[0][0]) // compression_n
    for n in range(amount_iterations):
        time = dataset[0][0][n * compression_n]
        tot_temp = 0
        tot_pressure = 0
        for i in range(compression_n):
            index = i + n * compression_n
            if index < len(dataset[0][1]):
                tot_temp += dataset[0][1][index]
                tot_pressure += dataset[0][2][index]
        avg_temp = round(tot_temp / compression_n, 1)
        avg_pressure = round(tot_pressure / compression_n, 1)
        temp_list.append(avg_temp)
        pressure_list.append(avg_pressure)
        time_list.append(time)

    new_set_name.append((time_list, temp_list, pressure_list))
