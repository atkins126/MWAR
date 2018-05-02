unit util;

interface

type

  TCameraMedia = (cmInativa, cmGeral, cmAmigo, cmInimigo);

  TSentido = (seEsquerda, seCentro, seDireita);

  TEstadoCombatente = (ecParado, ecDeslocamento, ecCombate, ecMorto); 

  TAcao = record
    Sentido: TSentido;
    Velocidade: Double;
    Ataque: Boolean;
  end;     


implementation

end.
