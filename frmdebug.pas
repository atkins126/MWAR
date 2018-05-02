unit frmdebug;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GLWin32Viewer;

type
  TformDebug = class(TForm)
    GLSceneViewer1: TGLSceneViewer;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formDebug: TformDebug;

implementation

uses DMControle;

{$R *.dfm}

procedure TformDebug.FormCreate(Sender: TObject);
begin
  GLSceneViewer1.Camera := DataModule1.GLCamera1;
//  avirecorder1.
end;

end.
