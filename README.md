# EasyConsole
EasyConsole is a library to make it easier for developers to build a simple menu interface for a Delphi  console application.

## Credit

The basic idea behind this library goes to splttingatms and his [EasyConsole](https://github.com/splttingatms/EasyConsole) build in c#
This project is a Delphi remake, and further development, of his idea. 

## Dependencies

EasyConsole make use of my own Console library [DelphiConsole](https://github.com/JensBorrisholt/DelphiConsole). When using this library. Please make sure you got the newest version of DelphiConsole also.

![Program Demo](http://borrisholt.dk/GitHub/Images/EasyConsole/Image1.gif)

### Features
* Automatically numbered menus
* Easy creation of menus
* Input/Output helpers

## Quick Start
### Menu
The base functionality of the library is to provide an easy way to create console menus. A `Menu` consists of `Options` that will be presented to a user for selection. An option contains a name, that will be displayed to the user, and a callback function to invoke if the user selects the option. Render the menu in the console using the `Display()` method.

```Delphi
uses
  System.Console,
  EasyConsole.Types;
begin
  with TMenu.Create do
    try
      Add('foo',
        procedure
        begin
          Console.WriteLine('foo selected')
        end);

      Add('bar',
        procedure
        begin
          Console.WriteLine('bar selected')
        end);

      Display;
    finally
      free;
    end;
end.
```
![Menu Demo](http://borrisholt.dk/GitHub/Images/EasyConsole/QuickStartMenu.png)


### Utilities - Input/Output
EasyConsole also provides input and output utilities to abstract the concept of dealing with the Console.

The `Output` class adds helper methods to control the color of text in the console.

```Delphi
uses
  System.Console,
  EasyConsole.Output;
begin
   Output.WriteLine('default');
   Output.WriteLine(TConsoleColor.Red, 'Red');
   Output.WriteLine(TConsoleColor.Green, 'Green');
   Output.WriteLine(TConsoleColor.Blue, 'Blue');
   Console.ReadLine;
end.
```

![Output Utility Demo](http://borrisholt.dk/GitHub/Images/EasyConsole/Image3.png)

The `Input` class adds helper methods that prompt the user for input. The utility takes care of displaying prompt text and handling parsing logic. For example, non-numeric input will be rejected by `ReadInt()` and the user will be re-prompted.

```Delphi
uses
  System.Console,
  EasyConsole.Input,
  EasyConsole.Output;
var
  s : String;
  i : Integer;
begin
  s := Input.ReadString('Please enter a string: ');
  Output.WriteLine(  'You wrote: {0}', [s]);

  i := Input.ReadInt('Please enter an integer(between 1 and 10): ', 1, 10);
  Output.WriteLine('You wrote: {0}', [i]);

  Console.ReadLine;
end.
```

![Input Utility Demo](http://borrisholt.dk/GitHub/Images/EasyConsole/Input.png)

### Program
All of these features can be put together to create complex programs with nested menus. A console program consists of a main `Program` class that contains `Pages`. The `Program` class is a navigator of pages and will keep a history of pages that a user is navigating through. Think of it as your browser history. To create a program you must subclass the `Program` class and add any `Pages` in the constructor. _Note_: Before exiting the constructor, you must set one of the pages as the _main_ page where the program should start.

```Delphi
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
```

A `Page` can display any type of data, but the subclass `MenuPage` was created to speed up the creation of pages that display menus. Simply pass in all of the options you want displayed into the `options` parameter in the constructor.

```Delphi

  TMainPage = class(TMenuPage)
  public
    constructor Create;
    procedure Display; override;
  end;

...

{ TMainPage }

constructor TMainPage.Create;
begin
  inherited Create('Main Page', [TOption.CreateNavigation<TPage1>('Page 1'), TOption.CreateNavigation<TPage2>('Page 2'), TOption.CreateNavigation<TInputPage>('Input')

    , TOption.Create('Exit',
    procedure
    begin
      Halt;
    end)

    ]);
end;

procedure TMainPage.Display;
begin
  Console.Clear;
  inherited;
end;

```

As you can see, navigation is handled by the `Program` class. As you navigate through to different pages, the history is logged. You can then invoke `NavigateBack()` if you would like to go back to the previous page.

## Example Project
The source code contains an example console demo under the [Demo directory](https://github.com/JensBorrisholt/EasyConsole/tree/master/Demo). It offers a demo with nested menu options as well as an example of how to prompt the user for input.

![Example Project](http://borrisholt.dk/GitHub/Images/EasyConsole/Final.gif)
