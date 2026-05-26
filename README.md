Teste Técnico - Sistema de Caixa 
Eletrônico 
Instruções Gerais 
• Não utilize frameworks ou bibliotecas externas de terceiros (apenas 
bibliotecas nativas da linguagem). 
• Linguagem de sua escolha. 
• O código deve ser limpo, estruturado e com comentários que você julgue 
necessários, focando na arquitetura e na aplicação dos princípios de 
Orientação a Objetos. 
• Dê nomes claros e expressivos para classes, métodos e variáveis. 
• O projeto pode ser publicado no Github ou enviado em um arquivo zipado. 
• Disponibilize uma interface para o usuário utilizar o caixa. Não precisa ser 
visual, pode ser por console. 
Questão 1 
Implemente um modelo robusto para a gestão do inventário de cédulas e moedas de 
um caixa eletrônico. O sistema deve ser capaz de gerenciar a contagem de diferentes 
denominações de forma eficiente e escalável. 
Requisitos: 
• O modelo deve suportar a adição ou remoção de valores de cédulas/moedas 
(ex: R$5, R$200, ou até moedas de R$1) sem a necessidade de modificar o 
código central de inventário. 
• Defina as operações necessárias para carregar, descarregar e consultar o 
estoque e o valor total disponível no caixa. 
Questão 2 
Implemente a funcionalidade de saque, garantindo que o algoritmo de composição das 
cédulas seja uma dependência configurável do sistema. 
Requisitos: 
1. Defina um Contrato para a estratégia de composição de cédulas. 
2. Crie pelo menos duas implementações para este contrato: 
a. Estratégia Padrão (Menor Quantidade): Busca a menor quantidade total 
de cédulas para entregar o valor solicitado. 
b. Estratégia Alternativa: Implemente uma estratégia que priorize a 
preservação das cédulas de maior valor (ex: R$100, R$200), utilizando 
as cédulas de menor valor o máximo possível para evitar que o caixa 
fique "preso" com troco pequeno. 
3. O componente que executa o saque não deve "saber" qual estratégia está 
sendo usada; ele deve apenas receber e executar a estratégia no momento da 
chamada. 
4. O saque só é permitido se for possível compor o valor exato com o estoque 
atual. Se não for possível, retorne uma mensagem clara. 
Questão 3 
Implemente um mecanismo de notificação para registrar eventos do caixa eletrônico. 
Requisitos: 
1. Crie uma interface de notificação. 
2. Permita que uma ou mais implementações da interface sejam registradas no 
sistema.  
3. Implemente uma classe que registre os eventos em um arquivo de texto, 
contendo:  
a. Data e hora 
b. Mensagem da operação 
Questão 4 
Implemente uma lógica que identifique quando o valor solicitado existe no caixa, mas 
não pode ser entregue com a composição atual de cédulas.  
O sistema deve detectar essa situação e retornar uma mensagem de erro clara.  
Implemente sugestões de valor alternativo para saque (ex: “Você pode sacar R$100”). 
