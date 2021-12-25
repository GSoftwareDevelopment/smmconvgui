unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons;

type

  { TFormMain }

  TFormMain = class(TForm)
    butDelProfile: TButton;
    butStart: TBitBtn;
    butChoiceFile: TButton;
    butSaveFile: TButton;
    butAddProfile: TButton;
    cb_audioBuf: TCheckBox;
    cb_engineRegs: TCheckBox;
    cb_chnRegs: TCheckBox;
    cb_songData: TCheckBox;
    cb_makeConf: TCheckBox;
    cb_makeRes: TCheckBox;
    cb_Origin: TCheckBox;
    cb_noteTab: TCheckBox;
    cb_sfxModes: TCheckBox;
    cb_sfxNotes: TCheckBox;
    cb_sfxTab: TCheckBox;
    cb_tabTab: TCheckBox;
    cb_data: TCheckBox;
    addrAudioBuf: TEdit;
    addrSFXRegs: TEdit;
    addrChnRegs: TEdit;
    addrSongData: TEdit;
    addrOrigin: TEdit;
    addrNoteTab: TEdit;
    addrSFXModes: TEdit;
    addrSFXNotes: TEdit;
    addrSFXTab: TEdit;
    addrTABTab: TEdit;
    addrData: TEdit;
    ConfigList: TComboBox;
    fileInName: TEdit;
    fileOutName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    grp_reindex: TRadioGroup;
    grp_regs: TGroupBox;
    grp_apifiles: TCheckGroup;
    grp_addr: TGroupBox;
    grp_reduce: TRadioGroup;
    OpenSMMDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure butDelProfileClick(Sender: TObject);
    procedure butAddProfileClick(Sender: TObject);
    procedure butChoiceFileClick(Sender: TObject);
    procedure butSaveFileClick(Sender: TObject);
    procedure butStartClick(Sender: TObject);
    procedure cb_audioBufChange(Sender: TObject);
    procedure cb_chnRegsChange(Sender: TObject);
    procedure cb_dataChange(Sender: TObject);
    procedure cb_noteTabChange(Sender: TObject);
    procedure cb_OriginChange(Sender: TObject);
    procedure cb_sfxModesChange(Sender: TObject);
    procedure cb_sfxNotesChange(Sender: TObject);
    procedure cb_sfxTabChange(Sender: TObject);
    procedure cb_songDataChange(Sender: TObject);
    procedure cb_tabTabChange(Sender: TObject);
    procedure cb_engineRegsChange(Sender: TObject);
    procedure ConfigListSelect(Sender: TObject);
    procedure fileInNameChange(Sender: TObject);
    procedure fileOutNameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  FormMain: TFormMain;

implementation
{$R *.lfm}
uses output, Logic;

{ TFormMain }

procedure TFormMain.FormCreate(Sender: TObject);
Var
  list:TStringList;

begin
  try
    openConfigINI();
    list:=getConfigList();
    ConfigList.Items.AddStrings(list);
  finally
    list.Free;
  end;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  CloseConfigINI();
end;

procedure TFormMain.butChoiceFileClick(Sender: TObject);
begin
  if OpenSMMDialog.Execute then
  begin
    fileInName.Text:=OpenSMMDialog.FileName;
    fileInName.SetFocus;
  end;
end;

procedure TFormMain.butAddProfileClick(Sender: TObject);
Var
  cfgName:string;
  saveIt:boolean;
  id:integer;

begin
  cfgName:='';
  if not InputQuery('Add configuration','Input conig name:',false,cfgName) then
    exit;
  cfgName:=trim(cfgName);
  if length(cfgName)<3 then
  begin
    MessageDlg('Error','Config name is wrong.',mtError,[mbClose],0);
    Exit;
  end;
  saveIt:=true;

  if isConfigExists(cfgName) then
    saveIt:=MessageDlg(
      'Error','Do you want overwrite config `'+cfgName+'`',
      mtConfirmation,[mbYes,mbNo],0)<>mrNo;

  if saveIt then
  begin
    id:=configList.Items.IndexOf(cfgName);
    if id>0 then configList.Items.Delete(id);
    configList.Items.add(cfgName);
    configList.ItemIndex:=configList.Items.IndexOf(cfgName);

    SaveConfig2INI(cfgName);
  end;
end;

procedure TFormMain.butDelProfileClick(Sender: TObject);
var
  curConfig:string;
  id:integer;

begin
  id:=configList.ItemIndex;
  curConfig:=ConfigList.Items[id];
  if MessageDlg('Delete configuration',
                  'Are you sure you want delete `'+curConfig+'` configuration?',
                  mtConfirmation, [mbYes, mbNo],0)=mrNo then exit;

  if not isConfigExists(curConfig) then
    MessageDlg('Error','Config not exist.',mtError,[mbClose],0)
  else
  begin
    configList.Items.Delete(id);
    DeleteConfigFromINI(curConfig);
    configList.ItemIndex:=0;
  end;
end;

procedure TFormMain.ConfigListSelect(Sender: TObject);
var
  cfgName:string;

begin
  cfgName:=ConfigList.Items[configList.ItemIndex];

  if not isConfigExists(cfgName) then
    MessageDlg('Error','Config not exist.',mtError,[mbClose],0)
  else
    ReadConfigFromINI(cfgName);
end;

procedure TFormMain.butSaveFileClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    fileOutName.Text:=SaveDialog.FileName;
    fileOutName.SetFocus;
  end;
end;

procedure TFormMain.butStartClick(Sender: TObject);
var
  frm:TFormOutput;

begin
  frm:=convertSMM();
  frm.ShowModal;
end;

procedure TFormMain.cb_audioBufChange(Sender: TObject);
begin
  switchAddr(addrAudioBuf,cb_audioBuf);
end;

procedure TFormMain.cb_chnRegsChange(Sender: TObject);
begin
  switchAddr(addrChnRegs,cb_chnRegs);
end;

procedure TFormMain.cb_OriginChange(Sender: TObject);
begin
  switchAddr(addrOrigin,cb_Origin);
end;

procedure TFormMain.cb_noteTabChange(Sender: TObject);
begin
  switchAddr(addrNoteTab,cb_noteTab);
end;

procedure TFormMain.cb_sfxModesChange(Sender: TObject);
begin
  switchAddr(addrSFXModes,cb_sfxModes);
end;

procedure TFormMain.cb_sfxNotesChange(Sender: TObject);
begin
  switchAddr(addrSFXNotes,cb_sfxNotes);
end;

procedure TFormMain.cb_sfxTabChange(Sender: TObject);
begin
  switchAddr(addrSFXTab,cb_sfxTab);
end;

procedure TFormMain.cb_songDataChange(Sender: TObject);
begin
  switchAddr(addrSongData,cb_songData);
end;

procedure TFormMain.cb_tabTabChange(Sender: TObject);
begin
  switchAddr(addrTABTab,cb_tabTab);
end;

procedure TFormMain.cb_engineRegsChange(Sender: TObject);
begin
  switchAddr(addrSFXRegs,cb_engineRegs);
end;

procedure TFormMain.cb_dataChange(Sender: TObject);
begin
  addrData.Enabled:=cb_data.Checked;
  if cb_data.Checked then
    addrData.SetFocus;
end;

procedure TFormMain.fileInNameChange(Sender: TObject);
begin
  butStart.Enabled:=isGood2Start;
end;

procedure TFormMain.fileOutNameChange(Sender: TObject);
begin
  butStart.Enabled:=isGood2Start;
end;

end.

