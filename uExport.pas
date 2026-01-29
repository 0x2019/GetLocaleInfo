unit uExport;

interface

uses
  Winapi.Windows, System.SysUtils, System.IOUtils, ShellAPI;

type
  TLocaleField = record
    Key: string;
    Value: string;
  end;

function BuildCSV(AForm: TObject): string;
function BuildJSON(AForm: TObject): string;
function BuildText(AForm: TObject): string;

procedure ExportCSV(AForm: TObject; const FileName: string);
procedure ExportJSON(AForm: TObject; const FileName: string);
procedure ExportText(AForm: TObject; const FileName: string);

implementation

uses
  uMain, uMain.UI.Messages, uMain.UI.Strings;

function BuildFields(AForm: TObject): TArray<TLocaleField>;
var
  F: TfrmMain;
begin
  SetLength(Result, 0);
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  SetLength(Result, 15);
  Result[0].Key := F.lblLocale.Caption;
  Result[0].Value := F.cbLocale.Text;

  Result[1].Key := F.lblCountryR.Caption;
  Result[1].Value := F.lblCountryW.Caption;

  Result[2].Key := F.lblLanguageR.Caption;
  Result[2].Value := F.lblLanguageW.Caption;

  Result[3].Key := F.lblCountryCodeR.Caption;
  Result[3].Value := F.lblCountryCodeW.Caption;

  Result[4].Key := F.lblLanguageIDR.Caption;
  Result[4].Value := F.lblLanguageIDW.Caption;

  Result[5].Key := F.lblCodePageR.Caption;
  Result[5].Value := F.lblCodePageW.Caption;

  Result[6].Key := F.lblBCP47R.Caption;
  Result[6].Value := F.lblBCP47W.Caption;

  Result[7].Key := F.lblISO6391R.Caption;
  Result[7].Value := F.lblISO6391W.Caption;

  Result[8].Key := F.lblISO31661R.Caption;
  Result[8].Value := F.lblISO31661W.Caption;

  Result[9].Key := F.lblNativeDisplayNameR.Caption;
  Result[9].Value := F.lblNativeDisplayNameW.Caption;

  Result[10].Key := F.lblShortDateFormatR.Caption;
  Result[10].Value := F.lblShortDateFormatW.Caption;

  Result[11].Key := F.lblLongDateFormatR.Caption;
  Result[11].Value := F.lblLongDateFormatW.Caption;

  Result[12].Key := F.lblTimeFormatR.Caption;
  Result[12].Value := F.lblTimeFormatW.Caption;

  Result[13].Key := F.lblCurrencySymbolR.Caption;
  Result[13].Value := F.lblCurrencySymbolW.Caption;

  Result[14].Key := F.lblCurrencyIntlSymbolR.Caption;
  Result[14].Value := F.lblCurrencyIntlSymbolW.Caption;
end;

function BuildCSV(AForm: TObject): string;
var
  Fields: TArray<TLocaleField>;
  I: Integer;
  Line: string;
  Item: string;
begin
  Result := '';
  Fields := BuildFields(AForm);
  if Length(Fields) = 0 then Exit;

  Line := '';
  for I := 0 to High(Fields) do
  begin
    if I > 0 then
      Line := Line + ',';
    Item := StringReplace(Fields[I].Key, '"', '""', [rfReplaceAll]);
    Line := Line + '"' + Item + '"';
  end;
  Result := Line + sLineBreak;

  Line := '';
  for I := 0 to High(Fields) do
  begin
    if I > 0 then
      Line := Line + ',';
    Item := StringReplace(Fields[I].Value, '"', '""', [rfReplaceAll]);
    Line := Line + '"' + Item + '"';
  end;
  Result := Result + Line;
end;

function BuildJSON(AForm: TObject): string;
var
  Fields: TArray<TLocaleField>;
  I: Integer;
  KeyText: string;
  ValueText: string;
  Line: string;
begin
  Result := '';
  Fields := BuildFields(AForm);
  if Length(Fields) = 0 then Exit;

  Result := '{' + sLineBreak;
  for I := 0 to High(Fields) do
  begin
    KeyText := StringReplace(Fields[I].Key, '\', '\\', [rfReplaceAll]);
    KeyText := StringReplace(KeyText, '"', '\"', [rfReplaceAll]);
    KeyText := StringReplace(KeyText, sLineBreak, '\n', [rfReplaceAll]);
    KeyText := StringReplace(KeyText, #13, '\n', [rfReplaceAll]);
    KeyText := StringReplace(KeyText, #10, '\n', [rfReplaceAll]);

    ValueText := StringReplace(Fields[I].Value, '\', '\\', [rfReplaceAll]);
    ValueText := StringReplace(ValueText, '"', '\"', [rfReplaceAll]);
    ValueText := StringReplace(ValueText, sLineBreak, '\n', [rfReplaceAll]);
    ValueText := StringReplace(ValueText, #13, '\n', [rfReplaceAll]);
    ValueText := StringReplace(ValueText, #10, '\n', [rfReplaceAll]);

    Line := '  "' + KeyText + '": "' + ValueText + '"';
    if I < High(Fields) then
      Line := Line + ',';
    Result := Result + Line + sLineBreak;
  end;
  Result := Result + '}';
end;

function BuildText(AForm: TObject): string;
var
  Fields: TArray<TLocaleField>;
  I: Integer;
begin
  Result := '';
  Fields := BuildFields(AForm);
  if Length(Fields) = 0 then Exit;

  for I := 0 to High(Fields) do
    Result := Result + Fields[I].Key + ' ' + Fields[I].Value + sLineBreak;
end;

procedure ExportCSV(AForm: TObject; const FileName: string);
var
  F: TfrmMain;
  Enc: TEncoding;
  Content: string;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  Content := BuildCSV(F);
  if Trim(Content) = '' then Exit;

  Enc := TUTF8Encoding.Create(False);
  try
    try
      TFile.WriteAllText(FileName, Content, Enc);
    except
      on E: Exception do
      begin
        UI_MessageBox(F, Format(SFileSaveFailMsg, [FileName, E.Message]), MB_ICONERROR or MB_OK);
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

procedure ExportJSON(AForm: TObject; const FileName: string);
var
  F: TfrmMain;
  Enc: TEncoding;
  Content: string;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  Content := BuildJSON(F);
  if Trim(Content) = '' then Exit;

  Enc := TUTF8Encoding.Create(False);
  try
    try
      TFile.WriteAllText(FileName, Content, Enc);
    except
      on E: Exception do
      begin
        UI_MessageBox(F, Format(SFileSaveFailMsg, [FileName, E.Message]), MB_ICONERROR or MB_OK);
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

procedure ExportText(AForm: TObject; const FileName: string);
var
  F: TfrmMain;
  Enc: TEncoding;
  Content: string;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  Content := BuildText(F);
  if Trim(Content) = '' then Exit;

  Enc := TUTF8Encoding.Create(False);
  try
    try
      TFile.WriteAllText(FileName, Content, Enc);
    except
      on E: Exception do
      begin
        UI_MessageBox(F, Format(SFileSaveFailMsg, [FileName, E.Message]), MB_ICONERROR or MB_OK);
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

end.
