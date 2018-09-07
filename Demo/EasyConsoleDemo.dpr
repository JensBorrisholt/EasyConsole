program EasyConsoleDemo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  DemoProgramU in 'DemoProgramU.pas',
  DemoPagesU in 'DemoPagesU.pas';

begin
  TDemoProgram.CreateAndRun;
end.
