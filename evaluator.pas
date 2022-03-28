unit evaluator;

interface
uses
  obj,
  ast;

  function Eval(node: INode): IObject;
  function EvalStatement(Stmts: TArray<IStatement>): IObject;
  function EvalPrefixExpression(Node: TPrefixExpression): IObject;
  function EvalBangOperatorExpression(Right: IObject): IObject;

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
  begin
    RightNode := Eval(Node.Right);
    if Node.Optor = '!' then
      Exit(EvalBangOperatorExpression(RightNode))
    else
      Exit(nil);
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
(*
      if Right is TBoolean then
      begin
        if (Right as TBoolean).Value = true then
          Exit(OFALSE);
        if (Right as TBoolean).Value = false then
          Exit(OTRUE);
      end;
      if Right is TNull then
        Exit(OTRUE);

      Exit(OFALSE);
*)
  end;
  initialization
    OTRUE :=  TBoolean.Create(true);
    OFALSE := TBoolean.Create(false);
    ONULL :=  TNull.Create;
end.
