unit UCaixaEletronico;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  UCedula,
  UInventario,
  UContaUsuario,
  UComposicaoCedulasStrategy,
  UNotificacaoService,
  UConstantes;

type
  EComposicaoImpossivel = class(Exception);

  TCaixaEletronico = class
  private
    FInventario: TInventario;
    FContasUsuarios: TDictionary<string, TContaUsuario>;
    FNotificacaoServices: TList<INotificacaoService>;

    procedure Notificar(const AMensagem: string);
    // Verifica se AValor pode ser composto com o inventario dado, usando greedy
    // descendente, sem lancar excecao — evita o uso de excecoes como controle
    // de fluxo no loop de sugestoes de saque.
    function PodeComporValor(AValor: Currency; AInventario: TList<TCedula>): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AdicionarCedulas(AValor: Currency; AQuantidade: Integer);
    procedure RemoverCedulas(AValor: Currency; AQuantidade: Integer);
    function ConsultarInventario: TList<TCedula>;
    function ConsultarSaldoTotal: Currency;

    procedure AdicionarContaUsuario(const AIdentificador: string; ASaldoInicial: Currency);
    function ObterContaUsuario(const AIdentificador: string): TContaUsuario;
    function ObterIdentificadoresContas: TArray<string>;

    procedure AdicionarServicoNotificacao(AService: INotificacaoService);

    // A estrategia e recebida como parametro no momento da chamada,
    // garantindo que o caixa nao conhece a implementacao usada
    function Sacar(const AIdentificadorUsuario: string; AValorSaque: Currency;
      AStrategy: IComposicaoCedulasStrategy): TDictionary<Currency, Integer>;
    // Sugestoes verificam composabilidade com greedy descendente interno —
    // nao dependem da estrategia do chamador, pois o objetivo e apenas informar
    // quais valores existem no inventario, sem gerar excecoes no processo.
    function SugerirValoresSaque(AValorDesejado: Currency): TArray<Currency>;
  end;

implementation

{ TCaixaEletronico }

procedure TCaixaEletronico.AdicionarCedulas(AValor: Currency; AQuantidade: Integer);
begin
  if AValor <= 0 then
    raise Exception.Create(ERR_VALOR_DEVE_SER_POSITIVO);
  if AQuantidade <= 0 then
    raise Exception.Create(ERR_QUANTIDADE_DEVE_SER_POSITIVA);
  FInventario.AdicionarCedula(AValor, AQuantidade);
  if AValor < 2.00 then
    Notificar(Format(MSG_MOEDAS_ADICIONADAS, [AQuantidade, AValor, FInventario.TotalValor]))
  else
    Notificar(Format(MSG_CEDULAS_ADICIONADAS, [AQuantidade, AValor, FInventario.TotalValor]));
end;

procedure TCaixaEletronico.AdicionarContaUsuario(const AIdentificador: string;
  ASaldoInicial: Currency);
begin
  if FContasUsuarios.ContainsKey(AIdentificador) then
    raise Exception.CreateFmt(ERR_CONTA_JA_EXISTE, [AIdentificador]);

  FContasUsuarios.Add(AIdentificador, TContaUsuario.Create(AIdentificador, ASaldoInicial));
  Notificar(Format(MSG_CONTA_CRIADA, [AIdentificador, ASaldoInicial]));
end;

function TCaixaEletronico.ConsultarInventario: TList<TCedula>;
begin
  Result := FInventario.ObterCedulasDisponiveis;
end;

function TCaixaEletronico.ConsultarSaldoTotal: Currency;
begin
  Result := FInventario.TotalValor;
end;

constructor TCaixaEletronico.Create;
begin
  inherited Create;
  FInventario := TInventario.Create;
  FContasUsuarios := TDictionary<string, TContaUsuario>.Create;
  FNotificacaoServices := TList<INotificacaoService>.Create;
end;

destructor TCaixaEletronico.Destroy;
var
  Conta: TContaUsuario;
begin
  FInventario.Free;
  for Conta in FContasUsuarios.Values do
    Conta.Free;
  FContasUsuarios.Free;
  FNotificacaoServices.Free;
  inherited Destroy;
end;

procedure TCaixaEletronico.AdicionarServicoNotificacao(AService: INotificacaoService);
begin
  FNotificacaoServices.Add(AService);
  Notificar(MSG_NOTIFICACAO_ADICIONADA);
end;

procedure TCaixaEletronico.Notificar(const AMensagem: string);
var
  Service: INotificacaoService;
begin
  for Service in FNotificacaoServices do
    Service.RegistrarNotificacao(AMensagem);
end;

function TCaixaEletronico.ObterContaUsuario(const AIdentificador: string): TContaUsuario;
begin
  if not FContasUsuarios.TryGetValue(AIdentificador, Result) then
    raise Exception.CreateFmt(ERR_CONTA_NAO_ENCONTRADA, [AIdentificador]);
end;

function TCaixaEletronico.ObterIdentificadoresContas: TArray<string>;
begin
  Result := FContasUsuarios.Keys.ToArray;
end;

procedure TCaixaEletronico.RemoverCedulas(AValor: Currency; AQuantidade: Integer);
begin
  if AValor <= 0 then
    raise Exception.Create(ERR_VALOR_DEVE_SER_POSITIVO);
  if AQuantidade <= 0 then
    raise Exception.Create(ERR_QUANTIDADE_DEVE_SER_POSITIVA);
  FInventario.RemoverCedula(AValor, AQuantidade);
  if AValor < 2.00 then
    Notificar(Format(MSG_MOEDAS_REMOVIDAS, [AQuantidade, AValor, FInventario.TotalValor]))
  else
    Notificar(Format(MSG_CEDULAS_REMOVIDAS, [AQuantidade, AValor, FInventario.TotalValor]));
end;

function TCaixaEletronico.PodeComporValor(AValor: Currency; AInventario: TList<TCedula>): Boolean;
var
  Ordenadas: TList<TCedula>;
  ValorRestante: Currency;
  Cedula: TCedula;
  QuantidadeUsada: Integer;
begin
  Ordenadas := TList<TCedula>.Create;
  try
    for Cedula in AInventario do
      Ordenadas.Add(Cedula);
    Ordenadas.Sort(TComparer<TCedula>.Construct(
      function(const L, R: TCedula): Integer
      begin
        if L.Valor > R.Valor then Result := -1
        else if L.Valor < R.Valor then Result := 1
        else Result := 0;
      end));
    ValorRestante := AValor;
    for Cedula in Ordenadas do
    begin
      if (ValorRestante >= Cedula.Valor) and (Cedula.Quantidade > 0) then
      begin
        QuantidadeUsada := Trunc(ValorRestante / Cedula.Valor);
        if QuantidadeUsada > Cedula.Quantidade then
          QuantidadeUsada := Cedula.Quantidade;
        ValorRestante := ValorRestante - (QuantidadeUsada * Cedula.Valor);
      end;
    end;
    Result := ValorRestante = 0;
  finally
    Ordenadas.Free;
  end;
end;

function TCaixaEletronico.SugerirValoresSaque(AValorDesejado: Currency): TArray<Currency>;
const
  MAX_SUGESTOES = 5;
var
  Sugestoes: TList<Currency>;
  ValorTentativa: Currency;
  InventarioDisponivel: TList<TCedula>;
  Cedula: TCedula;
  Passo: Currency;
begin
  Sugestoes := TList<Currency>.Create;
  try
    InventarioDisponivel := FInventario.ObterCedulasDisponiveis;
    try
      Passo := 0;
      for Cedula in InventarioDisponivel do
        if (Cedula.Quantidade > 0) and ((Passo = 0) or (Cedula.Valor < Passo)) then
          Passo := Cedula.Valor;
      if Passo = 0 then
        Exit;

      ValorTentativa := Trunc(AValorDesejado / Passo) * Passo;
      if ValorTentativa >= AValorDesejado then
        ValorTentativa := ValorTentativa - Passo;

      while (ValorTentativa > 0) and (Sugestoes.Count < MAX_SUGESTOES) do
      begin
        if PodeComporValor(ValorTentativa, InventarioDisponivel) then
          Sugestoes.Add(ValorTentativa);
        ValorTentativa := ValorTentativa - Passo;
      end;
    finally
      InventarioDisponivel.Free;
    end;

    Result := Sugestoes.ToArray;
  finally
    Sugestoes.Free;
  end;
end;

function TCaixaEletronico.Sacar(const AIdentificadorUsuario: string;
  AValorSaque: Currency; AStrategy: IComposicaoCedulasStrategy): TDictionary<Currency, Integer>;
var
  Conta: TContaUsuario;
  Composicao: TDictionary<Currency, Integer>;
  InventarioDisponivel: TList<TCedula>;
  CedulaValor: Currency;
  CedulaQuantidade: Integer;
begin
  if AValorSaque <= 0 then
    raise Exception.Create(ERR_VALOR_DEVE_SER_POSITIVO);
  if not Assigned(AStrategy) then
    raise Exception.Create(ERR_ESTRATEGIA_NAO_DEFINIDA);

  Conta := ObterContaUsuario(AIdentificadorUsuario);

  if Conta.SaldoAtual < AValorSaque then
  begin
    Notificar(Format(MSG_SAQUE_FALHOU_SALDO,
      [AValorSaque, AIdentificadorUsuario, Conta.SaldoAtual]));
    raise Exception.Create(ERR_SALDO_INSUFICIENTE);
  end;

  if FInventario.TotalValor < AValorSaque then
  begin
    Notificar(Format(MSG_SAQUE_FALHOU_CAIXA,
      [AValorSaque, AIdentificadorUsuario, FInventario.TotalValor]));
    raise Exception.Create(ERR_CAIXA_SEM_FUNDOS);
  end;

  InventarioDisponivel := FInventario.ObterCedulasDisponiveis;
  try
    try
      Composicao := AStrategy.ObterComposicao(AValorSaque, InventarioDisponivel);
    except
      on E: Exception do
        raise EComposicaoImpossivel.CreateFmt(ERR_COMPOSICAO_IMPOSSIVEL, [AValorSaque]);
    end;
  finally
    InventarioDisponivel.Free;
  end;

  try
    for CedulaValor in Composicao.Keys do
    begin
      CedulaQuantidade := Composicao[CedulaValor];
      FInventario.RemoverCedula(CedulaValor, CedulaQuantidade);
    end;

    Conta.Debitar(AValorSaque);
    Notificar(Format(MSG_SAQUE_SUCESSO, [AValorSaque, AIdentificadorUsuario]));
    Result := Composicao;
  except
    on E: Exception do
    begin
      Composicao.Free;
      Notificar(Format(MSG_SAQUE_FALHOU,
        [AValorSaque, AIdentificadorUsuario, E.Message]));
      raise;
    end;
  end;
end;

end.
