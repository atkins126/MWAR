# WAR
MANUAL DO TECHDEMO "MEDIEVAL WAR" (VERSÃO ALFA)

Grupo 6: Daniel Jorge Achkar e Souza e Marcelo Pereira Rocha

Descrição
---------
Este techdemo consiste num batalha entre dois exércitos medievais, onde o jogador controla o líder do seu exército. Os demais combatentes dos dois exércitos, incluindo o líder do exército inimigo são controlados por IA, especificamente utilizando sistema multi-agente.

Instruções para instalação
--------------------------
Descompacte o conteúdo deste zip em uma pasta com qualquer nome, porém respeitando os subdiretórios presentes. Como o arquivo foi enviado pelo GMAIL, torna-se necessário renomear o arquivo MWAR.BLAH para MWAR.EXE. 

Código-fonte
------------
Os arquivos de extensão .PAS, .DFM e .DPR constituem os fontes do projeto. O projeto foi desenvolvido em Delphi 2005 com OpenGL através da biblioteca de componentes GLScene.

Interface
---------
Para jogar esta versão é necessário entender que:

* O exército do jogador é identificado com a cor AZUL;
* O líder do exército do jogador pode ser controlado pelo próprio jogador e é identificado com a cor BRANCA;
* O exército do inimigo é identicado com a cor AMARELA;
* O líder do exército inimigo é identificado com a cor PRETA;
* Os combatentes mortos são identificados com a cor VERMELHA;


Principais comandos
-------------------

* Teclas Q-A-W-S-E-D: Alteram a posição da câmera. Esta câmera está sempre direcionada para o meio do campo de batalha. 

* Seta para Cima (UP): Faz com que o líder do seu exército ande para frente;

* Seta para esquerda (LEFT): Faz com que o líder do seu exército vire-se para a esquerda (sem andar);

* Seta para direita (RIGHT): Faz com que o líder do seu exército vire-se para a direita (sem andar);

* Seta para Cima + esquerda: Faz com que o líder do seu exército movimente-se virando para a esquerda;

* Seta para Cima + direita: Faz com que o líder do seu exército movimente-se virando para a direita;

* Tecla CONTROL: Amplia velocidade do líder do seu exército;

* F1: Camera Central
* F2: Camera que acompanha lider Jogador
* F3: Camera que acompanha lider inimigo
* F4: Camera que acompanha posicao media geral
* F5: Camera que acompanha posicao media exercito jogador
* F6: Camera que acompanha posicao media exercito inimigo

Importante: o jogador perde o controle do líder do seu exército quando o mesmo está em combate ou  morre.

Combates
--------

Para que combatentes de exércitos diferentes iniciem um combate basta ocorrer uma colisão entre os dois. Um combate só termina com a morte de um dos combatentes. Durante o combate, os participantes não podem se deslocar no cenário. 

A regra do combate é baseado no sistema da terceira edição do RPG D&D, onde cada combatente possui uma classe de armadura. A cada ataque, um dado de 20 faces é rolado (RANDOM(20) + 1). Caso o número obtido supere a classe de armadura do oponente, um dano é calculado através de um dado de 8 faces (RANDOM(8) + 1).

Onde foi utilizada IA
---------------------

Na movimentação de cada agente (combatente) dos dois exércitos, excluindo o líder do exército do jogador (que é controlado pelo próprio jogador). Foi utilizado um algoritmo de Flocking, que considera as seguintes prioridades:

1) Tento seguir o líder.
2) Tento atacar meu inimigo mais próximo.
3) Mantenho Afastamento, Coesao e Alinhamento com meus amigos.
4) Se não vejo nenhum amigo ou inimigo, começo a girar para um lado.

Um campo de visão de 210 graus é considerado.

Importante: sempre procurando combatentes VIVOS.

Últimas Implementações
-----------------------

1) Melhorias no sistema de combate: 
  1.1) Teste de iniciativa: nesta versãoa iniciativa é decidida por aleatoriedade.

2) Melhorias nas câmeras para melhor visualização do combate. Foram programadas câmeras que acompanham o ponto médio dos exércitos e de cada exército individualmente.

3) Limites do cenário: os personagens (exceto o líder controlado pelo jogador) não podem sair do limite da arena de combate.


Possíveis melhorias
-------------------

1) Tentativa de fuga: quando o combatente se sentir em perigo (dano acumulado do combate), tentar fugir.

2) Leitura de parâmetros: o jogo possui muitos parâmetros. É interessante que isso possa ser lido de um arquivo INI. 

3) Tentar exibir informações sobre combatentes em tempo real.



Bugs Conhecidos (não deu certo ! :/ )
---------------------------------------------

* Apesar do flocking considerar um elevado peso para separação, pode acontecer de combatentes do mesmo exército colidirem e 'invadirem' a área um do outro (ex.: braços atravessando cabeça e tórax de outros combatentes do mesmo exército). Tentamos implementar um sistema para desconsiderar jogadas que pudessem acarretar neste comportamento, mas o resultado não ficou adequado (ex.: todo o exército ficava paralisado, pois se alguem se mexesse iria acabar atravessando outro combatente).


