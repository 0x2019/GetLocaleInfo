program GetLocaleInfo;

uses
  Winapi.Windows,
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uAppController in 'uAppController.pas',
  uAppStrings in 'uAppStrings.pas',
  uLocale in 'uLocale.pas',
  uExport in '..\Common\uExport.pas',
  uForms in '..\Common\uForms.pas',
  uMenu.Popup in '..\Common\uMenu.Popup.pas',
  uMessageBox in '..\Common\uMessageBox.pas';

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
