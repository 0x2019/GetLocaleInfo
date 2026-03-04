unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls,
  Vcl.Forms, Vcl.StdCtrls, System.Generics.Collections, sSkinManager, sSkinProvider,
  sGroupBox, Vcl.Mask, sMaskEdit, sCustomComboEdit, sComboBox, sLabel,
  System.ImageList, Vcl.ImgList, acAlphaImageList, Vcl.Buttons, sBitBtn,
  Vcl.Dialogs, sDialogs, Vcl.Menus,

  uForms, uMenu.Popup, uMessageBox,
  uLocale;

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
    lblShortDateFormatR: TsLabel;
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
    pMCopy: TPopupMenu;
    pMCopyOnSelect: TMenuItem;
    btnCopy: TsBitBtn;
    lblISO31661A3R: TsLabel;
    lblISO31661A3W: TsLabel;
    lblISO6392R: TsLabel;
    lblISO6392W: TsLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbLocaleChange(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure pMCopyOnSelectClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure pMCopyPopup(Sender: TObject);
  private
    { Private declarations }
  public
    FLocales: TList<TLocaleItem>;
    procedure ChangeMessageBoxPosition(var Msg: TMessage); message mbMessage;
    procedure DragForm(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  uAppController, uAppStrings;

procedure TfrmMain.ChangeMessageBoxPosition(var Msg: TMessage);
begin
  UI_ChangeMessageBoxPosition(Self);
end;

procedure TfrmMain.DragForm(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  UI_DragForm(Self, Button);
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  AppController_About(Self);
end;

procedure TfrmMain.btnCopyClick(Sender: TObject);
begin
  AppController_Copy(Self);
end;

procedure TfrmMain.btnDefaultClick(Sender: TObject);
begin
  AppController_Default(Self);
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  AppController_Exit(Self);
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  AppController_SaveAs(Self);
end;

procedure TfrmMain.cbLocaleChange(Sender: TObject);
begin
  AppController_Update(Self);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  UI_SetMinConstraints(Self);
  UI_SetAlwaysOnTop(Self, True);

  grpLocale.OnMouseDown := DragForm;
  grpInfo.OnMouseDown := DragForm;

  AppController_Init(Self);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FLocales) then
    FLocales.Free;
end;

procedure TfrmMain.pMCopyOnSelectClick(Sender: TObject);
begin
  UI_Menu_Popup_Copy(Sender);
end;

procedure TfrmMain.pMCopyPopup(Sender: TObject);
var
  Items: TPopupItems;
begin
  Items := Default(TPopupItems);
  Items.Copy := pMCopyOnSelect;
  UI_Menu_Popup_Update(Sender, Items);
end;

end.
