unit obj;

interface

uses
  SysUtils;

type
  TObjectType = (otInteger,
                  otString,
                  otBoolean,
                  otNull,
                  otReturn,
                  otError
                );
  IObject = interface
    ['{91DB7B62-96CB-4298-A2A2-DCF4F4F6C1E5}']
    function ObjType: TObjectType;
    function Inspect: string;
  end;

  // TInteger
  TInteger = class(TInterfacedObject, IObject)
    Value: Integer;
    public
      constructor Create(Value: Integer); overload;
      function ObjType: TObjectType;
      function Inspect: string;
  end;

  // TBoolean
  TBoolean = class(TInterfacedObject, IObject)
    Value: Boolean;
    public
      constructor Create(Value: Boolean); overload;
      function ObjType: TObjectType;
      function Inspect: string;
  end;

  // TNull
  TNull = class(TInterfacedObject, IObject)
    function ObjType: TObjectType;
    function Inspect: string;
  end;

  // TReturn
  TReturn = class(TInterfacedObject, IObject)
    Value: IObject;
    constructor Create(Value: IObject); overload;
    function ObjType: TObjectType;
    function Inspect: string;
  end;

  // TError
  TError = class(TInterfacedObject, IObject)
    ErrorMsg: string;
    constructor Create(ErrorMsg: string); overload;
    function ObjType: TObjectType;
    function Inspect: string;
  end;

implementation
  // TInteger
  constructor TInteger.Create(Value: Integer);
  begin
    Self.Value := Value;
  end;

  function TInteger.ObjType: TObjectType;
  begin
    Result := otInteger;
  end;
  function TInteger.Inspect: string;
  begin
    Result := IntToStr(Value);
  end;
  // TBoolean
  constructor TBoolean.Create(Value: Boolean);
  begin
    Self.Value := Value;
  end;
  function TBoolean.ObjType: TObjectType;
  begin
    Result := otBoolean;
  end;
  function TBoolean.Inspect: string;
  begin
    if Value then
      Result := 'true'
    else
      Result := 'false';
  end;
  // TNull
  function TNull.ObjType: TObjectType;
  begin
    Result := otNull;
  end;
  function TNull.Inspect: string;
  begin
    Result := 'null';
  end;
  // TReturn
  function TReturn.ObjType: TObjectType;
  begin
    Result := otReturn;
  end;
  function TReturn.Inspect: string;
  begin
    Result := Value.Inspect;
  end;
  constructor TReturn.Create(Value: IObject);
  begin
    Self.Value := Value;
  end;

  // TError
  constructor TError.Create(ErrorMsg: string);
  begin
    Self.ErrorMsg := ErrorMsg;
  end;
  function TError.ObjType: TObjectType;
  begin
    Result := otError;
  end;
  function TError.Inspect: string;
  begin
    Result := ErrorMsg;
  end;
end.
