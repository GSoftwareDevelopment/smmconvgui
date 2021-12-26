unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    memAbout: TMemo;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation
uses logic, VersionSupport;

{$R *.lfm}

{ TFormAbout }

procedure TFormAbout.FormCreate(Sender: TObject);
Var
  CLIVer:String;

begin
  memAbout.Lines.Clear;
  memAbout.Lines.Add('version ' + GetFileVersion);
  memAbout.Lines.Add('');
  memAbout.Lines.Add('Built for '+GetTargetInfo);
  memAbout.Lines.Add(' with '+GetCompilerInfo + ' on '+GetCompiledDate);
  memAbout.Lines.Add(' and using '+GetLCLVersion + ' and ' + GetWidgetset);
  memAbout.Lines.Add('');
  CLIVer:=getSMMVersion;
  if CLIVer<>'' then
    memAbout.Lines.Add('CLI SMM Converter version: '+CLIVer);
end;

end.

