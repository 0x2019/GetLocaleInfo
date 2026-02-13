unit uMain.UI;

interface

uses
  Winapi.Windows, System.Classes, System.StrUtils, System.SysUtils,
  System.Generics.Collections, Vcl.Forms, Vcl.Menus, Vcl.StdCtrls, Clipbrd;

procedure UI_Init(AForm: TObject);

procedure UI_Default(AForm: TObject);
procedure UI_Copy(AForm: TObject);
procedure UI_CopyPM(Sender: TObject);
procedure UI_Save(AForm: TObject);
procedure UI_About(AForm: TObject);
procedure UI_Exit(AForm: TObject);

procedure UI_LocaleInit(AForm: TObject);
procedure UI_LocaleChange(AForm: TObject);

procedure UI_UpdateLocaleInfo(AForm: TObject; const LocaleName: string);

implementation

uses
  uExport, uLocale, uMain, uMain.UI.Messages, uMain.UI.Strings;

procedure UI_Init(AForm: TObject);
var
  F: TfrmMain;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  F.Constraints.MinWidth := F.Width;
  F.Constraints.MinHeight := F.Height;

  F.grpLocale.OnMouseDown := F.DragForm;
  F.grpInfo.OnMouseDown := F.DragForm;

  SetWindowPos(F.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
end;

procedure UI_Default(AForm: TObject);
var
  F: TfrmMain;
  SysLocale: string;
  Idx: Integer;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  if (F.FLocales = nil) or (F.FLocales.Count = 0) then Exit;

  SysLocale := GetUserDefaultLocaleNameS;
  Idx := FindLocaleIndex(F.FLocales, SysLocale);
  if Idx < 0 then
    Idx := 0;

  F.cbLocale.ItemIndex := Idx;
  UI_LocaleChange(F);
end;

procedure UI_Copy(AForm: TObject);
var
  F: TfrmMain;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  Clipboard.AsText := BuildText(F);
end;

procedure UI_CopyPM(Sender: TObject);
var
  MI: TMenuItem;
  PM: TPopupMenu;
  PopupCtrl: TComponent;
  S: string;
begin
  if not (Sender is TMenuItem) then Exit;
  MI := TMenuItem(Sender);

  PM := MI.GetParentMenu as TPopupMenu;
  if PM = nil then Exit;

  PopupCtrl := PM.PopupComponent;
  if not (PopupCtrl is TCustomLabel) then Exit;

  S := TCustomLabel(PopupCtrl).Caption;
  if S <> '' then
    Clipboard.AsText := S;
end;

procedure UI_Save(AForm: TObject);
var
  F: TfrmMain;
  FileName: string;
  Ext: string;
  FilterIndex: Integer;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  if not Assigned(F.sSaveDlg) then Exit;

  if F.sSaveDlg.FilterIndex < 1 then
    F.sSaveDlg.FilterIndex := 1;
  F.sSaveDlg.FileName := Format('GLI_%s', [FormatDateTime('yyyymmdd_hhnnss', Now)]);
  if not F.sSaveDlg.Execute then Exit;

  FileName := F.sSaveDlg.FileName;
  FilterIndex := F.sSaveDlg.FilterIndex;
  case FilterIndex of
    2: Ext := '.csv';
    3: Ext := '.json';
    4: Ext := LowerCase(ExtractFileExt(FileName));
  else
    Ext := '.txt';
  end;

  if Ext = '' then
    Ext := '.txt';

  if ExtractFileExt(FileName) = '' then
    FileName := FileName + Ext
  else if (FilterIndex <> 4) or not SameText(ExtractFileExt(FileName), Ext) then
    FileName := ChangeFileExt(FileName, Ext);

  if SameText(Ext, '.csv') then
    ExportCSV(F, FileName)
  else if SameText(Ext, '.json') then
    ExportJSON(F, FileName)
  else
    ExportText(F, FileName);
end;

procedure UI_About(AForm: TObject);
var
  F: TfrmMain;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  UI_MessageBox(F, Format(SAboutMsg, [APP_NAME, APP_VERSION, APP_RELEASE, APP_URL]), MB_ICONQUESTION or MB_OK);
end;

procedure UI_Exit(AForm: TObject);
var
  F: TfrmMain;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  F.Close;
end;

procedure UI_LocaleInit(AForm: TObject);
var
  F: TfrmMain;
  I: Integer;
  SysLocale: string;
  Idx: Integer;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  if F.FLocales = nil then
    F.FLocales := TList<TLocaleItem>.Create
  else
    F.FLocales.Clear;

  LoadSystemLocalesSorted(F.FLocales);

  F.cbLocale.Items.BeginUpdate;
  try
    F.cbLocale.Clear;
    for I := 0 to F.FLocales.Count - 1 do
      F.cbLocale.Items.Add(F.FLocales[I].Display);
  finally
    F.cbLocale.Items.EndUpdate;
  end;

  if F.cbLocale.Items.Count > 0 then
  begin
    SysLocale := GetUserDefaultLocaleNameS;
    Idx := FindLocaleIndex(F.FLocales, SysLocale);
    if Idx < 0 then
      Idx := 0;

    F.cbLocale.ItemIndex := Idx;
    UI_LocaleChange(F);
  end;
end;

procedure UI_LocaleChange(AForm: TObject);
var
  F: TfrmMain;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  if F.FLocales = nil then Exit;

  if (F.cbLocale.ItemIndex < 0) or (F.cbLocale.ItemIndex >= F.FLocales.Count) then
    Exit;

  UI_UpdateLocaleInfo(F, F.FLocales[F.cbLocale.ItemIndex].Name);
end;

procedure UI_UpdateLocaleInfo(AForm: TObject; const LocaleName: string);
var
  F: TfrmMain;
  Info: TLocaleInfo;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  Info := GetLocaleInfo(LocaleName);

  F.lblCountryW.Caption := Info.CountryName;
  F.lblCountryCodeW.Caption := Info.CountryCode;
  F.lblLanguageW.Caption := Info.LanguageName;
  F.lblNativeDisplayNameW.Caption := Info.NativeDisplayName;

  F.lblLanguageIDW.Caption := IfThen(Info.NLCID = 0, SNotAvailable, Format('%d (0x%.8x)', [Info.NLCID, Cardinal(Info.NLCID)]));
  F.lblCodePageW.Caption := IfThen(Info.CodePage = '', SNotAvailable, Info.CodePage);
  F.lblBCP47W.Caption := IfThen(Info.BCP47 = '', SNotAvailable, Info.BCP47);
  F.lblISO6391W.Caption := IfThen(Info.ISO6391 = '', SNotAvailable, Info.ISO6391);
  F.lblISO31661W.Caption := IfThen(Info.ISO31661 = '', SNotAvailable, Info.ISO31661);

  F.lblShortDateFormatW.Caption := IfThen(Info.ShortDateFormat = '', SNotAvailable, Info.ShortDateFormat);
  F.lblLongDateFormatW.Caption := IfThen(Info.LongDateFormat = '', SNotAvailable, Info.LongDateFormat);
  F.lblTimeFormatW.Caption := IfThen(Info.TimeFormat = '', SNotAvailable, Info.TimeFormat);
  F.lblCurrencySymbolW.Caption := IfThen(Info.CurrencySymbol = '', SNotAvailable, Info.CurrencySymbol);
  F.lblCurrencyIntlSymbolW.Caption := IfThen(Info.CurrencyIntlSymbol = '', SNotAvailable, Info.CurrencyIntlSymbol)
end;

end.
