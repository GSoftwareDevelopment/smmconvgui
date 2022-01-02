unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, ComCtrls, EditBtn, LCLIntf;

type

  { TFormMain }

  TFormMain = class(TForm)
    butOpenProjectURL: TButton;
    butOpenHelpURL: TButton;
    Label1: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    SourceName: TFileNameEdit;
    Label2: TLabel;
    OutputName: TFileNameEdit;

    grpProfile: TGroupBox;
      ProfilesList: TComboBox;
      butAddProfile: TSpeedButton;
      butDelProfile: TSpeedButton;

    Options: TPageControl;
    butStart: TSpeedButton;

      tabAPI_Optimize: TTabSheet;
        grp_apifiles: TCheckGroup;
          cb_makeConf: TCheckBox;
          cb_makeRes: TCheckBox;

          grp_reduce: TRadioGroup;
          grp_reindex: TRadioGroup;

      tabAddresses: TTabSheet;
        HeaderControl1: THeaderControl;

      tabBuf_Regs: TTabSheet;
        HeaderControl2: THeaderControl;

      tabAbout: TTabSheet;
        Label3: TLabel;
        memAbout: TMemo;



    procedure butDelProfileClick(Sender: TObject);
    procedure butAddProfileClick(Sender: TObject);
    procedure butOpenProjectURLClick(Sender: TObject);
    procedure butOpenHelpURLClick(Sender: TObject);
    procedure butStartClick(Sender: TObject);
    procedure OutputNameChange(Sender: TObject);
    procedure ProfilesListSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    procedure cb_addr_Click(Sender: TObject);
    procedure fn_addr_Origin(Sender: TObject);
    procedure fn_addr_trim(Sender: TObject);

  public

  end;

var
  FormMain: TFormMain;
  cb_addrs:array[0..10] of TCheckBox;
  ed_addrs:array[0..10] of TEdit;
  fn_addrs:array[0..7] of TEdit;

implementation
{$R *.lfm}
uses output, Logic;

{ TFormMain }

procedure TFormMain.FormCreate(Sender: TObject);
var
  list:TStrings;

  procedure preparePagesFields();
  const
    topStep = 28;
    addrs:array[0..10] of string = (
      'Origin','Note table','MOD table','Notes table','SFXs table','TABs table','Song data','Data',
      'Audio buffer','Engine regs','Channels regs'
    );
  var
    i:byte;
    _top:integer;
    tabAddresses,
    tabBuf_Regs:TTabSheet;

  begin
    tabAddresses:=FormMain.tabAddresses;
    tabBuf_Regs:=FormMain.tabBuf_Regs;

    for i:=0 to 10 do
    begin
      if i<=7 then
      begin
        _top:=35+(i*topStep);
        cb_addrs[i]:=TCheckBox.Create(tabAddresses);
        cb_addrs[i].Parent:=tabAddresses;
        ed_addrs[i]:=TEdit.Create(tabAddresses);
        ed_addrs[i].parent:=tabAddresses;
        fn_addrs[i]:=TEdit.Create(tabAddresses);
        fn_addrs[i].parent:=tabAddresses;

        with fn_addrs[i] do
        begin
          name:='fn_'+IntToStr(i);

          left:=210; top:=_top;
          width:=230; height:=24;

          borderStyle:=bsNone;
          enabled:=false;
          showHint:=true;

          text:='';
          font.Size:=12;
          if i=0 then
            onEditingDone:=@fn_addr_Origin
          else
            onEditingDone:=@fn_addr_trim;
        end;
      end
      else
      begin
        _top:=35+((i-8)*topStep);
        cb_addrs[i]:=TCheckBox.Create(tabBuf_Regs);
        cb_addrs[i].Parent:=tabBuf_Regs;
        ed_addrs[i]:=TEdit.Create(tabBuf_Regs);
        ed_addrs[i].parent:=tabBuf_Regs;
      end;
      with cb_addrs[i] do
      begin
        name:='cb_'+IntToStr(i);

        left:=2;    top:=_top;
        width:=135; height:=21;

        autoSize:=false;
        caption:=addrs[i];

        onClick:=@cb_addr_Click;
      end;

      with ed_addrs[i] do
      begin
        name:='ed_'+IntToStr(i);

        left:=140; top:=_top;
        width:=64; height:=24;

        alignment:=taRightJustify;
        borderStyle:=bsNone;
        charCase:=ecUppercase;
        enabled:=false;

        text:=addrs_defaults[i];
        font.pitch:=fpFixed;
        font.Size:=12;
      end;
    end;
  end;

begin
  prepareAbout();
  preparePagesFields();

  openConfigINI();
  list:=ProfilesList.Items;
  getConfigList(list);
  ProfilesList.ItemIndex:=list.IndexOf(DEFAULT_PROFILE_NAME);
  Options.ActivePage:=tabAbout;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  CloseConfigINI();
end;

//
//
//

procedure TFormMain.OutputNameChange(Sender: TObject);
begin
  fn_addrs[0].Text:=Trim(ExtractFileName(OutputName.Text));
end;

//
// Profiles
//

procedure TFormMain.butAddProfileClick(Sender: TObject);
Var
  cfgName:string;
  saveIt:boolean;
  id:integer;

begin
  id:=ProfilesList.ItemIndex;
  if id=-1 then
    cfgName:=''
  else
    cfgName:=ProfilesList.Items[id];

  repeat
    if not InputQuery('Add/Update profile','Profile name:',false,cfgName) then
      exit;
    cfgName:=trim(cfgName);
    if length(cfgName)<3 then
      MessageDlg('Name too short','Please enter at least 3 characters..',mtError,[mbClose],0);
  until length(cfgName)>=3;
  saveIt:=true;

  if isConfigExists(cfgName) then
    saveIt:=MessageDlg(
      'Warning',
      'Profile `'+cfgName+'` is exist.'+sLineBreak+sLineBreak+
      'Do you want update it?',
      mtConfirmation,[mbYes,mbNo],0)<>mrNo;

  if saveIt then
  begin
    id:=ProfilesList.Items.IndexOf(cfgName);
    if id>0 then ProfilesList.Items.Delete(id);
    ProfilesList.Items.add(cfgName);
    ProfilesList.ItemIndex:=ProfilesList.Items.IndexOf(cfgName);

    SaveConfig2INI(cfgName);
  end;
end;

procedure TFormMain.butDelProfileClick(Sender: TObject);
var
  curConfig:string;
  id:integer;

begin
  id:=ProfilesList.ItemIndex;
  curConfig:=ProfilesList.Items[id];
  if MessageDlg('Delete profile',
                'Are you sure you want delete `'+curConfig+'` profile?',
                mtConfirmation, [mbYes, mbNo],0)=mrNo then exit;

  if not isConfigExists(curConfig) then
    MessageDlg('Error','Profile not exist.',mtError,[mbClose],0)
  else
  begin
    ProfilesList.Items.Delete(id);
    DeleteConfigFromINI(curConfig);
    ProfilesList.ItemIndex:=0;
  end;
end;

procedure TFormMain.ProfilesListSelect(Sender: TObject);
var
  cfgName:string;

begin
  cfgName:=ProfilesList.Items[ProfilesList.ItemIndex];

  if not isConfigExists(cfgName) then
    MessageDlg('Error','Profile not exist.',mtError,[mbClose],0)
  else
    ReadConfigFromINI(cfgName);
end;

//
//
//

//
// About URLs buttons
//

procedure TFormMain.butOpenProjectURLClick(Sender: TObject);
begin
  openURL(PROJECT_URL);
end;

procedure TFormMain.butOpenHelpURLClick(Sender: TObject);
begin
  openURL(HELP_URL);
end;

procedure TFormMain.butStartClick(Sender: TObject);
var
  outputFileName:String;

begin
  if not isGood2Start(SourceName) then
  begin
    MessageDlg(
        'Information',
        'Source file was not specified.',
        mtInformation,
        [mbAbort],0);
    Exit;
  end;
  if not isGood2Start(OutputName) then
  begin
    outputFileName:=SourceName.Text+'.asm';
    if MessageDlg(
        'Information',
        'Output file was not specified.'+sLineBreak+sLineBreak+
        'Generated file will be created in the source file folder.'+sLineBreak+
        'The primary output file will be named'+sLineBreak+
        '"'+outputFileName+'"'+sLineBreak+sLineBreak+
        'Do you agree whit this?',
        mtInformation,
        [mbYes, mbNo],0)=mrNo then Exit;
  end;

  butStart.Enabled:=false;
  convertSMM();

  FormOutput.ShowModal;
  FreeAndNil(FormOutput);
  butStart.Enabled:=true;
end;

//
//
//

procedure TFormMain.fn_addr_trim(Sender: TObject);
var
  ed:TEdit;
  path:string;

begin
  if (Sender is TEdit) then
  begin
    ed:=TEdit(Sender);
    ed.Text:=Trim(ed.text);
    if (length(ed.Text)>0) then
    begin
      path:=ExtractFileDir(OutputName.Text);
      if length(path)>0 then
        path:=IncludeTrailingPathDelimiter(path);
      path:=path+ed.Text;
      ed.Hint:=path;
    end;
  end;
end;

procedure TFormMain.cb_addr_Click(Sender: TObject);
var
  cb: TCheckBox;
  id: integer;
begin
  if (Sender is TCheckBox) then
  begin
    cb:=TCheckBox(Sender);
    TryStrToInt(rightStr(cb.Name,length(cb.Name)-3), id);
    with ed_addrs[id] do
    begin
      Enabled:=cb.Checked;
      if changeFocus2Addr and enabled then SetFocus;
    end;
    if id<=7 then
      fn_addrs[id].Enabled:=cb.Checked;
  end;
end;

procedure TFormMain.fn_addr_Origin(Sender: TObject);
var
  ed:TEdit;
  path:string;

begin
  if (Sender is TEdit) then
  begin
    ed:=TEdit(Sender);
    fn_addr_trim(ed);
    if (length(ed.Text)>0) then
    begin
      path:=ExtractFileDir(OutputName.Text);
      if length(path)>0 then
        path:=IncludeTrailingPathDelimiter(path);
      path:=path+ed.Text;
      OutputName.Text:=path;
    end;
  end;
end;


end.

