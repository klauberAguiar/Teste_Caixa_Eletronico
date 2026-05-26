unit UConfigManager;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles;

type
  TConfigManagerSingleton = class
  private
    FIniFile: TIniFile;
    FFileName: string;
    class var FInstance: TConfigManagerSingleton;
    constructor Create(const AFileName: string);
  public
    destructor Destroy; override;
    class function GetInstance(const AFileName: string): TConfigManagerSingleton;
    class procedure ReleaseInstance;

    procedure WriteInteger(const ASection, AKey: string; AValue: Integer);
    function ReadInteger(const ASection, AKey: string; ADefault: Integer): Integer;

    procedure WriteFloat(const ASection, AKey: string; AValue: Extended);

    procedure UpdateIniFile;
    procedure ReadSectionValues(const ASection: string; AValues: TStrings);
    procedure EraseSection(const ASection: string);
  end;

implementation

{ TConfigManagerSingleton }

constructor TConfigManagerSingleton.Create(const AFileName: string);
begin
  inherited Create;
  FFileName := AFileName;
  FIniFile := TIniFile.Create(FFileName);
end;

destructor TConfigManagerSingleton.Destroy;
begin
  FIniFile.Free;
  inherited Destroy;
end;

class procedure TConfigManagerSingleton.ReleaseInstance;
begin
  if Assigned(FInstance) then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

class function TConfigManagerSingleton.GetInstance(const AFileName: string): TConfigManagerSingleton;
begin
  if not Assigned(FInstance) then
    FInstance := TConfigManagerSingleton.Create(AFileName);
  Result := FInstance;
end;

function TConfigManagerSingleton.ReadInteger(const ASection, AKey: string; ADefault: Integer): Integer;
begin
  Result := FIniFile.ReadInteger(ASection, AKey, ADefault);
end;

procedure TConfigManagerSingleton.UpdateIniFile;
begin
  FIniFile.UpdateFile;
end;

procedure TConfigManagerSingleton.WriteFloat(const ASection, AKey: string; AValue: Extended);
var
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Invariant;
  FIniFile.WriteString(ASection, AKey, FloatToStr(AValue, FS));
end;

procedure TConfigManagerSingleton.WriteInteger(const ASection, AKey: string; AValue: Integer);
begin
  FIniFile.WriteInteger(ASection, AKey, AValue);
end;

procedure TConfigManagerSingleton.ReadSectionValues(const ASection: string; AValues: TStrings);
begin
  FIniFile.ReadSectionValues(ASection, AValues);
end;

procedure TConfigManagerSingleton.EraseSection(const ASection: string);
begin
  FIniFile.EraseSection(ASection);
end;

end.
