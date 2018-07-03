unit NiceHashAPI;

interface

uses
  JSON, IdHttp, SysUtils;

type
  ALGORITHM_AVAILABLE = (SCRYPT, SHA256, SCRYPTNF, X11, X13, KECCAK, X15, NIST5,
    NEOSCRYPT, LYRA2RE, WHIRLPOOLX, QUBIT, QUARK, AXIOM, LYRA2REV2,
    SCRYPTJANENF16, BLAKE256R8, BLAKE256R14, BLAKE256R8VNL, HODL,
    DAGGERHASHIMOTO, DECRED, CRYPTONIGHT, LBRY, EQUIHASH, PASCAL, X11GOST, SIA,
    BLAKE2S, SKUNK, CRYPTONIGHTV7, CRYPTONIGHTHEAVY, LYRA2Z);

type
  ORDER_TYPES = (STANDARD, FIXED);

type
  LOCATION_AVAILABLE = (EUROPE, USA);

const
  BASE_URL: String = 'https://api.nicehash.com/api';

  // Get Source of URL(Indy)
function GetHTMLSource(URL: String): String; inline;
function StringToJSONObject(str: String): TJSONObject; inline;

type
  NiceAPI = class
  private
    fID: String;
    fKey: String;

  public
    procedure SetID(const Value: String);
    procedure SetKey(const Value: String);

    property ID: String Read fID Write SetID;
    property Key: String Read fKey Write SetKey;

    constructor Create(Api_ID: String; Key: String);
    destructor Destroy; override;

    // Public Static Functions. Doesn't require instance of class
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

    // Private functions
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
  end;

implementation

function GetHTMLSource(URL: String): String; inline;
var
  IndyHttp: TIdHttp;
  Response: String;
begin
  Result := '';
  try
    IndyHttp := TIdHttp.Create;
    Response := IndyHttp.Get(URL);
  finally
    IndyHttp.Free;
    Result := Response;
  end;
end;

function StringToJSONObject(str: String): TJSONObject; inline;
begin
  Result := TJSONObject.ParseJSONValue(str) as TJSONObject;;
end;

constructor NiceAPI.Create(Api_ID: String; Key: String);
begin
  Self.fID := Api_ID;
  Self.fKey := Key;
end;

procedure NiceAPI.SetID(const Value: String);
begin
  fID := Value;
end;

procedure NiceAPI.SetKey(const Value: String);
begin
  fKey := Value;
end;

destructor NiceAPI.Destroy;
begin
  inherited;
end;

class function NiceAPI.GetAPIDetail: String;
begin
  Result := GetHTMLSource(BASE_URL);
end;

class function NiceAPI.GetVersion: String;
var
  Json_response: String;
  Json_object: TJSONObject;
  Result_string: String;
begin
  Result := '';

  try
    Json_response := GetHTMLSource(BASE_URL);
    Json_object := StringToJSONObject(Json_response);
  finally
    Result_string := ((Json_object.Get('result').JsonValue) as TJSONObject)
      .GetValue<String>('api_version');
    Result := Result_string;
    Json_object.Free;
  end;
end;

class function NiceAPI.GetStatsGlobalCurrent: String;
var
  URL: String;
begin
  URL := Format('%s?method=%s', [BASE_URL, 'stats.global.current']);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetStatsGlobal24H: String;
var
  URL: String;
begin
  URL := Format('%s?method=%s', [BASE_URL, 'stats.global.24h']);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetStatsProvider(BTCAddr: String): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&addr=%s', [BASE_URL, 'stats.provider', BTCAddr]);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetStatsProviderEx(BTCAddr: String;
  From: Integer): String;
var
  URL: String;
begin
  if From = 0 then
    URL := Format('%s?method=%s&addr=%s',
      [BASE_URL, 'stats.provider.ex', BTCAddr])
  else
    URL := Format('%s?method=%s&addr=%s&from=%d',
      [BASE_URL, 'stats.provider.ex', BTCAddr, From]);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetStatsProviderPayments(BTCAddr: String;
  From: Integer): String;
var
  URL: String;
begin
  if From = 0 then
    URL := Format('%s?method=%s&addr=%s',
      [BASE_URL, 'stats.provider.payments', BTCAddr])
  else
    URL := Format('%s?method=%s&addr=%s&from=%d',
      [BASE_URL, 'stats.provider.payments', BTCAddr, From]);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetStatsProviderWorkers(BTCAddr: String;
  Algorithm: ALGORITHM_AVAILABLE): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&algo=%d', [BASE_URL, 'stats.provider.workers',
    Integer(Algorithm)]);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetOrders(Location: LOCATION_AVAILABLE;
  Algorithm: ALGORITHM_AVAILABLE): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&location=%d&algo=%d',
    [BASE_URL, 'orders.get', Integer(Location), Integer(Algorithm)]);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetMultiAlgorithmsInfo: String;
var
  URL: String;
begin
  URL := Format('%s?method=%s', [BASE_URL, 'multialgo.info']);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetSimpleMultiAlgorithmsInfo: String;
var
  URL: String;
begin
  URL := Format('%s?method=%s', [BASE_URL, 'simplemultialgo.info']);
  Result := GetHTMLSource(URL);
end;

class function NiceAPI.GetBuyInfo: String;
var
  URL: String;
begin
  URL := Format('%s?method=%s', [BASE_URL, 'buy.info']);
  Result := GetHTMLSource(URL);
end;

function NiceAPI.GetMyOrders(Location: LOCATION_AVAILABLE;
  Algorithm: ALGORITHM_AVAILABLE): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&id=%s&key=%s&location=%d&algo=%d',
    [BASE_URL, 'orders.get&my', Self.ID, Self.Key, Integer(Location),
    Integer(Algorithm)]);
  Result := GetHTMLSource(URL);
end;


function NiceAPI.SetNewLimit(Location: LOCATION_AVAILABLE;
  Algorithm: ALGORITHM_AVAILABLE; OrderId: String; Limit: double): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&location=%d&algo=%d&order=%s&limit=%f',
    [BASE_URL, 'orders.set.limit', Integer(Location), Integer(Algorithm),
    OrderId, Limit]);
  Result := GetHTMLSource(URL);
end;

function NiceAPI.SetNewPrice(Location: LOCATION_AVAILABLE;
  Algorithm: ALGORITHM_AVAILABLE; OrderId: String; Price: double): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&location=%d&algo=%d&order=%s&price=%f',
    [BASE_URL, 'orders.set.price', Integer(Location), Integer(Algorithm),
    OrderId, Price]);
  Result := GetHTMLSource(URL);
end;

function NiceAPI.CreateOrder(Location: LOCATION_AVAILABLE;
  Algorithm: ALGORITHM_AVAILABLE; Amount, Price, Limit: double;
  PoolHost, PoolPort, PoolUser, PoolPass: String; Code: String): String;
var
  URL: String;
begin
  if Code = '' then
    URL := Format('%s?method=%s&id=%s&key=%s&location=%d&algo=%d' +
      '&amount=%f&price=%f&limit=%f' +
      '&pool_host=%s&pool_port=%s&pool_user=%s&pool_pass=%s',
      [BASE_URL, 'orders.create', Self.ID, Self.Key, Integer(Location),
      Integer(Algorithm), Amount, Price, Limit, PoolHost, PoolPort, PoolUser,
      PoolPass])
  else
    URL := Format('%s?method=%s&id=%s&key=%s&location=%d&algo=%d' +
      '&amount=%f&price=%f&limit=%f' +
      '&pool_host=%s&pool_port=%s&pool_user=%s&pool_pass=%s' + '&code=%s',
      [BASE_URL, 'orders.create', Self.ID, Self.Key, Integer(Location),
      Integer(Algorithm), Amount, Price, Limit, PoolHost, PoolPort, PoolUser,
      PoolPass, Code]);
  Result := GetHTMLSource(URL);
end;

function NiceAPI.DecreasePrice(Location: LOCATION_AVAILABLE;
  Algorithm: ALGORITHM_AVAILABLE; OrderId: String): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&location=%d&algo=%d&order=%s',
    [BASE_URL, 'orders.set.price.decrease', Integer(Location),
    Integer(Algorithm), OrderId]);
  Result := GetHTMLSource(URL);
end;

function NiceAPI.RefillOrder(Location: LOCATION_AVAILABLE;
  Algorithm: ALGORITHM_AVAILABLE; OrderId: String; Amount: double): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&location=%d&algo=%d&order=%s&amount=%f',
    [BASE_URL, 'orders.refill', Integer(Location), Integer(Algorithm),
    OrderId, Amount]);
  Result := GetHTMLSource(URL);
end;

function NiceAPI.RemoveOrder(Location: LOCATION_AVAILABLE;
  Algorithm: ALGORITHM_AVAILABLE; OrderId: String): String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&location=%d&algo=%d&order=%s',
    [BASE_URL, 'orders.remove', Integer(Location), Integer(Algorithm),
    OrderId]);
  Result := GetHTMLSource(URL);
end;

function NiceAPI.GetBalance: String;
var
  URL: String;
begin
  URL := Format('%s?method=%s&id=%s&key=%s', [BASE_URL, 'balance', Self.ID,
    Self.Key]);
  Result := GetHTMLSource(URL);
end;

end.
