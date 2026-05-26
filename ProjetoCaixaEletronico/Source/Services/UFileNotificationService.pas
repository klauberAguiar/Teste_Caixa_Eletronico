unit UFileNotificationService;

interface

uses
  System.SysUtils,
  System.Classes,
  UNotificacaoService,
  UConstantes;

type
  TFileNotificationService = class(TInterfacedObject, INotificacaoService)
  private
    FLogFilePath: string;
  public
    constructor Create(const ALogFilePath: string);
    procedure RegistrarNotificacao(const AMensagem: string);
  end;

implementation

{ TFileNotificationService }

constructor TFileNotificationService.Create(const ALogFilePath: string);
begin
  inherited Create;
  FLogFilePath := ALogFilePath;
end;

procedure TFileNotificationService.RegistrarNotificacao(const AMensagem: string);
var
  LogFile: TextFile;
  LogEntry: string;
  LogDir: string;
begin
  LogDir := ExtractFileDir(FLogFilePath);
  if (LogDir <> '') and not DirectoryExists(LogDir) then
    ForceDirectories(LogDir);

  AssignFile(LogFile, FLogFilePath);
  try
    if FileExists(FLogFilePath) then
      Append(LogFile)
    else
      Rewrite(LogFile);

    LogEntry := Format(LOG_FORMATO_ENTRADA, [FormatDateTime(LOG_FORMATO_DATETIME, Now), AMensagem]);
    Writeln(LogFile, LogEntry);
  finally
    CloseFile(LogFile);
  end;
end;

end.
