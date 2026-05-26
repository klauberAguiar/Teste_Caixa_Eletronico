unit UTesteCaixaEletronico;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  DUnitX.TestFramework,
  UCaixaEletronico,
  UContaUsuario,
  UComposicaoCedulasStrategy,
  UComposicaoPadraoStrategy,
  UComposicaoAlternativaStrategy,
  UConstantes;

type
  [TestFixture]
  TTesteCaixaEletronico = class
  private
    FCaixa: TCaixaEletronico;
    FStrategy: IComposicaoCedulasStrategy;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // -- Saque ---------------------------------------------------------------
    [Test]
    procedure Sacar_ValorValido_DeveRetornarComposicaoEDebitarSaldo;
    [Test]
    procedure Sacar_SaldoUsuarioInsuficiente_DeveLancarExcecao;
    [Test]
    procedure Sacar_CaixaSemFundos_DeveLancarExcecao;
    [Test]
    procedure Sacar_ValorNaoComponivel_DeveLancarEComposicaoImpossivel;
    [Test]
    procedure Sacar_SemEstrategia_DeveLancarExcecao;

    // -- Contas --------------------------------------------------------------
    [Test]
    procedure AdicionarConta_Nova_DeveFuncionar;
    [Test]
    procedure AdicionarConta_Duplicada_DeveLancarExcecao;
    [Test]
    procedure ObterConta_Existente_DeveRetornarConta;
    [Test]
    procedure ObterConta_NaoExistente_DeveLancarExcecao;

    // -- Inventario ----------------------------------------------------------
    [Test]
    procedure ConsultarSaldoTotal_DeveRefletirInventario;
    [Test]
    procedure AdicionarERemoverCedulas_DeveAtualizarSaldo;

    // -- Sugestoes de saque --------------------------------------------------
    [Test]
    procedure SugerirValoresSaque_ValorImpossivel_DeveRetornarAlternativas;
    [Test]
    procedure SugerirValoresSaque_CaixaVazio_DeveRetornarArrayVazio;

    // -- Validacao de parametros ---------------------------------------------
    [Test]
    procedure AdicionarCedulas_ValorZero_DeveLancarExcecao;
    [Test]
    procedure AdicionarCedulas_QuantidadeNegativa_DeveLancarExcecao;
    [Test]
    procedure Sacar_ValorZero_DeveLancarExcecao;
    [Test]
    procedure Sacar_ValorNegativo_DeveLancarExcecao;
  end;

implementation

{ TTesteCaixaEletronico }

procedure TTesteCaixaEletronico.Setup;
begin
  FCaixa := TCaixaEletronico.Create;
  // Inventario: 10x100 + 10x50 + 10x20 + 10x10 = R$ 1.800,00
  FCaixa.AdicionarCedulas(100.00, 10);
  FCaixa.AdicionarCedulas(50.00,  10);
  FCaixa.AdicionarCedulas(20.00,  10);
  FCaixa.AdicionarCedulas(10.00,  10);
  FCaixa.AdicionarContaUsuario('cliente', 1000.00);
  FStrategy := TComposicaoPadraoStrategy.Create;
end;

procedure TTesteCaixaEletronico.TearDown;
begin
  FCaixa.Free;
end;

// -- Saque -------------------------------------------------------------------

procedure TTesteCaixaEletronico.Sacar_ValorValido_DeveRetornarComposicaoEDebitarSaldo;
// Cenario: saque de R$80 com inventario e saldo suficientes.
// Esperado: metodo retorna a composicao de cedulas utilizadas (dicionario nao vazio)
//           e o saldo da conta e debitado exatamente pelo valor sacado.
//           O chamador e responsavel por liberar o dicionario retornado.
var
  Composicao: TDictionary<Currency, Integer>;
  SaldoAntes: Currency;
begin
  SaldoAntes := FCaixa.ObterContaUsuario('cliente').SaldoAtual;
  Composicao := FCaixa.Sacar('cliente', 80.00, FStrategy);
  try
    Assert.IsNotNull(Composicao, 'Composicao nao deve ser nil');
    Assert.IsTrue(Composicao.Count > 0, 'Composicao deve ter ao menos uma cedula');
    Assert.AreEqual<Currency>(
      SaldoAntes - 80.00,
      FCaixa.ObterContaUsuario('cliente').SaldoAtual,
      'Saldo deve ser debitado');
  finally
    Composicao.Free;
  end;
end;

procedure TTesteCaixaEletronico.Sacar_SaldoUsuarioInsuficiente_DeveLancarExcecao;
// Cenario: usuario possui R$1.000,00; tentativa de saque de R$2.000,00.
// Esperado: excecao lancada antes de qualquer alteracao no inventario ou saldo.
//           O caixa verifica o saldo do usuario antes de processar a composicao.
begin
  Assert.WillRaise(
    procedure
    begin
      FCaixa.Sacar('cliente', 2000.00, FStrategy).Free;
    end,
    Exception);
end;

procedure TTesteCaixaEletronico.Sacar_CaixaSemFundos_DeveLancarExcecao;
// Cenario: conta com saldo elevado (R$99.999), mas o caixa possui apenas R$1.800.
// Esperado: excecao lancada — o caixa deve verificar seus proprios fundos
//           independentemente do saldo do usuario.
begin
  FCaixa.AdicionarContaUsuario('rico', 99999.00);
  Assert.WillRaise(
    procedure
    begin
      FCaixa.Sacar('rico', 5000.00, FStrategy).Free;
    end,
    Exception);
end;

procedure TTesteCaixaEletronico.Sacar_ValorNaoComponivel_DeveLancarEComposicaoImpossivel;
// Cenario: caixa com apenas cedulas de R$50; tentativa de sacar R$30.
// Esperado: excecao do tipo especifico EComposicaoImpossivel lancada —
//           permite ao chamador distinguir este caso (sugerir alternativas)
//           dos demais erros de saque (saldo insuficiente, caixa sem fundos, etc.).
var
  CaixaEspecifica: TCaixaEletronico;
begin
  CaixaEspecifica := TCaixaEletronico.Create;
  try
    CaixaEspecifica.AdicionarCedulas(50.00, 5);
    CaixaEspecifica.AdicionarContaUsuario('user', 500.00);
    Assert.WillRaise(
      procedure
      begin
        CaixaEspecifica.Sacar('user', 30.00, FStrategy).Free;
      end,
      EComposicaoImpossivel);
  finally
    CaixaEspecifica.Free;
  end;
end;

procedure TTesteCaixaEletronico.Sacar_SemEstrategia_DeveLancarExcecao;
// Cenario: estrategia de composicao passada como nil.
// Esperado: excecao lancada imediatamente, antes de consultar saldo ou inventario.
//           O caixa nao deve tentar processar um saque sem estrategia definida.
begin
  Assert.WillRaise(
    procedure
    begin
      FCaixa.Sacar('cliente', 50.00, nil).Free;
    end,
    Exception);
end;

// -- Contas ------------------------------------------------------------------

procedure TTesteCaixaEletronico.AdicionarConta_Nova_DeveFuncionar;
// Cenario: cadastrar uma conta com identificador novo e saldo inicial.
// Esperado: conta criada com sucesso e consultavel imediatamente pelo identificador,
//           com o saldo inicial exatamente igual ao informado.
begin
  FCaixa.AdicionarContaUsuario('novousuario', 250.00);
  Assert.AreEqual<Currency>(
    250.00,
    FCaixa.ObterContaUsuario('novousuario').SaldoAtual);
end;

procedure TTesteCaixaEletronico.AdicionarConta_Duplicada_DeveLancarExcecao;
// Cenario: tentativa de cadastrar uma segunda conta com o mesmo identificador
//          de uma conta ja existente ('cliente' foi criado no Setup).
// Esperado: excecao lancada — identificadores de conta devem ser unicos.
//           A conta original nao deve ser alterada.
begin
  Assert.WillRaise(
    procedure
    begin
      FCaixa.AdicionarContaUsuario('cliente', 100.00);
    end,
    Exception);
end;

procedure TTesteCaixaEletronico.ObterConta_Existente_DeveRetornarConta;
// Cenario: buscar uma conta pelo identificador correto ('cliente' criado no Setup).
// Esperado: objeto TContaUsuario retornado com identificador e saldo integros,
//           sem copias ou objetos distintos — deve ser a mesma instancia gerenciada.
var
  Conta: TContaUsuario;
begin
  Conta := FCaixa.ObterContaUsuario('cliente');
  Assert.IsNotNull(Conta);
  Assert.AreEqual('cliente', Conta.IdentificadorUnico);
  Assert.AreEqual<Currency>(1000.00, Conta.SaldoAtual);
end;

procedure TTesteCaixaEletronico.ObterConta_NaoExistente_DeveLancarExcecao;
// Cenario: buscar uma conta com identificador que nunca foi cadastrado.
// Esperado: excecao lancada — o caixa nao deve retornar nil nem criar
//           uma conta em branco para identificadores desconhecidos.
begin
  Assert.WillRaise(
    procedure
    begin
      FCaixa.ObterContaUsuario('naoexiste');
    end,
    Exception);
end;

// -- Inventario --------------------------------------------------------------

procedure TTesteCaixaEletronico.ConsultarSaldoTotal_DeveRefletirInventario;
// Cenario: inventario montado no Setup com 10x100 + 10x50 + 10x20 + 10x10.
// Esperado: saldo total = R$1.000 + R$500 + R$200 + R$100 = R$1.800.
//           Valida que ConsultarSaldoTotal agrega corretamente todas as denominacoes.
begin
  Assert.AreEqual<Currency>(1800.00, FCaixa.ConsultarSaldoTotal);
end;

procedure TTesteCaixaEletronico.AdicionarERemoverCedulas_DeveAtualizarSaldo;
// Cenario: adicionar e remover cedulas em sequencia a partir do estado do Setup.
// Esperado: saldo total reflete ambas as operacoes com precisao:
//           adicionar 4x50 (+R$200) e remover 5x10 (-R$50) = variacao liquida de +R$150.
var
  SaldoAntes: Currency;
begin
  SaldoAntes := FCaixa.ConsultarSaldoTotal;
  FCaixa.AdicionarCedulas(50.00, 4);   // +R$ 200,00
  FCaixa.RemoverCedulas(10.00, 5);     // -R$  50,00
  Assert.AreEqual<Currency>(SaldoAntes + 200.00 - 50.00, FCaixa.ConsultarSaldoTotal);
end;

// -- Sugestoes de saque ------------------------------------------------------

procedure TTesteCaixaEletronico.SugerirValoresSaque_ValorImpossivel_DeveRetornarAlternativas;
// Cenario: FCaixa possui cedulas de R$100, R$50, R$20 e R$10 (sem R$5);
//          valor desejado e R$75, que nao pode ser composto (50+20=70, faltam R$5).
// Esperado: metodo retorna ao menos uma sugestao de valor inferior que possa
//           ser composto com as cedulas disponiveis (ex: R$70 = 1x50 + 1x20).
//           Todas as sugestoes devem ser menores que o valor solicitado.
var
  Sugestoes: TArray<Currency>;
  Sugestao: Currency;
begin
  Sugestoes := FCaixa.SugerirValoresSaque(75.00);
  Assert.IsTrue(Length(Sugestoes) > 0, 'Deve retornar ao menos uma sugestao');
  for Sugestao in Sugestoes do
    Assert.IsTrue(Sugestao < 75.00,
      Format('Sugestao R$ %.2f deve ser menor que o valor solicitado', [Sugestao]));
end;

procedure TTesteCaixaEletronico.SugerirValoresSaque_CaixaVazio_DeveRetornarArrayVazio;
// Cenario: caixa sem nenhuma cedula no inventario.
// Esperado: array de sugestoes retornado vazio — sem cedulas disponiveis,
//           nenhum valor alternativo pode ser sugerido.
var
  CaixaVazia: TCaixaEletronico;
  Sugestoes: TArray<Currency>;
begin
  CaixaVazia := TCaixaEletronico.Create;
  try
    Sugestoes := CaixaVazia.SugerirValoresSaque(100.00);
    Assert.AreEqual(0, Length(Sugestoes), 'Caixa vazio nao deve retornar sugestoes');
  finally
    CaixaVazia.Free;
  end;
end;

// -- Validacao de parametros -------------------------------------------------

procedure TTesteCaixaEletronico.AdicionarCedulas_ValorZero_DeveLancarExcecao;
// Cenario: tentativa de adicionar uma denominacao com valor zero ao inventario.
// Esperado: excecao lancada na camada de dominio — valor de cedula deve ser
//           estritamente positivo, independentemente de quem chama o metodo.
begin
  Assert.WillRaise(
    procedure
    begin
      FCaixa.AdicionarCedulas(0.00, 5);
    end,
    Exception);
end;

procedure TTesteCaixaEletronico.AdicionarCedulas_QuantidadeNegativa_DeveLancarExcecao;
// Cenario: tentativa de adicionar quantidade negativa de cedulas ao inventario.
// Esperado: excecao lancada — quantidade negativa corromperia o saldo do inventario.
//           A validacao ocorre antes de qualquer acesso ao estado interno.
begin
  Assert.WillRaise(
    procedure
    begin
      FCaixa.AdicionarCedulas(10.00, -1);
    end,
    Exception);
end;

procedure TTesteCaixaEletronico.Sacar_ValorZero_DeveLancarExcecao;
// Cenario: tentativa de saque de R$0,00.
// Esperado: excecao lancada antes de verificar saldo, inventario ou estrategia —
//           um saque de zero nao tem sentido operacional e deve ser rejeitado
//           na entrada da operacao.
begin
  Assert.WillRaise(
    procedure
    begin
      FCaixa.Sacar('cliente', 0.00, FStrategy).Free;
    end,
    Exception);
end;

procedure TTesteCaixaEletronico.Sacar_ValorNegativo_DeveLancarExcecao;
// Cenario: tentativa de saque com valor negativo (ex: -R$50).
// Esperado: excecao lancada — valor negativo inverteria a logica de comparacao
//           de saldo e poderia creditar dinheiro na conta. Deve ser rejeitado
//           imediatamente pelo guard de validacao de parametros.
begin
  Assert.WillRaise(
    procedure
    begin
      FCaixa.Sacar('cliente', -50.00, FStrategy).Free;
    end,
    Exception);
end;

initialization
  TDUnitX.RegisterTestFixture(TTesteCaixaEletronico);

end.
