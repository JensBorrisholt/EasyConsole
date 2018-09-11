unit System.Console.ConsoleBuffer;

interface

uses
  Winapi.Windows, System.Console;

{$M+}

Type
  TConsoleBuffer = class
  strict private
    FFileHandle: THandle;
    FWindowHeight: Integer;
    FWidth: Integer;
    FWindowWidth: Integer;
    FHeight: Integer;
    FBuffer: array of CHAR_INFO;
    FClearBuffer: array of CHAR_INFO;
    FRect: TSmallRect;
    FCurrentLine: Integer;

    FBufferSize: COORD;
    FBufferCoordinale: COORD;
    FDefaultColor: TConsoleColor;
    procedure InternalWriteLine(aLine: String; xPos, yPos: Integer; aColor: TConsoleColor); inline;
  published
    property CurrentLine: Integer read FCurrentLine;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property WindowWidth: Integer read FWindowWidth;
    property WindowHeight: Integer read FWindowHeight;
  public
    constructor Create(aWidth: Integer = -1; aHeight: Integer = -1; aWindowWidth: Integer = -1; aWindowHeight: Integer = -1; aResizeConsole: Boolean = True);
    destructor Destroy; override;

    procedure Clear;
    procedure MovConsoleCursor;
    procedure Print(aMoveCursor: Boolean = false);
    procedure WriteLine(aLine: String; xPos, yPos: Integer; aColor: TConsoleColor); overload;
    procedure WriteLine(aLine: String; aColor: TConsoleColor); overload;
    procedure WriteLine(aLine: String); overload;
  end;

implementation

uses
  System.Sysutils;

{ TConsoleBuffer }

procedure TConsoleBuffer.Clear;
var
  i: Integer;
begin
  FCurrentLine := 0;
  i := Sizeof(FClearBuffer[0]) * length(FClearBuffer);
  Move(FClearBuffer[0], FBuffer[0], i);
end;

constructor TConsoleBuffer.Create(aWidth, aHeight, aWindowWidth, aWindowHeight: Integer; aResizeConsole: Boolean);
var
  i: Integer;
begin
  if aWindowWidth <= -1 then
    aWindowWidth := Console.WindowWidth;

  if aWindowHeight <= -1 then
    aWindowHeight := Console.WindowHeight;

  if aResizeConsole then
    Console.SetWindowSize(aWindowWidth, aWindowHeight);

  if aWidth <= -1 then
    aWidth := aWindowWidth;

  if aHeight <= -1 then
    aHeight := aWindowHeight;

  if (aWidth > aWindowWidth) or (aHeight > aWindowHeight) then
    raise EArgumentException.Create('The buffer width and height can not be greater than The window width and height.');

  FFileHandle := CreateFile('CONOUT$', GENERIC_READ or GENERIC_WRITE, FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  FWindowHeight := aWindowHeight;
  FWidth := aWidth;
  FWindowWidth := aWindowWidth;
  FHeight := aHeight;
  SetLength(FBuffer, Width * Height);
  FRect.Left := 0;
  FRect.Top := 0;
  FRect.Right := FWindowWidth;
  FRect.Bottom := FWindowHeight;

  FBufferSize.X := FWidth;
  FBufferSize.Y := FHeight;
  FBufferCoordinale.X := 0;
  FBufferCoordinale.Y := 0;

  FDefaultColor := Console.ForegroundColor;

  SetLength(FClearBuffer, Width * Height);
  for i := 0 to length(FClearBuffer) do
  begin
    FClearBuffer[i].Attributes := 1;
    FClearBuffer[i].AsciiChar := #32;
    FClearBuffer[i].UnicodeChar := #32;
  end;

  Clear;
end;

destructor TConsoleBuffer.Destroy;
begin
  SetLength(FBuffer, 0);
  SetLength(FClearBuffer, 0);
  inherited;
end;

procedure TConsoleBuffer.InternalWriteLine(aLine: String; xPos, yPos: Integer; aColor: TConsoleColor);
var
  i: Integer;
  Pixel: PCharInfo;
begin
  for i := 1 to length(aLine) do
  begin
    Pixel := @FBuffer[xPos + i - 1 + yPos * FWidth];
    Pixel^.AsciiChar := AnsiChar(aLine[i]); // Height * width is to get to the correct spot (since this array is not two dimensions).
    Pixel^.UnicodeChar := aLine[i];
    Pixel^.Attributes := byte(aColor);
  end;
end;

procedure TConsoleBuffer.MovConsoleCursor;
begin
  Console.CursorLeft := 0;
  Console.CursorTop := FCurrentLine;
end;

procedure TConsoleBuffer.Print(aMoveCursor: Boolean);
begin
  if FFileHandle <> 0 then
    WriteConsoleOutput(FFileHandle, FBuffer, FBufferSize, FBufferCoordinale, FRect);

  if aMoveCursor then
    MovConsoleCursor;
end;

procedure TConsoleBuffer.WriteLine(aLine: String);
begin
  InternalWriteLine(aLine, 0, FCurrentLine, FDefaultColor);
  FCurrentLine := FCurrentLine + 1;
end;

procedure TConsoleBuffer.WriteLine(aLine: String; aColor: TConsoleColor);
begin
  InternalWriteLine(aLine, 0, FCurrentLine, aColor);
  FCurrentLine := FCurrentLine + 1;
end;

procedure TConsoleBuffer.WriteLine(aLine: String; xPos, yPos: Integer; aColor: TConsoleColor);
begin
  if (xPos > FWindowWidth - 1) or (yPos > FWindowHeight - 1) then
    raise EArgumentOutOfRangeException.Create('xPos and yPos must be inside the Window bondrais');

  InternalWriteLine(aLine, xPos, yPos, aColor);
end;

end.
