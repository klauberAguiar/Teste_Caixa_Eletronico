unit UComposicaoAlternativaStrategy;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  UCedula,
  UComposicaoCedulasStrategy;

type
  TComposicaoAlternativaStrategy = class(TInterfacedObject, IComposicaoCedulasStrategy)
  public
    function ObterComposicao(AValor: Currency; AInventario: TList<TCedula>): TDictionary<Currency, Integer>;
  end;

implementation

uses
  System.SysUtils,
  UConstantes;

{ TComposicaoAlternativaStrategy }

function TComposicaoAlternativaStrategy.ObterComposicao(AValor: Currency; AInventario: TList<TCedula>): TDictionary<Currency, Integer>;
var
  Composicao: TDictionary<Currency, Integer>;
  CedulasOrdenadas: TList<TCedula>;
  ValorRestante: Currency;
  QuantidadeUsada: Integer;
  CedulaDisponivel: TCedula;
  Cedula: TCedula;
begin
  Composicao := TDictionary<Currency, Integer>.Create;
  ValorRestante := AValor;

  CedulasOrdenadas := TList<TCedula>.Create;
  try
    for Cedula in AInventario do
      CedulasOrdenadas.Add(Cedula);

    CedulasOrdenadas.Sort(TComparer<TCedula>.Construct(function(const Left, Right: TCedula): Integer
    begin
      if Left.Valor < Right.Valor then
        Result := -1
      else if Left.Valor > Right.Valor then
        Result := 1
      else
        Result := 0;
    end));

    for CedulaDisponivel in CedulasOrdenadas do
    begin
      if (ValorRestante >= CedulaDisponivel.Valor) and (CedulaDisponivel.Quantidade > 0) then
      begin
        QuantidadeUsada := Trunc(ValorRestante / CedulaDisponivel.Valor);

        if QuantidadeUsada > CedulaDisponivel.Quantidade then
          QuantidadeUsada := CedulaDisponivel.Quantidade;

        if QuantidadeUsada > 0 then
        begin
          Composicao.Add(CedulaDisponivel.Valor, QuantidadeUsada);
          ValorRestante := ValorRestante - (QuantidadeUsada * CedulaDisponivel.Valor);
        end;
      end;
    end;

    if ValorRestante > 0 then
    begin
      Composicao.Free;
      raise Exception.Create(ERR_COMPOSICAO_ALT_INTERNO);
    end;

    Result := Composicao;
  finally
    CedulasOrdenadas.Free;
  end;
end;

end.
