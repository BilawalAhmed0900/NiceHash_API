program NiceHash_API;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  NiceHashAPI in 'NiceHashAPI.pas';

var
  Client: NiceAPI;
begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
