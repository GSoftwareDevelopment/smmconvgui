unit logic;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Forms, INIFiles, Process, StdCtrls, EditBtn, Dialogs,
  main, output;

function getSMMVersion():String;
procedure convertSMM();
procedure switchAddr(var addr: TEdit; var cb: TCheckBox);
function isGood2Start(var textField:TFileNameEdit):boolean;

procedure openConfigINI();
procedure closeConfigINI();

procedure getConfigList(var list:TStrings);
function isConfigExists(cfgName:string):boolean;
procedure ReadConfigFromINI(cfgName:string);
procedure DeleteConfigFromINI(cfgName:string);
procedure SaveConfig2INI(cfgName:string);

procedure prepareAbout();

const
  INI_CONFIG_FILE = 'profiles.ini';
  DEFAULT_PROFILE_NAME = '- default -';
  FILE_SMMCONV = 'smm-conv';
  CMDPARAM_MAKECONFIG = '-MC';
  CMDPARAM_MAKERESOURCE = '-MR';
  CMDPARAM_REDUCE = '-reduce:';
  CMDPARAM_REINDEX = '-reindex:';
  CMDOPT_SFXONLY = 'sfxonly';
  CMDOPT_TABONLY = 'tabonly';
  CMDOPT_ALL = 'all';

  PROJECT_URL = 'https://github.com/GSoftwareDevelopment/smmconvgui';
  HELP_URL = 'https://gsoftwaredevelopment.github.io/smmconvgui/';

  addrs_params:array[0..10] of string = (
    '-org:','-notetable:','-sfxmodetable:','-sfxnotetable:','-sfxtable','-tabtable','-songdata:','-data:',
    '-audiobuffer:','-regs:','-chnregs:'
  );
  addrs_names:array[0..10] of string = (
    'origin','noteTab','modesTab','notesTab','SFXTab','TABTab','songData','data',
    'audioBuffer','engineRegs','channelRegs'
  );
  addrs_defaults:array[0..10] of string = (
    '$A000','','','','','','','',
    '$EB','$F0','$6C0'
  );

var
  fini:TINIFile;
  changeFocus2Addr:boolean = true;

implementation
uses VersionSupport;

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
  if not isConfigExists(DEFAULT_PROFILE_NAME) then
  begin
    list.Add(DEFAULT_PROFILE_NAME);
    SaveConfig2INI(DEFAULT_PROFILE_NAME);
  end;
end;

function isConfigExists(cfgName:string):boolean;
begin
  result:=fini.SectionExists(cfgName)
end;

procedure ReadConfigFromINI(cfgName:string);
var
  i:byte;

begin
  changeFocus2Addr:=false;
  with FormMain do
  begin
    cb_makeConf.Checked:=fini.ReadBool(cfgName,'makeConfig',false);
    cb_makeRes.Checked:=fini.ReadBool(cfgName,'makeResource',false);
    grp_reduce.ItemIndex:=fini.ReadInteger(cfgName,'reduce',3);
    grp_reindex.ItemIndex:=fini.ReadInteger(cfgName,'reindex',3);

    for i:=0 to 10 do
    begin
      cb_addrs[i].Checked:=fini.ReadBool(cfgName,addrs_names[i],false);
      ed_addrs[i].Text:=fini.ReadString(cfgName,'addr'+addrs_names[i],addrs_defaults[i]);
      if i<=7 then
        fn_addrs[i].Text:=fini.ReadString(cfgName,'fn'+addrs_names[i],'');
    end;
  end;
  changeFocus2Addr:=true;
end;

procedure DeleteConfigFromINI(cfgName:string);
begin
  fini.EraseSection(cfgName);
end;

procedure SaveConfig2INI(cfgName:string);
var
  i:byte;

begin
  with FormMain do
  begin
    fini.WriteBool(cfgName,'makeConfig',cb_makeConf.Checked);
    fini.WriteBool(cfgName,'makeResource',cb_makeRes.Checked);
    fini.WriteInteger(cfgName,'reduce',grp_reduce.ItemIndex);
    fini.WriteInteger(cfgName,'reindex',grp_reindex.ItemIndex);

    for i:=0 to 10 do
    begin
      fini.WriteBool(cfgName,addrs_names[i],cb_addrs[i].Checked);
      fini.WriteString(cfgName,'addr'+addrs_names[i],ed_addrs[i].Text);
      if i<=7 then
        fini.WriteString(cfgName,'fn'+addrs_names[i],fn_addrs[i].Text);
    end;
  end;
end;

procedure prepareConvertSMMParams(var Pro:TProcess);
var
  i:byte;
  fn:string;

begin
  with FormMain do
  begin
    Pro.Parameters.Add(SourceName.Text);
    if Length(OutputName.Text)>0 then
      Pro.Parameters.Add(OutputName.Text);

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

    for i:=0 to 10 do
      if cb_addrs[i].Checked then
      begin
        fn:='';
        if (i<=7) then
          if (length(fn_addrs[i].Text)>0) then
            fn:=':'+fn_addrs[i].Text;
        Pro.Parameters.Add(addrs_params[i]+ed_addrs[i].Text+fn);
      end;
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
  Pro.Options := [poUsePipes, poWaitOnExit, poNoConsole];
  Pro.ShowWindow:=swoHide;
  List:=TStringList.Create();
  try
    Pro.Execute();
    if Pro.Output<> nil then
    begin
      List.LoadFromStream(Pro.Output);
      result:=List.Text;
    end;
  except
    on E:EProcess do
      ShowMessage(E.Message);
    on E:Exception do
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
  output:=FormOutput.memo.Lines;
  output.Clear;

  Pro:=TProcess.Create(nil);
  Pro.Executable:=FILE_SMMCONV;
  prepareConvertSMMParams(Pro);
  Pro.Options := [poUsePipes, poWaitOnExit];
  Pro.ShowWindow:=swoMinimize;

  List:=TStringList.Create();
  try
    Pro.Execute();
    if Pro.Output<> nil then
    begin
      List.LoadFromStream(Pro.Output);
      output.Text:=output.Text+List.Text;
    end;
    if Pro.StdErr<> nil then
    begin
      List.LoadFromStream(Pro.StdErr);
      output.Text:=output.Text+List.Text;
    end;
  except
    on E:EProcess do
      output.Add(E.Message);
    on E:Exception do
      output.Add('Caught '+E.ClassName+': '+E.Message);
  end;

  List.Free();
  Pro.Free();
end;

procedure switchAddr(var addr: TEdit; var cb: TCheckBox);
begin
  addr.Enabled:=cb.Checked;
  if cb.Checked then
    if changeFocus2Addr then addr.SetFocus;
end;

function isGood2Start(var textField:TFileNameEdit):boolean;
begin
  textField.text:=trim(textField.Text);
  result:=(length(textField.Text)>0);
end;

procedure prepareAbout();
Var
  CLIVer:String;

begin
  FormMain.butOpenProjectURL.Hint:=PROJECT_URL;
  FormMain.butOpenHelpURL.Hint:=HELP_URL;

  with FormMain.memAbout do
  begin
    Lines.Clear;
    Lines.Add('version ' + GetFileVersion);
    Lines.Add('');
    Lines.Add('Built for '+GetTargetInfo);
    Lines.Add(' with '+GetCompilerInfo + ' on '+GetCompiledDate);
    Lines.Add(' and using '+GetLCLVersion + ' and ' + GetWidgetset);
    Lines.Add('');
    CLIVer:=getSMMVersion;
    if CLIVer<>'' then
      Lines.Add('CLI SMM Converter version: '+CLIVer);
  end;
end;

end.

