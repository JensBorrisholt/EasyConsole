unit DemoPagesU;

interface

uses
  EasyConsole.Types,
  EasyConsole.Framework;

type
  TFruit = (Apple, Banana, Coconut);

  TMainPage = class(TMenuPage)
  public
    constructor Create;
    procedure Display; override;
  end;

  TInputPage = class(TPage)
  public
    constructor Create; reintroduce;
    procedure Display; override;
  end;

  TPage1 = class(TMenuPage)
  public
    constructor Create;
  end;

  TPage1A = class(TMenuPage)
  public
    constructor Create;
  end;

  TPage1Ai = class(TPage)
  public
    constructor Create; reintroduce;
    procedure Display; override;
  end;

  TPage1B = class(TMenuPage)
  public
    constructor Create;
    procedure Display; override;
  end;

  TPage2 = class(TPage)
  public
    constructor Create; reintroduce;
    procedure Display; override;
  end;

implementation

uses
  System.Console, System.Enumeration, EasyConsole.Input, EasyConsole.Output;

{ TMainPage }

constructor TMainPage.Create;
begin
  inherited Create('Main Page', [TOption.CreateNavigation<TPage1>('Page 1'), TOption.CreateNavigation<TPage2>('Page 2'), TOption.CreateNavigation<TInputPage>('Input')

    , TOption.Create('Exit',
    procedure
    begin
      Halt;
    end)

    ]);
end;

procedure TMainPage.Display;
begin
  Console.Clear;
  inherited;
end;

{ TInputPage }

constructor TInputPage.Create;
begin
  inherited Create('Input');
end;

procedure TInputPage.Display;
var
  Fruit: TFruit;
begin
  inherited;

  Fruit := Input.ReadEnum<TFruit>('Select a fruit');
  Output.WriteLine(TConsoleColor.Green, 'You selected ' + TEnumeration<TFruit>.GetName(Fruit));
  Input.ReadString('Press [Enter] to navigate home');
  &Program.NavigateHome;
end;

{ TPage1 }

constructor TPage1.Create;
begin
  inherited Create('Page 1', [TOption.CreateNavigation<TPage1A>('Page 1A'), TOption.CreateNavigation<TPage1B>('Page 1B')]);
end;

{ TPage1A }

constructor TPage1A.Create;
begin
  inherited Create('Page 1A', [TOption.CreateNavigation<TPage1Ai>('Page 1Ai')]);
end;

{ TPage1Ai }

constructor TPage1Ai.Create;
begin
  inherited Create('Page 1Ai');
end;

procedure TPage1Ai.Display;
begin
  inherited;
  Output.WriteLine('Hello from Page 1 Ai');

  Input.ReadString('Press[Enter] to navigate home');
  &Program.NavigateHome;
end;

{ TPage1B }

constructor TPage1B.Create;
begin
  inherited Create('Page 1B', []);
end;

procedure TPage1B.Display;
begin
  inherited;
  Output.WriteLine('Hello from Page 1B');
  Input.ReadString('Press [Enter] to navigate home');
  &Program.NavigateHome;
end;

{ TPage2 }

constructor TPage2.Create;
begin
  inherited Create('Page 2');
end;

procedure TPage2.Display;
begin
  inherited;
  Output.WriteLine('Hello from Page 2');
  Input.ReadString('Press [Enter] to navigate home');
  &Program.NavigateHome;
end;

end.
