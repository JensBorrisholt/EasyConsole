unit EasyConsole.Input;

interface

uses
  System.Console, EasyConsole.Output;

type
  Input = record
  public
    class function ReadInt: Integer; overload; static;
    class function ReadInt(aMin, aMax: Integer): Integer; overload; static;
    class function ReadInt(aPrompt: string; aMin, aMax: Integer): Integer; overload; static;
    class function ReadString(aPrompt: string): string; static;
    class function WaitForKey(aPrompt: string): TConsoleKeyInfo; static;
  end;

resourcestring
  STR_ENTER_AN_INTEGER = 'Please enter an Integer between %d and %d (inclusive)';
  STR_PLEASE_ENTER_AN_INTEGER = 'Please enter an Integer';

implementation

uses
  System.Sysutils, EasyConsole.Types;

{ Input }

class function Input.ReadInt(aPrompt: string; aMin, aMax: Integer): Integer;
begin
  Output.DisplayPrompt(aPrompt);
  Result := ReadInt(aMin, aMax);
end;

class function Input.ReadString(aPrompt: string): string;
begin
  Output.DisplayPrompt(aPrompt);
  Result := Console.ReadLine;
end;

class function Input.WaitForKey(aPrompt: string): TConsoleKeyInfo;
var
  CursorVisible: Boolean;
begin
  Output.DisplayPrompt(aPrompt);
  CursorVisible := Console.CursorVisible;
  Console.CursorVisible := false;
  Result := Console.ReadKey(True);
  Console.CursorVisible := CursorVisible;
end;

class function Input.ReadInt(aMin, aMax: Integer): Integer;
var
  Value: Integer;
begin
  Value := ReadInt;

  while (Value < aMin) or (Value > aMax) do
  begin
    Output.DisplayPrompt(STR_ENTER_AN_INTEGER, [aMin, aMax]);
    Value := ReadInt;
  end;

  Result := Value;
end;

class function Input.ReadInt: Integer;
var
  Input: String;
  Value: Integer;
begin
  repeat
    Input := Console.ReadLine;
    if TryStrToInt(Input, Value) then
      break;

    Output.DisplayPrompt(STR_PLEASE_ENTER_AN_INTEGER);
  until false;

  Result := Value;
end;

initialization

end.
