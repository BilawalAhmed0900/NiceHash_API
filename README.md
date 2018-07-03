# NiceHash_API
NiceHash API implementation in Delphi. This was made at version 1.2.7. If any new function is created, ask me to add it or you can contribute yourself.

# Requirements
This library requires OpenSSL to work, you can download the dll [Here](https://indy.fulgan.com/SSL/).
Put respective dll close to binary file

# Uses
You can use the library from the file `NiceHashAPI.pas`

     NiceHashAPI in 'NiceHashAPI.pas'

# Functions
There are two types of function available

### Public Functions
These function don't require instance of class and can be called as `NiceAPI.GetBuyInfo`

    class function GetAPIDetail: String;
    class function GetVersion: String;

    class function GetStatsGlobalCurrent: String;
    class function GetStatsGlobal24H: String;

    class function GetStatsProvider(BTCAddr: String): String;
    class function GetStatsProviderEx(BTCAddr: String;
      From: Integer = 0): String;
    class function GetStatsProviderPayments(BTCAddr: String;
      From: Integer = 0): String;
    class function GetStatsProviderWorkers(BTCAddr: String;
      Algorithm: ALGORITHM_AVAILABLE): String;

    class function GetOrders(Location: LOCATION_AVAILABLE;
      Algorithm: ALGORITHM_AVAILABLE): String;

    class function GetMultiAlgorithmsInfo: String;
    class function GetSimpleMultiAlgorithmsInfo: String;

    class function GetBuyInfo: String;
    
### Private Functions
These functions require instance of class to be made as `Client = NiceAPI.Create('ID', 'KEY')` and are called as `Client.GetBalance` 

    function GetMyOrders(Location: LOCATION_AVAILABLE;
      Algorithm: ALGORITHM_AVAILABLE): String;

    function CreateOrder(Location: LOCATION_AVAILABLE;
      Algorithm: ALGORITHM_AVAILABLE; Amount, Price, Limit: double;
      PoolHost, PoolPort, PoolUser, PoolPass: String;
      Code: String = ''): String;
    function RefillOrder(Location: LOCATION_AVAILABLE;
      Algorithm: ALGORITHM_AVAILABLE; OrderId: String; Amount: double): String;
    function RemoveOrder(Location: LOCATION_AVAILABLE;
      Algorithm: ALGORITHM_AVAILABLE; OrderId: String): String;

    function SetNewPrice(Location: LOCATION_AVAILABLE;
      Algorithm: ALGORITHM_AVAILABLE; OrderId: String; Price: double): String;
    function DecreasePrice(Location: LOCATION_AVAILABLE;
      Algorithm: ALGORITHM_AVAILABLE; OrderId: String): String;

    function SetNewLimit(Location: LOCATION_AVAILABLE;
      Algorithm: ALGORITHM_AVAILABLE; OrderId: String; Limit: double): String;

    function GetBalance: String;
    
 # NiceHash Documentation link
 Link to NiceHash Documentation: [Here](https://www.nicehash.com/doc-api)
  
