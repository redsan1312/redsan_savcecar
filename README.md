# Vehicle Management Script

## English

This script is designed for use with the ESX Legacy (with oxmysql) framework in FiveM. It allows server administrators to manage vehicles with two main commands: `givecar` and `savecar`.

### Features

- **`givecar`**: Grants a vehicle to a specified player.
- **`savecar`**: Saves the current vehicle as private for the player using the command.

### Configuration

1. **Default Language**:
   - Set the default language in `config.lua`:
     ```lua
     Config.Locale = 'en' -- Change 'en' to your preferred language code
     ```

2. **Admin Groups**:
   - Define which groups can use the commands:
     ```lua
     Config.AdminGroups = {'admin', 'superadmin'}
     ```

3. **License Plate Length**:
   - Set the maximum length of the vehicle license plate:
     ```lua
     Config.PlateLength = 8
     ```

### Installation

1. Place the script in your resources directory.
2. Ensure you have the necessary dependencies installed, such as ESX and MySQL.
3. Add the script to your `server.cfg`:
   ```plaintext
   start redsan_savecar
   ```
Usage
givecar

    Command: /givecar [playerId] [model] [plate]
    Description: Grants a vehicle to the specified player.
    Permissions: Requires admin privileges as defined in Config.AdminGroups.

savecar

    Command: /savecar
    Description: Saves the current vehicle as private for the player executing the command.
    Permissions: Requires admin privileges as defined in Config.AdminGroups.

Language

To add or modify translations:

    Edit the locale files in the locales folder.
    Ensure the locale file is named according to the language code (e.g., en.lua for English).

License

This script is open source and available under the MIT License. See LICENSE for more details.
_____________________________________________________________
## Polski / Polish

Ten skrypt jest przeznaczony do użycia z frameworkiem ESX Legacy (z oxmysql) w FiveM. Umożliwia administratorom serwera zarządzanie pojazdami za pomocą dwóch głównych komend: givecar i savecar.
Funkcje

    givecar: Przyznaje pojazd określonemu graczowi.
    savecar: Zapisuje aktualny pojazd jako prywatny dla gracza używającego komendy.

Konfiguracja

    Domyślny Język:
        Ustaw domyślny język w config.lua:
   ```lua
    Config.Locale = 'pl' -- Zmień 'pl' na preferowany kod języka
   ```
Grupy Administratorów:

    Określ, które grupy mogą używać komend:
   ```lua
    Config.AdminGroups = {'admin', 'superadmin'}
   ```
Długość Tablicy Rejestracyjnej:

    Ustaw maksymalną długość tablicy rejestracyjnej pojazdu:
   ```lua
        Config.PlateLength = 8
   ```
Instalacja

    Umieść skrypt w katalogu resources.
    Upewnij się, że masz zainstalowane niezbędne zależności, takie jak ESX i MySQL.
    Dodaj skrypt do server.cfg:
```plaintext

    start redsan_savecar
```
Użycie
givecar

    Komenda: /givecar [playerId] [model] [plate]
    Opis: Przyznaje pojazd określonemu graczowi.
    Uprawnienia: Wymaga uprawnień administratora zgodnie z Config.AdminGroups.

savecar

    Komenda: /savecar
    Opis: Zapisuje aktualny pojazd jako prywatny dla gracza wykonującego komendę.
    Uprawnienia: Wymaga uprawnień administratora zgodnie z Config.AdminGroups.

Język

Aby dodać lub zmodyfikować tłumaczenia:

    Edytuj pliki językowe w folderze locales.
    Upewnij się, że plik lokalizacji jest nazwany zgodnie z kodem języka (np. pl.lua dla polskiego).

Licencja

Ten skrypt jest open source i dostępny na licencji MIT. Szczegóły znajdziesz w pliku LICENSE.
