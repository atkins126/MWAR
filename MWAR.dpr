program MWAR;

uses
  Forms,
  DMControle in 'DMControle.pas' {DataModule1: TDataModule},
  util in 'util.pas',
  combatente in 'combatente.pas',
  exercito in 'exercito.pas',
  motor in 'motor.pas',
  frmdebug in 'frmdebug.pas' {formDebug},
  constantes in 'constantes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TformDebug, formDebug);
  Application.Run;
end.
