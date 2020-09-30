# Kira Frontend

Kira Frontend is a user interface for Kira Network Users to manage their accounts, balance, transfer tokens between different wallets.

## Installation

_NOTE: For development, run chrome browser without security enabled, unless the api doesn't fetch data due to the cors error._

#### - Frontend
- Install required packages in pubspec.yaml

```
flutter pub get
```

- Run commands

```
flutter run -d chrome 
flutter run -d web
```

User input the password which will be used for encrypting mnemonic words and kira addresses, public/private keys.

After creating account, don't forget to keep the mnemonic words (seed) in a safe place and export the account as a file for restoring.

#### - Backend

To interact with INTERX, clone `KIP_9` branch of sekaid repository and check out INTERX readme for more information.
```
https://github.com/KiraCore/sekai/tree/KIP_9
```

- Run sekaid
```
sh sekaidtestsetup.sh
```

- Run INTERX
```
interx
```
or
```
go run main.go
```
