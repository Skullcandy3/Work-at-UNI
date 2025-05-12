import math
from datetime import datetime

import matplotlib.pyplot as plt
import pandas as pd


# Load the local dataset
def load_uis_data(file_path):
    # Read the data using semicolon as delimiter
    uis_data = pd.read_csv(file_path, delimiter=';', decimal=',')

    # Rename columns for easier access
    uis_data.rename(columns={'Temperatur (gr Celsius)': 'Temperature',
                             'Trykk - absolutt trykk maaler (bar)': 'Pressure',
                             'Trykk - barometer (bar)': 'Pressure low'}, inplace=True)

    # Prøv først å konvertere til datetime med formatet MM.DD.YYYY HH:MM
    uis_data['DateTime'] = pd.to_datetime(uis_data['Dato og tid'], format='%m.%d.%Y %H:%M', errors='coerce')

    # For rader der konverteringen feilet (NaT-verdier), prøv formatet MM/DD/YYYY HH:MM
    mask = uis_data['DateTime'].isna()  # Finn NaT-verdiene fra første forsøk
    uis_data.loc[mask, 'DateTime'] = pd.to_datetime(uis_data.loc[mask, 'Dato og tid'], format='%m/%d/%Y %H:%M',
                                                    errors='coerce')

    # For rader som fremdeles er NaT, prøv MM/DD/YYYY hh:mm:ss am/pm
    mask = uis_data['DateTime'].isna()
    uis_data.loc[mask, 'DateTime'] = pd.to_datetime(uis_data.loc[mask, 'Dato og tid'], format='%m/%d/%Y %I:%M:%S %p',
                                                    errors='coerce')
    # Drop rows with invalid date
    uis_data = uis_data.dropna(subset=['DateTime'])

    return uis_data


# Load the Sola dataset
def load_sola_data(file_path):
    # Read the data using semicolon as delimiter
    sola_data = pd.read_csv(file_path, delimiter=';', decimal=',')

    # Convert 'Tid(norsk normaltid)' to datetime format
    sola_data['DateTime'] = pd.to_datetime(sola_data['Tid(norsk normaltid)'], format='%d.%m.%Y %H:%M', errors='coerce')

    # Rename columns for easier access
    sola_data.rename(columns={'Lufttemperatur': 'Temperature', 'Lufttrykk i havnivå': 'Pressure'}, inplace=True)

    # Drop rows with invalid date
    sola_data = sola_data.dropna(subset=['DateTime'])

    return sola_data


# Load the Sinnes dataset
def load_sinnes_data(file_path):
    # Read the data using semicolon as delimiter
    sinnes_data = pd.read_csv(file_path, delimiter=';', decimal=',')

    # Convert 'Tid(norsk normaltid)' to datetime format
    sinnes_data['DateTime'] = pd.to_datetime(sinnes_data['Tid(norsk normaltid)'], format='%d.%m.%Y %H:%M',
                                             errors='coerce')

    # Rename columns for easier access
    sinnes_data.rename(columns={'Lufttemperatur': 'Temperature', 'Lufttrykk i havnivå': 'Pressure'}, inplace=True)

    # Drop rows with invalid date
    sinnes_data = sinnes_data.dropna(subset=['DateTime'])

    return sinnes_data


# Load the Sauda dataset

def load_sauda_data(file_path):
    # Read the data using semicolon as delimiter
    sauda_data = pd.read_csv(file_path, delimiter=';', decimal=',')

    # Convert 'Tid(norsk normaltid)' to datetime format
    sauda_data['DateTime'] = pd.to_datetime(sauda_data['Tid(norsk normaltid)'], format='%d.%m.%Y %H:%M',
                                            errors='coerce')

    # Rename columns for easier access
    sauda_data.rename(columns={'Lufttemperatur': 'Temperature', 'Lufttrykk i havnivå': 'Pressure'}, inplace=True)

    # Drop rows with invalid date
    sauda_data = sauda_data.dropna(subset=['DateTime'])

    return sauda_data

def load_kristiansand_data(file_path): #fra g
    # Read the data using semicolon as delimiter
    kristiansand_data = pd.read_csv(file_path, delimiter=';', decimal=',')

    # Convert 'Tid(norsk normaltid)' to datetime format
    kristiansand_data['DateTime'] = pd.to_datetime(kristiansand_data['Tid(norsk normaltid)'], format='%d.%m.%Y %H:%M', errors='coerce')

    # Rename columns for easier access
    kristiansand_data.rename(columns={'Lufttemperatur': 'Temperature', 'Lufttrykk i havnivå': 'Pressure'}, inplace=True)

    # Drop rows with invalid date
    kristiansand_data = kristiansand_data.dropna(subset=['DateTime'])

    return kristiansand_data


# Load datasets (replace with your actual file paths)
uis_data = load_uis_data(r"trykk_og_temperaturlogg_rune_time.csv.txt")
sola_data = load_sola_data(r"temperatur_trykk_met_samme_rune_time_datasett.csv.txt")
sinnes_data = load_sinnes_data(r"trykk_og_templogg Sinnes.txt")
sauda_data = load_sauda_data(r"trykk_og_templogg Sauda.txt")
kristiansand_data = load_kristiansand_data(r"tabel.csv") #fra g

#videre fra g:
kristiansand_data['Temperature'] = pd.to_numeric(kristiansand_data['Temperature'], errors='coerce')
kristiansand_data = kristiansand_data.dropna(subset=['Temperature'])

kristiansand_data['Pressure'] = pd.to_numeric(kristiansand_data['Pressure'], errors='coerce')
kristiansand_data = kristiansand_data.dropna(subset=['Pressure'])


# Ensure 'Temperature' is numeric and drop NaN values
uis_data['Temperature'] = pd.to_numeric(uis_data['Temperature'], errors='coerce')
uis_data = uis_data.dropna(subset=['Temperature'])

# Ensure 'Pressure' is numeric and drop NaN values
uis_data['Pressure'] = pd.to_numeric(uis_data['Pressure'], errors='coerce')
uis_data = uis_data.dropna(subset=['Pressure'])

uis_data['Pressure low'] = pd.to_numeric(uis_data['Pressure low'], errors='coerce')
uis_data = uis_data.dropna(subset=['Pressure low'])

# Display the first few rows of both datasets
print("Local Data (UiS):")
print(uis_data.head())
print("\nSola Data:")
print(sola_data.head())
print("\nSinnes Data:")
print(sinnes_data.head())
print("\nSauda Data:")
print(sauda_data.head())
print("\nKristiansand Data:") #fra g
print(kristiansand_data.head())


# Function to calculate moving average
def moving_average(temps, times, n):
    avg_temps = []
    valid_times = []
    for i in range(n, len(temps) - n):
        avg_temp = temps.iloc[i - n:i + n + 1].mean()  # Bruk .iloc for posisjonsbasert indeksering
        avg_temps.append(avg_temp)
        valid_times.append(times.iloc[i])  # Bruk .iloc her også for posisjon
    return valid_times, avg_temps


def calculate_standard_deviation(standard_array, avg_array, n):
    standard_deviation = []
    for j in range(n, len(standard_array) - n):
        avg_value = avg_array[j // 30]  # Use the corresponding avg for each 30-element block
        sum_difference = 0
        for i in range(j - n, j + n + 1):
            sum_difference += (standard_array.iloc[i] - avg_value) ** 2
        deviation = round(math.sqrt((1 / (2 * n)) * sum_difference), 2)
        standard_deviation.append(deviation)
    return standard_deviation


# Calculate the moving average for UiS data
n = 30
valid_times_ui, avg_temps_uis = moving_average(uis_data['Temperature'], uis_data['DateTime'], n)
standard_deviation_uis = calculate_standard_deviation(uis_data['Temperature'], avg_temps_uis, n)
# Define the time period for temperature drop
start_time = datetime(2021, 6, 11, 17, 31)
end_time = datetime(2021, 6, 12, 3, 5)

# Filter the UiS data for the specified time period
drop_data = uis_data[(uis_data['DateTime'] >= start_time) & (uis_data['DateTime'] <= end_time)]
uis_data['Pressure'] = uis_data['Pressure'] * 10
uis_data['Pressure low'] = uis_data['Pressure low'] * 10

# Plot the temperature and pressure in a single figure with two subplots
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10), sharex=True)

# Plot Temperature Data (UiS and Sola)
ax1.plot(uis_data['DateTime'], uis_data['Temperature'], label='UiS Temperature', color='blue', alpha=0.5)
ax1.plot(valid_times_ui, avg_temps_uis, label='UiS Avg Temp', color='orange')
ax1.plot(drop_data['DateTime'], drop_data['Temperature'], label='Temperature Drop', color='purple')
ax1.plot(sola_data['DateTime'], sola_data['Temperature'], label='Sola Temperature', color='green')
ax1.plot(sinnes_data['DateTime'], sinnes_data['Temperature'], label='Sinnes Temperature', color='yellow', alpha=0.8)
ax1.plot(sauda_data['DateTime'], sauda_data['Temperature'], label='Sauda Temperature', color='red', alpha=0.8)
ax1.set_ylabel('Temperature (°C)')
ax1.set_title('Temperature Comparison: UiS vs Sola vs Sinnes vs Sauda')
ax1.plot(kristiansand_data['DateTime'], kristiansand_data['Temperature'], label='Kristiansand Temperature', color='magenta', alpha=0.8) #fra g
ax1.legend()
ax1.grid()

# Plot Pressure Data (UiS and Sola)
ax2.plot(uis_data['DateTime'], uis_data['Pressure'], label='UiS Pressure', color='blue', alpha=0.8)
ax2.plot(uis_data['DateTime'], uis_data['Pressure low'], label='UiS Barometer', color='red', alpha=0.8)
ax2.plot(sola_data['DateTime'], sola_data['Pressure'], label='Sola Pressure', color='green')
ax2.plot(sinnes_data['DateTime'], sinnes_data['Pressure'], label='Sinnes Pressure', color='yellow', alpha=0.8)
ax2.plot(sauda_data['DateTime'], sauda_data['Pressure'], label='Sauda Pressure', color='orange', alpha=0.8)
ax2.set_ylabel('Pressure (hPa)')
ax2.set_title('Pressure Comparison: UiS vs Sola')
ax2.plot(kristiansand_data['DateTime'], kristiansand_data['Pressure'], label='Kristiansand Pressure', color='magenta', alpha=0.8) #fra g
ax2.legend()
ax2.grid()

# Set common x-axis label
ax2.set_xlabel('Date and Time')

# Plot standart deviation
fig2, ax3 = plt.subplots(figsize=(12, 5))

min_length = min(len(uis_data['DateTime']), len(avg_temps_uis), len(standard_deviation_uis))

uis_data_deviation = pd.DataFrame({
    'DateTime': uis_data['DateTime'][:min_length],               # DateTime list
    'avg_temps_uis': avg_temps_uis[:min_length],                 # Avg_temps_uis list
    'standard_deviation_uis': standard_deviation_uis[:min_length]  # Standard_deviation_uis list
})


ax3.errorbar(uis_data_deviation['DateTime'], uis_data_deviation['avg_temps_uis'], yerr=uis_data_deviation['standard_deviation_uis'], errorevery = 30, label='Deviation UiS', color='blue', alpha=0.8,capsize=2)
ax3.set_ylabel('Temperature')
ax3.set_title('Standard deviation in UiS measurements')
ax3.legend()
ax3.grid()



plt.tight_layout()
plt.show()
