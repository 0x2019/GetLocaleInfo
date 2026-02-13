unit uLocale;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

type
  TLocaleItem = record
    Name: string;
    Display: string;
  end;

type
  TLocaleInfo = record
    CountryName: string;
    CountryCode: string;
    NativeDisplayName: string;
    LanguageName: string;
    NLCID: LCID;
    CodePage: string;
    BCP47: string;
    ISO6391: string;
    ISO31661: string;
    ShortDateFormat: string;
    LongDateFormat: string;
    TimeFormat: string;
    CurrencySymbol: string;
    CurrencyIntlSymbol: string;
  end;

function FindLocaleIndex(const List: TList<TLocaleItem>; const LocaleName: string): Integer;

function GetLocaleInfo(const LocaleName: string): TLocaleInfo;
function GetLocaleInfoExS(const LocaleName: string; LCTYPE: Integer): string;

function GetUserDefaultLocaleNameS: string;

procedure LoadSystemLocales(const List: TList<TLocaleItem>);
procedure LoadSystemLocalesSorted(const List: TList<TLocaleItem>);

implementation

function EnumLocalesProc(lpLocaleString: PWideChar; dwFlags: DWORD; lParam: LPARAM): Integer; stdcall;
var
  List: TList<TLocaleItem>;
  Item: TLocaleItem;
  Name, DisplayName: string;
begin
  Result := 1;
  if lpLocaleString = nil then
    Exit;

  List := TList<TLocaleItem>(Pointer(lParam));
  if List = nil then
    Exit;

  Name := lpLocaleString;

  DisplayName := GetLocaleInfoExS(Name, LOCALE_SLOCALIZEDDISPLAYNAME);
  if DisplayName = '' then
    DisplayName := Name;

  Item.Name := Name;
  Item.Display := DisplayName;
  List.Add(Item);
end;

function FindLocaleIndex(const List: TList<TLocaleItem>; const LocaleName: string): Integer;
var
  I, P: Integer;
  Lang, Prefix: string;
begin
  Result := -1;
  if (List = nil) or (List.Count = 0) then
    Exit;

  if LocaleName <> '' then
    for I := 0 to List.Count - 1 do
      if SameText(List[I].Name, LocaleName) then
      begin
        Result := I;
        Exit;
      end;

  Lang := LocaleName;
  P := Pos('-', Lang);
  if P > 0 then
    Lang := Copy(Lang, 1, P - 1);

  if Lang = '' then
    Exit;

  Prefix := Lang + '-';
  for I := 0 to List.Count - 1 do
    if SameText(List[I].Name, Lang) or SameText(Copy(List[I].Name, 1, Length(Prefix)), Prefix) then
    begin
      Result := I;
      Exit;
    end;
end;

function GetLocaleInfo(const LocaleName: string): TLocaleInfo;
var
  CodePageValue: Integer;
  CodePageInfo: TCPInfoEx;
begin
  Result.CountryName := GetLocaleInfoExS(LocaleName, LOCALE_SLOCALIZEDCOUNTRYNAME);
  if Result.CountryName = '' then
    Result.CountryName := GetLocaleInfoExS(LocaleName, LOCALE_SCOUNTRY);

  Result.CountryCode := GetLocaleInfoExS(LocaleName, LOCALE_ICOUNTRY);
  Result.NativeDisplayName := GetLocaleInfoExS(LocaleName, LOCALE_SNATIVEDISPLAYNAME);
  Result.LanguageName := GetLocaleInfoExS(LocaleName, LOCALE_SLOCALIZEDLANGUAGENAME);
  Result.NLCID := LocaleNameToLCID(PChar(LocaleName), LOCALE_ALLOW_NEUTRAL_NAMES);
  Result.CodePage := GetLocaleInfoExS(LocaleName, LOCALE_IDEFAULTANSICODEPAGE);

  if TryStrToInt(Result.CodePage, CodePageValue) and (CodePageValue <> 0) and
    GetCPInfoEx(CodePageValue, 0, CodePageInfo) then
    Result.CodePage := CodePageInfo.CodePageName
  else
    Result.CodePage := '';

  Result.BCP47 := LocaleName;
  Result.ISO6391 := GetLocaleInfoExS(LocaleName, LOCALE_SISO639LANGNAME);
  Result.ISO31661 := GetLocaleInfoExS(LocaleName, LOCALE_SISO3166CTRYNAME);
  Result.ShortDateFormat := GetLocaleInfoExS(LocaleName, LOCALE_SSHORTDATE);
  Result.LongDateFormat := GetLocaleInfoExS(LocaleName, LOCALE_SLONGDATE);
  Result.TimeFormat := GetLocaleInfoExS(LocaleName, LOCALE_STIMEFORMAT);
  Result.CurrencySymbol := GetLocaleInfoExS(LocaleName, LOCALE_SCURRENCY);
  Result.CurrencyIntlSymbol := GetLocaleInfoExS(LocaleName, LOCALE_SINTLSYMBOL);
end;

function GetLocaleInfoExS(const LocaleName: string; LCTYPE: Integer): string;
var
  Len: Integer;
begin
  Len := GetLocaleInfoEx(PChar(LocaleName), LCTYPE, nil, 0);
  if Len <= 1 then
    Exit('');

  SetLength(Result, Len - 1);
  if GetLocaleInfoEx(PChar(LocaleName), LCTYPE, PChar(Result), Len) = 0 then
    Result := '';
end;

function GetUserDefaultLocaleNameS: string;
var
  Buf: array[0..LOCALE_NAME_MAX_LENGTH-1] of WideChar;
begin
  if GetUserDefaultLocaleName(@Buf[0], LOCALE_NAME_MAX_LENGTH) > 0 then
    Result := Buf
  else
    Result := '';
end;

procedure LoadSystemLocales(const List: TList<TLocaleItem>);
begin
  if List = nil then Exit;
  List.Clear;

  EnumSystemLocalesEx(@EnumLocalesProc, LOCALE_ALL, LPARAM(List), nil);
end;

procedure LoadSystemLocalesSorted(const List: TList<TLocaleItem>);
begin
  LoadSystemLocales(List);
  List.Sort(TComparer<TLocaleItem>.Construct(
    function(const A, B: TLocaleItem): Integer
    begin
      Result := CompareText(A.Display, B.Display);
    end));
end;

end.
