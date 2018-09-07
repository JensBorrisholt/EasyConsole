unit EasyConsole.Output;

interface

uses
  System.Console, System.Sysutils, EasyConsole.Spinner;

type
  TSequence = EasyConsole.Spinner.TSequence;

  Output = class
  public
    class function BusyIndicator<T>(aAction: TFunc<T>; aSequence: TSequence = TSequence.Sequence1): T; overload;
    class function BusyIndicator<T>(aPromp: string; aAction: TFunc<T>; aSequence: TSequence = TSequence.Sequence1): T; overload;
    class function BusyIndicator<T>(aPromp: string; Arg1: T; aAction: TFunc<T, T>; aSequence: TSequence = TSequence.Sequence1): T; overload;

    class procedure DisplayPrompt(aPrompt: string); overload; static;
    class procedure DisplayPrompt(aPrompt: string; Args: array of const); overload; static;

    class procedure EmptyLine;

    class procedure WriteLine(Value: Variant; Args: array of Variant); overload; static;
    class procedure WriteLine(aColor: TConsoleColor; Value: Variant; Args: array of Variant); overload; static;
    class procedure WriteLine(aColor: TConsoleColor; aValue: string); overload; static;
    class procedure WriteLine(Value: Variant); overload; static;
  end;

implementation

{ Output }

class function Output.BusyIndicator<T>(aPromp: string; aAction: TFunc<T>; aSequence: TSequence = TSequence.Sequence1): T;
begin
  with TSpinner.Create(aSequence) do
    try
      Start(aPromp);
      Result := aAction;
      Stop;
    finally
      free;
    end;
end;

class function Output.BusyIndicator<T>(aAction: TFunc<T>; aSequence: TSequence): T;
begin
  Result := BusyIndicator<T>('', aAction, aSequence);
end;

class function Output.BusyIndicator<T>(aPromp: string; Arg1: T; aAction: TFunc<T, T>; aSequence: TSequence): T;
begin
  with TSpinner.Create(aSequence) do
    try
      Start(aPromp);
      Result := aAction(Arg1);
      Stop;
    finally
      free;
    end;
end;

class procedure Output.DisplayPrompt(aPrompt: string; Args: array of const);
begin
  Console.Write(Trim(aPrompt) + ' ', Args);
end;

class procedure Output.EmptyLine;
begin
  Console.WriteLine('');
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
