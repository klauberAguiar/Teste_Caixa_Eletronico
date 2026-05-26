unit UTesteInventario;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  UInventario,
  UConstantes;

type
  [TestFixture]
  TTesteInventario = class
  private
    FInventario: TInventario;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure AdicionarCedula_Nova_DeveRegistrar;
    [Test]
    procedure AdicionarCedula_Existente_DeveAcumular;
    [Test]
    procedure RemoverCedula_DeveDescontar;
    [Test]
    procedure RemoverCedula_Insuficiente_DeveLancarExcecao;
    [Test]
    procedure RemoverCedula_NaoEncontrada_DeveLancarExcecao;
    [Test]
    procedure TotalValor_DeveCalcularCorretamente;
    [Test]
    procedure TemCedulasSuficientes_DeveRetornarTrue;
    [Test]
    procedure TemCedulasSuficientes_DeveRetornarFalse;
  end;

implementation

{ TTesteInventario }

procedure TTesteInventario.Setup;
begin
  FInventario := TInventario.Create;
end;

procedure TTesteInventario.TearDown;
begin
  FInventario.Free;
end;

procedure TTesteInventario.AdicionarCedula_Nova_DeveRegistrar;
// Cenario: adicionar uma denominacao que ainda nao existe no inventario.
// Esperado: a denominacao e registrada com exatamente a quantidade informada;
//           ConsultarCedula deve retornar esse valor sem perdas nem arredondamentos.
begin
  FInventario.AdicionarCedula(50.00, 10);
  Assert.AreEqual(10, FInventario.ConsultarCedula(50.00));
end;

procedure TTesteInventario.AdicionarCedula_Existente_DeveAcumular;
// Cenario: adicionar a mesma denominacao em duas chamadas separadas (reabastecimento parcial).
// Esperado: as quantidades sao somadas (5 + 3 = 8), nao sobrescritas.
//           O inventario deve acumular corretamente multiplos reabastecimentos.
begin
  FInventario.AdicionarCedula(50.00, 5);
  FInventario.AdicionarCedula(50.00, 3);
  Assert.AreEqual(8, FInventario.ConsultarCedula(50.00));
end;

procedure TTesteInventario.RemoverCedula_DeveDescontar;
// Cenario: remover uma quantidade valida de uma denominacao existente.
// Esperado: saldo da denominacao reduzido pelo valor retirado (10 - 4 = 6);
//           o restante permanece disponivel para operacoes futuras.
begin
  FInventario.AdicionarCedula(20.00, 10);
  FInventario.RemoverCedula(20.00, 4);
  Assert.AreEqual(6, FInventario.ConsultarCedula(20.00));
end;

procedure TTesteInventario.RemoverCedula_Insuficiente_DeveLancarExcecao;
// Cenario: tentar remover mais unidades do que as disponiveis (2 existentes, 5 solicitadas).
// Esperado: excecao lancada antes de qualquer alteracao, protegendo a integridade
//           do inventario contra saldo negativo de cedulas.
begin
  FInventario.AdicionarCedula(10.00, 2);
  Assert.WillRaise(
    procedure
    begin
      FInventario.RemoverCedula(10.00, 5);
    end,
    Exception);
end;

procedure TTesteInventario.RemoverCedula_NaoEncontrada_DeveLancarExcecao;
// Cenario: tentar remover uma denominacao que nunca foi adicionada ao inventario.
// Esperado: excecao lancada — o inventario nao deve criar denominacoes inexistentes
//           nem ignorar silenciosamente a solicitacao invalida.
begin
  Assert.WillRaise(
    procedure
    begin
      FInventario.RemoverCedula(100.00, 1);
    end,
    Exception);
end;

procedure TTesteInventario.TotalValor_DeveCalcularCorretamente;
// Cenario: inventario com duas denominacoes distintas.
// Esperado: TotalValor = soma de (valor x quantidade) de cada denominacao.
//           2 x R$100 + 3 x R$50 = R$200 + R$150 = R$350.
begin
  FInventario.AdicionarCedula(100.00, 2);  // R$ 200,00
  FInventario.AdicionarCedula(50.00,  3);  // R$ 150,00
  Assert.AreEqual<Currency>(350.00, FInventario.TotalValor);
end;

procedure TTesteInventario.TemCedulasSuficientes_DeveRetornarTrue;
// Cenario: quantidade disponivel e igual a quantidade consultada (caso de fronteira exato).
// Esperado: retorna True — o limite exato deve ser considerado suficiente para o saque.
begin
  FInventario.AdicionarCedula(20.00, 5);
  Assert.IsTrue(FInventario.TemCedulasSuficientes(20.00, 5));
end;

procedure TTesteInventario.TemCedulasSuficientes_DeveRetornarFalse;
// Cenario: quantidade disponivel e inferior a solicitada (3 existentes, 5 solicitadas).
// Esperado: retorna False — utilizado como pre-validacao antes de tentar remover
//           cedulas do inventario, evitando falhas em operacoes de saque.
begin
  FInventario.AdicionarCedula(20.00, 3);
  Assert.IsFalse(FInventario.TemCedulasSuficientes(20.00, 5));
end;

initialization
  TDUnitX.RegisterTestFixture(TTesteInventario);

end.
