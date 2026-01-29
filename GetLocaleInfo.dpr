program GetLocaleInfo;

uses
  Winapi.Windows,
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uLocale in 'uLocale.pas',
  uMain.UI in 'uMain.UI.pas',
  uMain.UI.Messages in 'uMain.UI.Messages.pas',
  uMain.UI.Strings in 'uMain.UI.Strings.pas',
  uExport in 'uExport.pas';

var
  uMutex: THandle;

{$O+} {$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED}
{$R *.res}

begin
  uMutex := CreateMutex(nil, True, 'GLI!');
  if (uMutex <> 0 ) and (GetLastError = 0) then begin

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;

  if uMutex <> 0 then
    CloseHandle(uMutex);
  end;
end.
