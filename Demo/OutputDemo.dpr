program OutputDemo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Console,
  System.Classes,
  EasyConsole.Input,
  EasyConsole.Output,
  EasyConsole.Types;

Type
  TTestObject = class
  strict private
    FTest: Integer;
  public
    property Test: Integer read FTest write FTest;
  end;

var
  Test: String;
  iTest: Integer;
  TestObject: TTestObject;
begin
  Console.WriteLine('Test 1: String test');
  Test := Output.BusyIndicator<string>('Test 1 prompt',
    function: string
    begin
      TThread.Sleep(2000);
      Result := 'Test 1';
    end, TSequence.Sequence1);

  Output.WriteLine('Result: {0}', [Test]);
  Output.EmptyLine;

  Console.WriteLine('Test 2: Integer test');
  iTest := Output.BusyIndicator<Integer>('Test 2 prompt',
    function: Integer
    begin
      TThread.Sleep(2000);
      Result := 47;
    end, TSequence.Sequence2);

  Output.WriteLine('Result: {0}', [iTest]);
  Output.EmptyLine;

  Console.WriteLine('Test 3: Object test 1');
  TestObject := Output.BusyIndicator<TTestObject>('Test 3 prompt',
    function: TTestObject
    begin
      Result := TTestObject.Create;
      Result.Test := 4242;
      TThread.Sleep(2000);
    end, TSequence.Sequence3);

  Output.WriteLine('TestObject.Test: {0}', [TestObject.Test]);
  TestObject.Free;
  Output.EmptyLine;

  Console.WriteLine('Test 4: Object test 2');
  TestObject := TTestObject.Create;
  TestObject.Test := 47;
  Output.WriteLine('TestObject.Test before: {0} ', [TestObject.Test]);

  Output.BusyIndicator<TTestObject>('Test 4 prompt', TestObject,
    function(aObject: TTestObject): TTestObject
    begin
      aObject.Test := 42;
      Result := aObject;
      TThread.Sleep(2000);
    end, TSequence.Sequence4);

  Output.WriteLine('TestObject.Test after: {0}', [TestObject.Test]);
  TestObject.Free;
  Output.EmptyLine;

  Input.WaitForKey('Press Any Key To Exit.');
end.
