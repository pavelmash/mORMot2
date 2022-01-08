program httpServerRaw;

{$ifdef OSWINDOWS}
  {$apptype console}
  {../../src/$R mormot.win.default.manifest.res}
{$endif OSWINDOWS}

uses
  {$I mormot.uses.inc}
  sysutils,
  classes,
  mormot.core.base,
  mormot.core.os,
  mormot.core.log,
  mormot.core.text,
  mormot.net.http,
  mormot.net.async;

type

  { TSimpleHttpAsyncServer }

  TSimpleHttpAsyncServer = class
  private
    FHttpServer: THttpAsyncServer;
  protected
    // this is where the process would take place
    function DoOnRequest(Ctxt: THttpServerRequestAbstract): cardinal;
  public
    constructor Create;
    destructor Destroy; override;
  end;


{ TSimpleHttpAsyncServer }
function TSimpleHttpAsyncServer.DoOnRequest(Ctxt: THttpServerRequestAbstract): cardinal;
begin
  if Ctxt.Method = 'GET' then
    Ctxt.OutContent := FormatUtf8('got request from connection #%', [Ctxt.ConnectionID])
  else
    Ctxt.OutContent := Ctxt.InContent;
  Result := HTTP_SUCCESS;
end;

constructor TSimpleHttpAsyncServer.Create;
begin
  inherited Create;
  FHttpServer := THttpAsyncServer.Create('8888', nil, nil, 'mormotHttpServer', 4);
  FHttpServer.OnRequest := @DoOnRequest;
end;

destructor TSimpleHttpAsyncServer.Destroy;
begin
  FHttpServer.Free;
  inherited Destroy;
end;

var
  simpleServer: TSimpleHttpAsyncServer;

begin
  with TSynLog.Family do
    begin // enable logging to file and to console
      Level := LOG_VERBOSE;
      //EchoToConsole := LOG_VERBOSE;
      PerThreadLog := ptIdentifiedInOnFile;
    end;

  simpleServer := TSimpleHttpAsyncServer.Create();
  try
    TextColor(ccLightGreen);
    writeln('HTTP 1.1 Async Server running on localhost:8888'#10);
    TextColor(ccWhite);
    writeln('try curl http://localhost:8888/echo'#10);
    TextColor(ccLightGray);
    writeln('Press [Enter] to quit'#10);
    TextColor(ccCyan);
    readln;
  finally
    simpleServer.Free;
  end;


end.

