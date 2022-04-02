unit obj;

interface

uses
  SysUtils,
  Generics.Collections,
  ast;

type
  TObjectType = (otInteger,
                  otString,
                  otBoolean,
                  otNull,
                  otReturn,
                  otFunction,
                  otError
                );
  IObject = interface
    ['{91DB7B62-96CB-4298-A2A2-DCF4F4F6C1E5}']
    function ObjType: TObjectType;
    function Inspect: string;
  end;

  TEnvironment = class
    private
      Store: TDictionary<string, IObject>;
      Outer: TEnvironment;
    public
      constructor Create; overload;
      constructor Create(Outer: TEnvironment); overload;
      function GetObj(Name: string; out Found:boolean): IObject;
      function SetObj(Name: string; Val: IObject): IObject;
  end;

  // TInteger
  TInteger = class(TInterfacedObject, IObject)
    Value: Integer;
    public
      constructor Create(Value: Integer); overload;
      function ObjType: TObjectType;
      function Inspect: string;
  end;

  // TString
  TString = class(TInterfacedObject, IObject)
    Value: string;
    public
      constructor Create(Value: string); overload;
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

  // TFunction
  TFunction = class(TInterfacedObject, IObject)
    Parameters: TArray<TIdentifier>;
    Body: TBlockStatement;
    Env: TEnvironment;
    constructor Create(Parameters: TArray<TIdentifier>; Body: TBlockStatement; Env: TEnvironment); overload;
    function ObjType: TObjectType;
    function Inspect: string;
  end;

implementation
  // This maps NewEnvironment
  constructor TEnvironment.Create;
  begin
    Store := TDictionary<string, IObject>.Create;
  end;
  // This maps NewEnclosedEnvironment
  constructor TEnvironment.Create(Outer: TEnvironment);
  begin
    Store := TDictionary<string, IObject>.Create;
    Self.Outer := Outer;  
  end;
  function TEnvironment.GetObj(Name: string; out Found:boolean): IObject;
  var
    Obj: IObject;
  begin
    if Store.ContainsKey(Name) then
    begin
      Found := true;
      Store.TryGetValue(Name, Obj);
    end
    else
    begin
      if Outer <> nil then
        Obj := Outer.GetObj(Name, Found)
      else
      begin
        Found := false;
        Obj := nil;
      end;      
    end;
    Result := Obj;
  end;
  function TEnvironment.SetObj(Name: string; Val: IObject): IObject;
  begin
    Store.Add(Name, Val);
    Result := Val;
  end;

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
  // TString
  constructor TString.Create(Value: string);
  begin
    Self.Value := Value;
  end;
  function TString.ObjType: TObjectType;
  begin
    Result := otString;
  end;
  function TString.Inspect: string;
  begin
    Result := Value;
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
  // TFunction
  constructor TFunction.Create(Parameters: TArray<TIdentifier>; Body: TBlockStatement; Env: TEnvironment);
  begin
    Self.Parameters := Parameters;
    Self.Body := Body;
    Self.Env := Env;
  end;
  function TFunction.ObjType: TObjectType;
  begin
    Result := otFunction;
  end;
  function TFunction.Inspect: string;
  var
    Output: TStringBuilder;
    Params: TArray<string>;
    Param: TIdentifier;
    I: integer;
  begin
    Output := TStringBuilder.Create;
    I := 0;
    try
      Output.Append('fn');
      Output.Append('(');

      if Length(Parameters) > 0 then
      begin
        for Param in Parameters do
        begin
          Inc(I);
          SetLength(Params, I);
          Params[I-1] := Param.Print;
        end;
        Output.Append(String.Join(', ', Params));
      end;
      Output.Append(')');
      Output.Append(Body.Print);
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;
end.
