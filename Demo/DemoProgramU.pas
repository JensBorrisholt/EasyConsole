unit DemoProgramU;

interface

uses
  EasyConsole.Types;

type
  TDemoProgram = class(TProgram)
  protected
    constructor Create;
  public
    class procedure CreateAndRun;
  end;

implementation

uses
  DemoPagesU;

{ TDemoProgram }

constructor TDemoProgram.Create;
begin
  inherited Create('EasyConsole Demo', True);
end;

class procedure TDemoProgram.CreateAndRun;
begin
  with TDemoProgram.Create do
    try
      AddPage<TMainPage>;
      AddPage<TPage1>;
      AddPage<TPage1A>;
      AddPage<TPage1AI>;
      AddPage<TPage1B>;
      AddPage<TPage2>;
      AddPage<TInputPage>;
      SetPage<TMainPage>;
      Run;
    finally
      Free;
    end;
end;

end.
