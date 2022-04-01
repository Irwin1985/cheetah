unit evaluator;

interface
uses
  SysUtils,
  TypInfo,
  obj,
  ast,
  environment;

  function Eval(node: INode; Env: TEnvironment): IObject;
  function EvalProgram(Node: TProgram; Env: TEnvironment): IObject;
  function EvalBlockStatement(Node: TBlockStatement; Env: TEnvironment): IObject;
  function EvalPrefixExpression(Node: TPrefixExpression; Env: TEnvironment): IObject;
  function EvalBangOperatorExpression(Right: IObject; Env: TEnvironment): IObject;
  function EvalMinusPrefixOperatorExpression(RightNode: IObject; Env: TEnvironment): IObject;
  function EvalInfixExpression(Node: TInfixExpression; Env: TEnvironment): IObject;
  function EvalIntegerInfixExpression(Optor: string; LeftObj: TInteger; RightObj: TInteger; Env: TEnvironment): IObject;
  function EvalIdentifier(Node: TIdentifier; Env: TEnvironment): IObject;
  function NativeToBooleanObject(Input: boolean): IObject;
  function EvalIfExpression(Node: TIfExpression; Env: TEnvironment): IObject;
  function IsTruthy(Value: IObject): boolean;
  function NewError(ErrorMsg: string): TError;
  function IsError(Obj: IObject): boolean;
implementation
  var
    OTRUE:  IObject;
    OFALSE: IObject;
    ONULL:  IObject;

  function Eval(Node: INode; Env: TEnvironment): IObject;
  var
    Res: IObject;
  begin
    // TProgram
    if Node is TProgram then
      Exit(EvalProgram(Node as TProgram, Env))
    // TExpressionStatement
    else if Node is TExpressionStatement then
      Exit(Eval((Node as TExpressionStatement).Expression, Env))
    // TInteger
    else if Node is TIntegerLiteral then
      Exit(TInteger.Create((Node as TIntegerLiteral).Value))
    else if Node is TStringLiteral then
      Exit(TString.Create((Node as TStringLiteral).Value))
    // TBoolean
    else if Node is TBooleanLiteral then
      if (Node as TBooleanLiteral).Value = true then
        Exit(OTRUE)
      else
        Exit(OFALSE)
    // TNullLiteral
    else if Node is TNullLiteral then
      Exit(ONULL)
    // TPrefixExpression
    else if Node is TPrefixExpression then
      Exit(EvalPrefixExpression((Node as TPrefixExpression), Env))
    // TInfixExpression
    else if Node is TInfixExpression then
      Exit(EvalInfixExpression((Node as TInfixExpression), Env))
    // TBlockStatement
    else if Node is TBlockStatement then
      Exit(EvalBlockStatement((Node as TBlockStatement), Env))
    // TIfExpression
    else if Node is TIfExpression then
      Exit(EvalIfExpression((Node as TIfExpression), Env))
    // TReturnStatement
    else if Node is TReturnStatement then
    begin
      Res := Eval((Node as TReturnStatement).Value, Env);
      if IsError(Res) then
        Exit(Res);
      Exit(TReturn.Create(Res))
    end
    // TLetStatement
    else if Node is TLetStatement then
    begin
      Res := Eval((Node as TLetStatement).Value, Env);
      if IsError(Res) then
        Exit(Res)
      else
        Exit(Env.SetObj((Node as TLetStatement).Name.Value, Res))
    end
    // TIdentifier
    else if Node is TIdentifier then
      Exit(EvalIdentifier((Node as TIdentifier), Env))
    else
      Exit(nil);
  end;

  function EvalProgram(Node: TProgram; Env: TEnvironment): IObject;
  var
    Res: IObject;
    Stmt: IStatement;
  begin
    Res := ONULL;
    for Stmt in Node.Statements do
    begin
      Res := Eval(Stmt, Env);
      if Res.ObjType = otReturn then
        Exit((Res as TReturn).Value); // Se devuelve el valor
      if Res.ObjType = otError then
        Exit((Res as TError));


    end;
    Result := Res;
  end;

  function EvalBlockStatement(Node: TBlockStatement; Env: TEnvironment): IObject;
  var
    Res: IObject;
    Stmt: IStatement;
  begin
    Res := ONULL;
    for Stmt in Node.Statements do
    begin
      Res := Eval(Stmt, Env);
      if (Res <> nil) and ((Res.ObjType = otReturn) or (Res.ObjType = otError)) then
        Exit(Res); // se devuelve el objeto TReturn
    end;
    Result := Res;
  end;

  function EvalPrefixExpression(Node: TPrefixExpression; Env: TEnvironment): IObject;
  var
    RightObj: IObject;
    ResObj: IObject;
    RightTypeStr: string;
  begin
    ResObj := ONULL;
    RightObj := Eval(Node.Right, Env);

    if IsError(RightObj) then
      Exit(RightObj);

    if Node.Optor = '!' then
      ResObj := EvalBangOperatorExpression(RightObj, Env)
    else if Node.Optor = '-' then
      ResObj := EvalMinusPrefixOperatorExpression(RightObj, Env)
    else
    begin
      RightTypeStr := GetEnumName(TypeInfo(TObjectType), ord(RightObj.ObjType));
      ResObj := NewError(Format('unknown operator: %s %s', [Node.Optor, RightTypeStr]));
    end;
    Result := ResObj;
  end;
  function EvalBangOperatorExpression(Right: IObject; Env: TEnvironment): IObject;
  begin
    if Right = OTRUE then
      Exit(OFALSE);
    if Right = OFALSE then
      Exit(OTRUE);
    if Right = ONULL then
      Exit(OTRUE);
    Exit(OFALSE);
  end;
  function EvalInfixExpression(Node: TInfixExpression; Env: TEnvironment): IObject;
  var
    LeftObj     : IObject;
    RightObj    : IObject;
    Optor       : string;
    LeftTypeStr : string;
    RightTypeStr: string;
  begin
    Optor := Node.Optor;
    // Evaluate the Left hand side of the expression
    LeftObj := Eval(Node.Left, Env);
    if IsError(LeftObj) then
      Exit(LeftObj);
    // Evaluate the Right hand side of the expression
    RightObj := Eval(Node.Right, Env);
    if IsError(RightObj) then
      Exit(RightObj);

    // get the both objects types
    LeftTypeStr   := GetEnumName(TypeInfo(TObjectType), ord(LeftObj.ObjType));
    RightTypeStr  := GetEnumName(TypeInfo(TObjectType), ord(RightObj.ObjType));

    // Check for the operator to compute the expression
    if (LeftObj.ObjType = otInteger) and (RightObj.ObjType = otInteger) then
      Exit(EvalIntegerInfixExpression(Optor, LeftObj as TInteger, RightObj as TInteger, Env))
    else if Optor = '==' then
      Exit(NativeToBooleanObject(LeftObj = RightObj))
    else if Optor = '!=' then
      Exit(NativeToBooleanObject(LeftObj <> RightObj))
    else if LeftObj.ObjType <> RightObj.ObjType then
      Exit(NewError(Format('type mismatch: %s %s %s', [LeftTypeStr, Node.Optor, RightTypeStr])))
    else
      Exit(NewError(Format('unknown operator: %s %s %s', [LeftTypeStr, Node.Optor, RightTypeStr])));
  end;

  function EvalIntegerInfixExpression(Optor: string; LeftObj: TInteger; RightObj: TInteger; Env: TEnvironment): IObject;
  var
    ResObj: IObject;
    LeftTypeStr: string;
    RightTypeStr: string;
  begin
    ResObj := ONULL;
    if Optor = '+' then
      ResObj := TInteger.Create(LeftObj.Value + RightObj.Value)
    else if Optor = '-' then
      ResObj := TInteger.Create(LeftObj.Value - RightObj.Value)
    else if Optor = '*' then
      ResObj := TInteger.Create(LeftObj.Value * RightObj.Value)
    else if Optor = '/' then
      ResObj := TInteger.Create(LeftObj.Value div RightObj.Value)
    else if Optor = '<' then
      ResObj := NativeToBooleanObject(LeftObj.Value < RightObj.Value)
    else if Optor = '>' then
      ResObj := NativeToBooleanObject(LeftObj.Value > RightObj.Value)
    else if Optor = '==' then
      ResObj := NativeToBooleanObject(LeftObj.Value = RightObj.Value)
    else if Optor = '!=' then
      ResObj := NativeToBooleanObject(LeftObj.Value <> RightObj.Value)
    else
    begin
      LeftTypeStr := GetEnumName(TypeInfo(TObjectType), ord(LeftObj.ObjType));
      RightTypeStr := GetEnumName(TypeInfo(TObjectType), ord(RightObj.ObjType));
      ResObj := NewError(Format('unknown operator: %s %s %s', [LeftTypeStr, Optor, RightTypeStr]));
    end;

    Result := ResObj;
  end;

  function EvalIdentifier(Node: TIdentifier; Env: TEnvironment): IObject;
  var
    Found: boolean;
    Val: IObject;
  begin
    Val := Env.GetObj(Node.Value, Found);
    if not Found then
      Exit(NewError('Identifier not found: ' + Node.Value));
    Result := Val;
  end;

  function EvalMinusPrefixOperatorExpression(RightNode: IObject; Env: TEnvironment): IObject;
  var
    RightTypeStr: string;
  begin
    if RightNode.ObjType <> otInteger then
    begin
      RightTypeStr := GetEnumName(TypeInfo(TObjectType), ord(RightNode.ObjType));
      Exit(NewError(Format('unknown operator: -%s', [RightTypeStr])));
    end;
    Result := TInteger.Create(-(RightNode as TInteger).Value);
  end;

  function NativeToBooleanObject(Input: boolean): IObject;
  begin
    if Input = true then
      Exit(OTRUE);
    Exit(OFALSE);
  end;
  function EvalIfExpression(Node: TIfExpression; Env: TEnvironment): IObject;
  var
    Condition: IObject;
    ResObj: IObject;
  begin
    ResObj := ONULL;
    Condition := Eval(Node.Condition, Env);

    if IsError(Condition) then
      Exit(Condition);

    if IsTruthy(Condition) then
      ResObj := EvalBlockStatement(Node.Consequence, Env)
    else
    begin
      if Node.Alternative <> nil then
        ResObj := EvalBlockStatement(Node.Alternative, Env);
    end;
    Result := ResObj;
  end;
  function IsTruthy(Value: IObject): boolean;
  var
    Res: Boolean;
  begin
    Res := true;
    if Value.ObjType = otNull then
      Res := false;
    if Value = OTRUE then
      Res := true;
    if Value = OFALSE then
      Res := false;
    Result := Res;
  end;
  function NewError(ErrorMsg: string): TError;
  begin
    Result := TError.Create(ErrorMsg);
  end;
  function IsError(Obj: IObject): boolean;
  begin
    if Obj <> nil then
      Exit(Obj.ObjType = otError);
    Result := false;
  end;
  initialization
    OTRUE :=  TBoolean.Create(true);
    OFALSE := TBoolean.Create(false);
    ONULL :=  TNull.Create;
end.
