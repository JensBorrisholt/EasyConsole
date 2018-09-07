unit EasyConsole.Types;

interface

uses
  System.Generics.Collections, System.Sysutils;

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
    constructor Create(aTitle: String); reintroduce; virtual;
    property &Program: TProgram read FProgram;
  public
    procedure Display; virtual;
  published
    property Title: string read FTitle;
  end;

  TMenu = class
  strict private
    FOptions: TObjectList<TOption>;
  protected
    function DisplayAndGetChoice: Integer; virtual;
    property Options: TObjectList<TOption> read FOptions;
  public
    constructor Create;
    destructor Destroy; override;
    Function Add(Option: string; Action: TProc): TMenu; overload;
    Function Add(aOption: TOption): TMenu; overload;
    Function Contains(aOption: string): Boolean;
    procedure Display; virtual;
  end;

  TMenuVariable = class(TMenu)
  public
    Function Add(Option: string; Action: TProc<Variant>): TMenu;
    procedure Display; reintroduce;
  end;

  TOption = class
  strict private
    FName: String;
    FCallBack: TProc;
    FCallbackParam: TProc<Variant>;
  public
    constructor Create(aName: string; aCallback: TProc); reintroduce; overload;
    class function CreateNavigation<T: TPage>(aName: string): TOption;
    constructor Create(aName: string; aCallbackParam: TProc<Variant>); overload;
  published
    property Name: String read FName;
    property Callback: TProc read FCallBack;
    property CallbackParam: TProc<Variant> read FCallbackParam;
  end;

resourcestring
  STR_PAGE_NOT_FOUND = 'The given page %s was not present in the program.';
  STR_CHOOSE_AN_OPTION = 'Choose an option:';

implementation

uses
  System.Classes, Winapi.Windows, System.Console, EasyConsole.Output, EasyConsole.Input;

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
end;

procedure TPage.Display;
var
  BreadCrumb, Title: string;
  Titles: TList<string>;
  Page: TPage;
begin
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
      Console.WriteLine(BreadCrumb);
    end
    else
      Console.WriteLine(FTitle);

    Console.WriteLine('---');
  finally
    Titles.Free;
  end;
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
  CurrentPage.Display;
  Result := CurrentPage;
end;

procedure TProgram.NavigateHome;
begin
  while History.Count > 1 do
    History.Pop;

  Console.Clear;
  CurrentPage.Display;
end;

function TProgram.NavigateTo<T>: T;
begin
  SetPage<T>;
  Console.Clear;
  CurrentPage.Display;
  Result := CurrentPage as T;
end;

procedure TProgram.Run;
begin
  Console.Title := Title;
  try
    CurrentPage.Display;
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
      exit(true);

  exit(false);
end;

constructor TMenu.Create;
begin
  inherited;
  FOptions := TObjectList<TOption>.Create;
end;

destructor TMenu.Destroy;
begin
  FOptions.Free;
  inherited;
end;

procedure TMenu.Display;
var
  Choice: Integer;
begin
  Choice := DisplayAndGetChoice;
  FOptions[Choice - 1].Callback();
end;

function TMenu.DisplayAndGetChoice: Integer;
var
  i: Integer;
begin
  for i := 0 to FOptions.Count - 1 do
    Console.WriteLine('{0}. {1}', [i + 1, FOptions[i].Name]);
  Result := Input.ReadInt(STR_CHOOSE_AN_OPTION, 1, FOptions.Count);
end;

{ TOption }

constructor TOption.Create(aName: string; aCallback: TProc);
begin
  inherited Create;
  FName := aName;
  FCallBack := aCallback;
end;

constructor TOption.Create(aName: string; aCallbackParam: TProc<Variant>);
begin
  inherited Create;
  FName := aName;
  FCallbackParam := aCallbackParam;
end;

class function TOption.CreateNavigation<T>(aName: string): TOption;
begin
  Result := TOption.Create(aName,
    procedure
    begin
      TProgram.Instance.NavigateTo<T>;
    end);
end;

{ TMenuVariable }

function TMenuVariable.Add(Option: string; Action: TProc<Variant>): TMenu;
begin
  Result := inherited Add(TOption.Create(Option, Action));
end;

procedure TMenuVariable.Display;
var
  Choice: Integer;
begin
  Choice := DisplayAndGetChoice;
  Options[Choice - 1].CallbackParam(Choice);
end;

{ THistory }

end.
