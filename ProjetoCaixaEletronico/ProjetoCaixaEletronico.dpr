program ProjetoCaixaEletronico;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  Winapi.Windows,
  UCedula in 'Source\Core\UCedula.pas',
  UInventario in 'Source\Core\UInventario.pas',
  UContaUsuario in 'Source\Core\UContaUsuario.pas',
  UCaixaEletronico in 'Source\Core\UCaixaEletronico.pas',
  UComposicaoCedulasStrategy in 'Source\Interfaces\UComposicaoCedulasStrategy.pas',
  UNotificacaoService in 'Source\Interfaces\UNotificacaoService.pas',
  UComposicaoPadraoStrategy in 'Source\Strategies\UComposicaoPadraoStrategy.pas',
  UComposicaoAlternativaStrategy in 'Source\Strategies\UComposicaoAlternativaStrategy.pas',
  UFileNotificationService in 'Source\Services\UFileNotificationService.pas',
  UConfigManager in 'Source\Utils\UConfigManager.pas',
  UConstantes in 'Source\Utils\UConstantes.pas';

var
  Caixa: TCaixaEletronico;
  ConfigManager: TConfigManagerSingleton;
  FileNotificationService: INotificacaoService;
  EstrategiaComposicao: IComposicaoCedulasStrategy;
  EstrategiaAtual: string;

  UsuarioAutenticado: string;
  Opcao: Integer;

  Composicao: TDictionary<Currency, Integer>;
  ValorSaque: Currency;
  Sugestoes: TArray<Currency>;
  Chaves: TArray<Currency>;
  Key: Currency;
  S: Currency;

  Inventario: TList<TCedula>;
  Cedula: TCedula;
  CedulaValor: Currency;
  CedulaQuantidade: Integer;

  IDs: TArray<string>;
  ID: string;

// ---------------------------------------------------------------------------

procedure LimparTela;
var
  Handle: THandle;
  Coord: TCoord;
  Info: TConsoleScreenBufferInfo;
  Written: DWORD;
begin
  Handle := GetStdHandle(STD_OUTPUT_HANDLE);
  Coord.X := 0;
  Coord.Y := 0;
  GetConsoleScreenBufferInfo(Handle, Info);
  FillConsoleOutputCharacter(Handle, ' ', Info.dwSize.X * Info.dwSize.Y, Coord, Written);
  FillConsoleOutputAttribute(Handle, Info.wAttributes, Info.dwSize.X * Info.dwSize.Y, Coord, Written);
  SetConsoleCursorPosition(Handle, Coord);
end;

procedure AguardarEnter;
begin
  Writeln('');
  Write(UI_PRESSIONE_ENTER);
  Readln;
end;

function LerValorMonetario: Currency;
var
  Str: string;
  Valor: Extended;
  FS: TFormatSettings;
begin
  Readln(Str);
  Str := Trim(Str);
  // Se tiver ponto E virgula juntos, o ultimo deles e o separador decimal
  if Str.Contains('.') and Str.Contains(',') then
  begin
    if Str.LastIndexOf('.') > Str.LastIndexOf(',') then
      // Formato ingles - 1,500.77 -> remove virgula (milhar)
      Str := Str.Replace(',', '')
    else
      // Formato brasileiro - 1.500,77 -> remove ponto (milhar), virgula vira ponto
      Str := Str.Replace('.', '').Replace(',', '.');
  end
  else
    // Somente um separador - normaliza virgula para ponto
    Str := Str.Replace(',', '.');
  FS := TFormatSettings.Invariant;
  if not TryStrToFloat(Str, Valor, FS) then
    raise Exception.CreateFmt(ERR_VALOR_INVALIDO, [Str]);
  Result := Valor;
end;

procedure ExibirCabecalho;
begin
  LimparTela;
  Writeln(UI_SEPARADOR_DUPLO);
  Writeln(UI_TITULO_APP);
  Writeln(UI_SEPARADOR_DUPLO);
  if UsuarioAutenticado <> '' then
    Writeln(Format(UI_CONTA_AUTENTICADA, [UsuarioAutenticado]))
  else
    Writeln(UI_CONTA_NENHUMA);
  Writeln(Format(UI_SALDO_CAIXA_HEADER, [Caixa.ConsultarSaldoTotal]));
  Writeln(Format(UI_ESTRATEGIA_HEADER, [EstrategiaAtual]));
  Writeln(UI_SEPARADOR_SIMPLES);
end;

procedure ExibirMenu;
begin
  ExibirCabecalho;
  Writeln(UI_MENU_1);
  Writeln(UI_MENU_2);
  Writeln(UI_MENU_3);
  Writeln(UI_MENU_4);
  Writeln(UI_MENU_5);
  Writeln(UI_MENU_6);
  Writeln(UI_MENU_7);
  Writeln(UI_MENU_8);
  Writeln(UI_MENU_9);
  Writeln(UI_MENU_0);
  Writeln(UI_SEPARADOR_DUPLO);
  Write(UI_OPCAO_PROMPT);
end;

procedure InicializarCaixa;
var
  SecInventario: TStringList;
  Contas: TStringList;
  I: Integer;
  ChaveIni: string;
  ValorStr: string;
  QtdIni: Integer;
  ValorIni: Extended;
  UserID: string;
  SaldoStr: string;
  Saldo: Extended;
  FS: TFormatSettings;
begin
  ConfigManager := TConfigManagerSingleton.GetInstance(CFG_ARQUIVO_CONFIG);

  FileNotificationService := TFileNotificationService.Create(CFG_ARQUIVO_LOG);
  Caixa.AdicionarServicoNotificacao(FileNotificationService);

  FS := TFormatSettings.Invariant;
  SecInventario := TStringList.Create;
  try
    ConfigManager.ReadSectionValues(INI_SEC_INVENTARIO, SecInventario);
    for I := 0 to SecInventario.Count - 1 do
    begin
      ChaveIni := SecInventario.Names[I];
      QtdIni   := StrToIntDef(SecInventario.ValueFromIndex[I], 0);
      if QtdIni <= 0 then Continue;

      if ChaveIni.StartsWith(INI_PREFIXO_CEDULA) then
        ValorStr := Copy(ChaveIni, Length(INI_PREFIXO_CEDULA) + 1, MaxInt)
      else if ChaveIni.StartsWith(INI_PREFIXO_MOEDA) then
        ValorStr := Copy(ChaveIni, Length(INI_PREFIXO_MOEDA) + 1, MaxInt)
      else
        Continue;

      ValorStr := ValorStr.Replace('_', '.');
      if TryStrToFloat(ValorStr, ValorIni, FS) and (ValorIni > 0) then
        Caixa.AdicionarCedulas(ValorIni, QtdIni);
    end;
  finally
    SecInventario.Free;
  end;

  Contas := TStringList.Create;
  try
    ConfigManager.ReadSectionValues(INI_SEC_CONTAS, Contas);
    for I := 0 to Contas.Count - 1 do
    begin
      UserID   := Contas.Names[I];
      SaldoStr := Contas.ValueFromIndex[I];
      if UserID <> '' then
      begin
        if not TryStrToFloat(SaldoStr, Saldo, FS) then
          Saldo := 0;
        Caixa.AdicionarContaUsuario(UserID, Saldo);
      end;
    end;
  finally
    Contas.Free;
  end;

  EstrategiaAtual := ESTRATEGIA_PADRAO;
  EstrategiaComposicao := TComposicaoPadraoStrategy.Create;
end;

procedure SalvarEstadoCaixa;
var
  Cedula: TCedula;
  Prefixo: string;
  Chave: string;
  ID: string;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Invariant;

  ConfigManager.EraseSection(INI_SEC_INVENTARIO);
  Inventario := Caixa.ConsultarInventario;
  try
    for Cedula in Inventario do
    begin
      if Cedula.Quantidade = 0 then
        Continue;
      if Cedula.Valor < 2.00 then
        Prefixo := INI_PREFIXO_MOEDA
      else
        Prefixo := INI_PREFIXO_CEDULA;
      Chave := Prefixo + FloatToStr(Cedula.Valor, FS).Replace('.', '_');
      ConfigManager.WriteInteger(INI_SEC_INVENTARIO, Chave, Cedula.Quantidade);
    end;
  finally
    Inventario.Free;
  end;

  ConfigManager.EraseSection(INI_SEC_CONTAS);
  for ID in Caixa.ObterIdentificadoresContas do
    ConfigManager.WriteFloat(INI_SEC_CONTAS, ID, Caixa.ObterContaUsuario(ID).SaldoAtual);

  ConfigManager.UpdateIniFile;
end;

procedure Autenticar;
begin
  UsuarioAutenticado := '';
  repeat
    LimparTela;
    Writeln(UI_SEPARADOR_DUPLO);
    Writeln(UI_TITULO_APP);
    Writeln(UI_SEPARADOR_DUPLO);
    Writeln(UI_BEM_VINDO);
    Writeln('');
    Write(UI_IDENTIFICADOR_PROMPT);
    Readln(UsuarioAutenticado);
    UsuarioAutenticado := Trim(UsuarioAutenticado);
    Writeln('');
    try
      Caixa.ObterContaUsuario(UsuarioAutenticado);
      Writeln(Format(UI_ACESSO_AUTORIZADO, [UsuarioAutenticado]));
      AguardarEnter;
    except
      on E: Exception do
      begin
        Writeln('  ' + E.Message);
        Writeln(UI_VERIFIQUE_IDENTIFICADOR);
        UsuarioAutenticado := '';
        AguardarEnter;
      end;
    end;
  until UsuarioAutenticado <> '';
end;

// ---------------------------------------------------------------------------

begin
  SetConsoleOutputCP(1252);
  SetConsoleCP(1252);
  FormatSettings.DecimalSeparator  := ',';
  FormatSettings.ThousandSeparator := '.';

  Caixa := TCaixaEletronico.Create;
  try
    InicializarCaixa;
    Autenticar;

    repeat
      ExibirMenu;
      try
        Readln(Opcao);
      except
        Opcao := -1;
      end;

      case Opcao of
        1:
        begin
          ExibirCabecalho;
          Writeln(Format(UI_SALDO_TOTAL, [Caixa.ConsultarSaldoTotal]));
          AguardarEnter;
        end;

        2:
        begin
          ExibirCabecalho;
          Writeln(UI_TITULO_INVENTARIO);
          Writeln('  ' + StringOfChar('-', 46));
          Writeln(Format(UI_INV_HEADER, [UI_INV_DENOMINACAO, UI_INV_QTD, UI_INV_SUBTOTAL]));
          Writeln('  ' + StringOfChar('-', 46));
          Inventario := Caixa.ConsultarInventario;
          try
            for Cedula in Inventario do
              if Cedula.Quantidade > 0 then
                Writeln(Format(UI_INV_LINHA,
                  [Cedula.Valor, Cedula.Quantidade, Cedula.Valor * Cedula.Quantidade]));
          finally
            Inventario.Free;
          end;
          Writeln('  ' + StringOfChar('-', 46));
          Writeln(Format(UI_INV_TOTAL_LINHA, [UI_INV_TOTAL_LABEL, Caixa.ConsultarSaldoTotal]));
          AguardarEnter;
        end;

        3:
        begin
          ExibirCabecalho;
          Writeln(UI_TITULO_SAQUE);
          Writeln('');
          Writeln(Format(UI_SAQUE_CONTA, [UsuarioAutenticado]));
          Writeln(Format(UI_SAQUE_SALDO, [Caixa.ObterContaUsuario(UsuarioAutenticado).SaldoAtual]));
          Writeln('');
          Write(UI_SAQUE_VALOR_PROMPT);
          ValorSaque := LerValorMonetario;
          Writeln('');
          try
            Composicao := Caixa.Sacar(UsuarioAutenticado, ValorSaque, EstrategiaComposicao);
            try
              Chaves := Composicao.Keys.ToArray;
              TArray.Sort<Currency>(Chaves, TComparer<Currency>.Construct(
                function(const L, R: Currency): Integer
                begin
                  if L > R then Result := -1
                  else if L < R then Result := 1
                  else Result := 0;
                end));
              Writeln(Format(UI_SAQUE_SUCESSO_MSG, [ValorSaque]));
              Writeln(UI_SAQUE_DISPENSADAS);
              for Key in Chaves do
                Writeln(Format(UI_SAQUE_CEDULA_LINHA, [Key, Composicao[Key]]));
            finally
              FreeAndNil(Composicao);
            end;
          except
            on E: EComposicaoImpossivel do
            begin
              Writeln(UI_ERRO_PREFIX + E.Message);
              Writeln('');
              Sugestoes := Caixa.SugerirValoresSaque(ValorSaque);
              if Length(Sugestoes) > 0 then
              begin
                Writeln(UI_SAQUE_SUGESTOES);
                for S in Sugestoes do
                  Writeln(Format(UI_SAQUE_SUGESTAO_LINHA, [S]));
              end
              else
                Writeln(UI_SAQUE_SEM_SUGESTOES);
            end;
            on E: Exception do
              Writeln(UI_ERRO_PREFIX + E.Message);
          end;
          AguardarEnter;
        end;

        4:
        begin
          ExibirCabecalho;
          Writeln(UI_TITULO_ADICIONAR_CEDULAS);
          Writeln('');
          Write(UI_CEDULA_VALOR_PROMPT);
          CedulaValor := LerValorMonetario;
          Write(UI_CEDULA_QTDE_PROMPT);
          Readln(CedulaQuantidade);
          Writeln('');
          try
            Caixa.AdicionarCedulas(CedulaValor, CedulaQuantidade);
            if CedulaValor < 2.00 then
              Writeln(Format(UI_MOEDAS_ADICIONADAS_MSG, [CedulaQuantidade, CedulaValor]))
            else
              Writeln(Format(UI_CEDULAS_ADICIONADAS_MSG, [CedulaQuantidade, CedulaValor]));
          except
            on E: Exception do
              Writeln(UI_ERRO_PREFIX + E.Message);
          end;
          AguardarEnter;
        end;

        5:
        begin
          ExibirCabecalho;
          Writeln(UI_TITULO_REMOVER_CEDULAS);
          Writeln('');
          Write(UI_CEDULA_VALOR_PROMPT);
          CedulaValor := LerValorMonetario;
          Write(UI_CEDULA_QTDE_PROMPT);
          Readln(CedulaQuantidade);
          Writeln('');
          try
            Caixa.RemoverCedulas(CedulaValor, CedulaQuantidade);
            if CedulaValor < 2.00 then
              Writeln(Format(UI_MOEDAS_REMOVIDAS_MSG, [CedulaQuantidade, CedulaValor]))
            else
              Writeln(Format(UI_CEDULAS_REMOVIDAS_MSG, [CedulaQuantidade, CedulaValor]));
          except
            on E: Exception do
              Writeln(UI_ERRO_PREFIX + E.Message);
          end;
          AguardarEnter;
        end;

        6:
        begin
          EstrategiaComposicao := TComposicaoPadraoStrategy.Create;
          EstrategiaAtual := ESTRATEGIA_PADRAO;
          ExibirCabecalho;
          Writeln(UI_ESTRATEGIA_PADRAO_MSG);
          AguardarEnter;
        end;

        7:
        begin
          EstrategiaComposicao := TComposicaoAlternativaStrategy.Create;
          EstrategiaAtual := ESTRATEGIA_ALTERNATIVA;
          ExibirCabecalho;
          Writeln(UI_ESTRATEGIA_ALT_MSG);
          AguardarEnter;
        end;

        8:
        begin
          ExibirCabecalho;
          Writeln(UI_TITULO_SALDO_USUARIO);
          Writeln('');
          try
            Writeln(Format(UI_SALDO_USUARIO_LINHA, [UsuarioAutenticado, Caixa.ObterContaUsuario(UsuarioAutenticado).SaldoAtual]));
          except
            on E: Exception do
              Writeln(UI_ERRO_PREFIX + E.Message);
          end;
          AguardarEnter;
        end;

        9:
        begin
          ExibirCabecalho;
          Writeln(UI_TITULO_USUARIOS);
          Writeln('  ' + StringOfChar('-', 40));
          Writeln(Format(UI_USR_HEADER, [UI_USR_ID_LABEL, UI_USR_SALDO_LABEL]));
          Writeln('  ' + StringOfChar('-', 40));
          IDs := Caixa.ObterIdentificadoresContas;
          TArray.Sort<string>(IDs);
          for ID in IDs do
            Writeln(Format(UI_USR_LINHA,
              [ID, Caixa.ObterContaUsuario(ID).SaldoAtual]));
          Writeln('  ' + StringOfChar('-', 40));
          AguardarEnter;
        end;

        0:
        begin
          LimparTela;
          Writeln(UI_ENCERRAMENTO);
          Writeln('');
        end;

        else
        begin
          Writeln('');
          Writeln(UI_OPCAO_INVALIDA);
          AguardarEnter;
        end;
      end;
    until Opcao = 0;

  finally
    SalvarEstadoCaixa;
    Caixa.Free;
    TConfigManagerSingleton.ReleaseInstance;
  end;
end.
