unit EasyConsole.FrameWork;

interface

uses
  EasyConsole.Types, System.Console.ConsoleBuffer;

type
  TMenuPage = class(TPage)
  strict private
    FWantGoBack: boolean;

  strict protected
    FMenu: TMenu;
    procedure AddGoBackPage;
    constructor Create(aTitle: String; Options: array of TOption; aWantGoBack: boolean = True); reintroduce; overload; virtual;
  public
    destructor Destory;
    function WaitForChoice: Integer; virtual;
    procedure Display; override;
  published
    property WantGoBack: boolean read FWantGoBack;
  end;

  TMenuPageInput<TEnum: Record > = class(TMenuPage)
  protected
    function SlectedEnumName(MenuItem: Integer): string;
  public
    constructor Create(aTitle: String); reintroduce; virtual;
  end;

resourcestring
  STR_GoBack = 'Go back';

implementation

uses
  System.Console, System.Sysutils, System.SysConst, System.Math, System.Enumeration, EasyConsole.Output;

{ TMenuPage }

type
  TConsoleKeyHelper = record
    InternalKey: TConsoleKey;
    class operator Add(Left: Integer; Right: TConsoleKeyHelper): TConsoleKeyHelper;
    class operator Add(Left: TConsoleKeyHelper; Right: Integer): TConsoleKeyHelper;
    class operator LessThanOrEqual(ConsoleKey: TConsoleKeyHelper; Value: Integer): boolean;
    class operator Implicit(ConsoleKey: TConsoleKey): TConsoleKeyHelper;
  end;

procedure TMenuPage.AddGoBackPage;
var
  &Program: TProgram;
begin
  &Program := TProgram.Instance;

  if (&Program.NavigationEnabled) and not(FMenu.Contains(STR_GoBack)) then
    FMenu.Add(STR_GoBack,
      procedure
      begin
        &Program.NavigateBack;
      end);
end;

constructor TMenuPage.Create(aTitle: String; Options: array of TOption; aWantGoBack: boolean);
var
  Option: TOption;
begin
  inherited Create(aTitle);
  FWantGoBack := aWantGoBack;
  FMenu := TMenu.Create(FConsoleBuffer);
  for Option in Options do
    FMenu.Add(Option);
end;

destructor TMenuPage.Destory;
begin
  FMenu.Free;
  inherited;
end;

procedure TMenuPage.Display;
begin
  inherited;

  if FWantGoBack then
    AddGoBackPage;

  FMenu.Display;

  FConsoleBuffer.Print(True);
  Output.DisplayPrompt(STR_CHOOSE_AN_OPTION + #32 + FMenu.CurrentMenuItem.ToString);
end;

function TMenuPage.WaitForChoice: Integer;
var
  Key: TConsoleKeyHelper;
  ConsoleKeyInfo: TConsoleKeyInfo;
begin
  Display;

  while True do
  begin
    ConsoleKeyInfo := Console.ReadKey(True);
    Key := ConsoleKeyInfo.Key;

    case Key.InternalKey of
      TConsoleKey.UpArrow:
        FMenu.DecreaseCurrentMenuItem;
      TConsoleKey.DownArrow:
        FMenu.IncreaseCurrentMenuItem;
      TConsoleKey.Enter:
        Key := TConsoleKeyHelper(TConsoleKey.D0) + FMenu.CurrentMenuItem;
    end;

    Display;

    if Key.InternalKey in [TConsoleKey.D0 .. TConsoleKey.D9] then // Number pressed
    begin
      Result := Integer(Key.InternalKey) - Integer(TConsoleKey.D1) + 1;

      if InRange(Result, 1, FMenu.Count) then
        break;
    end;
  end;

  FMenu.ExecuteAction(Result);
end;

{ TMenuPageInput<T> }

constructor TMenuPageInput<TEnum>.Create(aTitle: String);
var
  IterValue: Integer;
  IterName: String;
  Enumeration: TEnumeration<TEnum>;
begin
  if not Enumeration.IsEnumeration then
    raise EInvalidCast.CreateRes(@SInvalidCast);

  inherited Create(aTitle, [], false);

  FMenu := TMenu.Create(FConsoleBuffer);

  for IterValue := Enumeration.MinValue to Enumeration.MaxValue do
  begin
    IterName := Enumeration.GetName(IterValue);
    FMenu.Add(IterName, nil)
  end;
end;

function TMenuPageInput<TEnum>.SlectedEnumName(MenuItem: Integer): string;
var
  Enum: TEnum;
begin
  Enum := TEnumeration<TEnum>.FromOrdinal(MenuItem - 1);
  Result := TEnumeration<TEnum>.GetName(Enum);
end;

{ TConsoleKeyHelper }

class operator TConsoleKeyHelper.Add(Left: Integer; Right: TConsoleKeyHelper): TConsoleKeyHelper;
begin
  Result.InternalKey := TConsoleKey(Left + Integer(Right.InternalKey));
end;

class operator TConsoleKeyHelper.Add(Left: TConsoleKeyHelper; Right: Integer): TConsoleKeyHelper;
begin
  Result.InternalKey := TConsoleKey(Integer(Left.InternalKey) + Right);
end;

class operator TConsoleKeyHelper.Implicit(ConsoleKey: TConsoleKey): TConsoleKeyHelper;
begin
  Result.InternalKey := ConsoleKey;
end;

class operator TConsoleKeyHelper.LessThanOrEqual(ConsoleKey: TConsoleKeyHelper; Value: Integer): boolean;
begin
  Result := Integer(ConsoleKey.InternalKey) <= Value;
end;

end.
