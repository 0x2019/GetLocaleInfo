unit uAppController;

interface

uses
  Winapi.Windows, System.Classes, System.Generics.Collections, System.StrUtils,
  System.SysUtils, Vcl.Forms, Vcl.Menus, Vcl.StdCtrls, ShellAPI, Clipbrd, uMain;

procedure AppController_Init(F: TfrmMain);
procedure AppController_Update(F: TfrmMain);

procedure AppController_Default(F: TfrmMain);
procedure AppController_Copy(F: TfrmMain);
procedure AppController_SaveAs(F: TfrmMain);
procedure AppController_About(F: TfrmMain);
procedure AppController_Exit(F: TfrmMain);

implementation

uses
  uExport, uMessageBox,
  uAppStrings, uLocale;

function GetLocaleFields(F: TfrmMain): TArray<TExportField>;
var
  Idx: Integer;
  procedure Add(const AKey, AValue: string);
  begin
    Idx := Length(Result);
    SetLength(Result, Idx + 1);
    Result[Idx].Key := AKey;
    Result[Idx].Value := AValue;
  end;
begin
  Result := nil;
  if F = nil then Exit;

  Add(F.lblLocale.Caption, F.cbLocale.Text);
  Add(F.lblCountryR.Caption, F.lblCountryW.Caption);
  Add(F.lblLanguageR.Caption, F.lblLanguageW.Caption);
  Add(F.lblCountryCodeR.Caption, F.lblCountryCodeW.Caption);
  Add(F.lblLanguageIDR.Caption, F.lblLanguageIDW.Caption);
  Add(F.lblCodePageR.Caption, F.lblCodePageW.Caption);
  Add(F.lblBCP47R.Caption, F.lblBCP47W.Caption);
  Add(F.lblISO6391R.Caption, F.lblISO6391W.Caption);
  Add(F.lblISO6392R.Caption, F.lblISO6392W.Caption);
  Add(F.lblISO31661R.Caption, F.lblISO31661W.Caption);
  Add(F.lblISO31661A3R.Caption, F.lblISO31661A3W.Caption);
  Add(F.lblNativeDisplayNameR.Caption, F.lblNativeDisplayNameW.Caption);
  Add(F.lblShortDateFormatR.Caption, F.lblShortDateFormatW.Caption);
  Add(F.lblLongDateFormatR.Caption, F.lblLongDateFormatW.Caption);
  Add(F.lblTimeFormatR.Caption, F.lblTimeFormatW.Caption);
  Add(F.lblCurrencySymbolR.Caption, F.lblCurrencySymbolW.Caption);
  Add(F.lblCurrencyIntlSymbolR.Caption, F.lblCurrencyIntlSymbolW.Caption);
end;

procedure AppController_Init(F: TfrmMain);
var
  I, Idx: Integer;
  SysLocale: string;
begin
  if F = nil then Exit;

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
    if Idx < 0 then Idx := 0;

    F.cbLocale.ItemIndex := Idx;
    AppController_Update(F);
  end;
end;

procedure AppController_Update(F: TfrmMain);
var
  Info: TLocaleInfo;
  LocaleName: string;
begin
  if F = nil then Exit;
  if F.FLocales = nil then Exit;
  if (F.cbLocale.ItemIndex < 0) or (F.cbLocale.ItemIndex >= F.FLocales.Count) then Exit;

  LocaleName := F.FLocales[F.cbLocale.ItemIndex].Name;
  Info := GetLocaleInfo(LocaleName);

  F.lblCountryW.Caption := Info.CountryName;
  F.lblCountryCodeW.Caption := Info.CountryCode;
  F.lblLanguageW.Caption := Info.LanguageName;
  F.lblNativeDisplayNameW.Caption := Info.NativeDisplayName;

  F.lblLanguageIDW.Caption := IfThen(Info.NLCID = 0, SNotAvailable, Format('%d (0x%.8x)', [Info.NLCID, Cardinal(Info.NLCID)]));
  F.lblCodePageW.Caption := IfThen(Info.CodePage = '', SNotAvailable, Info.CodePage);
  F.lblBCP47W.Caption := IfThen(Info.BCP47 = '', SNotAvailable, Info.BCP47);
  F.lblISO6391W.Caption := IfThen(Info.ISO6391 = '', SNotAvailable, Info.ISO6391);
  F.lblISO6392W.Caption := IfThen(Info.ISO6392 = '', SNotAvailable, Info.ISO6392);
  F.lblISO31661W.Caption := IfThen(Info.ISO31661 = '', SNotAvailable, Info.ISO31661);
  F.lblISO31661A3W.Caption := IfThen(Info.ISO31661A3 = '', SNotAvailable, Info.ISO31661A3);

  F.lblShortDateFormatW.Caption := IfThen(Info.ShortDateFormat = '', SNotAvailable, Info.ShortDateFormat);
  F.lblLongDateFormatW.Caption := IfThen(Info.LongDateFormat = '', SNotAvailable, Info.LongDateFormat);
  F.lblTimeFormatW.Caption := IfThen(Info.TimeFormat = '', SNotAvailable, Info.TimeFormat);
  F.lblCurrencySymbolW.Caption := IfThen(Info.CurrencySymbol = '', SNotAvailable, Info.CurrencySymbol);
  F.lblCurrencyIntlSymbolW.Caption := IfThen(Info.CurrencyIntlSymbol = '', SNotAvailable, Info.CurrencyIntlSymbol);
end;

procedure AppController_Default(F: TfrmMain);
var
  SysLocale: string;
  Idx: Integer;
begin
  if F = nil then Exit;
  if (F.FLocales = nil) or (F.FLocales.Count = 0) then Exit;

  SysLocale := GetUserDefaultLocaleNameS;
  Idx := FindLocaleIndex(F.FLocales, SysLocale);
  if Idx < 0 then Idx := 0;

  F.cbLocale.ItemIndex := Idx;
  AppController_Update(F);
end;

procedure AppController_Copy(F: TfrmMain);
begin
  if F = nil then Exit;
  try
    Clipboard.AsText := BuildText(GetLocaleFields(F));
  except
    on E: Exception do
      UI_MessageBox(F, Format(SClipboardCopyErrMsg, [E.Message]), MB_ICONWARNING or MB_OK);
  end;
end;

procedure AppController_SaveAs(F: TfrmMain);
var
  FileName, Ext, Content: string;
  FilterIndex: Integer;
  Fields: TArray<TExportField>;
begin
  if F = nil then Exit;
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

  if Ext = '' then Ext := '.txt';

  if ExtractFileExt(FileName) = '' then
    FileName := FileName + Ext
  else if (FilterIndex <> 4) or not SameText(ExtractFileExt(FileName), Ext) then
    FileName := ChangeFileExt(FileName, Ext);

  Fields := GetLocaleFields(F);

  if SameText(Ext, '.csv') then
    Content := BuildCSV(Fields)
  else if SameText(Ext, '.json') then
    Content := BuildJSON(Fields)
  else
    Content := BuildText(Fields);

  try
    ExportToFile(FileName, Content);
  except
    on E: Exception do
    begin
      UI_MessageBox(F, Format(SFileSaveFailMsg, [FileName, E.Message]), MB_ICONERROR or MB_OK);
      Exit;
    end;
  end;

  if UI_ConfirmYesNo(F, Format(SFileSavedMsg, [FileName]) + sLineBreak + sLineBreak + SOpenFileMsg) then
  begin
    if ShellExecute(0, 'open', PChar(FileName), nil, nil, SW_SHOWNORMAL) <= 32 then
      UI_MessageBox(F, SOpenFileFailMsg, MB_ICONWARNING or MB_OK);
  end;
end;

procedure AppController_About(F: TfrmMain);
begin
  if F = nil then Exit;
  UI_MessageBox(F, Format(SAboutMsg, [APP_NAME, APP_VERSION, APP_RELEASE, APP_URL]), MB_ICONQUESTION or MB_OK);
end;

procedure AppController_Exit(F: TfrmMain);
begin
  if F = nil then Exit;
  F.Close;
end;

end.
