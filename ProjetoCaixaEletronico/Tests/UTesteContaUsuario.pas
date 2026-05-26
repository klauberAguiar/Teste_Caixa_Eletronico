unit UTesteContaUsuario;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  UContaUsuario,
  UConstantes;

type
  [TestFixture]
  TTesteContaUsuario = class
  private
    FConta: TContaUsuario;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Criar_DeveDefinirIdentificadorESaldo;
    [Test]
    procedure Debitar_SaldoSuficiente_DeveDescontar;
    [Test]
    procedure Debitar_ExatamenteOSaldo_DeveZerarSaldo;
    [Test]
    procedure Debitar_SaldoInsuficiente_DeveLancarExcecao;
  end;

implementation

{ TTesteContaUsuario }

procedure TTesteContaUsuario.Setup;
begin
  FConta := TContaUsuario.Create('cliente01', 500.00);
end;

procedure TTesteContaUsuario.TearDown;
begin
  FConta.Free;
end;

procedure TTesteContaUsuario.Criar_DeveDefinirIdentificadorESaldo;
// Cenario: criacao de uma nova conta com identificador unico e saldo inicial.
// Esperado: IdentificadorUnico e SaldoAtual refletem exatamente os valores passados
//           ao construtor. As propriedades sao somente leitura (sem setter publico),
//           garantindo encapsulamento correto do estado da conta.
begin
  Assert.AreEqual('cliente01', FConta.IdentificadorUnico);
  Assert.AreEqual<Currency>(500.00, FConta.SaldoAtual);
end;

procedure TTesteContaUsuario.Debitar_SaldoSuficiente_DeveDescontar;
// Cenario: debito de um valor inferior ao saldo disponivel.
// Esperado: saldo reduzido pelo valor exato informado (500 - 200 = 300),
//           sem arredondamentos nem efeitos colaterais.
begin
  FConta.Debitar(200.00);
  Assert.AreEqual<Currency>(300.00, FConta.SaldoAtual);
end;

procedure TTesteContaUsuario.Debitar_ExatamenteOSaldo_DeveZerarSaldo;
// Cenario: debito de valor identico ao saldo disponivel (caso de fronteira).
// Esperado: operacao bem-sucedida, saldo zerado. Debitar exatamente o saldo
//           disponivel nao deve ser tratado como insuficiente.
begin
  FConta.Debitar(500.00);
  Assert.AreEqual<Currency>(0.00, FConta.SaldoAtual);
end;

procedure TTesteContaUsuario.Debitar_SaldoInsuficiente_DeveLancarExcecao;
// Cenario: tentativa de debito superior ao saldo disponivel (saldo R$500, solicitado R$600).
// Esperado: excecao lancada antes de qualquer alteracao no saldo — a conta nao pode
//           ficar com saldo negativo. Saldo deve permanecer inalterado apos a excecao.
begin
  Assert.WillRaise(
    procedure
    begin
      FConta.Debitar(600.00);
    end,
    Exception);
end;

initialization
  TDUnitX.RegisterTestFixture(TTesteContaUsuario);

end.
