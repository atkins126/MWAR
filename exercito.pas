unit exercito;

interface

uses Classes, VectorTypes, VectorGeometry, util, combatente;

type

  TExercito = class
  private
    FCombatentes: TList;
    FEfetivo: Integer;
    FCor: TVector4f;
    FCorDoLider: TVector4f;
    FDistanciaDoCentro: Integer;
    FPosicaoInicial: TSentido;
    FLider: TCombatente;
    FLideradoPorIA: Boolean;
    function get_Combatentes: TList;
    function get_Efetivo: Integer;
    procedure set_Efetivo(const Value: Integer);
    function get_DistanciaDoCentro: Integer;
    procedure set_DistanciaDoCentro(const Value: Integer);
    function get_PosicaoInicial: TSentido;
    procedure set_PosicaoInicial(const Value: TSentido);
    function get_Lider: TCombatente;
    procedure set_Lider(const Value: TCombatente);
    function get_PosicaoMedia: TAffineVector;
  public
    property Efetivo: Integer read get_Efetivo write set_Efetivo;
    property Combatentes: TList read get_Combatentes;
    property Cor: TVector4f read FCor write FCor;
    property CorDoLider: TVector4f read FCorDoLider write FCorDoLider;
    property DistanciaDoCentro: Integer read get_DistanciaDoCentro write set_DistanciaDoCentro;
    property PosicaoInicial: TSentido read get_PosicaoInicial write set_PosicaoInicial;
    property Lider: TCombatente read get_Lider write set_Lider;
    property LideradoPorIA: Boolean read FLideradoPorIA write FLideradoPorIA;
    property PosicaoMedia: TAffineVector read get_PosicaoMedia;
  end;

implementation

uses constantes;

{ TExercito }

function TExercito.get_Combatentes: TList;
var
  i: Integer;
begin
  if not Assigned(FCombatentes) then
  begin
    // definir aqui proporcoes de tipos de combatentes
    FCombatentes := TList.Create;
    for i := 0 to FEfetivo - 1 do
      FCombatentes.Add(TCombatente.Create(Self));
    Lider := FCombatentes[0];
    Lider.PontosDeVida := PONTOS_DE_VIDA_LIDER;
  end;
  Result := FCombatentes;
end;

function TExercito.get_DistanciaDoCentro: Integer;
begin
  Result := FDistanciaDoCentro;
end;

function TExercito.get_Efetivo: Integer;
begin
  Result := FEfetivo;
end;

function TExercito.get_Lider: TCombatente;
begin
  Result := FLider;
end;

function TExercito.get_PosicaoInicial: TSentido;
begin
  Result := FPosicaoInicial;
end;

function TExercito.get_PosicaoMedia: TAffineVector;
var
  i, combatentes: integer;
  fracao: Single;
  combatente: TCombatente;
  posAcum: TAffineVector;
begin
  combatentes := 0;
  for i := 0 to 2 do //   vector (0,0,0)
    posAcum[i] :=  0;

  for i := 0 to Self.Combatentes.Count - 1 do
  begin
    combatente := TCombatente(Self.Combatentes[i]);
    if combatente.Estado <> ecMorto then
    begin
      Inc(combatentes);
      AddVector(posAcum, combatente.Posicao.AsAffineVector);
    end;
  end;

  fracao := 1 / combatentes;
  VectorScale(posAcum, fracao, Result);
end;

procedure TExercito.set_DistanciaDoCentro(const Value: Integer);
begin
  FDistanciaDoCentro := Value;
end;

procedure TExercito.set_Efetivo(const Value: Integer);
begin
  FEfetivo := Value;
end;

procedure TExercito.set_Lider(const Value: TCombatente);
begin
  if Assigned(FLider) then // desliga o lider atual, se existir
    FLider.EhLider := False;
  FLider := Value;          // seta novo lider
  FLider.EhLider := True;  // liga novo lider
end;

procedure TExercito.set_PosicaoInicial(const Value: TSentido);
begin
  FPosicaoInicial := Value;
end;

end.
