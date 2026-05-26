unit UContaUsuario;

interface

uses
  System.SysUtils,
  UConstantes;

type
  TContaUsuario = class
  private
    FIdentificadorUnico: string;
    FSaldoAtual: Currency;
  public
    constructor Create(const AIdentificadorUnico: string; ASaldoInicial: Currency);

    property IdentificadorUnico: string read FIdentificadorUnico;
    property SaldoAtual: Currency read FSaldoAtual;

    procedure Debitar(AValor: Currency);
  end;

implementation

{ TContaUsuario }

constructor TContaUsuario.Create(const AIdentificadorUnico: string; ASaldoInicial: Currency);
begin
  inherited Create;
  FIdentificadorUnico := AIdentificadorUnico;
  FSaldoAtual := ASaldoInicial;
end;

procedure TContaUsuario.Debitar(AValor: Currency);
begin
  if FSaldoAtual < AValor then
    raise Exception.Create(ERR_SALDO_INSUFICIENTE_OPERACAO);
  FSaldoAtual := FSaldoAtual - AValor;
end;

end.
