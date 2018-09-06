unit System.Enumeration;

interface
(*
   Credit:
      Part of this class was taken from the internet long time ago. And then later modified by me.
      I don't remember where I got it from. But credit to the original author :D
*)
uses
  System.TypInfo, System.Math;

type
  TEnumeration<T: record > = class sealed
  strict private
    class function TypeInfo: pTypeInfo; inline; static;
    class function TypeData: pTypeData; inline; static;
  strict protected
    constructor Create; reintroduce;
  public
    class function IsEnumeration: Boolean; static;
    class function GetName(Value: Integer): String; overload; inline; static;
    class function GetName(Value: T): String; overload; inline; static;
    class function ToOrdinal(Enum: T): Integer; inline; static;
    class function FromOrdinal(Value: Integer): T; inline; static;
    class function ToString(Enum: T): string; reintroduce; inline; static;
    class function FromString(const S: string): T; inline; static;
    class function MinValue: Integer; inline; static;
    class function MaxValue: Integer; inline; static;
    class function InRange(Value: Integer): Boolean; inline; static;
    class function EnsureRange(Value: Integer): Integer; inline; static;
  end;

implementation

constructor TEnumeration<T>.Create;
begin
  // Do no create instances of this class!
end;

{ TEnumeration<T> }

class function TEnumeration<T>.TypeInfo: pTypeInfo;
begin
  Result := System.TypeInfo(T);
end;

class function TEnumeration<T>.TypeData: pTypeData;
begin
  Result := GetTypeData(TypeInfo);
end;

class function TEnumeration<T>.IsEnumeration: Boolean;
begin
  Result := TypeInfo.Kind = tkEnumeration;
end;

class function TEnumeration<T>.ToOrdinal(Enum: T): Integer;
begin
  Assert(IsEnumeration);
  Assert(SizeOf(Enum) <= SizeOf(Result));
  Result := 0; // needed when SizeOf(Enum) < SizeOf(Result)
  Move(Enum, Result, SizeOf(Enum));
  Assert(InRange(Result));
end;

class function TEnumeration<T>.FromOrdinal(Value: Integer): T;
begin
  Assert(IsEnumeration);
  Assert(InRange(Value));
  Assert(SizeOf(Result) <= SizeOf(Value));
  Move(Value, Result, SizeOf(Result));
end;

class function TEnumeration<T>.ToString(Enum: T): string;
begin
  Result := GetEnumName(TypeInfo, ToOrdinal(Enum));
end;

class function TEnumeration<T>.FromString(const S: string): T;
begin
  Result := FromOrdinal(GetEnumValue(TypeInfo, S));
end;

class function TEnumeration<T>.GetName(Value: Integer): String;
begin
  Result := GetEnumName(TypeInfo, Value);
end;

class function TEnumeration<T>.GetName(Value: T): String;
var
  v: Integer;
begin
  case TypeData^.OrdType of
    otUByte, otSByte:
      v := PByte(@Value)^;
    otUWord, otSWord:
      v := PWord(@Value)^;
    otULong, otSLong:
      v := PInteger(@Value)^;
  end;

  Result := GetEnumName(TypeInfo, v);
end;

class function TEnumeration<T>.MinValue: Integer;
begin
  Assert(IsEnumeration);
  Result := TypeData.MinValue;
end;

class function TEnumeration<T>.MaxValue: Integer;
begin
  Assert(IsEnumeration);
  Result := TypeData.MaxValue;
end;

class function TEnumeration<T>.InRange(Value: Integer): Boolean;
var
  ptd: pTypeData;
begin
  Assert(IsEnumeration);
  ptd := TypeData;
  Result := System.Math.InRange(Value, ptd.MinValue, ptd.MaxValue);
end;

class function TEnumeration<T>.EnsureRange(Value: Integer): Integer;
var
  ptd: pTypeData;
begin
  Assert(IsEnumeration);
  ptd := TypeData;
  Result := System.Math.EnsureRange(Value, ptd.MinValue, ptd.MaxValue);
end;

end.
