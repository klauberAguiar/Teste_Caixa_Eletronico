unit UNotificacaoService;

interface

type
  INotificacaoService = interface
    ['{F0A1B2C3-D4E5-F6A7-B8C9-D0E1F2A3B4C5}']
    procedure RegistrarNotificacao(const AMensagem: string);
  end;

implementation

end.
