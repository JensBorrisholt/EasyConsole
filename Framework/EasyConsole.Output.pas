unit EasyConsole.Output;

interface

uses
  System.Console;

type
  Output = record
  public
    class procedure WriteLine(Value: Variant; Args: array of Variant); overload; static;
    class procedure WriteLine(aColor: TConsoleColor; Value: Variant; Args: array of Variant); overload; static;

    class procedure WriteLine(aColor: TConsoleColor; aValue: string); overload; static;

    class procedure WriteLine(Value: Variant); overload; static;

    class procedure DisplayPrompt(aPrompt: string); overload; static;

    class procedure DisplayPrompt(aPrompt: string; Args: array of const); overload; static;
  end;

implementation

uses
  System.Sysutils;
{ Output }

class procedure Output.DisplayPrompt(aPrompt: string; Args: array of const);
begin
  Console.Write(Trim(aPrompt) + ' ', Args);
end;

class procedure Output.WriteLine(Value: Variant; Args: array of Variant);
begin
  Output.WriteLine(Console.ForegroundColor, Value, Args);
end;

class procedure Output.WriteLine(aColor: TConsoleColor; Value: Variant; Args: array of Variant);
begin
  Console.ForegroundColor := aColor;
  Console.WriteLine(Value, Args);
  Console.ResetColor;
end;

class procedure Output.WriteLine(Value: Variant);
begin
  Console.WriteLine(Value);
end;

class procedure Output.DisplayPrompt(aPrompt: string);
begin
  DisplayPrompt(aPrompt, []);
end;

class procedure Output.WriteLine(aColor: TConsoleColor; aValue: string);
begin
  Output.WriteLine(aColor, aValue, []);
end;

end.
