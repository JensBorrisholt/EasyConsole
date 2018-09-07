unit EasyConsole.Spinner;

interface

uses
  System.SysUtils, System.Classes;

Type
  TSequence = (Sequence1, Sequence2, Sequence3, Sequence4, Sequence5, Sequence6);

const
  StrSequence: array [TSequence] of string = ('└┘┐┌', '/-\|', '<^>v', '".o0o', '"#■.', '"▄▀');
{$M+}

type
  TSpinner = class sealed
  strict private
  private
    FActive: Boolean;
    FBusyMessage: string;
    FCounter: Integer;
    FDealy: Integer;
    FSequence: TSequence;
    FSequenceStr: String;
    FThread: TThread;
    procedure Draw(c: Char);
    procedure Turn;
  protected
    procedure ClearCurrentConsoleLine;
  public
    constructor Create(aSequence: TSequence = TSequence.Sequence1; aDelay: Integer = 200); reintroduce;
    destructor Destroy; override;
    procedure Start; overload;
    procedure Start(aBusyMessage: string); overload;
    procedure Stop;
  published
    property Active: Boolean read FActive;
    property Delay: Integer read FDealy;
  end;

implementation

uses
  System.Console;
{ TSpinner }

procedure TSpinner.ClearCurrentConsoleLine;
var
  CurrentLineCursor: Integer;
begin
  CurrentLineCursor := Console.CursorTop;
  Console.SetCursorPosition(0, Console.CursorTop);
  Console.ClearEOL;
  Console.SetCursorPosition(0, CurrentLineCursor);
end;

constructor TSpinner.Create(aSequence: TSequence; aDelay: Integer);
begin
  inherited Create;
  FSequence := aSequence;
  FDealy := aDelay;
  FSequenceStr := StrSequence[FSequence];
end;

destructor TSpinner.Destroy;
begin
  Stop;
  inherited;
end;

procedure TSpinner.Draw(c: Char);
var
  Left, Top: Integer;
begin
  Left := Console.CursorLeft;
  Top := Console.CursorTop;
  Console.Write('[');
  Console.ForegroundColor := TConsoleColor.Green;
  Console.Write(c);
  Console.ForegroundColor := TConsoleColor.Gray;
  Console.Write(']');

  if FBusyMessage <> '' then
    Console.WriteLine(' ' + FBusyMessage);

  // reset cursor position
  Console.SetCursorPosition(Left, Top);
end;

procedure TSpinner.Start;

begin
  FCounter := 0;
  FActive := True;
  Console.CursorVisible := false;

  if FThread = nil then
  begin
    FThread := TThread.CreateAnonymousThread(
      procedure
      begin
        while FActive do
        begin
          Turn;
          TThread.Sleep(FDealy);
        end;
      end);
    FThread.Start;
  end;

end;

procedure TSpinner.Start(aBusyMessage: string);
begin
  FBusyMessage := aBusyMessage;
  Start;
end;

procedure TSpinner.Stop;
begin
  FActive := false;

  while (FThread <> nil) and (not FThread.Finished) do
    Sleep(0);

  Console.CursorVisible := True;
  ClearCurrentConsoleLine;
  FBusyMessage := '';
  FThread := nil;
end;

procedure TSpinner.Turn;
begin
  FCounter := (FCounter + 1) mod Length(FSequenceStr);
  Draw(FSequenceStr[FCounter]);
end;

end.
