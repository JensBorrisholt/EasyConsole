program ConsoleBufferDemo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Console,
  System.Diagnostics,
  System.Console.ConsoleBuffer;

var
  ConsoleBuffer: TConsoleBuffer;
  i, j, k: Integer;
  s: String;
  StopWatch: TStopwatch;
  Counter: Integer;

begin
  ConsoleBuffer := TConsoleBuffer.Create;
  Counter := 0;

  StopWatch := TStopwatch.StartNew;

  for i := 0 to 1000 do
  begin
    for j := ord('A') to ord('Z') do
    begin
      ConsoleBuffer.Clear;

      s := StringOfChar(Char(j), 25);

      for k := 0 to 25 do
        ConsoleBuffer.WriteLine(s);

      ConsoleBuffer.Print;
      Inc(Counter);
    end;
  end;

  ConsoleBuffer.MovConsoleCursor;
  StopWatch.Stop;
  Console.WriteLine('WriteConsoleOutput called {0} times in {1} milliseconds', [Counter, StopWatch.ElapsedMilliseconds]);
  Console.ReadKey;
  ConsoleBuffer.Free;
end.
