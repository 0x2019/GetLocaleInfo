unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls,
  Vcl.Forms, Vcl.StdCtrls, System.Generics.Collections, sSkinManager, sSkinProvider, uLocale,
  sGroupBox, Vcl.Mask, sMaskEdit, sCustomComboEdit, sComboBox, sLabel,
  System.ImageList, Vcl.ImgList, acAlphaImageList, Vcl.Buttons, sBitBtn,
  Vcl.Dialogs, sDialogs;

const
  mbMessage = WM_USER + 1024;

type
  TfrmMain = class(TForm)
    grpInfo: TsGroupBox;
    lblCountryR: TsLabel;
    lblLanguageR: TsLabel;
    lblCountryCodeR: TsLabel;
    lblLanguageIDR: TsLabel;
    lblBCP47R: TsLabel;
    lblISO31661R: TsLabel;
    lblISO6391R: TsLabel;
    sSkinProvider: TsSkinProvider;
    sSkinManager: TsSkinManager;
    grpLocale: TsGroupBox;
    cbLocale: TsComboBox;
    lblLocale: TsLabel;
    lblCountryW: TsLabel;
    lblLanguageW: TsLabel;
    lblCountryCodeW: TsLabel;
    lblBCP47W: TsLabel;
    lblISO6391W: TsLabel;
    lblISO31661W: TsLabel;
    lblLanguageIDW: TsLabel;
    lblNativeDisplayNameW: TsLabel;
    lblNativeDisplayNameR: TsLabel;
    lblShortDateFormatW: TsLabel;
    lblShortDateFormatR: TLabel;
    lblLongDateFormatW: TsLabel;
    lblLongDateFormatR: TsLabel;
    lblTimeFormatR: TsLabel;
    lblTimeFormatW: TsLabel;
    lblCurrencySymbolR: TsLabel;
    lblCurrencySymbolW: TsLabel;
    lblCurrencyIntlSymbolW: TsLabel;
    lblCurrencyIntlSymbolR: TsLabel;
    btnAbout: TsBitBtn;
    btnExit: TsBitBtn;
    sCharImageList: TsCharImageList;
    sSaveDlg: TsSaveDialog;
    btnSave: TsBitBtn;
    lblCodePageR: TsLabel;
    lblCodePageW: TsLabel;
    btnDefault: TsBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbLocaleChange(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
  private
    { Private declarations }
  public
    FLocales: TList<TLocaleItem>;
    procedure ChangeMessageBoxPosition(var Msg: TMessage); message mbMessage;
    procedure DragForm(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  uMain.UI, uMain.UI.Messages;

procedure TfrmMain.ChangeMessageBoxPosition(var Msg: TMessage);
begin
  UI_ChangeMessageBoxPosition(Self);
end;

procedure TfrmMain.DragForm(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
  end;
end;

procedure TfrmMain.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  if Msg.Result = htClient then Msg.Result := htCaption;
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  UI_About(Self);
end;

procedure TfrmMain.btnDefaultClick(Sender: TObject);
begin
  UI_Default(Self);
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  UI_Exit(Self);
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  UI_Save(Self);
end;

procedure TfrmMain.cbLocaleChange(Sender: TObject);
begin
  UI_LocaleChange(Self);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  UI_Init(Self);
  UI_LocaleInit(Self);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FLocales.Free;
end;

end.
