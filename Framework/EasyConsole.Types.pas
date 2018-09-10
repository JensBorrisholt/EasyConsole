unit EasyConsole.Types;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Console.ConsoleBuffer;

{$M+}

type
  EKeyNotFoundException = class(Exception);
  TPage = class;
  THistory = TStack<TPage>;
  TPages = TObjectDictionary<string, TPage>;

  TOption = class;

  TProgram = class
  strict private
    class var FInstance: TProgram;
  var
    FTitle: string;
    FBreadcrumbHeader: Boolean;
    FHistory: THistory;
    FPages: TPages;
    procedure DisplayCurrentPage;
    function GetCurrentPage: TPage;
    function GetNavigationEnabled: Boolean;
  protected
    constructor Create(aTitle: string; aBreadcrumbHeader: Boolean); reintroduce;
    property Title: string read FTitle;
  public
    destructor Destroy; override;
    procedure AddPage(aPage: TPage); overload;
    procedure AddPage<T: TPage, constructor>; overload;
    function NavigateBack: TPage;
    procedure NavigateHome;
    function NavigateTo<T: TPage>: T;
    procedure Run; virtual;
    function SetPage<T: TPage>: T;
    class property Instance: TProgram read FInstance;
  published
    property BreadcrumbHeader: Boolean read FBreadcrumbHeader;
    property CurrentPage: TPage read GetCurrentPage;
    property History: THistory read FHistory;
    property NavigationEnabled: Boolean read GetNavigationEnabled;
  end;

  TPage = class abstract
  strict private
    FTitle: string;
    FProgram: TProgram;
  protected
    FConsoleBuffer: TConsoleBuffer;
    constructor Create(aTitle: String); reintroduce; virtual;
    procedure DrawAsciiArt;
    property &Program: TProgram read FProgram;
  public
    procedure Display; virtual;
    Destructor Destroy; override;
  published
    property Title: string read FTitle;
  end;

  TMenu = class
  strict private
    FOptions: TObjectList<TOption>;
    FCurrentMenuItem: Integer;
    FConsoleBuffer: TConsoleBuffer;
    function GetCount: Integer;
  protected
    property Options: TObjectList<TOption> read FOptions;
  public
    constructor Create(aConsoleBuffer: TConsoleBuffer);
    destructor Destroy; override;
    function Add(Option: string; Action: TProc): TMenu; overload;
    Function Add(aOption: TOption): TMenu; overload;
    Function Contains(aOption: string): Boolean;
    procedure Display; virtual;
    procedure ExecuteAction(Index: Integer);
    procedure DecreaseCurrentMenuItem;
    procedure IncreaseCurrentMenuItem;
  published
    property CurrentMenuItem: Integer read FCurrentMenuItem;
    property Count: Integer read GetCount;
  end;

  TOption = class
  strict private
    FName: String;
    FCallBack: TProc;
  public
    constructor Create(aName: string; aCallback: TProc); reintroduce; overload;
    class function CreateNavigation<T: TPage>(aName: string): TOption;
  published
    property Name: String read FName;
    property Callback: TProc read FCallBack;
  end;

resourcestring
  STR_PAGE_NOT_FOUND = 'The given page %s was not present in the program.';
  STR_CHOOSE_AN_OPTION = 'Choose an option:';

implementation

uses
  System.Classes, System.Math, System.Console, EasyConsole.Output, EasyConsole.Input, EasyConsole.FrameWork;

{ TPage }

type
  TAnonymousEvent<TEventPointer> = record
  public
    class function Construct(AEvent: Pointer): TEventPointer; static;
  end;

  { TAnonymousEvent<TEventPointer> }

class function TAnonymousEvent<TEventPointer>.Construct(AEvent: Pointer): TEventPointer;
type
  TVtable = array [0 .. 3] of Pointer;
  PVtable = ^TVtable;
  PPVtable = ^PVtable;
begin
  pMethod(@Result)^.Code := PPVtable((@AEvent)^)^^[3];;
  pMethod(@Result)^.Data := Pointer((@AEvent)^);
end;

constructor TPage.Create(aTitle: String);
begin
  inherited Create;
  FTitle := aTitle;
  FProgram := TProgram.Instance;
  FConsoleBuffer := TConsoleBuffer.Create;
end;

destructor TPage.Destroy;
begin
  FConsoleBuffer.Free;
  inherited;
end;

procedure TPage.Display;
var
  BreadCrumb, Title: string;
  Titles: TList<string>;
  Page: TPage;
begin
  Console.Clear;
  FConsoleBuffer.Clear;
  Titles := TList<string>.Create;

  try
    if (FProgram.History.Count > 1) and (FProgram.BreadcrumbHeader) then
    begin
      for Page in FProgram.History do
        Titles.Add(Page.Title);

      Titles.Reverse;

      for Title in Titles do
        BreadCrumb := BreadCrumb + Title + ' > ';

      if BreadCrumb <> '' then
        BreadCrumb := BreadCrumb.Remove(BreadCrumb.Length - 3);
    end
    else
    begin
      DrawAsciiArt;
      BreadCrumb := FTitle;
    end;

    FConsoleBuffer.WriteLine(BreadCrumb, TConsoleColor.Magenta);
    FConsoleBuffer.WriteLine('---', TConsoleColor.Gray);
  finally
    Titles.Free;
  end;
end;

procedure TPage.DrawAsciiArt;
begin
  FConsoleBuffer.WriteLine('  ______                   _____                      _', TConsoleColor.Blue);
  FConsoleBuffer.WriteLine(' |  ____|                 / ____|                    | |', TConsoleColor.Blue);
  FConsoleBuffer.WriteLine(' | |__   __ _ ___ _   _  | |     ___  _ __  ___  ___ | | ___', TConsoleColor.Blue);
  FConsoleBuffer.WriteLine(' |  __| / _` / __| | | | | |    / _ \| ''_ \/ __|/ _ \| |/ _ \', TConsoleColor.Blue);
  FConsoleBuffer.WriteLine(' | |___| (_| \__ \ |_| | | |___| (_) | | | \__ \ (_) | |  __/', TConsoleColor.Blue);
  FConsoleBuffer.WriteLine(' |______\__,_|___/\__, |  \_____\___/|_| |_|___/\___/|_|\___|', TConsoleColor.Blue);
  FConsoleBuffer.WriteLine('                   __/ |', TConsoleColor.Blue);
  FConsoleBuffer.WriteLine('                  |___/', TConsoleColor.Blue);
  FConsoleBuffer.WriteLine('', TConsoleColor.Blue);
end;

{ TProgram }

procedure TProgram.AddPage(aPage: TPage);
var
  PageClass: string;
begin
  PageClass := aPage.ClassName;
  if FPages.ContainsKey(PageClass) then
    FPages[PageClass] := aPage
  else
    FPages.Add(PageClass, aPage);
end;

procedure TProgram.AddPage<T>;
begin
  AddPage(T.Create);
end;

constructor TProgram.Create(aTitle: string; aBreadcrumbHeader: Boolean);
begin
  inherited Create;
  FInstance := Self;
  FTitle := aTitle;
  FBreadcrumbHeader := aBreadcrumbHeader;
  FPages := TPages.Create([doOwnsValues]);
  FHistory := THistory.Create;
end;

destructor TProgram.Destroy;
begin
  FPages.Free;
  FHistory.Free;
  FInstance := nil;
  inherited;
end;

procedure TProgram.DisplayCurrentPage;
begin
  if (CurrentPage is TMenuPage) then
    (CurrentPage as TMenuPage).WaitForChoice
  else
    CurrentPage.Display;
end;

function TProgram.GetCurrentPage: TPage;
begin
  if History.Count = 0 then
    Result := nil
  else
    Result := History.Peek;
end;

function TProgram.GetNavigationEnabled: Boolean;
begin
  Result := History.Count > 1;
end;

function TProgram.NavigateBack: TPage;
begin
  History.Pop;
  Console.Clear;
  DisplayCurrentPage;
  Result := CurrentPage;
end;

procedure TProgram.NavigateHome;
begin
  while History.Count > 1 do
    History.Pop;

  Console.Clear;
  DisplayCurrentPage;
end;

function TProgram.NavigateTo<T>: T;
begin
  SetPage<T>;
  Console.Clear;
  DisplayCurrentPage;
  Result := CurrentPage as T;
end;

procedure TProgram.Run;
begin
  Console.Title := Title;
  try
    DisplayCurrentPage;
  except
    on e: Exception do
      Output.WriteLine(TConsoleColor.Red, e.ToString);
  end;
end;

function TProgram.SetPage<T>: T;
var
  PageType: String;
  NextPage: TPage;
begin
  PageType := T.ClassName;

  if (CurrentPage <> nil) and (CurrentPage.ClassName = PageType) then
    exit(CurrentPage as T);
  // leave the current page

  // select the new page
  if not(FPages.TryGetValue(PageType, NextPage)) then
    raise EKeyNotFoundException.CreateFmt(STR_PAGE_NOT_FOUND, [PageType]);

  // enter the new page
  History.Push(NextPage);

  Result := CurrentPage as T;
end;

{ TMenu }

function TMenu.Add(Option: string; Action: TProc): TMenu;
begin
  Result := Add(TOption.Create(Option, Action));
end;

function TMenu.Add(aOption: TOption): TMenu;
begin
  FOptions.Add(aOption);
  Result := Self;
end;

function TMenu.Contains(aOption: string): Boolean;
var
  Option: TOption;
begin
  for Option in FOptions do
    if aOption.Equals(Option.Name) then
      exit(True);

  exit(False);
end;

constructor TMenu.Create;
begin
  inherited Create;
  FOptions := TObjectList<TOption>.Create;
  FCurrentMenuItem := 1;
  FConsoleBuffer := aConsoleBuffer;
end;

procedure TMenu.DecreaseCurrentMenuItem;
begin
  FCurrentMenuItem := FCurrentMenuItem - 1;
  if FCurrentMenuItem < 1 then
    FCurrentMenuItem := FOptions.Count;
end;

destructor TMenu.Destroy;
begin
  FOptions.Free;
  inherited;
end;

procedure TMenu.Display;
var
  i, MenuItem: Integer;
  FontColor: TConsoleColor;
  DisplayText: String;
begin
  for i := 0 to FOptions.Count - 1 do
  begin
    MenuItem := i + 1;

    if MenuItem = FCurrentMenuItem then
      FontColor := TConsoleColor.Yellow
    else
      FontColor := TConsoleColor.White;

    if MenuItem = FCurrentMenuItem then
      DisplayText := FOptions[i].Name + ' <--'
    else
      DisplayText := FOptions[i].Name;

    if FConsoleBuffer <> nil then
      FConsoleBuffer.WriteLine(MenuItem.ToString + '. ' + DisplayText, FontColor)
    else
      Output.WriteLine(FontColor, '{0}. {1}', [MenuItem, DisplayText]);
  end;
end;

procedure TMenu.ExecuteAction(Index: Integer);
begin
  if not InRange(Index, 1, FOptions.Count) then
    exit;

  FCurrentMenuItem := Index;
  dec(Index);

  if Assigned(FOptions[Index].Callback) then
    FOptions[Index].Callback();
end;

function TMenu.GetCount: Integer;
begin
  Result := FOptions.Count;
end;

procedure TMenu.IncreaseCurrentMenuItem;
begin
  FCurrentMenuItem := FCurrentMenuItem + 1;
  if FCurrentMenuItem > FOptions.Count then
    FCurrentMenuItem := 1;
end;

{ TOption }

constructor TOption.Create(aName: string; aCallback: TProc);
begin
  inherited Create;
  FName := aName;
  FCallBack := aCallback;
end;

class function TOption.CreateNavigation<T>(aName: string): TOption;
begin
  Result := TOption.Create(aName,
    procedure
    begin
      TProgram.Instance.NavigateTo<T>;
    end);
end;

end.
