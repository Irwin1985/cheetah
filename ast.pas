unit ast;

interface
  uses
    SysUtils, Classes, token;

  type
    // TNode class
    INode = interface
      ['{9105BFC0-E9D9-4F46-A4C6-F2E2A7D65FEC}']
      function TokenLiteral: string;
      function ToString: string;
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
      Statements: array of IStatement;
      function TokenLiteral: string;
      function ToString: string;
    end;
    // TIdentifier
    TIdentifier = class(TInterfacedObject, IExpression)
      Token: TToken;
      Value: string;
      function TokenLiteral: string;
      function ToString: string;
      procedure ExpressionNode;
    end;
    // TLetStatement class
    TLetStatement = class(TInterfacedObject, IStatement)
      Token: TToken;
      Name: TIdentifier;
      Value: IExpression;
      function TokenLiteral:string;
      function ToString: string;
      procedure StatementNode;
    end;
    // TReturnStatement
    TReturnStatement = class(TInterfacedObject, IStatement)
      Token: TToken;
      Value: IExpression;
      function TokenLiteral:string;
      function ToString: string;
      procedure StatementNode;
    end;
    // ExpressionStatement
    TExpressionStatement = class(TInterfacedObject, IStatement)
      Token: TToken;
      Expression: IExpression;
      function TokenLiteral:string;
      function ToString: string;
      procedure StatementNode;
    end;
    // TInteger
    TIntegerLiteral = class(TInterfacedObject, IExpression)
      Token: TToken;
      Value: Integer;
      function TokenLiteral: string;
      function ToString: string;
      procedure ExpressionNode;
    end;
    // TBooleanLiteral
    TBooleanLiteral = class(TInterfacedObject, IExpression)
      Token: TToken;
      Value: boolean;
      procedure ExpressionNode;
      function TokenLiteral:string;
      function ToSTring:string;
    end;
    // TStringLiteral
    TStringLiteral = class(TInterfacedObject, IExpression)
      Token: TToken;
      Value: string;
      procedure ExpressionNode;
      function TokenLiteral:string;
      function ToString:string;
    end;
    // TPrefixExpression
    TPrefixExpression = class(TInterfacedObject, IExpression)
      Token: TToken;
      Optor: string;
      Right: IExpression;
      function TokenLiteral: string;
      function ToString: string;
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
      function ToString:string;
    end;
    // TBlockStatement
    TBlockStatement = class(TInterfacedObject, IStatement)
      Token: TToken;
      Statements: array of IStatement;
      procedure StatementNode;
      function TokenLiteral:string;
      function ToString:string;
    end;
    // TIfExpression
    TIfExpression = class(TInterfacedObject, IExpression)
      Token: TToken;
      Condition: IExpression;
      Consequence: TBlockStatement;
      Alternative: TBlockStatement;
      procedure ExpressionNode;
      function TokenLiteral:String;
      function ToString:String;
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

  function TProgram.ToString: string;
  var
    Output: TStringBuilder;
    Stmt: IStatement;
  begin
    Output := TStringBuilder.Create;
    try
      for Stmt in Statements do
      begin
        Output.Append(Stmt.ToString);
      end;
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;

  // TIdentifier class
  function TIdentifier.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;

  function TIdentifier.ToString: string;
  begin
    Result := Token.Literal;
  end;

  procedure TIdentifier.ExpressionNode;
  begin
  end;

  // TLetStatement class
  function TLetStatement.TokenLiteral:string;
  begin
    Result := Token.Literal;
  end;

  function TLetStatement.ToString: string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append(Token.Literal + ' ');
      Output.Append(Name.ToString);
      Output.Append(' = ');

      if Value <> nil then
        Output.Append(Value.ToString);

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

  function TReturnStatement.ToString: string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append(Token.Literal + ' ');
      if Value <> nil then
        Output.Append(Value.ToString);
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

  function TExpressionStatement.ToString: string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append(Expression.ToString);
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
  function TIntegerLiteral.ToString: string;
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
  function TBooleanLiteral.ToSTring:string;
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
  function TStringLiteral.ToString:string;
  begin
    Result := '"' + Value + '"';
  end;
  // TPrefixExpression
  function TPrefixExpression.TokenLiteral: string;
  begin
     Result := Token.Literal;
  end;
  function TPrefixExpression.ToString: string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append('(');
      Output.Append(Optor);
      Output.Append(Right.ToString);
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
  function TInfixExpression.ToString:string;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append('(');
      Output.Append(Left.ToString);
      Output.Append(' ');
      Output.Append(Optor);
      Output.Append(' ');
      Output.Append(Right.ToString);
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
  function TBlockStatement.ToString:string;
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
        Output.Append(Stmt.ToString);
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
  function TIfExpression.ToString:String;
  var
    Output: TStringBuilder;
  begin
    Output := TStringBuilder.Create;
    try
      Output.Append('if (');
      Output.Append(Condition.ToString);
      Output.Append(')');
      Output.Append(Consequence.ToString);
      if Alternative <> nil then
      begin
        //Output.Append(chr(13));
        Output.Append('else');
        Output.Append(Alternative.ToString);
      end;
      Result := Output.ToString;
    finally
      FreeAndNil(Output);
    end;
  end;
end.
