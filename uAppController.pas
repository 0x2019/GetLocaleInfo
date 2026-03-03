unit uAppController;

interface

uses
  Winapi.Windows, System.Classes, System.Generics.Collections, System.StrUtils,
  System.SysUtils, Vcl.Forms, Vcl.Menus, Vcl.StdCtrls, ShellAPI, Clipbrd, uMain;

procedure App_InitLocales(AForm: TfrmMain);
procedure App_UpdateLocaleInfo(AForm: TfrmMain);
procedure App_SetDefaultLocale(AForm: TfrmMain);
procedure App_CopyLocaleInfo(AForm: TfrmMain);
procedure App_SaveToFile(AForm: TfrmMain);

implementation

uses
  uExport, uMessageBox,
  uAppStrings, uLocale;

function GetLocaleFields(AForm: TfrmMain): TArray<TExportField>;
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
  if AForm = nil then Exit;

  Add(AForm.lblLocale.Caption, AForm.cbLocale.Text);
  Add(AForm.lblCountryR.Caption, AForm.lblCountryW.Caption);
  Add(AForm.lblLanguageR.Caption, AForm.lblLanguageW.Caption);
  Add(AForm.lblCountryCodeR.Caption, AForm.lblCountryCodeW.Caption);
  Add(AForm.lblLanguageIDR.Caption, AForm.lblLanguageIDW.Caption);
  Add(AForm.lblCodePageR.Caption, AForm.lblCodePageW.Caption);
  Add(AForm.lblBCP47R.Caption, AForm.lblBCP47W.Caption);
  Add(AForm.lblISO6391R.Caption, AForm.lblISO6391W.Caption);
  Add(AForm.lblISO6392R.Caption, AForm.lblISO6392W.Caption);
  Add(AForm.lblISO31661R.Caption, AForm.lblISO31661W.Caption);
  Add(AForm.lblISO31661A3R.Caption, AForm.lblISO31661A3W.Caption);
  Add(AForm.lblNativeDisplayNameR.Caption, AForm.lblNativeDisplayNameW.Caption);
  Add(AForm.lblShortDateFormatR.Caption, AForm.lblShortDateFormatW.Caption);
  Add(AForm.lblLongDateFormatR.Caption, AForm.lblLongDateFormatW.Caption);
  Add(AForm.lblTimeFormatR.Caption, AForm.lblTimeFormatW.Caption);
  Add(AForm.lblCurrencySymbolR.Caption, AForm.lblCurrencySymbolW.Caption);
  Add(AForm.lblCurrencyIntlSymbolR.Caption, AForm.lblCurrencyIntlSymbolW.Caption);
end;

procedure App_InitLocales(AForm: TfrmMain);
var
  I, Idx: Integer;
  SysLocale: string;
begin
  if AForm = nil then Exit;

  if AForm.FLocales = nil then
    AForm.FLocales := TList<TLocaleItem>.Create
  else
    AForm.FLocales.Clear;

  LoadSystemLocalesSorted(AForm.FLocales);

  AForm.cbLocale.Items.BeginUpdate;
  try
    AForm.cbLocale.Clear;
    for I := 0 to AForm.FLocales.Count - 1 do
      AForm.cbLocale.Items.Add(AForm.FLocales[I].Display);
  finally
    AForm.cbLocale.Items.EndUpdate;
  end;

  if AForm.cbLocale.Items.Count > 0 then
  begin
    SysLocale := GetUserDefaultLocaleNameS;
    Idx := FindLocaleIndex(AForm.FLocales, SysLocale);
    if Idx < 0 then Idx := 0;

    AForm.cbLocale.ItemIndex := Idx;
    App_UpdateLocaleInfo(AForm);
  end;
end;

procedure App_UpdateLocaleInfo(AForm: TfrmMain);
var
  Info: TLocaleInfo;
  LocaleName: string;
begin
  if AForm = nil then Exit;
  if AForm.FLocales = nil then Exit;
  if (AForm.cbLocale.ItemIndex < 0) or (AForm.cbLocale.ItemIndex >= AForm.FLocales.Count) then Exit;

  LocaleName := AForm.FLocales[AForm.cbLocale.ItemIndex].Name;
  Info := GetLocaleInfo(LocaleName);

  AForm.lblCountryW.Caption := Info.CountryName;
  AForm.lblCountryCodeW.Caption := Info.CountryCode;
  AForm.lblLanguageW.Caption := Info.LanguageName;
  AForm.lblNativeDisplayNameW.Caption := Info.NativeDisplayName;

  AForm.lblLanguageIDW.Caption := IfThen(Info.NLCID = 0, SNotAvailable, Format('%d (0x%.8x)', [Info.NLCID, Cardinal(Info.NLCID)]));
  AForm.lblCodePageW.Caption := IfThen(Info.CodePage = '', SNotAvailable, Info.CodePage);
  AForm.lblBCP47W.Caption := IfThen(Info.BCP47 = '', SNotAvailable, Info.BCP47);
  AForm.lblISO6391W.Caption := IfThen(Info.ISO6391 = '', SNotAvailable, Info.ISO6391);
  AForm.lblISO6392W.Caption := IfThen(Info.ISO6392 = '', SNotAvailable, Info.ISO6392);
  AForm.lblISO31661W.Caption := IfThen(Info.ISO31661 = '', SNotAvailable, Info.ISO31661);
  AForm.lblISO31661A3W.Caption := IfThen(Info.ISO31661A3 = '', SNotAvailable, Info.ISO31661A3);

  AForm.lblShortDateFormatW.Caption := IfThen(Info.ShortDateFormat = '', SNotAvailable, Info.ShortDateFormat);
  AForm.lblLongDateFormatW.Caption := IfThen(Info.LongDateFormat = '', SNotAvailable, Info.LongDateFormat);
  AForm.lblTimeFormatW.Caption := IfThen(Info.TimeFormat = '', SNotAvailable, Info.TimeFormat);
  AForm.lblCurrencySymbolW.Caption := IfThen(Info.CurrencySymbol = '', SNotAvailable, Info.CurrencySymbol);
  AForm.lblCurrencyIntlSymbolW.Caption := IfThen(Info.CurrencyIntlSymbol = '', SNotAvailable, Info.CurrencyIntlSymbol);
end;

procedure App_SetDefaultLocale(AForm: TfrmMain);
var
  SysLocale: string;
  Idx: Integer;
begin
  if AForm = nil then Exit;
  if (AForm.FLocales = nil) or (AForm.FLocales.Count = 0) then Exit;

  SysLocale := GetUserDefaultLocaleNameS;
  Idx := FindLocaleIndex(AForm.FLocales, SysLocale);
  if Idx < 0 then Idx := 0;

  AForm.cbLocale.ItemIndex := Idx;
  App_UpdateLocaleInfo(AForm);
end;

procedure App_CopyLocaleInfo(AForm: TfrmMain);
begin
  if AForm = nil then Exit;
  Clipboard.AsText := BuildText(GetLocaleFields(AForm));
end;

procedure App_SaveToFile(AForm: TfrmMain);
var
  FileName, Ext, Content: string;
  FilterIndex: Integer;
  Fields: TArray<TExportField>;
begin
  if AForm = nil then Exit;
  if not Assigned(AForm.sSaveDlg) then Exit;

  if AForm.sSaveDlg.FilterIndex < 1 then
    AForm.sSaveDlg.FilterIndex := 1;
  AForm.sSaveDlg.FileName := Format('GLI_%s', [FormatDateTime('yyyymmdd_hhnnss', Now)]);

  if not AForm.sSaveDlg.Execute then Exit;

  FileName := AForm.sSaveDlg.FileName;
  FilterIndex := AForm.sSaveDlg.FilterIndex;

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

  Fields := GetLocaleFields(AForm);

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
      UI_MessageBox(AForm, Format(SFileSaveFailMsg, [FileName, E.Message]), MB_ICONERROR or MB_OK);
      Exit;
    end;
  end;

  if UI_ConfirmYesNo(AForm, Format(SFileSavedMsg, [FileName]) + sLineBreak + sLineBreak + SOpenFileMsg) then
  begin
    if ShellExecute(0, 'open', PChar(FileName), nil, nil, SW_SHOWNORMAL) <= 32 then
      UI_MessageBox(AForm, SOpenFileFailMsg, MB_ICONWARNING or MB_OK);
  end;
end;

end.
