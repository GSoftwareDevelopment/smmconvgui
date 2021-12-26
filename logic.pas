unit logic;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Forms, INIFiles, Process, StdCtrls, Dialogs,
  main, output;

function getSMMVersion():String;
procedure convertSMM();
procedure switchAddr(var addr: TEdit; var cb: TCheckBox);
function isGood2Start():boolean;

procedure openConfigINI();
procedure closeConfigINI();

procedure getConfigList(var list:TStrings);
function isConfigExists(cfgName:string):boolean;
procedure ReadConfigFromINI(cfgName:string);
procedure DeleteConfigFromINI(cfgName:string);
procedure SaveConfig2INI(cfgName:string);

const
  INI_CONFIG_FILE = 'configs.ini';
  FILE_SMMCONV = 'smm-conv';
  CMDPARAM_MAKECONFIG = '-MC';
  CMDPARAM_MAKERESOURCE = '-MR';
  CMDPARAM_REDUCE = '-reduce:';
  CMDPARAM_REINDEX = '-reindex:';
  CMDOPT_SFXONLY = 'sfxonly';
  CMDOPT_TABONLY = 'tabonly';
  CMDOPT_ALL = 'all';
  CMDPARAM_AUDIOBUFFER='-audiobuffer:';
  CMDPARAM_REGS='-regs:';
  CMDPARAM_CHANNELREGS='-chnregs:';
  CMDPARAM_ORIGIN='-org:';
  CMDPARAM_NOTETABLE='-notetable:';
  CMDPARAM_SFXNOTETABLE='-sfxnotetable:';
  CMDPARAM_SFXMODETABLE='-sfxmodetable:';
  CMDPARAM_SFXTABLE='-sfxtable:';
  CMDPARAM_TABTABLE='-tabtable:';
  CMDPARAM_SONGDATA='-songdata:';
  CMDPARAM_DATA='-data:';

var
  fini:TINIFile;

implementation

procedure openConfigINI();
begin
  fini:=TINIFile.Create(INI_CONFIG_FILE);
end;

procedure closeConfigINI();
begin
  fini.Free;
end;

procedure getConfigList(var list:TStrings);
begin
  fini.ReadSections(list);
end;

function isConfigExists(cfgName:string):boolean;
begin
  result:=fini.SectionExists(cfgName)
end;

procedure ReadConfigFromINI(cfgName:string);
begin
  with FormMain do
  begin
    cb_makeConf.Checked:=fini.ReadBool(cfgName,'makeConfig',false);
    cb_makeRes.Checked:=fini.ReadBool(cfgName,'makeResource',false);
    grp_reduce.ItemIndex:=fini.ReadInteger(cfgName,'reduce',3);
    grp_reindex.ItemIndex:=fini.ReadInteger(cfgName,'reindex',3);

    cb_Origin.Checked:=fini.ReadBool(cfgName,'origin',false);
    addrOrigin.Text:=fini.ReadString(cfgName,'addrOrigin','$A000');
    cb_noteTab.Checked:=fini.ReadBool(cfgName,'noteTab',false);
    addrNoteTab.Text:=fini.ReadString(cfgName,'addrNoteTab','');
    cb_sfxModes.Checked:=fini.ReadBool(cfgName,'sfxModes',false);
    addrSFXModes.Text:=fini.ReadString(cfgName,'addrSFXModes','');
    cb_sfxNotes.Checked:=fini.ReadBool(cfgName,'sfxNotes',false);
    addrSFXNotes.Text:=fini.ReadString(cfgName,'addrSFXNotes','');
    cb_sfxTab.Checked:=fini.ReadBool(cfgName,'SFXTable',false);
    addrSFXTab.Text:=fini.ReadString(cfgName,'addrSFXTable','');
    cb_tabTab.Checked:=fini.ReadBool(cfgName,'TABTable',false);
    addrTABTab.Text:=fini.ReadString(cfgName,'addrTABTable','');
    cb_songData.Checked:=fini.ReadBool(cfgName,'songData',false);
    addrSongData.Text:=fini.ReadString(cfgName,'addrSongData','');
    cb_data.Checked:=fini.ReadBool(cfgName,'data',false);
    addrData.Text:=fini.ReadString(cfgName,'addrData','');

    cb_audioBuf.Checked:=fini.ReadBool(cfgName,'audioBuffer',false);
    addrAudioBuf.Text:=fini.ReadString(cfgName,'addrAudioBuffer','$EB');
    cb_engineRegs.Checked:=fini.ReadBool(cfgName,'engineRegs',false);
    addrSFXRegs.Text:=fini.ReadString(cfgName,'addrEngineRegs','$F0');
    cb_chnRegs.Checked:=fini.ReadBool(cfgName,'channelRegs',false);
    addrChnRegs.Text:=fini.ReadString(cfgName,'addrChannelRegs','$6C0');
  end;
end;

procedure DeleteConfigFromINI(cfgName:string);
begin
  fini.EraseSection(cfgName);
end;

procedure SaveConfig2INI(cfgName:string);
begin
  with FormMain do
  begin
    fini.WriteBool(cfgName,'makeConfig',cb_makeConf.Checked);
    fini.WriteBool(cfgName,'makeResource',cb_makeRes.Checked);
    fini.WriteInteger(cfgName,'reduce',grp_reduce.ItemIndex);
    fini.WriteInteger(cfgName,'reindex',grp_reindex.ItemIndex);

    fini.WriteBool(cfgName,'origin',cb_Origin.Checked);
    fini.WriteString(cfgName,'addrOrigin',addrOrigin.Text);
    fini.WriteBool(cfgName,'noteTab',cb_noteTab.Checked);
    fini.WriteString(cfgName,'addrNoteTab',addrNoteTab.Text);
    fini.WriteBool(cfgName,'sfxModes',cb_sfxModes.Checked);
    fini.WriteString(cfgName,'addrSFXModes',addrSFXModes.Text);
    fini.WriteBool(cfgName,'sfxNotes',cb_sfxNotes.Checked);
    fini.WriteString(cfgName,'addrSFXNotes',addrSFXNotes.Text);
    fini.WriteBool(cfgName,'SFXTable',cb_sfxTab.Checked);
    fini.WriteString(cfgName,'addrSFXTable',addrSFXTab.Text);
    fini.WriteBool(cfgName,'TABTable',cb_tabTab.Checked);
    fini.WriteString(cfgName,'addrTABTable',addrTABTab.Text);
    fini.WriteBool(cfgName,'songData',cb_songData.Checked);
    fini.WriteString(cfgName,'addrSongData',addrSongData.Text);
    fini.WriteBool(cfgName,'data',cb_data.Checked);
    fini.WriteString(cfgName,'addrData',addrData.Text);

    fini.WriteBool(cfgName,'audioBuffer',cb_audioBuf.Checked);
    fini.WriteString(cfgName,'addrAudioBuffer',addrAudioBuf.Text);
    fini.WriteBool(cfgName,'engineRegs',cb_engineRegs.Checked);
    fini.WriteString(cfgName,'addrEngineRegs',addrSFXRegs.Text);
    fini.WriteBool(cfgName,'channelRegs',cb_chnRegs.Checked);
    fini.WriteString(cfgName,'addrChannelRegs',addrChnRegs.Text);
  end;
end;

procedure prepareConvertSMMParams(var Pro:TProcess);
begin
  with FormMain do
  begin
    Pro.Parameters.Add(fileInName.Text);
    Pro.Parameters.Add(fileOutName.Text);

    if cb_makeConf.Checked then Pro.Parameters.Add(CMDPARAM_MAKECONFIG);
    if cb_makeRes.Checked then Pro.Parameters.Add(CMDPARAM_MAKERESOURCE);
    case grp_reduce.ItemIndex of
      0: Pro.Parameters.Add(CMDPARAM_REDUCE+CMDOPT_SFXONLY);
      1: Pro.Parameters.Add(CMDPARAM_REDUCE+CMDOPT_TABONLY);
      2: Pro.Parameters.Add(CMDPARAM_REDUCE+CMDOPT_ALL);
    end;
    case grp_reindex.ItemIndex of
      0: Pro.Parameters.Add(CMDPARAM_REINDEX+CMDOPT_SFXONLY);
      1: Pro.Parameters.Add(CMDPARAM_REINDEX+CMDOPT_TABONLY);
      2: Pro.Parameters.Add(CMDPARAM_REINDEX+CMDOPT_ALL);
    end;

    if cb_audioBuf.Checked then Pro.Parameters.Add(CMDPARAM_AUDIOBUFFER+addrAudioBuf.Text);
    if cb_engineRegs.Checked then Pro.Parameters.Add(CMDPARAM_REGS+addrSFXRegs.Text);
    if cb_chnRegs.Checked then Pro.Parameters.Add(CMDPARAM_CHANNELREGS+addrChnRegs.Text);

    if cb_Origin.Checked then Pro.Parameters.Add(CMDPARAM_ORIGIN+addrOrigin.Text);
    if cb_noteTab.Checked then Pro.Parameters.Add(CMDPARAM_NOTETABLE+addrNoteTab.Text);
    if cb_sfxNotes.Checked then Pro.Parameters.Add(CMDPARAM_SFXNOTETABLE+addrSFXNotes.Text);
    if cb_sfxModes.Checked then Pro.Parameters.Add(CMDPARAM_SFXMODETABLE+addrSFXModes.Text);
    if cb_sfxTab.Checked then Pro.Parameters.Add(CMDPARAM_SFXTABLE+addrSFXTab.Text);
    if cb_tabTab.Checked then Pro.Parameters.Add(CMDPARAM_TABTABLE+addrTABTab.Text);
    if cb_songData.Checked then Pro.Parameters.Add(CMDPARAM_SONGDATA+addrSongData.Text);
    if cb_data.Checked then Pro.Parameters.Add(CMDPARAM_DATA+addrData.Text);
  end;
end;

function getSMMVersion():String;
var
  Pro: TProcess;
  List:TStringList;

begin
  result:='';
  Pro := TProcess.Create(nil);
  Pro.Executable := FILE_SMMCONV;
  Pro.Parameters.Add('--v');
  Pro.Options := [poUsePipes,{ poStderrToOutPut, }poWaitOnExit, poNoConsole];
  Pro.ShowWindow:=swoHide;
  List:=TStringList.Create();
  try
    Pro.Execute();
    if Pro.Output<> nil then
    begin
      List.LoadFromStream(Pro.Output);
      result:=List.Text;
//      Frm.ListBox1.Items.Text:=Frm.ListBox1.Items.Text + List.Text;
    end;
  except
    on E:EProcess do
      ShowMessage(E.Message);
    on E:Exception do  // generic handler
      ShowMessage('Caught ' + E.ClassName + ': ' + E.Message);
  end;
  List.Free;
  Pro.Free;
end;

procedure convertSMM();
var
  Pro: TProcess;
  List: TStringList;
  output: TStrings;

begin
  FormOutput:=TFormOutput.Create(nil);
  FormOutput.memo.Clear;

  Pro:=TProcess.Create(nil);
  Pro.Executable:=FILE_SMMCONV;
  prepareConvertSMMParams(Pro);
//  Frm.ListBox1.Items.AddStrings(Pro.Parameters.Text);
  Pro.Options := [
                   poUsePipes,
//                   poStderrToOutPut,
                   poWaitOnExit
//                   poNewProcessGroup
//                   poNoConsole
                 ];
  Pro.ShowWindow:=swoMinimize;

  List:=TStringList.Create();
  output:=FormOutput.memo.Lines;
  try
    Pro.Execute();
    if Pro.Output<> nil then
    begin
      List.LoadFromStream(Pro.Output);
      output.Text:=output.Text+'Output:';
      output.Text:=output.Text+List.Text;
    end;
    if Pro.StdErr<> nil then
    begin
      List.LoadFromStream(Pro.StdErr);
      output.Text:=output.Text+'StdErr:';
      output.Text:=output.Text+List.Text;
    end;
  except
    on E:EProcess do
      output.Add(E.Message);
    on E:Exception do  // generic handler
      output.Add('Caught '+E.ClassName+': '+E.Message);
  end;

  List.Free();
  Pro.Free();
end;

procedure switchAddr(var addr: TEdit; var cb: TCheckBox);
begin
  addr.Enabled:=cb.Checked;
  if cb.Checked then
    addr.SetFocus;
end;

function isGood2Start():boolean;
begin
  result:=(length(FormMain.fileInName.Text)>0) and
          (length(FormMain.fileOutName.Text)>0);
end;

end.

