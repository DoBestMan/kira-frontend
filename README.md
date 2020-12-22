# Kira Frontend

Kira Frontend is a user interface for Kira Network Users to manage their accounts, balance, transfer tokens between different wallets.

## Installation

_NOTE: For development, run chrome browser without security enabled, unless the api doesn't fetch data due to the cors error. GO is required to install Sekai and Interix for this current test build_

#### - Frontend

- Install required packages in pubspec.yaml

```
flutter pub get
```

- Run commands

```
flutter run -d chrome --dart-define=FLUTTER_WEB_USE_SKIA=true
flutter run -d web --dart-define=FLUTTER_WEB_USE_SKIA=true
```

_NOTE: To render svg in flutter, we need to enable SKIA mode when running command_

User input the password which will be used for encrypting mnemonic words and kira addresses, public/private keys.

After creating account, don't forget to keep the mnemonic words (seed) in a safe place and export the account as a file for restoring.

#### - Backend

At this current stage: Both INTERX and Sekai will need to be launched before launching the front-end application. Sekai can be considered a validator API service, while INTERX a proxy between the API service and the front-end.

To interact with INTERX, clone `KIP_9` branch of sekaid repository and check out INTERX readme for more information.

```
https://github.com/KiraCore/sekai/tree/KIP_9
```

- Run sekaid
  To get sekai started. Cloned the branch, heaad to current directory "/sekai" within a command line and run the following command:

```
go install ./cmd/sekaid
```

once the dependecies are complete. run the following command:

```
sh sekaidtestsetup.sh
or
run sekaidtestsetup.sh
```

This will launch a local validator which will start producting blocks.
![](https://imgur.com/sLU1XvA.png)

- Run INTERX
  Interix is a proxy between a front-end and a API provider. In this current version. Sekai acts as the local service provider and Interx interacts with it, to provide services to the front-end.
  Head to the active branch and clone the repository. Open the folder and navigate to "/INTERX", get this directory open within a command line and run this command:

```
go run main.go
```

this will download the required dependecies and launch the proxy.
![](https://imgur.com/GF50xBQ.png)
