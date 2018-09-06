unit EasyConsole.FrameWork;

interface

uses
  EasyConsole.Types;

type
  TMenuPage = class(TPage)
  strict private
    FMenu: TMenu;
    procedure AddGoBackPage;
  protected
    constructor Create(aTitle: String; Options: array of TOption); reintroduce; overload; virtual;
  public
    destructor Destory;
    procedure Display; override;
  end;

resourcestring
  STR_GoBack = 'Go back';

implementation

{ TMenuPage }

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

constructor TMenuPage.Create(aTitle: String; Options: array of TOption);
var
  Option: TOption;
begin
  inherited Create(aTitle);
  FMenu := TMenu.Create;
  for Option in Options do
    FMenu.Add(Option)
end;

destructor TMenuPage.Destory;
begin
  FMenu.Free;
  inherited;
end;

procedure TMenuPage.Display;
begin
  inherited;
  AddGoBackPage;
  FMenu.Display;
end;

end.
