unit logic;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Forms, INIFiles, Process, StdCtrls,
  main, output;

function convertSMM():TFormOutput;
procedure switchAddr(var addr: TEdit; var cb: TCheckBox);
function isGood2Start():boolean;

procedure openConfigINI();
procedure closeConfigINI();

function getConfigList():TStringList;
function isConfigExists(cfgName:string):boolean;
procedure ReadConfigFromINI(cfgName:string);
procedure DeleteConfigFromINI(cfgName:string);
procedure SaveConfig2INI(cfgName:string);

const
  INI_CONFIG_FILE = 'configs.ini';

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

function getConfigList():TStringList;
var
   list:TStringList;

begin
  list:=TStringList.Create();
  try
     fini.ReadSections(list);
  finally
  end;
  result:=list;
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

function convertSMM():TFormOutput;
var
  frm: TFormOutput;
  Pro: TProcess;
  List: TStringList;

begin
  frm:=TFormOutput.Create(nil);
  result:=frm;
  Pro := TProcess.Create(nil);
  try
    with FormMain do
    begin
      Pro.Executable := 'smm-conv';
      Pro.Parameters.Add(fileInName.Text);
      Pro.Parameters.Add(fileOutName.Text);

      if cb_makeConf.Checked then Pro.Parameters.Add('-MC');
      if cb_makeRes.Checked then Pro.Parameters.Add('-MR');
      case grp_reduce.ItemIndex of
        0: Pro.Parameters.Add('-reduce:sfxonly');
        1: Pro.Parameters.Add('-reduce:tabonly');
        2: Pro.Parameters.Add('-reduce:all');
      end;
      case grp_reindex.ItemIndex of
        0: Pro.Parameters.Add('-reindex:sfxonly');
        1: Pro.Parameters.Add('-reindex:tabonly');
        2: Pro.Parameters.Add('-reindex:all');
      end;

      if cb_audioBuf.Checked then Pro.Parameters.Add('-audiobuffer:'+addrAudioBuf.Text);
      if cb_engineRegs.Checked then Pro.Parameters.Add('-regs:'+addrSFXRegs.Text);
      if cb_chnRegs.Checked then Pro.Parameters.Add('-chnregs:'+addrChnRegs.Text);

      if cb_Origin.Checked then Pro.Parameters.Add('-org:'+addrOrigin.Text);
      if cb_noteTab.Checked then Pro.Parameters.Add('-notetable:'+addrNoteTab.Text);
      if cb_sfxNotes.Checked then Pro.Parameters.Add('-sfxnotetable:'+addrSFXNotes.Text);
      if cb_sfxModes.Checked then Pro.Parameters.Add('-sfxmodetable:'+addrSFXModes.Text);
      if cb_sfxTab.Checked then Pro.Parameters.Add('-sfxtable:'+addrSFXTab.Text);
      if cb_tabTab.Checked then Pro.Parameters.Add('-tabtable:'+addrTABTab.Text);
      if cb_songData.Checked then Pro.Parameters.Add('-songdata:'+addrSongData.Text);
      if cb_data.Checked then Pro.Parameters.Add('-data:'+addrData.Text);
    end;

    Pro.Options := [poUsePipes, poStderrToOutPut, poWaitOnExit, poNoConsole];
    Pro.ShowWindow:=swoNone;
    Pro.Execute();
    List:=TStringList.Create();
    try
       Frm.ListBox1.Items.Clear;
       if Pro.Output<> nil then List.LoadFromStream(Pro.Output);
       Frm.ListBox1.Items.Text := Frm.ListBox1.Items.Text  + List.Text;
    finally
      List.Free();
    end;
  finally
    Pro.Free();
  end;
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

