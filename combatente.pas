unit combatente;

interface

uses Classes, GLMisc, GLVectorFileObjects, GLNavigator, GLObjects, GLGeomObjects, util;

type
  TCombatente = class; // forward declaration

  TCombatente = class
  private
    FArquivoModelo3D: string;
    FArquivoTextura: string;
    FArquivoAnimacao: string;
    FActor: TGLActor;
    FDisk: TGLDisk;
    FGLNavigator: TGLNavigator;
    FEhLider: Boolean;
    FEstado: TEstadoCombatente;
    FOponente: TCombatente;
    FPontosDeVida: Integer;
    FClasseDeArmadura: Integer;
    FUltimaVelocidadeAdotada: Double;
    FRodadasParado: Integer;
    FLag: Integer;
    FExercito: TObject;
    FPodeAtacar: Boolean;
    FCubo: TGLDummyCube;
    function get_ArquivoModelo3D: string;
    function get_ArquivoTextura: string;
    function get_ArquivoAnimacao: string;
    function get_Direcao: TGLCoordinates;
    function get_Posicao: TGLCoordinates;
    procedure set_Direcao(const Value: TGLCoordinates);
    procedure set_Posicao(const Value: TGLCoordinates);
    function get_Actor: TGLActor;
    procedure set_Actor(const Value: TGLActor);
    function get_GLNavigator: TGLNavigator;
    procedure set_GLNavigator(const Value: TGLNavigator);
    function get_VelocidadeCaminhada: Double;
    function get_VelocidadeCorrida: Double;
    function InternalLineOfSightLider(LiderAmigo, LiderInimigo: TCombatente; Amigos, Inimigos: TList): TAcao;
    function InternalFlocking(Amigos, Inimigos: TList): TAcao;
    function InternalProcureOCentro: TAcao;
    function InternalCombate: TAcao;
    function ForaDoCenario: Boolean;
    function get_Disk: TGLDisk;
    procedure set_Disk(const Value: TGLDisk);
    function get_UltimaVelocidadeAdotada: Double;

  public
    constructor Create(Exercito: TObject);
    property ArquivoModelo3D: string read get_ArquivoModelo3D;
    property ArquivoTextura: string read get_ArquivoTextura;
    property ArquivoAnimacao: string read get_ArquivoAnimacao;

    property Posicao: TGLCoordinates read get_Posicao write set_Posicao;
    property Direcao: TGLCoordinates read get_Direcao write set_Direcao;

    property VelocidadeCaminhada: Double read get_VelocidadeCaminhada;
    property VelocidadeCorrida: Double read get_VelocidadeCorrida;
    property UltimaVelocidadeAdotada: Double read get_UltimaVelocidadeAdotada;

    property EhLider: Boolean read FEhLider write FEhLider;

    property Actor: TGLActor read get_Actor write set_Actor;
    property Cubo: TGLDummyCube read FCubo write FCubo;
    property Disk: TGLDisk read get_Disk write set_Disk;
    property GLNavigator: TGLNavigator read get_GLNavigator write set_GLNavigator;

    property Estado: TEstadoCombatente read FEstado write FEstado;
    property Oponente: TCombatente read FOponente write FOponente;
    property Exercito: TObject read FExercito;

    property PontosDeVida: Integer read FPontosDeVida write FPontosDeVida;
    property ClasseDeArmadura: Integer read FClasseDeArmadura write FClasseDeArmadura;

    property Lag: Integer read FLag write FLag;
    property RodadasParado: Integer read FRodadasParado write FRodadasParado;

    property PodeAtacar: Boolean read FPodeAtacar write FPodeAtacar;

    function AcaoDecidida(LiderAmigo, LiderInimigo: TCombatente; Amigos, Inimigos: TList): TAcao;

    procedure Andar(velocidade: Double);
    procedure Parar;
    procedure VirarPraDireita;
    procedure VirarPraEsquerda;
    procedure Atacar;
    procedure Apanhar;
    procedure Morrer;
  end;

implementation

uses VectorGeometry, VectorTypes, GLTexture, constantes;

{ TCombatente }

constructor TCombatente.Create(Exercito: TObject);
begin
  // Isso aqui será movido para as classes descendentes
  FArquivoModelo3D := '.\Modelos\waste.md2';
  FArquivoTextura := '.\Texturas\cavaleiro.jpg';
  FArquivoAnimacao := '.\Movimentos\Quake2Animations.aaf';

  FClasseDeArmadura := CLASSE_DE_ARMADURA;
  FPontosDeVida := PONTOS_DE_VIDA;
  FUltimaVelocidadeAdotada := 0;
  FRodadasParado := 0;

  FEstado := ecParado;

  FExercito := Exercito;
  inherited Create;
end;

function TCombatente.AcaoDecidida(LiderAmigo, LiderInimigo: TCombatente; Amigos, Inimigos: TList): TAcao;
begin
  if Estado = ecCombate then
    Result := InternalCombate
  else
  begin
    if ForaDoCenario then
      Result := InternalProcureOCentro
    else
      Result := InternalFlocking(Amigos, Inimigos);
  end;
end;

function TCombatente.get_Actor: TGLActor;
begin
  Result := FActor;
end;

function TCombatente.get_Direcao: TGLCoordinates;
begin
  Result := Cubo.Direction;
end;

function TCombatente.get_ArquivoModelo3D: string;
begin
  Result := FArquivoModelo3D;
end;

function TCombatente.get_ArquivoAnimacao: string;
begin
  Result := FArquivoAnimacao;
end;

function TCombatente.get_Posicao: TGLCoordinates;
begin
  Result := Cubo.Position;
end;

function TCombatente.get_ArquivoTextura: string;
begin
  Result := FArquivoTextura;
end;

procedure TCombatente.set_Actor(const Value: TGLActor);
begin
  FActor := Value;
end;

procedure TCombatente.set_Direcao(const Value: TGLCoordinates);
begin
  Cubo.Direction := Value;
end;

procedure TCombatente.set_Posicao(const Value: TGLCoordinates);
begin
  Cubo.Position := Value;
end;

function TCombatente.get_GLNavigator: TGLNavigator;
begin
  Result := FGLNavigator;
end;

procedure TCombatente.set_GLNavigator(const Value: TGLNavigator);
begin
  FGLNavigator := Value;
end;

function TCombatente.get_VelocidadeCaminhada: Double;
begin
  Result := VELOCIDADE_CAMINHADA;
end;

procedure TCombatente.Andar(velocidade: Double);
begin
  FGLNavigator.MovingObject := Cubo;
  FGLNavigator.MoveForward(velocidade);  // corrida normal
  FGLNavigator.MovingObject := nil;
  if Assigned(FActor) then
    if FActor.CurrentAnimation <> 'run' then
      FActor.SwitchToAnimation('run');
  FUltimaVelocidadeAdotada := velocidade;
  FRodadasParado := 0;
end;

procedure TCombatente.Parar;
begin
  if Assigned(FActor) then
    if FActor.CurrentAnimation <> 'stand' then
      FActor.SwitchToAnimation('stand');
  FEstado := ecParado;
end;

procedure TCombatente.VirarPraDireita;
begin
  FGLNavigator.MovingObject := Cubo;
  FGLNavigator.TurnHorizontal(ANGULO_VIRADA);
  FGLNavigator.MovingObject := nil;
  if Assigned(FActor) then
    if FActor.CurrentAnimation <> 'run' then
      FActor.SwitchToAnimation('run');
end;

procedure TCombatente.VirarPraEsquerda;
begin
  FGLNavigator.MovingObject := Cubo;
  FGLNavigator.TurnHorizontal(-ANGULO_VIRADA);
  FGLNavigator.MovingObject := nil;
  if Assigned(FActor) then
    if FActor.CurrentAnimation <> 'run' then
      FActor.SwitchToAnimation('run');
end;

procedure TCombatente.Atacar;
begin
  if Assigned(FActor) then
    if FActor.CurrentAnimation <> 'point' then
      FActor.SwitchToAnimation('point');
end;

procedure TCombatente.Apanhar;
begin
  if Assigned(FActor) then
  begin
    if FActor.CurrentAnimation <> 'pain1' then
      FActor.SwitchToAnimation('pain1');
    FActor.SwitchToAnimation('stand');
  end;
end;

procedure TCombatente.Morrer;
begin
  if FActor.CurrentAnimation <> 'death3' then
    FActor.SwitchToAnimation('death3');
  Estado := ecMorto;
  FActor.AnimationMode := aamPlayOnce;
  with FDisk do
  begin
    Material.BackProperties.Ambient.Color := clrred;
    Material.BackProperties.Diffuse.Color := clrred;
    Material.BackProperties.Emission.Color := clrred;
    Material.FrontProperties.Ambient.Color := clrred;
    Material.FrontProperties.Diffuse.Color := clrred;
    Material.FrontProperties.Emission.Color := clrred;
  end;
end;

function TCombatente.InternalLineOfSightLider(LiderAmigo, LiderInimigo: TCombatente; Amigos, Inimigos: TList): TAcao;
var
  direcaoLider, posicaoLider, vetorDistancia: TVector3F;
  vetorAux: TAffineVector;
//  produtoEscalar: Single;

begin
//  produtoEscalar := VectorDotProduct(Posicao.AsVector, Direcao.AsVector);

  direcaoLider := LiderAmigo.Direcao.AsAffineVector;
  posicaoLider := LiderAmigo.Posicao.AsAffineVector;

  vetorDistancia := VectorSubtract(Self.Posicao.AsAffineVector, posicaoLider);

  vetorAux := VectorCrossProduct(Self.Direcao.AsAffineVector, vetorDistancia);

  if vetorAux[1] < 0 then
    Result.Sentido := seEsquerda
  else
  begin
    if vetorAux[1] = 0 then
      Result.Sentido := seCentro
    else
     Result.Sentido := seDireita
  end;


    Result.Velocidade := VelocidadeCaminhada
end;


function TCombatente.get_VelocidadeCorrida: Double;
begin
  Result := VELOCIDADE_CORRIDA;
end;

function TCombatente.InternalCombate: TAcao;
begin
  Result.Velocidade := 0;
  Result.Sentido := seCentro;
  Result.Ataque := True;
end;


function TCombatente.InternalFlocking(Amigos, Inimigos: TList): TAcao;
var
  raioVisao, anguloVisao, numAmigosVisualizados, numInimigosVisualizados: Integer;
  pesoCoesao, pesoAlinhamento, pesoSeparacao, pesoLider, pesoOfensivo, fracao: Single;
  prodEscalar, distAmigoMaisProximo, distInimigoMaisProximo: Single;
  anguloVisaoRad:  Double;
  distAmigo, distInimigo: TVector3f;
  posAmigoAcum, dirAmigoAcum, distAmigoNorm, distInimigoNorm,
  dirCoesao, dirLider, dirAlinhamento, dirSeparacao, dirOfensivo,
  dirFlocking, prodVetorial, posAmigoMedia: TAffineVector;
  amigo, inimigo, amigoMaisProximo, inimigoMaisProximo, liderAmigo: TCombatente;

  procedure AnalisaAmigos;
  var i: Integer;
  begin
    numAmigosVisualizados := 0;

    for i := 0 to 2 do //   vector (0,0,0)
      posAmigoAcum[i] :=  0;

    for i := 0 to 2 do //   vector (0,0,0)
      dirAmigoAcum[i] :=  0;

    amigoMaisProximo := nil;
    liderAmigo := nil;
    distAmigoMaisProximo := 0;

    // PROCURA POR AMIGOS
    for i := 0 to Amigos.Count - 1 do
    begin
      amigo := TCombatente(Amigos[i]);
      if (Self <> amigo) and (amigo.Estado <> ecMorto) then // Não me considero nem aos amigos mortos
      begin
        distAmigo := VectorSubtract(amigo.Posicao.AsAffineVector, Self.Posicao.AsAffineVector);

        if VectorLength(distAmigo) <= raioVisao then
        begin
          distAmigoNorm := VectorNormalize(distAmigo);
          prodEscalar := VectorDotProduct(distAmigoNorm, Self.Direcao.AsAffineVector);
          if prodEscalar > cos (anguloVisaoRad / 2) then
          begin
            numAmigosVisualizados := numAmigosVisualizados + 1;
            AddVector(posAmigoAcum, amigo.Posicao.AsAffineVector);
            AddVector(dirAmigoAcum, amigo.Direcao.AsAffineVector);
            if amigo.EhLider then
              liderAmigo := amigo;
            if (not Assigned(amigoMaisProximo)) or (VectorLength(distAmigo) < distAmigoMaisProximo) then
            begin
              amigoMaisProximo := amigo;
              distAmigoMaisProximo := VectorLength(distAmigo);
            end;
          end;
        end;
      end;
    end;

  end;


   procedure AnalisaInimigos;
   var
     i: integer;
   begin
     numInimigosVisualizados := 0;
     inimigoMaisProximo := nil;
     distInimigoMaisProximo := 0;

     // PROCURA POR INIMIGOS
     for i := 0 to Inimigos.Count - 1 do
     begin
       inimigo := TCombatente(Inimigos[i]);
       if (inimigo.Estado <> ecMorto) then // Não me considero nem aos amigos mortos
       begin
         distInimigo := VectorSubtract(inimigo.Posicao.AsAffineVector, Self.Posicao.AsAffineVector);

         if VectorLength(distInimigo) <= raioVisao then
         begin
           distInimigoNorm := VectorNormalize(distInimigo);
           prodEscalar := VectorDotProduct(Self.Direcao.AsAffineVector, distInimigoNorm);
           if prodEscalar > cos (anguloVisaoRad / 2) then
           begin
             numInimigosVisualizados := numInimigosVisualizados + 1;
             if (not Assigned(inimigoMaisProximo)) or (VectorLength(distInimigo) < distInimigoMaisProximo) then
             begin
               inimigoMaisProximo := inimigo;
               distInimigoMaisProximo := VectorLength(distInimigo);
             end;
           end;
         end;
       end;
     end;
   end;

   procedure AproximacaoFinal;
   begin
     pesoCoesao := PESO_COESAO;
     pesoAlinhamento := PESO_ALINHAMENTO;
     pesoSeparacao := PESO_SEPARACAO;

     if EhLider then
       pesoOfensivo := PESO_OFENSIVO_LIDER
     else
       pesoOfensivo := PESO_OFENSIVO;


    if numAmigosVisualizados > 0 then
    begin
      fracao := 1 / numamigosvisualizados;
      VectorScale(posAmigoAcum, fracao, posAmigoMedia);
      dirCoesao := VectorNormalize(VectorSubtract(posAmigoMedia, Self.Posicao.AsAffineVector));
      dirAlinhamento := VectorNormalize(dirAmigoAcum);
      dirSeparacao := VectorNormalize(VectorSubtract(Self.Posicao.AsAffineVector, amigoMaisProximo.Posicao.AsAffineVector));
      CombineVector(dirFlocking, dirCoesao, pesoCoesao);
      CombineVector(dirFlocking, dirAlinhamento, pesoAlinhamento);
      CombineVector(dirFlocking, dirSeparacao, pesoSeparacao);
      // Se visualizar o lider, siga-o.
      if Assigned(liderAmigo) then
      begin
        pesoLider := PESO_LIDER;
        dirLider := VectorNormalize(VectorSubtract(LiderAmigo.Posicao.AsAffineVector, Self.Posicao.AsAffineVector));
        CombineVector(dirFlocking, dirLider, pesoLider);
      end;
    end;

    if numInimigosVisualizados > 0 then
    begin
      dirOfensivo := VectorNormalize(VectorSubtract(inimigoMaisProximo.Posicao.AsAffineVector, Self.Posicao.AsAffineVector));
      CombineVector(dirFlocking, dirOfensivo, pesoOfensivo);
    end;


    prodVetorial := VectorCrossProduct(Self.Direcao.AsAffineVector, dirFlocking);

    if prodVetorial[1] <= 0 then
      Result.Sentido := seDireita
    else
      Result.Sentido := seEsquerda;


(* Estudar isso melhor...
    if ehLider then
    begin
      if Assigned(inimigoMaisProximo) then
        Result.Velocidade := inimigoMaisProximo.UltimaVelocidadeAdotada
      else
        Result.Velocidade := VelocidadeCaminhada;
    end
    else
    begin            *)

      // Se visualizar o lider e estiver com mais de 50% da energia, tente acompanha-lo.
      if (PontosDeVida > VITALIDADE_MINIMA_CORRIDA) and Assigned(LiderAmigo) and (LiderAmigo.UltimaVelocidadeAdotada > 0) then
        Result.Velocidade := LiderAmigo.UltimaVelocidadeAdotada
      else
        Result.Velocidade := VelocidadeCaminhada;
//    end;
   end;



begin

  raioVisao := RAIO_VISAO;
  anguloVisao := ANGULO_VISAO;
  anguloVisaoRad := anguloVisao * Pi / 180.0;

  numAmigosVisualizados := 0;
  numInimigosVisualizados := 0;


  AnalisaAmigos;
  AnalisaInimigos;

  if (numInimigosVisualizados = 0) and (numAmigosVisualizados = 0) then
  begin    // caso contrario, procuro por eles (mudanca no campo visual) *)
    Result.Sentido := seDireita; 
    Result.Velocidade := 0;
  end
  else
    AproximacaoFinal;
end;

function TCombatente.get_Disk: TGLDisk;
begin
  Result := FDisk;
end;

procedure TCombatente.set_Disk(const Value: TGLDisk);
begin
  FDisk := Value;
end;

function TCombatente.get_UltimaVelocidadeAdotada: Double;
begin
  Result := FUltimaVelocidadeAdotada;
end;

function TCombatente.ForaDoCenario: Boolean;
begin
  Result := VectorLength(Self.Posicao.AsAffineVector) > 38;
end;

function TCombatente.InternalProcureOCentro: TAcao;
var
  i: integer;
  dirCentro, posicaoCentro, prodVetorial: TAffineVector;
begin
  for i := 0 to 2 do
    posicaoCentro[i] := 0;

  dirCentro := VectorSubtract(Self.Posicao.AsAffineVector, posicaoCentro);
  prodVetorial := VectorCrossProduct(Self.Direcao.AsAffineVector, dirCentro);

  if prodVetorial[1] < 0 then
    Result.Sentido := seEsquerda
  else
  begin
    if prodVetorial[1] = 0 then
      Result.Sentido := seCentro
    else
     Result.Sentido := seDireita
  end;

  Result.Velocidade := VelocidadeCaminhada;
end;

end.
