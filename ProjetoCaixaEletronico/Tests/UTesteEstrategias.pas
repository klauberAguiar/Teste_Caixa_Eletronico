unit UTesteEstrategias;

// Inventario padrao usado nos testes:
//   5 cedulas de cada denominacao: 200, 100, 50, 20, 10
//
// Estrategia Padrao (descendente — menor quantidade de cedulas):
//   Ordena do maior para o menor valor e greedily preenche o montante.
//   R$80 → 1x50 + 1x20 + 1x10 = 3 cedulas
//
// Estrategia Alternativa (ascendente — preservar cedulas de maior valor):
//   Ordena do menor para o maior valor, consumindo as menores primeiro.
//   R$30 → 3x10 = 3 cedulas  (a padrao usaria 1x20 + 1x10, consumindo o R$20)

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  DUnitX.TestFramework,
  UCedula,
  UComposicaoCedulasStrategy,
  UComposicaoPadraoStrategy,
  UComposicaoAlternativaStrategy,
  UConstantes;

type
  [TestFixture]
  TTesteEstrategias = class
  private
    FInventario: TList<TCedula>;
    procedure AdicionarCedula(AValor: Currency; AQuantidade: Integer);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // -- Estrategia Padrao ---------------------------------------------------
    [Test]
    procedure Padrao_ValorExato_DeveUsarMenorQuantidadeDeCedulas;
    [Test]
    procedure Padrao_ValorImpossivel_DeveLancarExcecao;
    [Test]
    procedure Padrao_InventarioVazio_DeveLancarExcecao;

    // -- Estrategia Alternativa ----------------------------------------------
    [Test]
    procedure Alternativa_DevePreservarCedulasDeMaiorValor;
    [Test]
    procedure Alternativa_ValorImpossivel_DeveLancarExcecao;
    [Test]
    procedure Alternativa_DiferesDoPadraoNaEscolhaDeCedulas;
  end;

implementation

{ TTesteEstrategias }

procedure TTesteEstrategias.Setup;
begin
  FInventario := TList<TCedula>.Create;
end;

procedure TTesteEstrategias.TearDown;
begin
  FInventario.Free;
end;

procedure TTesteEstrategias.AdicionarCedula(AValor: Currency; AQuantidade: Integer);
var
  Cedula: TCedula;
begin
  Cedula.Valor      := AValor;
  Cedula.Quantidade := AQuantidade;
  FInventario.Add(Cedula);
end;

// -- Estrategia Padrao -------------------------------------------------------

procedure TTesteEstrategias.Padrao_ValorExato_DeveUsarMenorQuantidadeDeCedulas;
// Cenario: inventario com 5 cedulas de cada denominacao (200, 100, 50, 20, 10);
//          solicitar composicao de R$80 com a estrategia padrao (descendente).
// Esperado: algoritmo guloso (greedy) percorre do maior para o menor valor e,
//           a cada denominacao, pega o maximo possivel antes de passar para a proxima.
//           Resultado: 1x50 + 1x20 + 1x10 = 3 cedulas. Nao usa R$100 nem R$200
//           porque ambos excedem o valor restante em seus respectivos passos.
var
  Strategy: IComposicaoCedulasStrategy;
  Resultado: TDictionary<Currency, Integer>;
begin
  AdicionarCedula(200.00, 5);
  AdicionarCedula(100.00, 5);
  AdicionarCedula(50.00,  5);
  AdicionarCedula(20.00,  5);
  AdicionarCedula(10.00,  5);

  Strategy  := TComposicaoPadraoStrategy.Create;
  Resultado := Strategy.ObterComposicao(80.00, FInventario);
  try
    Assert.AreEqual(1, Resultado[50.00], 'Deve usar 1 cedula de 50');
    Assert.AreEqual(1, Resultado[20.00], 'Deve usar 1 cedula de 20');
    Assert.AreEqual(1, Resultado[10.00], 'Deve usar 1 cedula de 10');
    Assert.IsFalse(Resultado.ContainsKey(200.00), 'Nao deve usar cedula de 200');
    Assert.IsFalse(Resultado.ContainsKey(100.00), 'Nao deve usar cedula de 100');
  finally
    Resultado.Free;
  end;
end;

procedure TTesteEstrategias.Padrao_ValorImpossivel_DeveLancarExcecao;
// Cenario: inventario contem apenas cedulas de R$50; valor solicitado e R$30.
// Esperado: excecao lancada — nenhuma combinacao inteira de R$50 resulta em R$30
//           exatamente. A estrategia nao deve retornar composicao parcial nem R$0.
var
  Strategy: IComposicaoCedulasStrategy;
begin
  AdicionarCedula(50.00, 10);
  Strategy := TComposicaoPadraoStrategy.Create;
  Assert.WillRaise(
    procedure
    begin
      Strategy.ObterComposicao(30.00, FInventario).Free;
    end,
    Exception);
end;

procedure TTesteEstrategias.Padrao_InventarioVazio_DeveLancarExcecao;
// Cenario: inventario sem nenhuma cedula; qualquer valor e impossivel de compor.
// Esperado: excecao lancada imediatamente — a estrategia nao deve retornar
//           composicao vazia nem nil como resultado valido.
var
  Strategy: IComposicaoCedulasStrategy;
begin
  // FInventario vazio
  Strategy := TComposicaoPadraoStrategy.Create;
  Assert.WillRaise(
    procedure
    begin
      Strategy.ObterComposicao(50.00, FInventario).Free;
    end,
    Exception);
end;

// -- Estrategia Alternativa --------------------------------------------------

procedure TTesteEstrategias.Alternativa_DevePreservarCedulasDeMaiorValor;
// Cenario: inventario com 5 cedulas de cada denominacao (200, 100, 50, 20, 10);
//          solicitar composicao de R$30 com a estrategia alternativa (ascendente).
// Esperado: algoritmo guloso (greedy) percorre do menor para o maior valor e,
//           a cada denominacao, pega o maximo possivel antes de passar para a proxima.
//           Resultado: 3x10 = R$30, deixando intactas as cedulas de 20, 50, 100
//           e 200 para saques futuros de maior valor.
var
  Strategy: IComposicaoCedulasStrategy;
  Resultado: TDictionary<Currency, Integer>;
begin
  AdicionarCedula(200.00, 5);
  AdicionarCedula(100.00, 5);
  AdicionarCedula(50.00,  5);
  AdicionarCedula(20.00,  5);
  AdicionarCedula(10.00,  5);

  Strategy  := TComposicaoAlternativaStrategy.Create;
  Resultado := Strategy.ObterComposicao(30.00, FInventario);
  try
    Assert.AreEqual(3, Resultado[10.00], 'Deve usar 3 cedulas de 10');
    Assert.IsFalse(Resultado.ContainsKey(20.00),  'Nao deve tocar na cedula de 20');
    Assert.IsFalse(Resultado.ContainsKey(50.00),  'Nao deve tocar na cedula de 50');
    Assert.IsFalse(Resultado.ContainsKey(100.00), 'Nao deve tocar na cedula de 100');
    Assert.IsFalse(Resultado.ContainsKey(200.00), 'Nao deve tocar na cedula de 200');
  finally
    Resultado.Free;
  end;
end;

procedure TTesteEstrategias.Alternativa_ValorImpossivel_DeveLancarExcecao;
// Cenario: inventario contem apenas cedulas de R$100; valor solicitado e R$30.
// Esperado: excecao lancada — nenhuma combinacao inteira de R$100 resulta em R$30.
//           Verifica que a estrategia alternativa tambem trata impossibilidade corretamente.
var
  Strategy: IComposicaoCedulasStrategy;
begin
  AdicionarCedula(100.00, 5);
  Strategy := TComposicaoAlternativaStrategy.Create;
  Assert.WillRaise(
    procedure
    begin
      Strategy.ObterComposicao(30.00, FInventario).Free;
    end,
    Exception);
end;

procedure TTesteEstrategias.Alternativa_DiferesDoPadraoNaEscolhaDeCedulas;
// Cenario: inventario com apenas R$20 e R$10 (5 de cada); ambas as estrategias
//          conseguem compor R$30, mas com escolhas de cedulas distintas.
// Esperado:
//   - Estrategia padrao  (desc 20→10): 1x20 + 1x10 = 2 cedulas (menor quantidade)
//   - Estrategia alternativa (asc 10→20): 3x10       = 3 cedulas (preserva o R$20)
// Este teste valida que o padrao Strategy produz comportamentos diferentes
// conforme a implementacao injetada, sem alterar o contrato da interface.
var
  StrategyPadrao: IComposicaoCedulasStrategy;
  StrategyAlt: IComposicaoCedulasStrategy;
  ResultadoPadrao: TDictionary<Currency, Integer>;
  ResultadoAlt: TDictionary<Currency, Integer>;
begin
  AdicionarCedula(20.00, 5);
  AdicionarCedula(10.00, 5);

  StrategyPadrao := TComposicaoPadraoStrategy.Create;
  StrategyAlt    := TComposicaoAlternativaStrategy.Create;

  ResultadoPadrao := StrategyPadrao.ObterComposicao(30.00, FInventario);
  ResultadoAlt    := StrategyAlt.ObterComposicao(30.00, FInventario);
  try
    // Padrao: usa 1x20 + 1x10 (2 cedulas — menor quantidade)
    Assert.IsTrue(ResultadoPadrao.ContainsKey(20.00), 'Padrao deve usar cedula de 20');

    // Alternativa: usa 3x10 (3 cedulas — preserva o R$20)
    Assert.IsFalse(ResultadoAlt.ContainsKey(20.00), 'Alternativa nao deve usar cedula de 20');
    Assert.AreEqual(3, ResultadoAlt[10.00], 'Alternativa deve usar 3 cedulas de 10');
  finally
    ResultadoPadrao.Free;
    ResultadoAlt.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTesteEstrategias);

end.
