unit ast;

interface
  uses
    SysUtils,
    Classes,
    Generics.Collections,
    token;

  type
    // TNode class
    INode = interface
      ['{9105BFC0-E9D9-4F46-A4C6-F2E2A7D65FEC}']
      function TokenLiteral: string;
      function Print: string;
    end;
    // TStatement class
    IStatement = interface(INode)
      ['{10C9E129-A0C3-4E5D-AD57-F26C317E2FEE}']
      procedure StatementNode;
    end;
    // TExpression class
    IExpression = interface(INode)
      ['{F87674C4-70D1-4CB6-8D75-9FF1823F92B7}']
      procedure ExpressionNode;
    end;
    // TProgram class
    TProgram = class(TInterfacedObject, INode)
      Statements: TArray<IStatement>;
      function TokenLiteral: string;
      function Print: string;
    end;
    // TIdentifier
    TIdentifier = class(TInterfacedObject, IExpression)
      Token: TToken;
      Value: string;
      constructor Create(Token: TToken; Value: string); overload;
      function TokenLiteral: string;
      function Print: string;
      procedure ExpressionNode;
    end;
    // TLetStatement class
    TLetStatement = class(TInterfacedObject, IStatement)
      Token: TToken;
      Name: TIdentifier;
      Value: IExpression;
      function TokenLiteral:string;
      function Print: string;
      procedure StatementNode;
    end;
    // TReturnStatement
    TReturnStatement = class(TInterfacedObject, IStatement)
      Token: TToken;
      Value: IExpression;
      function TokenLiteral:string;
      function Print: string;
      procedure StatementNode;
    end;
    // ExpressionStatement
    TExpressionStatement = class(TInterfacedObject, IStatement)
      Token: TToken;
      Expression: IExpression;
      function TokenLiteral:string;
      function Print: string;
      procedure StatementNode;
    end;
    // TInteger
    TIntegerLiteral = class(TInterfacedObject, IExpression)
      Token: TToken;
      Value: Integer;
      function TokenLiteral: string;
      function Print: string;
      procedure ExpressionNode;
    end;
    // TBooleanLiteral
    TBooleanLiteral = class(TInterfacedObject, IExpression)
      Token: TToken;
      Value: boolean;
      procedure ExpressionNode;
      function TokenLiteral:string;
      function Print:string;
    end;
    // TStringLiteral
    TStringLiteral = class(TInterfacedObject, IExpression)
      Token: TToken;
      Value: string;
      procedure ExpressionNode;
      function TokenLiteral:string;
      function Print:string;
    end;
    // TNullLiteral
    TNullLiteral = class(TInterfacedObject, IExpression)
      Token: TToken;
      procedure ExpressionNode;
      function TokenLiteral: string;
      function Print:string;
    end;
    // TPrefixExpression
    TPrefixExpression = class(TInterfacedObject, IExpression)
      Token: TToken;
      Optor: string;
      Right: IExpression;
      function TokenLiteral: string;
      function Print: string;
      procedure ExpressionNode;
    end;
    // TInfixExpression
    TInfixExpression = class(TInterfacedObject, IExpression)
      Token: TToken;
      Optor: string;
      Left: IExpression;
      Right: IExpression;
      procedure ExpressionNode;
      function TokenLiteral:string;
      function Print:string;
    end;
    // TBlockStatement
    TBlockStatement = class(TInterfacedObject, IStatement)
      Token: TToken;
      Statements: TArray<IStatement>;
      procedure StatementNode;
      function TokenLiteral:string;
      function Print: string;
    end;
    // TIfExpression
    TIfExpression = class(TInterfacedObject, IExpression)
      Token: TToken;
      Condition: IExpression;
      Consequence: TBlockStatement;
      Alternative: TBlockStatement;
      procedure ExpressionNode;
      function TokenLiteral:String;
      function Print:String;
    end;
    // TFunctionLiteral
    TFunctionLiteral = class(TInterfacedObject, IExpression)
      Token: TToken;
      Parameters: TArray<TIdentifier>;
      Body: TBlockStatement;
      procedure ExpressionNode;
      function TokenLiteral:string;
      function Print:string;
    end;
    // TCallExpression
    TCallExpression = class(TInterfacedObject, IExpression)
      Token: TToken;
      Func: IExpression;
      Arguments: TArray<IExpression>;
      function TokenLiteral:string;
      function Print:string;
      procedure ExpressionNode;
    end;
implementation
  // TProgram class
  function TProgram.TokenLiteral: string;
  begin
    if Length(Self.Statements) > 0 then
      Result := Statements[0].TokenLiteral
    else
      Result := '';
  end;

  function TProgram.Print: string;
  var
    Output: TStringBuilder;
    Stmt: IStatement;
  begin
    Output := TStringBuilder.Create;
    try
      for Stmt in Statements do
      begin
        Output.Append(Stmt.Print);
      end;
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;

  // TIdentifier class
  constructor TIdentifier.Create(Token: TToken; Value: string);
  begin
    Self.Token := Token;
    Self.Value := Value;
  end;
  function TIdentifier.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;

  function TIdentifier.Print: string;
  begin
    Result := Value;
  end;

  procedure TIdentifier.ExpressionNode;
  begin
  end;

  // TLetStatement class
  function TLetStatement.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;

  function TLetStatement.Print: string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append(Token.Literal + ' ');
      Output.Append(Name.Print);
      Output.Append(' = ');

      if Value <> nil then
        Output.Append(Value.Print);

      Output.Append(';');

      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;

  end;
  procedure TLetStatement.StatementNode;
  begin
  end;

  // TReturnStatement
  function TReturnStatement.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;

  function TReturnStatement.Print: string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append(Token.Literal + ' ');
      if Value <> nil then
        Output.Append(Value.Print);
      Output.Append(';');
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;
  procedure TReturnStatement.StatementNode;
  begin
  end;

  // TExpressionStatement
  function TExpressionStatement.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;

  function TExpressionStatement.Print: string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append(Expression.Print);
      Output.Append(';');
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;

  procedure TExpressionStatement.StatementNode;
  begin
  end;
  // TInteger Literal
  function TIntegerLiteral.TokenLiteral: string;
  begin
    Result := Token.Literal;
  end;
  function TIntegerLiteral.Print: string;
  begin
    Result := Token.Literal;
  end;
  procedure TIntegerLiteral.ExpressionNode;
  begin
  end;
  // TBooleanLiteral
  procedure TBooleanLiteral.ExpressionNode;
  begin
  end;
  function TBooleanLiteral.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;
  function TBooleanLiteral.Print:string;
  begin
    Result := Token.Literal;
  end;
  // TStringLiteral
  procedure TStringLiteral.ExpressionNode;
  begin
  end;
  function TStringLiteral.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;
  function TStringLiteral.Print:string;
  begin
    Result := '"' + Value + '"';
  end;
  // TPrefixExpression
  function TPrefixExpression.TokenLiteral: string;
  begin
     Result := Token.Literal;
  end;
  function TPrefixExpression.Print: string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append('(');
      Output.Append(Optor);
      Output.Append(Right.Print);
      Output.Append(')');
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;
  procedure TPrefixExpression.ExpressionNode;
  begin
  end;

  procedure TInfixExpression.ExpressionNode;
  begin
  end;
  function TInfixExpression.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;
  function TInfixExpression.Print:string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append('(');
      Output.Append(Left.Print);
      Output.Append(' ');
      Output.Append(Optor);
      Output.Append(' ');
      Output.Append(Right.Print);
      Output.Append(')');
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;
  // TBlockStatement
  procedure TBlockStatement.StatementNode;
  begin
  end;
  function TBlockStatement.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;
  function TBlockStatement.Print:string;
  var
    Output: TStringBuilder;
    Stmt: IStatement;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append('{');
      //Output.Append(chr(13));
      for Stmt in Statements do
      begin
        Output.Append(Stmt.Print);
        //Output.Append(chr(13));
      end;
      Output.Append('}');
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;

  // TIfExpression
  procedure TIfExpression.ExpressionNode;
  begin
  end;
  function TIfExpression.TokenLiteral:String;
  begin
    Result := Token.Literal;
  end;
  function TIfExpression.Print:String;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append('if (');
      Output.Append(Condition.Print);
      Output.Append(')');
      Output.Append(Consequence.Print);
      if Alternative <> nil then
      begin
        //Output.Append(chr(13));
        Output.Append('else');
        Output.Append(Alternative.Print);
      end;
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;
  // TFunctionLiteral
  procedure TFunctionLiteral.ExpressionNode;
  begin
  end;
  function TFunctionLiteral.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;
  function TFunctionLiteral.Print:string;
  var
    Output: TStringBuilder;
    ParametersStr: array of string;
    Param: TIdentifier;
    I: integer;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append('fn (');
      I := 0;
      if Length(Parameters) > 0 then
      begin
        for Param in Parameters do
        begin
          Inc(I);
          SetLength(ParametersStr, I);
          ParametersStr[I-1] := Param.Print;
        end;
        Output.Append(String.Join(', ', ParametersStr));
      end;
      Output.Append(')');
      Output.Append(Body.Print);
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;
  function TCallExpression.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;
  function TCallExpression.Print:string;
  var
    Output: TStringBuilder;
    Arg: IExpression;
    Args: TList<string>;
  begin
    Args := TList<string>.Create;
    Output := TStringBuilder.Create;
    try
      Output.Append(Func.Print);
      Output.Append('(');
      if Length(Arguments) > 0 then
      begin
        for Arg in Arguments do
        begin
          Args.Add(Arg.Print);
        end;
        Output.Append(String.Join(', ', Args.ToArray))
      end;
      Output.Append(')');
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
      FreeAndNil(Args);
    end;
  end;
  procedure TCallExpression.ExpressionNode;
  begin

  end;
  procedure TNullLiteral.ExpressionNode;
  begin
  end;
  function TNullLiteral.TokenLiteral: string;
  begin
    Result := Token.Literal;
  end;
  function TNullLiteral.Print:string;
  begin
    Result := 'null';
  end;
end.
