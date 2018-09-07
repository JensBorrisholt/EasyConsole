unit EasyConsole.Input;

interface

uses
  System.Console, EasyConsole.Output;

type
  Input = record
  public
    class function ReadEnum<TEnum: record >(Prompt: string): TEnum; static;
    class function ReadInt: Integer; overload; static;
    class function ReadInt(aMin, aMax: Integer): Integer; overload; static;
    class function ReadInt(aPrompt: string; aMin, aMax: Integer): Integer; overload; static;
    class function ReadString(aPrompt: string): string; static;
    class function WaitForKey(aPrompt: string): string; static;
  end;

resourcestring
  STR_ENTER_AN_INTEGER = 'Please enter an Integer between %d and %d (inclusive)';
  STR_PLEASE_ENTER_AN_INTEGER = 'Please enter an Integer';

implementation

uses
  System.Sysutils, System.SysConst, System.Enumeration,
  EasyConsole.Types;
{ Input }

class function Input.ReadEnum<TEnum>(Prompt: string): TEnum;
var
  IterValue: Integer;
  Menu: TMenuVariable;
  Choice: TEnum;
  IterName: String;
  Enumeration: TEnumeration<TEnum>;
begin
  if not Enumeration.IsEnumeration then
    raise EInvalidCast.CreateRes(@SInvalidCast);

  Output.WriteLine(Prompt);

  Menu := TMenuVariable.Create;
  try
    for IterValue := Enumeration.MinValue to Enumeration.MaxValue do
    begin
      IterName := Enumeration.GetName(IterValue);
      Menu.Add(IterName,
        procedure(MenuItem: Variant)
        begin
          Choice := Enumeration.FromOrdinal(MenuItem - 1);
        end)
    end;
    Menu.Display;
    Result := Choice;
  finally
    Menu.Free;
  end;
end;

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

class function Input.WaitForKey(aPrompt: string): string;
var
  CursorVisible : Boolean;
begin
  Output.DisplayPrompt(aPrompt);
  CursorVisible := Console.CursorVisible;
  Console.CursorVisible := false;
  Result := Console.ReadLine;
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
  until False;

  Result := Value;
end;

initialization

end.
