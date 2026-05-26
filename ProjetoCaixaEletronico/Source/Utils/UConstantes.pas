unit UConstantes;

interface

const
  // -------------------------------------------------------
  // Caminhos de arquivo
  // -------------------------------------------------------
  CFG_ARQUIVO_CONFIG = 'Config/settings.ini';
  CFG_ARQUIVO_LOG    = 'Logs/notifications.log';

  // -------------------------------------------------------
  // Secoes do arquivo de configuracao
  // -------------------------------------------------------
  INI_SEC_INVENTARIO = 'INVENTARIO';
  INI_SEC_CONTAS     = 'CONTAS';

  // -------------------------------------------------------
  // Prefixos de chave para salvamento dinamico do inventario
  // -------------------------------------------------------
  INI_PREFIXO_CEDULA = 'CEDULA_';
  INI_PREFIXO_MOEDA  = 'MOEDA_';

  // -------------------------------------------------------
  // Chaves das cedulas
  // -------------------------------------------------------
  INI_CEDULA_200 = 'CEDULA_200';
  INI_CEDULA_100 = 'CEDULA_100';
  INI_CEDULA_50  = 'CEDULA_50';
  INI_CEDULA_20  = 'CEDULA_20';
  INI_CEDULA_10  = 'CEDULA_10';
  INI_CEDULA_5   = 'CEDULA_5';
  INI_CEDULA_2   = 'CEDULA_2';

  // -------------------------------------------------------
  // Chaves das moedas
  // -------------------------------------------------------
  INI_MOEDA_1 = 'MOEDA_1';

  // -------------------------------------------------------
  // Nomes das estrategias de composicao
  // -------------------------------------------------------
  ESTRATEGIA_PADRAO      = 'Padrao (menor quantidade de cedulas)';
  ESTRATEGIA_ALTERNATIVA = 'Alternativa (preservar cedulas de maior valor)';

  // -------------------------------------------------------
  // Mensagens de erro — conta de usuario
  // -------------------------------------------------------
  ERR_CONTA_JA_EXISTE             = 'Conta de usuario ''%s'' ja existe.';
  ERR_CONTA_NAO_ENCONTRADA        = 'Conta de usuario ''%s'' nao encontrada.';
  ERR_SALDO_INSUFICIENTE_OPERACAO = 'Saldo insuficiente para a operacao.';

  // -------------------------------------------------------
  // Mensagens de erro — saque
  // -------------------------------------------------------
  ERR_ESTRATEGIA_NAO_DEFINIDA = 'Estrategia de composicao de cedulas nao definida.';
  ERR_SALDO_INSUFICIENTE      = 'Saldo insuficiente para o saque.';
  ERR_CAIXA_SEM_FUNDOS        = 'Caixa sem fundos suficientes para o saque.';
  ERR_COMPOSICAO_IMPOSSIVEL   = 'Nao foi possivel compor R$ %.2f com as cedulas disponiveis.';

  // -------------------------------------------------------
  // Mensagens de erro — inventario
  // -------------------------------------------------------
  ERR_CEDULAS_INSUFICIENTES = 'Nao ha cedulas suficientes de %.2f para remover.';
  ERR_CEDULA_NAO_ENCONTRADA = 'Cedula de %.2f nao encontrada no inventario.';

  // -------------------------------------------------------
  // Mensagens de erro — estrategia (internas, substituidas pelo Sacar)
  // -------------------------------------------------------
  ERR_COMPOSICAO_PADRAO_INTERNO = 'Nao foi possivel compor o valor solicitado com as cedulas disponiveis.';
  ERR_COMPOSICAO_ALT_INTERNO    = 'Nao foi possivel compor o valor usando a estrategia alternativa.';

  // -------------------------------------------------------
  // Mensagens de erro — entrada do usuario
  // -------------------------------------------------------
  ERR_VALOR_INVALIDO            = 'Valor invalido: "%s".';
  ERR_VALOR_DEVE_SER_POSITIVO   = 'O valor informado deve ser maior que zero.';
  ERR_QUANTIDADE_DEVE_SER_POSITIVA = 'A quantidade informada deve ser maior que zero.';

  // -------------------------------------------------------
  // Mensagens de notificacao (gravadas em log)
  // -------------------------------------------------------
  MSG_CEDULAS_ADICIONADAS    = 'Adicionadas %d cedulas de %.2f. Novo saldo total: %.2f';
  MSG_CEDULAS_REMOVIDAS      = 'Removidas %d cedulas de %.2f. Novo saldo total: %.2f';
  MSG_MOEDAS_ADICIONADAS     = 'Adicionadas %d moedas de %.2f. Novo saldo total: %.2f';
  MSG_MOEDAS_REMOVIDAS       = 'Removidas %d moedas de %.2f. Novo saldo total: %.2f';
  MSG_CONTA_CRIADA           = 'Conta ''%s'' criada com saldo inicial de %.2f.';
  MSG_NOTIFICACAO_ADICIONADA = 'Servico de notificacao adicionado.';
  MSG_SAQUE_FALHOU_SALDO     = 'Saque de %.2f para ''%s'' falhou: Saldo insuficiente (%.2f).';
  MSG_SAQUE_FALHOU_CAIXA     = 'Saque de %.2f para ''%s'' falhou: Caixa sem fundos suficientes (%.2f).';
  MSG_SAQUE_SUCESSO          = 'Saque de %.2f realizado com sucesso para ''%s''.';
  MSG_SAQUE_FALHOU           = 'Saque de %.2f para ''%s'' falhou: %s';

  // -------------------------------------------------------
  // Formato de log
  // -------------------------------------------------------
  LOG_FORMATO_ENTRADA  = '[%s] %s';
  LOG_FORMATO_DATETIME = 'yyyy-mm-dd hh:nn:ss';

  // -------------------------------------------------------
  // Interface do usuario — elementos estruturais
  // -------------------------------------------------------
  UI_SEPARADOR_DUPLO   = '=================================================';
  UI_SEPARADOR_SIMPLES = '-------------------------------------------------';
  UI_TITULO_APP        = '          CAIXA ELETRONICO  -  ATM              ';

  // -------------------------------------------------------
  // Interface do usuario — cabecalho e autenticacao
  // -------------------------------------------------------
  UI_CONTA_AUTENTICADA       = '  Conta autenticada : %s';
  UI_CONTA_NENHUMA           = '  Conta autenticada : (nenhuma)';
  UI_SALDO_CAIXA_HEADER      = '  Saldo no caixa    : R$ %.2f';
  UI_ESTRATEGIA_HEADER       = '  Estrategia        : %s';
  UI_BEM_VINDO               = '  Bem-vindo! Identifique-se para continuar.';
  UI_IDENTIFICADOR_PROMPT    = '  Identificador da conta : ';
  UI_ACESSO_AUTORIZADO       = '  Acesso autorizado. Bem-vindo, [%s]!';
  UI_VERIFIQUE_IDENTIFICADOR = '  Verifique o identificador e tente novamente.';

  // -------------------------------------------------------
  // Interface do usuario — menu principal
  // -------------------------------------------------------
  UI_OPCAO_PROMPT  = '  Opcao: ';
  UI_MENU_1        = '  [1]  Consultar Saldo do Caixa';
  UI_MENU_2        = '  [2]  Consultar Inventario do Caixa';
  UI_MENU_3        = '  [3]  Realizar Saque';
  UI_MENU_4        = '  [4]  Adicionar Cedulas ao Caixa';
  UI_MENU_5        = '  [5]  Remover Cedulas do Caixa';
  UI_MENU_6        = '  [6]  Estrategia: Padrao (menor qtd de cedulas)';
  UI_MENU_7        = '  [7]  Estrategia: Alternativa (preservar maiores)';
  UI_MENU_8        = '  [8]  Consultar Saldo de Usuario';
  UI_MENU_9        = '  [9]  Listar Usuarios Cadastrados';
  UI_MENU_0        = '  [0]  Sair';
  UI_PRESSIONE_ENTER = '  Pressione Enter para continuar...';
  UI_OPCAO_INVALIDA  = '  Opcao invalida. Tente novamente.';
  UI_ENCERRAMENTO    = '  Encerrando sistema. Ate logo!';
  UI_ERRO_PREFIX     = '  ERRO: ';

  // -------------------------------------------------------
  // Interface do usuario — tela de saldo do caixa
  // -------------------------------------------------------
  UI_SALDO_TOTAL = '  Saldo total disponivel: R$ %.2f';

  // -------------------------------------------------------
  // Interface do usuario — tela de inventario
  // -------------------------------------------------------
  UI_TITULO_INVENTARIO   = '  INVENTARIO ATUAL DO CAIXA';
  UI_INV_HEADER          = '  %-14s  %8s  %12s';
  UI_INV_LINHA           = '  R$ %8.2f  %8d  R$ %9.2f';
  UI_INV_TOTAL_LINHA     = '  %-24s  R$ %9.2f';
  UI_INV_DENOMINACAO     = 'Denominacao';
  UI_INV_QTD             = 'Qtd';
  UI_INV_SUBTOTAL        = 'Subtotal';
  UI_INV_TOTAL_LABEL     = 'TOTAL';

  // -------------------------------------------------------
  // Interface do usuario — tela de saque
  // -------------------------------------------------------
  UI_TITULO_SAQUE          = '  REALIZAR SAQUE';
  UI_SAQUE_CONTA           = '  Conta  : [%s]';
  UI_SAQUE_SALDO           = '  Saldo  : R$ %.2f';
  UI_SAQUE_VALOR_PROMPT    = '  Valor a sacar (R$) : ';
  UI_SAQUE_SUCESSO_MSG     = '  Saque de R$ %.2f realizado com sucesso!';
  UI_SAQUE_DISPENSADAS     = '  Cedulas/moedas dispensadas:';
  UI_SAQUE_CEDULA_LINHA    = '    R$ %.2f  x  %d unidades';
  UI_SAQUE_SUGESTOES       = '  Valores que podem ser sacados:';
  UI_SAQUE_SUGESTAO_LINHA  = '    -> R$ %.2f';
  UI_SAQUE_SEM_SUGESTOES   = '  Nenhum valor alternativo disponivel no momento.';

  // -------------------------------------------------------
  // Interface do usuario — tela de cedulas
  // -------------------------------------------------------
  UI_TITULO_ADICIONAR_CEDULAS = '  ADICIONAR CEDULAS';
  UI_TITULO_REMOVER_CEDULAS   = '  REMOVER CEDULAS';
  UI_CEDULA_VALOR_PROMPT      = '  Valor da cedula (R$) : ';
  UI_CEDULA_QTDE_PROMPT       = '  Quantidade           : ';
  UI_CEDULAS_ADICIONADAS_MSG  = '  %d cedulas de R$ %.2f adicionadas com sucesso.';
  UI_CEDULAS_REMOVIDAS_MSG    = '  %d cedulas de R$ %.2f removidas com sucesso.';
  UI_MOEDAS_ADICIONADAS_MSG   = '  %d moedas de R$ %.2f adicionadas com sucesso.';
  UI_MOEDAS_REMOVIDAS_MSG     = '  %d moedas de R$ %.2f removidas com sucesso.';

  // -------------------------------------------------------
  // Interface do usuario — tela de estrategia
  // -------------------------------------------------------
  UI_ESTRATEGIA_PADRAO_MSG = '  Estrategia alterada para: Padrao.';
  UI_ESTRATEGIA_ALT_MSG    = '  Estrategia alterada para: Alternativa.';

  // -------------------------------------------------------
  // Interface do usuario — tela de saldo do usuario
  // -------------------------------------------------------
  UI_TITULO_SALDO_USUARIO = '  CONSULTAR SALDO DE USUARIO';
  UI_SALDO_USUARIO_LINHA  = '  Saldo de [%s]: R$ %.2f';

  // -------------------------------------------------------
  // Interface do usuario — tela de listagem de usuarios
  // -------------------------------------------------------
  UI_TITULO_USUARIOS  = '  USUARIOS CADASTRADOS';
  UI_USR_HEADER       = '  %-24s  %s';
  UI_USR_LINHA        = '  %-24s  R$ %.2f';
  UI_USR_ID_LABEL     = 'Identificador';
  UI_USR_SALDO_LABEL  = 'Saldo';

implementation

end.
