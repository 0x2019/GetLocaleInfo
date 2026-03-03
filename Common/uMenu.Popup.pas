unit uMenu.Popup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, Vcl.Menus, Vcl.Controls,
  Vcl.StdCtrls, Clipbrd;

type
  TPopupItems = record
    Copy: TMenuItem;
    SelectAll: TMenuItem;
  end;

procedure UI_Menu_Popup_Update(Sender: TObject; const AItems: TPopupItems);

procedure UI_Menu_Popup_Copy(Sender: TObject);
procedure UI_Menu_Popup_SelectAll(Sender: TObject);

implementation

const
  EM_GETSCROLLPOS = WM_USER + 221;
  EM_SETSCROLLPOS = WM_USER + 222;

function GetPopupComponent(Sender: TObject): TComponent;
var
  MI: TMenuItem;
begin
  Result := nil;
  if Sender is TPopupMenu then
    Result := TPopupMenu(Sender).PopupComponent
  else if Sender is TMenuItem then
  begin
    MI := TMenuItem(Sender);
    if MI.GetParentMenu is TPopupMenu then
      Result := TPopupMenu(MI.GetParentMenu).PopupComponent;
  end;
end;

procedure UI_Menu_Popup_Update(Sender: TObject; const AItems: TPopupItems);
var
  Comp: TComponent;
  CanCopy, CanSelectAll: Boolean;
begin
  Comp := GetPopupComponent(Sender);
  CanCopy := False;
  CanSelectAll := False;

  if Comp is TCustomEdit then
  begin
    CanCopy := TCustomEdit(Comp).SelLength > 0;
    CanSelectAll := Length(TCustomEdit(Comp).Text) > 0;
  end
  else if Comp is TCustomLabel then
  begin
    CanCopy := TCustomLabel(Comp).Caption <> '';
    CanSelectAll := False;
  end;

  if Assigned(AItems.Copy) then AItems.Copy.Enabled := CanCopy;
  if Assigned(AItems.SelectAll) then AItems.SelectAll.Enabled := CanSelectAll;
end;

procedure UI_Menu_Popup_Copy(Sender: TObject);
var
  Comp: TComponent;
begin
  Comp := GetPopupComponent(Sender);

  if Comp is TCustomEdit then
    TCustomEdit(Comp).CopyToClipboard
  else if Comp is TCustomLabel then
    Clipboard.AsText := TCustomLabel(Comp).Caption;
end;

procedure UI_Menu_Popup_SelectAll(Sender: TObject);
var
  Comp: TComponent;
  ScrollPos: TPoint;
begin
  Comp := GetPopupComponent(Sender);

  if Comp is TCustomEdit then
  begin
    SendMessage(TWinControl(Comp).Handle, EM_GETSCROLLPOS, 0, LPARAM(@ScrollPos));
    SendMessage(TWinControl(Comp).Handle, WM_SETREDRAW, 0, 0);

    TCustomEdit(Comp).SelectAll;

    SendMessage(TWinControl(Comp).Handle, EM_SETSCROLLPOS, 0, LPARAM(@ScrollPos));
    SendMessage(TWinControl(Comp).Handle, WM_SETREDRAW, 1, 0);

    InvalidateRect(TWinControl(Comp).Handle, nil, True);
  end;
end;

end.
