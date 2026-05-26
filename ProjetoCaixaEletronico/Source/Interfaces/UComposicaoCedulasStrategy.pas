unit UComposicaoCedulasStrategy;

interface

uses
  System.Generics.Collections,
  UCedula;

type
  IComposicaoCedulasStrategy = interface
    ['{E0A1B2C3-D4E5-F6A7-B8C9-D0E1F2A3B4C5}']
    function ObterComposicao(AValor: Currency; AInventario: TList<TCedula>): TDictionary<Currency, Integer>;
  end;

implementation

end.
