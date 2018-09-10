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
    FRect: TSmallRect;
    FCurrentLine: Integer;

    FBufferSize: COORD;
    FBufferCoordinale: COORD;
  published
    property CurrentLine: Integer read FCurrentLine;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property WindowWidth: Integer read FWindowWidth;
    property WindowHeight: Integer read FWindowHeight;
  public
    constructor Create(aWidth: Integer = -1; aHeight: Integer = -1; aWindowWidth: Integer = -1; aWindowHeight: Integer = -1; aResizeConsole: Boolean = true);
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
  for i := 0 to Length(FBuffer) do
  begin
    FBuffer[i].Attributes := 1;
    FBuffer[i].AsciiChar := #32;
  end;
end;

constructor TConsoleBuffer.Create(aWidth, aHeight, aWindowWidth, aWindowHeight: Integer; aResizeConsole: Boolean);
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
  FCurrentLine := 0;

  FBufferSize.X := FWidth;
  FBufferSize.Y := FHeight;
  FBufferCoordinale.X := 0;
  FBufferCoordinale.Y := 0;
  Clear;
end;

destructor TConsoleBuffer.Destroy;
begin
  SetLength(FBuffer, 0);
  inherited;
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
  WriteLine(aLine, 0, FCurrentLine, Console.ForegroundColor);
  FCurrentLine := FCurrentLine + 1;
end;

procedure TConsoleBuffer.WriteLine(aLine: String; aColor: TConsoleColor);
begin
  WriteLine(aLine, 0, FCurrentLine, aColor);
  FCurrentLine := FCurrentLine + 1;
end;

procedure TConsoleBuffer.WriteLine(aLine: String; xPos, yPos: Integer; aColor: TConsoleColor);
var
  i: Integer;
  Pixel: PCharInfo;
begin
  if (xPos > FWindowWidth - 1) or (yPos > FWindowHeight - 1) then
    raise EArgumentOutOfRangeException.Create('xPos and yPos must be inside the Window bondrais');

  if aLine = '' then
    exit;

  for i := 1 to Length(aLine) do
  begin
    Pixel := @FBuffer[xPos + i - 1 + yPos * FWidth];
    Pixel^.AsciiChar := AnsiChar(aLine[i]); // Height * width is to get to the correct spot (since this array is not two dimensions).
    Pixel^.UnicodeChar := aLine[i];

    if aColor <> TConsoleColor.Black then
      Pixel^.Attributes := byte(aColor);
  end;

end;

end.
