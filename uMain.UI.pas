unit uMain.UI;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, System.IOUtils,
  Vcl.Forms, ShellAPI;

procedure UI_Init(AForm: TObject);

procedure UI_Save(AForm: TObject);
procedure UI_About(AForm: TObject);
procedure UI_Exit(AForm: TObject);

procedure UI_LocaleInit(AForm: TObject);
procedure UI_LocaleChange(AForm: TObject);

procedure UI_UpdateLocaleInfo(AForm: TObject; const LocaleName: string);

implementation

uses
  uLocale, uMain, uMain.UI.Messages, uMain.UI.Strings;

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

procedure UI_Save(AForm: TObject);
var
  F: TfrmMain;
  FileName: string;
  Enc: TEncoding;
  S: string;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  if not Assigned(F.sSaveDlg) then Exit;

  S :=
    F.lblLocale.Caption + ' ' + F.cbLocale.Text + sLineBreak +
    F.lblCountryR.Caption + ' ' + F.lblCountryW.Caption + sLineBreak +
    F.lblLanguageR.Caption + ' ' + F.lblLanguageW.Caption + sLineBreak +
    F.lblCountryCodeR.Caption + ' ' + F.lblCountryCodeW.Caption + sLineBreak +
    F.lblLanguageIDR.Caption + ' ' + F.lblLanguageIDW.Caption + sLineBreak +
    F.lblBCP47R.Caption + ' ' + F.lblBCP47W.Caption + sLineBreak +
    F.lblISO6391R.Caption + ' ' + F.lblISO6391W.Caption + sLineBreak +
    F.lblISO31661R.Caption + ' ' + F.lblISO31661W.Caption + sLineBreak +
    F.lblNativeDisplayNameR.Caption + ' ' + F.lblNativeDisplayNameW.Caption + sLineBreak +
    F.lblShortDateFormatR.Caption + ' ' + F.lblShortDateFormatW.Caption + sLineBreak +
    F.lblLongDateFormatR.Caption + ' ' + F.lblLongDateFormatW.Caption + sLineBreak +
    F.lblTimeFormatR.Caption + ' ' + F.lblTimeFormatW.Caption + sLineBreak +
    F.lblCurrencySymbolR.Caption + ' ' + F.lblCurrencySymbolW.Caption + sLineBreak +
    F.lblCurrencyIntlSymbolR.Caption + ' ' + F.lblCurrencyIntlSymbolW.Caption + sLineBreak;

  if Trim(S) = '' then Exit;

  F.sSaveDlg.FileName := Format('GLI_%s.txt', [FormatDateTime('yyyymmdd_hhnnss', Now)]);
  if not F.sSaveDlg.Execute then Exit;

  FileName := F.sSaveDlg.FileName;
  if ExtractFileExt(FileName) = '' then
    FileName := FileName + '.txt';

  Enc := TUTF8Encoding.Create(False);
  try
    try
      TFile.WriteAllText(FileName, S, Enc);
    except
      on E: Exception do
      begin
        UI_MessageBox(F, Format(SFileSaveErrMsg, [FileName, E.Message]), MB_ICONERROR or MB_OK);
        Exit;
      end;
    end;
  finally
    Enc.Free;
  end;

  if UI_ConfirmYesNo(F, Format(SFileSavedMsg, [FileName]) + sLineBreak + sLineBreak + SOpenFileMsg) then
  begin
    if ShellExecute(0, 'open', PChar(FileName), nil, nil, SW_SHOWNORMAL) <= 32 then
      UI_MessageBox(F, SOpenFileFailMsg, MB_ICONWARNING or MB_OK);
  end;
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

  if Info.NLCID = 0 then
    F.lblLanguageIDW.Caption := 'N/A'
  else
    F.lblLanguageIDW.Caption := Format('%d (0x%.8x)', [Info.NLCID, Cardinal(Info.NLCID)]);

  F.lblBCP47W.Caption := Info.BCP47;
  F.lblISO6391W.Caption := Info.ISO6391;
  F.lblISO31661W.Caption := Info.ISO31661;

  F.lblShortDateFormatW.Caption := Info.ShortDateFormat;
  F.lblLongDateFormatW.Caption := Info.LongDateFormat;
  F.lblTimeFormatW.Caption := Info.TimeFormat;
  F.lblCurrencySymbolW.Caption := Info.CurrencySymbol;
  F.lblCurrencyIntlSymbolW.Caption := Info.CurrencyIntlSymbol;
end;

end.
