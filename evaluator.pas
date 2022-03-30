unit evaluator;

interface
uses
  obj,
  ast;

  function Eval(node: INode): IObject;
  function EvalStatement(Stmts: TArray<IStatement>): IObject;
  function EvalPrefixExpression(Node: TPrefixExpression): IObject;
  function EvalBangOperatorExpression(Right: IObject): IObject;
  function EvalMinusPrefixOperatorExpression(RightNode: IObject): IObject;
  function EvalInfixExpression(Node: TInfixExpression): IObject;
  function EvalIntegerInfixExpression(Optor: string; LeftObj: TInteger; RightObj: TInteger): IObject;
  function NativeToBooleanObject(Input: boolean): IObject;
  function EvalStatements(Statements: TArray<IStatement>): IObject;
  function EvalIfExpression(Node: TIfExpression): IObject;
  function IsTruthy(Value: IObject): boolean;
implementation
  var
    OTRUE:  IObject;
    OFALSE: IObject;
    ONULL:  IObject;

  function Eval(Node: INode): IObject;
  var
    Res: IObject;
  begin
    Res := nil;
    // TProgram
    if Node is TProgram then
      Res := EvalStatement((Node as TProgram).Statements);
    // TExpressionStatement
    if Node is TExpressionStatement then
      Res := Eval((Node as TExpressionStatement).Expression);
    // TInteger
    if Node is TIntegerLiteral then
      Res := TInteger.Create((Node as TIntegerLiteral).Value);
    // TBoolean
    if Node is TBooleanLiteral then
      if (Node as TBooleanLiteral).Value = true then
        Exit(OTRUE)
      else
        Exit(OFALSE);
    // TNullLiteral
    if Node is TNullLiteral then
      Res := ONULL;
    // TPrefixExpression
    if Node is TPrefixExpression then
      Res := EvalPrefixExpression((Node as TPrefixExpression));
    // TInfixExpression
    if Node is TInfixExpression then
      Res := EvalInfixExpression((Node as TInfixExpression));
    // TBlockStatement
    if Node is TBlockStatement then
      Res := EvalStatements((Node as TBlockStatement).Statements);
    // TIfExpression
    if Node is TIfExpression then
      Res := EvalIfExpression((Node as TIfExpression));

    Result := Res;
  end;

  function EvalStatement(Stmts: TArray<IStatement>): IObject;
  var
    Res: IObject;
    Stmt: IStatement;
  begin
    for Stmt in Stmts do
    begin
      Res := Eval(Stmt);
    end;
    Result := Res;
  end;

  function EvalPrefixExpression(Node: TPrefixExpression): IObject;
  var
    RightNode: IObject;
    ResObj: IObject;
  begin
    ResObj := ONULL;
    RightNode := Eval(Node.Right);
    if Node.Optor = '!' then
      ResObj := EvalBangOperatorExpression(RightNode);
    if Node.Optor = '-' then
      ResObj := EvalMinusPrefixOperatorExpression(RightNode);

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
    LeftObj: IObject;
    RightObj: IObject;
    ResObj: IObject;
    Optor: string;
  begin
    ResObj := ONULL;
    LeftObj := Eval(Node.Left);
    RightObj := Eval(Node.Right);
    Optor := Node.Optor;

    if (LeftObj.ObjType = otInteger) and (RightObj.ObjType = otInteger) then
      ResObj := EvalIntegerInfixExpression(Optor, LeftObj as TInteger, RightObj as TInteger);

    if (ResObj = ONULL) and (Optor = '==') then
      ResObj := NativeToBooleanObject(LeftObj = RightObj);

    if (ResObj = ONULL) and (Optor = '!=') then
      ResObj := NativeToBooleanObject(LeftObj <> RightObj);

    Result := ResObj;
  end;

  function EvalIntegerInfixExpression(Optor: string; LeftObj: TInteger; RightObj: TInteger): IObject;
  var
    ResObj: IObject;
  begin
    ResObj := ONULL;
    if Optor = '+' then
      ResObj := TInteger.Create(LeftObj.Value + RightObj.Value);
    if Optor = '-' then
      ResObj := TInteger.Create(LeftObj.Value - RightObj.Value);
    if Optor = '*' then
      ResObj := TInteger.Create(LeftObj.Value * RightObj.Value);
    if Optor = '/' then
      ResObj := TInteger.Create(LeftObj.Value div RightObj.Value);
    if Optor = '<' then
      ResObj := NativeToBooleanObject(LeftObj.Value < RightObj.Value);
    if Optor = '>' then
      ResObj := NativeToBooleanObject(LeftObj.Value > RightObj.Value);
    if Optor = '==' then
      ResObj := NativeToBooleanObject(LeftObj.Value = RightObj.Value);
    if Optor = '!=' then
      ResObj := NativeToBooleanObject(LeftObj.Value <> RightObj.Value);

    Result := ResObj;
  end;

  function EvalMinusPrefixOperatorExpression(RightNode: IObject): IObject;
  begin
    if RightNode.ObjType <> otInteger then
      Exit(ONULL);
    Result := TInteger.Create(-(RightNode as TInteger).Value);
  end;

  function NativeToBooleanObject(Input: boolean): IObject;
  begin
    if Input = true then
      Exit(OTRUE);
    Exit(OFALSE);
  end;
  function EvalStatements(Statements: TArray<IStatement>): IObject;
  var
    ResObj: IObject;
    Stmt: IStatement;
  begin
    for Stmt in Statements do
    begin
       ResObj := Eval(Stmt);
    end;
    Result := ResObj;
  end;
  function EvalIfExpression(Node: TIfExpression): IObject;
  var
    Condition: IObject;
    ResObj: IObject;
  begin
    ResObj := ONULL;
    Condition := Eval(Node.Condition);
    if IsTruthy(Condition) then
      ResObj := EvalStatements((Node.Consequence as TBlockStatement).Statements)
    else
    begin
      if Node.Alternative <> nil then
        ResObj := EvalStatements((Node.Alternative as TBlockStatement).Statements);
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
  initialization
    OTRUE :=  TBoolean.Create(true);
    OFALSE := TBoolean.Create(false);
    ONULL :=  TNull.Create;
end.
