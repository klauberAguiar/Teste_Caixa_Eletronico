# Teste Técnico Escalasoft - Sistema de Caixa Eletrônico (Delphi)

## Visão Geral

Este projeto apresenta uma solução para o teste técnico da Escalasoft, implementando um sistema de caixa eletrônico em Delphi. O foco principal foi demonstrar **boas práticas de desenvolvimento, arquitetura limpa, modularidade e extensibilidade**, utilizando apenas bibliotecas nativas da linguagem, conforme as instruções do teste.

## Requisitos Atendidos

Todos os requisitos especificados no documento `TesteEscalasoftv3.pdf` foram abordados:

*   **Questão 1: Gestão de Inventário de Cédulas e Moedas**
    *   Adição e remoção de valores de cédulas/moedas.
    *   Operações de carregar, descarregar e consultar o estoque e o valor total disponível no caixa.
*   **Questão 2: Funcionalidade de Saque com Estratégias Configuráveis**
    *   Definição de um contrato (`IComposicaoCedulasStrategy`) para estratégias de composição de cédulas.
    *   Duas implementações de estratégia:
        *   **Estratégia Padrão (`TComposicaoPadraoStrategy`):** Busca a menor quantidade de cédulas.
        *   **Estratégia Alternativa (`TComposicaoAlternativaStrategy`):** Prioriza a preservação das cédulas de maior valor (ex: R$100, R$200), evitando que o caixa fique com troco "preso".
    *   O componente de saque não "sabe" qual estratégia está sendo usada, apenas recebe e executa.
    *   Saque permitido apenas se compor o valor exato.
*   **Questão 3: Mecanismo de Notificação**
    *   Interface de notificação (`INotificacaoService`).
    *   Implementação de registro de eventos em arquivo de texto (`TFileNotificationService`), incluindo data, hora e mensagem da operação.
*   **Questão 4: Lógica de Identificação de Valor Inexistente/Sugestão**
    *   O sistema detecta quando o valor solicitado não pode ser entregue com a composição atual de cédulas.
    *   Retorna mensagem de erro clara.
*   **Questão 5: Modelo de Contas de Usuário**
    *   Contas com `Identificador Único` para autenticação e `Saldo Atual`.
    *   Todas as interações com o caixa eletrônico são iniciadas informando o identificador da conta.

## Arquitetura e Design

A solução foi projetada com base nos princípios de **Orientação a Objetos (OOP)** e **Separação de Responsabilidades**, utilizando padrões de projeto para garantir um código limpo, testável e de fácil manutenção.

### Estrutura de Pastas

```
ProjetoCaixaEletronico/
├── Source/
│   ├── Core/                  // Classes do domínio principal e lógica de negócio
│   │   ├── UCaixaEletronico.pas
│   │   ├── UContaUsuario.pas
│   │   ├── UCedula.pas
│   │   └── UInventario.pas
│   ├── Interfaces/            // Definições de interfaces para estratégias e serviços
│   │   ├── IComposicaoCedulasStrategy.pas
│   │   └── INotificacaoService.pas
│   ├── Strategies/            // Implementações das estratégias de composição de cédulas
│   │   ├── TComposicaoPadraoStrategy.pas
│   │   └── TComposicaoAlternativaStrategy.pas
│   ├── Services/              // Implementações dos serviços (e.g., notificação)
│   │   └── TFileNotificationService.pas
│   ├── Utils/                 // Utilitários e classes auxiliares
│   │   └── UConfigManager.pas // Para gerenciar configurações (e.g., .ini file)
│   └── MainModule.pas         // Módulo principal ou ponto de entrada da aplicação (se console)
├── Config/
│   └── settings.ini           // Arquivo de configuração (inventário inicial, saldos de usuários)
├── Logs/
│   └── notifications.log      // Arquivo de log para notificações
└── ProjetoCaixaEletronico.dpr // Arquivo principal do projeto Delphi
```

### Componentes Chave

*   **`UCedula`**: Um `record` simples para representar uma cédula ou moeda com `Valor` e `Quantidade`.
*   **`UInventario`**: Gerencia a coleção de `TCedula`, permitindo adicionar, remover, consultar e calcular o valor total. Utiliza `TList<TCedula>` para armazenar as cédulas.
*   **`UContaUsuario`**: Representa uma conta de usuário com `IdentificadorUnico` e `SaldoAtual`, oferecendo métodos para `Debitar` e `Creditar`.
*   **`IComposicaoCedulasStrategy`**: Interface que define o contrato para as estratégias de saque. O método `ObterComposicao` recebe o valor desejado e o inventário disponível, retornando um `TDictionary<Currency, Integer>` com a composição de cédulas.
*   **`TComposicaoPadraoStrategy`**: Implementação de `IComposicaoCedulasStrategy` que busca a menor quantidade de cédulas para o saque, priorizando as de maior valor.
*   **`TComposicaoAlternativaStrategy`**: Implementação de `IComposicaoCedulasStrategy` que busca preservar as cédulas de maior valor, utilizando uma abordagem que tenta usar o máximo de cédulas menores, mas garantindo que o valor total seja atingido.
*   **`INotificacaoService`**: Interface para serviços de notificação, com o método `RegistrarNotificacao`.
*   **`TFileNotificationService`**: Implementação de `INotificacaoService` que registra as notificações em um arquivo de log (`notifications.log`).
*   **`UConfigManager`**: Uma classe Singleton para gerenciar configurações a partir de um arquivo `.ini` (`settings.ini`). Permite ler e escrever strings, inteiros e floats, e é usada para persistir o inventário do caixa e os saldos dos usuários.
*   **`UCaixaEletronico`**: A classe central que orquestra as operações. Ela possui um `TInventario`, um `TDictionary` de `TContaUsuario`, uma `IComposicaoCedulasStrategy` e uma `TList` de `INotificacaoService`. É responsável por:
    *   Adicionar/remover cédulas.
    *   Adicionar/obter contas de usuário.
    *   Definir a estratégia de composição de cédulas.
    *   Adicionar serviços de notificação.
    *   Realizar saques, validando saldo do usuário e do caixa, e utilizando a estratégia de composição configurada.
    *   Notificar eventos importantes através dos serviços de notificação registrados.

### Padrões de Projeto Aplicados

*   **Strategy Pattern**: Utilizado para as diferentes lógicas de composição de cédulas (`IComposicaoCedulasStrategy`, `TComposicaoPadraoStrategy`, `TComposicaoAlternativaStrategy`). Isso permite trocar a estratégia em tempo de execução sem modificar a classe `TCaixaEletronico`.
*   **Dependency Injection**: A classe `TCaixaEletronico` recebe suas dependências (estratégia de composição e serviços de notificação) via métodos, o que facilita a testabilidade e a flexibilidade.
*   **Singleton Pattern**: Aplicado a `TConfigManager` para garantir que haja apenas uma instância do gerenciador de configurações em toda a aplicação.
*   **Observer Pattern (simplificado)**: A classe `TCaixaEletronico` mantém uma lista de `INotificacaoService` e notifica todos os serviços registrados sobre eventos, permitindo adicionar novos mecanismos de notificação facilmente.

### Boas Práticas

*   **Código Limpo e Comentado**: O código é estruturado de forma clara, com nomes de classes, métodos e variáveis em português, seguindo as convenções do Delphi. Comentários são utilizados para explicar lógicas complexas ou decisões de design.
*   **Separação de Responsabilidades**: Cada unidade (unit) e classe tem uma responsabilidade bem definida, promovendo a modularidade.
*   **Tratamento de Exceções**: Operações críticas como saque e manipulação de inventário incluem tratamento de exceções para lidar com cenários de erro (saldo insuficiente, cédulas indisponíveis, etc.).
*   **Persistência Simples**: O estado do inventário e das contas de usuário é persistido em um arquivo `.ini` (`settings.ini`) para atender ao requisito de não usar frameworks externos e simular um estado persistente entre execuções. As notificações são logadas em `notifications.log`.

## Como Executar o Projeto

1.  **Pré-requisitos**: Delphi (versão compatível com `System.Generics.Collections` e `System.IniFiles`).
2.  **Estrutura de Pastas**: Certifique-se de que a estrutura de pastas (`Source`, `Config`, `Logs`) esteja organizada conforme descrito acima, com o arquivo `.dpr` na raiz do projeto.
3.  **Compilação**: Abra o arquivo `ProjetoCaixaEletronico.dpr` no Delphi e compile o projeto.
4.  **Execução**: Execute o arquivo `.exe` gerado. A aplicação é um console interativo.

### Interação com o Console

O programa apresentará um menu com as seguintes opções:

*   **1. Consultar Saldo do Caixa**: Exibe o valor total em dinheiro disponível no caixa.
*   **2. Consultar Inventário do Caixa**: Lista as cédulas e moedas disponíveis e suas quantidades.
*   **3. Realizar Saque**: Solicita o identificador do usuário e o valor a ser sacado. Se bem-sucedido, mostra a composição das cédulas entregues.
*   **4. Adicionar Cédulas ao Caixa**: Permite adicionar uma quantidade de cédulas de um determinado valor ao inventário.
*   **5. Remover Cédulas do Caixa**: Permite remover uma quantidade de cédulas de um determinado valor do inventário.
*   **6. Definir Estratégia de Composição (Padrão)**: Altera a estratégia de saque para a que busca a menor quantidade de cédulas.
*   **7. Definir Estratégia de Composição (Alternativa)**: Altera a estratégia de saque para a que busca preservar cédulas de maior valor.
*   **8. Consultar Saldo de Usuário**: Solicita o identificador do usuário e exibe seu saldo atual.
*   **0. Sair**: Encerra a aplicação, salvando o estado atual do inventário e dos saldos dos usuários no `settings.ini`.

## Considerações Adicionais

*   **Testes Unitários**: Embora não implementados neste escopo, a arquitetura com interfaces e a separação de responsabilidades tornam a solução altamente testável. Seria trivial criar testes unitários para `TInventario`, `TContaUsuario`, `TComposicaoPadraoStrategy`, `TComposicaoAlternativaStrategy` e `TFileNotificationService`.
*   **Interface Gráfica**: O teste não exigia uma interface visual. A implementação em console demonstra a lógica de negócio de forma clara e funcional, podendo ser facilmente integrada a uma GUI (VCL ou FMX) no futuro.
*   **Escalabilidade**: A modularidade e o uso de interfaces permitem que novas estratégias de composição, serviços de notificação ou até mesmo mecanismos de persistência (e.g., banco de dados) sejam adicionados com mínimo impacto no código existente.

Este projeto demonstra uma compreensão sólida dos princípios de engenharia de software e a capacidade de construir soluções robustas e bem estruturadas em Delphi.
