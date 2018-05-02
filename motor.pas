unit motor;

interface

uses Graphics, GLScene, GLObjects, GLNavigator, GLCollision, VectorGeometry, exercito;

type
  TMotor = class
  private
    FExercitoJogador: TExercito;
    FExercitoInimigo: TExercito;
    FGLScene: TGLScene;
    FGLNavigator: TGLNavigator;
    FCollisionManager: TCollisionManager;
    FDummyCube: TGLDummyCube;
    FNumeroColisoesMesmoExercito: Integer;
    function get_ExercitoInimigo: TExercito;
    function get_ExercitoJogador: TExercito;
    procedure InternalCriarExercito(Exercito: TExercito);
    procedure InternalExecutarAcoes(Exercito, Contra: TExercito);
    function get_PosicaoMediaExercitos: TAffineVector;
  public
    constructor Create(GLScene: TGLScene; GLNavigator: TGLNavigator; CollisionManager: TCollisionManager; DummyCube: TGLDummyCube);
    property ExercitoJogador: TExercito read get_ExercitoJogador;
    property ExercitoInimigo: TExercito read get_ExercitoInimigo;
    property PosicaoMediaExercitos: TAffineVector read get_PosicaoMediaExercitos;
    property NumeroColisoesMesmoExercito: Integer read FNumeroColisoesMesmoExercito write FNumeroColisoesMesmoExercito;
    procedure CriarExercitos;
    procedure ExecutarAcoes;
  end;

implementation

uses XCollection, VectorTypes, GLVectorFileObjects, GLGeomObjects, GLTexture, combatente, util, constantes;

{ TMotor }

constructor TMotor.Create(GLScene: TGLScene; GLNavigator: TGLNavigator; CollisionManager: TCollisionManager; DummyCube: TGLDummyCube);
begin
  FGLScene := GLScene;
  FGLNavigator := GLNavigator;
  FCollisionManager := CollisionManager;
  FDummyCube := DummyCube;
  FNumeroColisoesMesmoExercito := 0;
end;

procedure TMotor.CriarExercitos;
begin
  InternalCriarExercito(FExercitoJogador);
  InternalCriarExercito(FExercitoInimigo);
end;

procedure TMotor.ExecutarAcoes;
begin
  InternalExecutarAcoes(FExercitoJogador, FExercitoInimigo);
  InternalExecutarAcoes(FExercitoInimigo, FExercitoJogador);
end;

function TMotor.get_ExercitoInimigo: TExercito;
begin
  if not Assigned(FExercitoInimigo) then
  begin
    FExercitoInimigo := TExercito.Create;
    FExercitoInimigo.Cor := clrYellow;
    FExercitoInimigo.CorDoLider := clrBlack;
    FExercitoInimigo.PosicaoInicial := seDireita;
    FExercitoInimigo.LideradoPorIA := True;
  end;
  Result := FExercitoInimigo;
end;

function TMotor.get_ExercitoJogador: TExercito;
begin
  if not Assigned(FExercitoJogador) then
  begin
    FExercitoJogador := TExercito.Create;
    FExercitoJogador.Cor := clrNavy;
    FExercitoJogador.CorDoLider := clrWhite;
    FExercitoJogador.PosicaoInicial := seEsquerda;
    FExercitoJogador.LideradoPorIA := False;
  end;
  Result := FExercitoJogador;
end;

function TMotor.get_PosicaoMediaExercitos: TAffineVector;
var
  fracao: Single;
  i: Integer;
  posAcum: TAffineVector;
begin
  for i := 0 to 2 do //   vector (0,0,0)
    posAcum[i] :=  0;

  AddVector(posAcum, ExercitoJogador.PosicaoMedia);
  AddVector(posAcum, ExercitoInimigo.PosicaoMedia);

  fracao := 1 / 2;
  VectorScale(posAcum, fracao, Result);
end;

procedure TMotor.InternalCriarExercito(Exercito: TExercito);
var
  i : Integer;
  actor: TGLActor;
  disk: TGLDisk;
  cube: TGLDummyCube;
  combatente: TCombatente;
  corDoDisco: TVector4f;
  colisao: TGLBCollision;
begin
  for i := 0 to Exercito.Combatentes.Count - 1 do
  begin
    combatente := TCombatente(Exercito.Combatentes[i]);

    cube := TGLDummyCube.CreateAsChild(FGLScene.Objects);

    with cube do
    begin
      TagObject := combatente;
      Direction.X := 0;
      Direction.Y := 0;
      Direction.Z := 1;
      if Exercito.PosicaoInicial = seDireita then
        Direction.Z := Direction.Z * -1;

      Position.X := i * ESPACAMENTO_INICIAL;       // i para um ao lado do outro
      Position.Y := 1; // i para um em cima do outro


      Position.Z := Exercito.DistanciaDoCentro;    // i para um atrás do outro


      if combatente.EhLider then
        Position.Z := position.Z - (Exercito.DistanciaDoCentro div 2)
      else
        Position.X := Position.X - (Exercito.Combatentes.Count div 2 * ESPACAMENTO_INICIAL);

      if Exercito.PosicaoInicial = seEsquerda then
        Position.Z := Position.Z * -1;

      CubeSize := 0.05;

      colisao := TGLBCollision.Create(cube.Behaviours);
      colisao.Manager := FCollisionManager;
      colisao.BoundingMode := cbmFaces;
    end;

    disk := TGLDisk.Create(FGLScene);
    disk.Parent := cube;

    with disk do
    begin
      if Combatente.EhLider then
        corDoDisco := Exercito.CorDoLider
      else
        corDoDisco := Exercito.Cor;

      Material.BackProperties.Ambient.Color := corDoDisco;
      Material.BackProperties.Diffuse.Color := corDoDisco;
      Material.BackProperties.Emission.Color := corDoDisco;
      Material.FrontProperties.Ambient.Color := corDoDisco;
      Material.FrontProperties.Diffuse.Color := corDoDisco;
      Material.FrontProperties.Emission.Color := corDoDisco;

//      Material.Texture.MinFilter = miLinear
      Material.Texture.MappingTCoordinates.X := 0;
      Material.Texture.MappingTCoordinates.Y := 1;
      Material.Texture.MappingTCoordinates.Z := 0;
      Material.Texture.MappingTCoordinates.W := 0;
      Direction.X := 0;
      Direction.Y := 1;
      Direction.Z := 0;
      Position.X := 0;
      Position.Y := -0.9;
      Position.Z := 0;
      Up.X := 0;
      Up.Y := 0;
      Up.Z := 1;
      Loops := 1;
      OuterRadius := 1.000000000000000000;
      Slices := 7;
      SweepAngle := 360.000000000000000000;
    end;

    actor := TGLActor.Create(FGLScene);

    actor.Parent := cube;

    with actor do
    begin
      Material.FrontProperties.Emission.Alpha := 1;
      Material.FrontProperties.Emission.Blue := 1;
      Material.FrontProperties.Emission.Green := 1;
      Material.FrontProperties.Emission.Red := 1;

      Material.Texture.MappingTCoordinates.X := 0;
      Material.Texture.MappingTCoordinates.Y := 1;
      Material.Texture.MappingTCoordinates.Z := 0;
      Material.Texture.MappingTCoordinates.W := 0;
      Material.Texture.Disabled := False;

      Direction.X :=  0;
      Direction.Y :=  1;
      Direction.Z :=  0;

      Up.X := 1;
      Up.Y := 0;
      Up.Z := 0;

      Interval := 100;

      LoadFromFile(combatente.ArquivoModelo3D);
      Material.Texture.Image.LoadFromFile(combatente.ArquivoTextura);
      Animations.LoadFromFile(combatente.ArquivoAnimacao);
      Scale.SetVector(TAMANHO_PERSONAGEM, TAMANHO_PERSONAGEM, TAMANHO_PERSONAGEM, 0);
      AnimationMode:=aamLoop;
      SwitchToAnimation('stand');
    end;

    combatente.Actor := actor;
    combatente.Cubo := cube;
    combatente.Disk := disk;
    combatente.GLNavigator := FGLNavigator;
  end;

end;

procedure TMotor.InternalExecutarAcoes(Exercito, Contra: TExercito);
var
  i, dano, ataque: Integer;
  combatente(*, fakeCombatente*): TCombatente;
  acao: TAcao;
  EhLiderHumano, EmCombate: Boolean;

  procedure InternalMovimentacao(_combatente: TCombatente);
  begin
    case acao.Sentido of
      seDireita: _combatente.VirarPraDireita;
      seEsquerda: _combatente.VirarPraEsquerda;
    end;
    if acao.Velocidade > 0 then
      _combatente.Andar(acao.Velocidade)
    else
    begin
      if _combatente.RodadasParado >= MAX_RODADAS_SEM_MOVIMENTO then
        _combatente.Parar
      else
        _combatente.RodadasParado := _combatente.RodadasParado + 1;
  end;

end;

begin
  for i := 0 to Exercito.Combatentes.Count - 1 do
  begin
    combatente := TCombatente(Exercito.Combatentes[i]);
    EhLiderHumano := combatente.EhLider and not Exercito.LideradoPorIA;
    EmCombate := (combatente.Estado = ecCombate);

    // líderes HUMANOS só se submetem a IA quando em combate
    if (combatente.Estado <> ecMorto) and
       ((not EhLiderHumano) or (EhLiderHumano and EmCombate)) then
    begin
      acao := combatente.AcaoDecidida(Exercito.Lider, Contra.Lider, Exercito.Combatentes, Contra.Combatentes);

      if combatente.Estado = ecCombate then
      begin
        if combatente.PodeAtacar then
        begin
          if combatente.Lag > 0 then
            combatente.Lag := combatente.Lag - 1
          else
          begin
            combatente.Lag := LAG_ATAQUE;
            combatente.Atacar;
            ataque := random(20) + 1;  //d20
            if ataque >= combatente.oponente.ClasseDeArmadura then
            begin
              dano := random(8) + 1;  //d8
              combatente.oponente.PontosDeVida := combatente.oponente.PontosDeVida - dano;
              if combatente.Oponente.PontosDeVida <= 0 then
              begin
                combatente.Oponente.Morrer;
                combatente.Oponente := nil;
                combatente.Estado := ecDeslocamento;
                combatente.Parar;
              end
              else
                combatente.Oponente.Apanhar;
            end;
          end;
          // Se o meu oponente ainda está vivo e
          //  eu sou o oponente do meu oponente (ou seja,
          //  se meu oponente está lutando comigo (e não apenas apanhando de mim)
          // então ele pode atacar na vez dele
          if Assigned(combatente.Oponente) and
          (combatente = combatente.Oponente.Oponente) then
            combatente.Oponente.PodeAtacar := True;
        end;
      end
      else
      begin
        // IMPLEMENTACAO FUTURA PARA AJUDAR A SEPARACAO DO MESMO EXERCITO
        //SIMULA MOVIMENTACAO E TESTA COLISAO COM AMIGOS
        //SE NAO HOUVE COLISAO, ENTAO
(*        fakeCombatente := TCombatente.Create(exercito);
        try
          fakeCombatente.GLNavigator := FGLNavigator;
          fakeCombatente.Cubo := FDummyCube;
          FDummyCube.TagObject := fakeCombatente;
          InternalMovimentacao(fakeCombatente);
          NumeroColisoesMesmoExercito := 0;
          FCollisionManager.CheckCollisions;
          if NumeroColisoesMesmoExercito = 0 then *)
            InternalMovimentacao(combatente);
(*        finally
          NumeroColisoesMesmoExercito := 0;
          FDummyCube.TagObject := nil;
          fakeCombatente.Free;
        end; *)
      end;
    end;
  end;
end;

end.
