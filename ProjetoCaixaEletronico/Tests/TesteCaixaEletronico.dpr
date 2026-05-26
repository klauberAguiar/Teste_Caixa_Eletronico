program TesteCaixaEletronico;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  UCedula               in '..\Source\Core\UCedula.pas',
  UInventario           in '..\Source\Core\UInventario.pas',
  UContaUsuario         in '..\Source\Core\UContaUsuario.pas',
  UCaixaEletronico      in '..\Source\Core\UCaixaEletronico.pas',
  UComposicaoCedulasStrategy  in '..\Source\Interfaces\UComposicaoCedulasStrategy.pas',
  UNotificacaoService         in '..\Source\Interfaces\UNotificacaoService.pas',
  UComposicaoPadraoStrategy   in '..\Source\Strategies\UComposicaoPadraoStrategy.pas',
  UComposicaoAlternativaStrategy in '..\Source\Strategies\UComposicaoAlternativaStrategy.pas',
  UConstantes           in '..\Source\Utils\UConstantes.pas',
  UTesteInventario      in 'UTesteInventario.pas',
  UTesteContaUsuario    in 'UTesteContaUsuario.pas',
  UTesteEstrategias     in 'UTesteEstrategias.pas',
  UTesteCaixaEletronico in 'UTesteCaixaEletronico.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
begin
  // Suprime notificacoes de first-chance exception do depurador do IDE.
  // Sem isso, cada excecao esperada nos testes (Assert.WillRaise) interrompe
  // a execucao e exige um clique em "Continue" no Delphi.
  // Nao tem efeito fora do IDE (DebugHook ja e 0 em executaveis normais).
  DebugHook := 0;

  try
    Runner := TDUnitX.CreateRunner;
    Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
    Runner.FailsOnNoAsserts := False;
    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := EXIT_ERRORS;
    Writeln('');
    Write('Pressione Enter para sair...');
    Readln;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;
end.
