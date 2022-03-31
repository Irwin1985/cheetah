unit evaluator;

interface
uses
  SysUtils,
  TypInfo,
  obj,
  ast;

  function Eval(node: INode): IObject;
  function EvalProgram(Node: TProgram): IObject;
  function EvalBlockStatement(Node: TBlockStatement): IObject;
  function EvalPrefixExpression(Node: TPrefixExpression): IObject;
  function EvalBangOperatorExpression(Right: IObject): IObject;
  function EvalMinusPrefixOperatorExpression(RightNode: IObject): IObject;
  function EvalInfixExpression(Node: TInfixExpression): IObject;
  function EvalIntegerInfixExpression(Optor: string; LeftObj: TInteger; RightObj: TInteger): IObject;
  function NativeToBooleanObject(Input: boolean): IObject;
  function EvalIfExpression(Node: TIfExpression): IObject;
  function IsTruthy(Value: IObject): boolean;
  function NewError(ErrorMsg: string): TError;
  function IsError(Obj: IObject): boolean;
implementation
  var
    OTRUE:  IObject;
    OFALSE: IObject;
    ONULL:  IObject;

  function Eval(Node: INode): IObject;
  var
    Res: IObject;
  begin
    // TProgram
    if Node is TProgram then
      Exit(EvalProgram(Node as TProgram))
    // TExpressionStatement
    else if Node is TExpressionStatement then
      Exit(Eval((Node as TExpressionStatement).Expression))
    // TInteger
    else if Node is TIntegerLiteral then
      Exit(TInteger.Create((Node as TIntegerLiteral).Value))
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
      Exit(EvalPrefixExpression((Node as TPrefixExpression)))
    // TInfixExpression
    else if Node is TInfixExpression then
      Exit(EvalInfixExpression((Node as TInfixExpression)))
    // TBlockStatement
    else if Node is TBlockStatement then
      Exit(EvalBlockStatement((Node as TBlockStatement)))
    // TIfExpression
    else if Node is TIfExpression then
      Exit(EvalIfExpression((Node as TIfExpression)))
    // TReturnStatement
    else if Node is TReturnStatement then
    begin
      Res := Eval((Node as TReturnStatement).Value);
      if IsError(Res) then
        Exit(Res);
      Exit(TReturn.Create(Res))
    end
    else
      Exit(nil);
  end;

  function EvalProgram(Node: TProgram): IObject;
  var
    Res: IObject;
    Stmt: IStatement;
  begin
    Res := ONULL;
    for Stmt in Node.Statements do
    begin
      Res := Eval(Stmt);
      if Res.ObjType = otReturn then
        Exit((Res as TReturn).Value); // Se devuelve el valor
      if Res.ObjType = otError then
        Exit((Res as TError));


    end;
    Result := Res;
  end;

  function EvalBlockStatement(Node: TBlockStatement): IObject;
  var
    Res: IObject;
    Stmt: IStatement;
  begin
    Res := ONULL;
    for Stmt in Node.Statements do
    begin
      Res := Eval(Stmt);
      if (Res <> nil) and ((Res.ObjType = otReturn) or (Res.ObjType = otError)) then
        Exit(Res); // se devuelve el objeto TReturn
    end;
    Result := Res;
  end;

  function EvalPrefixExpression(Node: TPrefixExpression): IObject;
  var
    RightObj: IObject;
    ResObj: IObject;
    RightTypeStr: string;
  begin
    ResObj := ONULL;
    RightObj := Eval(Node.Right);

    if IsError(RightObj) then
      Exit(RightObj);

    if Node.Optor = '!' then
      ResObj := EvalBangOperatorExpression(RightObj)
    else if Node.Optor = '-' then
      ResObj := EvalMinusPrefixOperatorExpression(RightObj)
    else
    begin
      RightTypeStr := GetEnumName(TypeInfo(TObjectType), ord(RightObj.ObjType));
      ResObj := NewError(Format('unknown operator: %s %s', [Node.Optor, RightTypeStr]));
    end;
    Result := ResObj;
  end;
  function EvalBangOperatorExpression(Right: IObject): IObject;
  begin
    if Right = OTRUE then
      Exit(OFALSE);
    if Right = OFALSE then
      Exit(OTRUE);
    if Right = ONULL then
      Exit(OTRUE);
    Exit(OFALSE);
  end;
  function EvalInfixExpression(Node: TInfixExpression): IObject;
  var
    LeftObj     : IObject;
    RightObj    : IObject;
    Optor       : string;
    LeftTypeStr : string;
    RightTypeStr: string;
  begin
    Optor := Node.Optor;
    // Evaluate the Left hand side of the expression
    LeftObj := Eval(Node.Left);
    if IsError(LeftObj) then
      Exit(LeftObj);
    // Evaluate the Right hand side of the expression
    RightObj := Eval(Node.Right);
    if IsError(RightObj) then
      Exit(RightObj);

    // get the both objects types
    LeftTypeStr   := GetEnumName(TypeInfo(TObjectType), ord(LeftObj.ObjType));
    RightTypeStr  := GetEnumName(TypeInfo(TObjectType), ord(RightObj.ObjType));

    // Check for the operator to compute the expression
    if (LeftObj.ObjType = otInteger) and (RightObj.ObjType = otInteger) then
      Exit(EvalIntegerInfixExpression(Optor, LeftObj as TInteger, RightObj as TInteger))
    else if Optor = '==' then
      Exit(NativeToBooleanObject(LeftObj = RightObj))
    else if Optor = '!=' then
      Exit(NativeToBooleanObject(LeftObj <> RightObj))
    else if LeftObj.ObjType <> RightObj.ObjType then
      Exit(NewError(Format('type mismatch: %s %s %s', [LeftTypeStr, Node.Optor, RightTypeStr])))
    else
      Exit(NewError(Format('unknown operator: %s %s %s', [LeftTypeStr, Node.Optor, RightTypeStr])));
  end;

  function EvalIntegerInfixExpression(Optor: string; LeftObj: TInteger; RightObj: TInteger): IObject;
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

  function EvalMinusPrefixOperatorExpression(RightNode: IObject): IObject;
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
  function EvalIfExpression(Node: TIfExpression): IObject;
  var
    Condition: IObject;
    ResObj: IObject;
  begin
    ResObj := ONULL;
    Condition := Eval(Node.Condition);

    if IsError(Condition) then
      Exit(Condition);

    if IsTruthy(Condition) then
      ResObj := EvalBlockStatement(Node.Consequence)
    else
    begin
      if Node.Alternative <> nil then
        ResObj := EvalBlockStatement(Node.Alternative);
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
