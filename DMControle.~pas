unit DMControle;

interface

uses
  Forms, Windows, SysUtils, Classes, ExtCtrls, GLScene, GLWin32FullScreenViewer,
  GLNavigator, GLVectorFileObjects, GLObjects, GLGeomObjects, GLMisc,
  GLSkydome, GLCadencer, motor, GLCollision, Dialogs, GLGui, GLWindows, GLSound,
  GLSMBASS, util;

type
  TDataModule1 = class(TDataModule)
    GLCadencer1: TGLCadencer;
    GLScene1: TGLScene;
    SkyDome1: TGLSkyDome;
    GLCamera1: TGLCamera;
    Disk1: TGLDisk;
    GLLightSource2: TGLLightSource;
    DummyCubePosicaoMedia: TGLDummyCube;
    DummyCube: TGLDummyCube;
    GLNavigator1: TGLNavigator;
    GLUserInterface1: TGLUserInterface;
    GLSceneViewer1: TGLFullScreenViewer;
    CollisionManager1: TCollisionManager;
    GLLabel1: TGLLabel;
    GLForm1: TGLForm;
    GLGuiLayout1: TGLGuiLayout;
    GLSoundLibrary: TGLSoundLibrary;
    GLSMBASS: TGLSMBASS;
    procedure DataModuleCreate(Sender: TObject);
    procedure HandleKeys(const deltaTime: Double);
    procedure GLCadencer1Progress(Sender: TObject; const deltaTime,
      newTime: Double);
    procedure CollisionManager1Collision(Sender: TObject; object1,
      object2: TGLBaseSceneObject);
  private
    CameraMedia: TCameraMedia;
    FMotor: TMotor;
    function get_Motor: TMotor;
  public
    property Motor: TMotor read get_Motor;
  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.dfm}

uses GLFileMD2, VectorGeometry, Jpeg, Keyboard, Combatente, constantes;

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
//  GLSceneViewer1.Active := True;

  Motor.ExercitoJogador.Efetivo := EFETIVO_JOGADOR;
  Motor.ExercitoInimigo.Efetivo := EFETIVO_INIMIGO;

  Motor.ExercitoJogador.DistanciaDoCentro := DISTANCIA_CENTRO;
  Motor.ExercitoInimigo.DistanciaDoCentro := DISTANCIA_CENTRO;

  Motor.CriarExercitos;

  Disk1.Material.Texture.Image.LoadFromFile('.\texturas\grama.jpg');

  GLCamera1.TargetObject := Motor.ExercitoJogador.Lider.Cubo;
(* Para jogo FULL SCREEN  
  while GLSceneViewer1.Active do
  begin
    Forms.Application.ProcessMessages;
    Sleep(1);
  end; *)
end;

function TDataModule1.get_Motor: TMotor;
begin
  if not Assigned(FMotor) then
    FMotor := TMotor.Create(GLScene1, GLNavigator1, CollisionManager1, DummyCube);
  Result := FMotor;
end;

procedure TDataModule1.GLCadencer1Progress(Sender: TObject;
  const deltaTime, newTime: Double);
begin
  // SERIA O "MAIN LOOP"
  HandleKeys(deltaTime); // Acoes do Usuario
  Motor.ExecutarAcoes;  // Acoes dos demais combatentes
  CollisionManager1.CheckCollisions;
  GLUserInterface1.Mouselook;
//   GLSceneViewer1.Invalidate;
  GLUserInterface1.MouseUpdate;
end;

procedure TDataModule1.HandleKeys(const deltaTime: Double);
var
  camera: TGLCamera;
  liderJogador, liderInimigo: TCombatente;
begin
  if IsKeyDown(VK_ESCAPE) then
    GLSceneViewer1.Active:=False;

  camera := GLSceneViewer1.Camera;
  liderJogador := TCombatente(Motor.ExercitoJogador.Lider);
  liderInimigo := TCombatente(Motor.ExercitoInimigo.Lider);

  if IsKeyDown('Q') then
    camera.Position.X := camera.Position.X + 1;
  if IsKeyDown('A') then
    camera.Position.X := camera.Position.X - 1;
  if IsKeyDown('W') then
    camera.Position.Z := camera.Position.Z + 1;
  if IsKeyDown('S') then
    camera.Position.Z := camera.Position.Z - 1;
  if IsKeyDown('E') then
    camera.Position.Y := camera.Position.Y + 1;
  if IsKeyDown('D') then
    camera.Position.Y := camera.Position.Y - 1;

  if IsKeyDown(VK_F1) then   // Camera Central
  begin
    CameraMedia := cmInativa;
    GLCamera1.TargetObject := Disk1;
  end
  else if IsKeyDown(VK_F2) then  // Camera Lider Jogador
  begin
    CameraMedia := cmInativa;
    GLCamera1.TargetObject := LiderJogador.Cubo;
  end
  else if IsKeyDown(VK_F3) then  // Camera Lider Inimigo
  begin
    CameraMedia := cmInativa;
    GLCamera1.TargetObject := LiderInimigo.Cubo;
  end
  else if IsKeyDown(VK_F4) then  // Camera Media Geral
    CameraMedia := cmGeral
  else if IsKeyDown(VK_F5) then  // Camera Media Jogador
    CameraMedia := cmAmigo
  else if IsKeyDown(VK_F6) then  // Camera Media Inimigo
    CameraMedia := cmInimigo;


  case CameraMedia of
    cmGeral: dummycubePosicaoMedia.Position.AsAffineVector := Motor.PosicaoMediaExercitos;
    cmAmigo: dummycubePosicaoMedia.Position.AsAffineVector := Motor.ExercitoJogador.PosicaoMedia;
    cmInimigo: dummycubePosicaoMedia.Position.AsAffineVector := Motor.ExercitoInimigo.PosicaoMedia;
  end;

  if CameraMedia <> cmInativa then
    GLCamera1.TargetObject := dummycubePosicaoMedia;

  if (liderJogador.Estado in [ecDeslocamento, ecParado]) then
  begin

    if IsKeyDown(VK_UP) then
      if IsKeyDown(VK_CONTROL) then
        liderJogador.Andar(liderJogador.VelocidadeCorrida)
      else
        liderJogador.Andar(liderJogador.VelocidadeCaminhada);

     if IsKeyDown(VK_LEFT) then
       liderJogador.VirarPraEsquerda;

     if IsKeyDown(VK_RIGHT) then
       liderJogador.VirarPraDireita;

     if not (IsKeyDown(VK_UP) or IsKeyDown(VK_LEFT) or IsKeyDown(VK_RIGHT)) then
       liderJogador.Parar;

  end;
end;


procedure TDataModule1.CollisionManager1Collision(Sender: TObject; object1,
  object2: TGLBaseSceneObject);
var
  c1, c2: TCombatente;

  procedure TrataColisaoExercitosDiferentes;
  begin
    // Colisao de combatentes de exercitos diferentes
    if Assigned(c1.Oponente) and (not Assigned(c2.Oponente)) then
      c2.PodeAtacar := True;

    if Assigned(c2.Oponente) and (not Assigned(c1.Oponente)) then
      c1.PodeAtacar := True;

    if (not Assigned(c2.Oponente)) and (not Assigned(c1.Oponente)) then
    begin
      // par para c1; impar para c2;
      c1.PodeAtacar := (random(2) = 0);
      c2.PodeAtacar := not c1.PodeAtacar;
    end;

    if not Assigned(c1.Oponente) then
    begin
      c1.Oponente := c2;
      c1.Estado := ecCombate;
    end;

    if not Assigned(c2.Oponente) then
    begin
      c2.Oponente := c1;
      c2.Estado := ecCombate;
    end;
  end;

  procedure TrataColisaoMesmoExercito;
  begin
    // Colisao do mesmo exercito
    Motor.NumeroColisoesMesmoExercito := Motor.NumeroColisoesMesmoExercito + 1;
  end;

begin
  if (object1 is TGLDummyCube) and
     Assigned(object1.TagObject) and
     (object1.TagObject is TCombatente) and
     (object2 is TGLDummyCube) and
     Assigned(object2.TagObject) and
     (object2.TagObject is TCombatente) then
  begin
    c1 := TCombatente(object1.TagObject);
    c2 := TCombatente(object2.TagObject);

    if (c1.Estado <> ecMorto) and (c2.Estado <> ecMorto) then // Os dois tem de estar vivos
    begin
      if Assigned(c1.Exercito) and Assigned(c2.Exercito) then
      begin
        if (c1.Exercito <> c2.Exercito) then
          TrataColisaoExercitosDiferentes
(* IMPLEMENTACAO FUTURA
else
          TrataColisaoMesmoExercito *);
      end
      else
       raise exception.create('ASSERT: exercito nao assinalado ???');
    end;

  end;
end;


end.
