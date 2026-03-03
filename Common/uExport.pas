unit uExport;

interface

uses
  System.SysUtils, System.IOUtils, System.JSON;

type
  TExportField = record
    Key: string;
    Value: string;
  end;

function BuildCSV(const Fields: TArray<TExportField>): string;
function BuildJSON(const Fields: TArray<TExportField>): string;
function BuildText(const Fields: TArray<TExportField>): string;

procedure ExportToFile(const FileName, Content: string);

implementation

function BuildCSV(const Fields: TArray<TExportField>): string;
var
  I: Integer;
  Line, Item: string;
begin
  Result := '';
  if Length(Fields) = 0 then Exit;

  Line := '';
  for I := 0 to High(Fields) do
  begin
    if I > 0 then Line := Line + ',';
    Item := StringReplace(Fields[I].Key, '"', '""', [rfReplaceAll]);
    Line := Line + '"' + Item + '"';
  end;
  Result := Line + sLineBreak;

  Line := '';
  for I := 0 to High(Fields) do
  begin
    if I > 0 then Line := Line + ',';
    Item := StringReplace(Fields[I].Value, '"', '""', [rfReplaceAll]);
    Line := Line + '"' + Item + '"';
  end;
  Result := Result + Line;
end;

function BuildJSON(const Fields: TArray<TExportField>): string;
var
  I: Integer;
  KeyText: string;
  JSONObj: TJSONObject;
begin
  Result := '';
  if Length(Fields) = 0 then Exit;

  JSONObj := TJSONObject.Create;
  try
    for I := 0 to High(Fields) do
    begin
      KeyText := Trim(Fields[I].Key);
      if (KeyText <> '') and (KeyText[Length(KeyText)] = ':') then
        SetLength(KeyText, Length(KeyText) - 1);
      JSONObj.AddPair(KeyText, Fields[I].Value);
    end;
    Result := JSONObj.Format(2);
  finally
    JSONObj.Free;
  end;
end;

function BuildText(const Fields: TArray<TExportField>): string;
var
  I: Integer;
begin
  Result := '';
  if Length(Fields) = 0 then Exit;

  for I := 0 to High(Fields) do
    Result := Result + Fields[I].Key + ' ' + Fields[I].Value + sLineBreak;
end;

procedure ExportToFile(const FileName, Content: string);
var
  Enc: TEncoding;
begin
  if Trim(Content) = '' then Exit;

  Enc := TUTF8Encoding.Create(False);
  try
    TFile.WriteAllText(FileName, Content, Enc);
  finally
    Enc.Free;
  end;
end;

end.
