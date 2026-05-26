unit UInventario;

interface

uses
  System.Generics.Collections,
  UCedula;

type
  TInventario = class
  private
    FCedulas: TList<TCedula>;
    function GetTotalValor: Currency;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AdicionarCedula(AValor: Currency; AQuantidade: Integer);
    procedure RemoverCedula(AValor: Currency; AQuantidade: Integer);
    function ConsultarCedula(AValor: Currency): Integer;
    function TemCedulasSuficientes(AValor: Currency; AQuantidade: Integer): Boolean;
    function ObterCedulasDisponiveis: TList<TCedula>;

    property TotalValor: Currency read GetTotalValor;
  end;

implementation

uses
  System.SysUtils,
  UConstantes;

{ TInventario }

procedure TInventario.AdicionarCedula(AValor: Currency; AQuantidade: Integer);
var
  I: Integer;
  Found: Boolean;
  TempCedula: TCedula;
  NovaCedula: TCedula;
begin
  Found := False;
  for I := 0 to FCedulas.Count - 1 do
  begin
    if FCedulas[I].Valor = AValor then
    begin
      TempCedula := FCedulas[I];
      TempCedula.Quantidade := TempCedula.Quantidade + AQuantidade;
      FCedulas[I] := TempCedula;
      Found := True;
      Break;
    end;
  end;

  if not Found then
  begin
    NovaCedula.Valor := AValor;
    NovaCedula.Quantidade := AQuantidade;
    FCedulas.Add(NovaCedula);
  end;
end;

function TInventario.ConsultarCedula(AValor: Currency): Integer;
var
  Cedula: TCedula;
begin
  Result := 0;
  for Cedula in FCedulas do
  begin
    if Cedula.Valor = AValor then
    begin
      Result := Cedula.Quantidade;
      Exit;
    end;
  end;
end;

constructor TInventario.Create;
begin
  inherited;
  FCedulas := TList<TCedula>.Create;
end;

destructor TInventario.Destroy;
begin
  FCedulas.Free;
  inherited;
end;

function TInventario.GetTotalValor: Currency;
var
  Cedula: TCedula;
begin
  Result := 0;
  for Cedula in FCedulas do
    Result := Result + (Cedula.Valor * Cedula.Quantidade);
end;

function TInventario.ObterCedulasDisponiveis: TList<TCedula>;
var
  Cedula: TCedula;
begin
  Result := TList<TCedula>.Create;
  for Cedula in FCedulas do
    Result.Add(Cedula);
end;

procedure TInventario.RemoverCedula(AValor: Currency; AQuantidade: Integer);
var
  I: Integer;
  Found: Boolean;
  TempCedula: TCedula;
begin
  Found := False;
  for I := 0 to FCedulas.Count - 1 do
  begin
    if FCedulas[I].Valor = AValor then
    begin
      if FCedulas[I].Quantidade < AQuantidade then
        raise Exception.CreateFmt(ERR_CEDULAS_INSUFICIENTES, [AValor]);
      TempCedula := FCedulas[I];
      TempCedula.Quantidade := TempCedula.Quantidade - AQuantidade;
      FCedulas[I] := TempCedula;
      Found := True;
      Break;
    end;
  end;
  if not Found then
    raise Exception.CreateFmt(ERR_CEDULA_NAO_ENCONTRADA, [AValor]);
end;

function TInventario.TemCedulasSuficientes(AValor: Currency; AQuantidade: Integer): Boolean;
begin
  Result := ConsultarCedula(AValor) >= AQuantidade;
end;

end.
