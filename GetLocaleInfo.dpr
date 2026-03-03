program GetLocaleInfo;

uses
  Winapi.Windows,
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uLocale in 'uLocale.pas',
  uAppStrings in 'uAppStrings.pas',
  uExport in 'Common\uExport.pas',
  uMessageBox in 'Common\uMessageBox.pas',
  uForms in 'Common\uForms.pas',
  uAppController in 'uAppController.pas',
  uMenu.Popup in 'Common\uMenu.Popup.pas';

var
  uMutex: THandle;

{$R *.res}

begin
  uMutex := CreateMutex(nil, True, 'GLI!');
  if (uMutex <> 0) and (GetLastError = 0) then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TfrmMain, frmMain);
    Application.Run;

    if uMutex <> 0 then
      CloseHandle(uMutex);
  end;
end.
