unit parser;

interface
  uses
    SysUtils,
    TypInfo,
    lexer,
    token,
    ast,
    Generics.Collections;

  type
    TPrefixParseFn  = reference to function: IExpression;
    TInfixParseFn   = reference to function(Left: IExpression):IExpression;
    TErrors         = array of string;
    //TArrayIdent     = array of TIdentifier;
    TParser         = class
    private
      L: TLexer;
      CurToken: TToken;
      PeekToken: TToken;
      Errors: TErrors;
      PrefixParseFns: TDictionary<TTokenKind, TPrefixParseFn>;
      InfixParseFns: TDictionary<TTokenKind, TInfixParseFn>;
      Precedences: TDictionary<TTokenKind, Integer>;

      {Private functions}
      procedure NextToken;
      function ParseStatement:IStatement;
      function ParseLetStatement:TLetStatement;
      function ParseReturnStatement:TReturnStatement;
      function CurTokenIs(Kind: TTokenKind): boolean;
      function CurPrecedence(Kind: TTokenKind): integer;
      procedure Match(kind: TTokenKind);
      procedure NewError(ErrorMsg: string);
      function ParseExpressionStatement: TExpressionStatement;
      function ParseExpression(Precedence: integer): IExpression;
      function ParseIdentifier: IExpression;
      function ParseIntegerLiteral: IExpression;
      function ParseBooleanExpression: IExpression;
      function ParseStringLiteral: IExpression;
      function ParseNullExpression: IExpression;
      function ParsePrefixExpression: IExpression;
      function ParseInfixExpression(Left: IExpression): IExpression;
      function ParseGroupedExpression: IExpression;
      function ParseBlockStatement: TBlockStatement;
      function ParseIfExpression: IExpression;
      function ParseFunctionParameters : TArray<TIdentifier>;
      function ParseFunctionLiteral: IExpression;
      function ParseCallExpression(Func: IExpression): IExpression;
      function ParseCallArguments: TArray<IExpression>;
      // Register procedures
      procedure RegisterPrefix(Kind: TTokenKind; Func: TPrefixParseFn);
      procedure RegisterInfix(Kind: TTokenKind; Func: TInfixParseFn);
    public
      constructor Create(Lexer: TLexer); overload;
      function ParseProgram: TProgram;
      function GetErrors:TErrors;
    end;

implementation
  const
    LOWEST      = 1;
    EQUALITY    = 2; // ==
    COMPARISON  = 3; // > or <
    TERM        = 4; // +
    FACTOR      = 5; // *
    PREFIX      = 6; // -X or !X
    CALL        = 7; // myFunction(X)


  constructor TParser.Create(Lexer: TLexer);
  begin
    L              := Lexer;
    PrefixParseFns := TDictionary<TTokenKind, TPrefixParseFn>.Create;
    InfixParseFns  := TDictionary<TTokenKind, TInfixParseFn>.Create;
    Precedences    := TDictionary<TTokenKind, Integer>.Create;

    // Fill the token precedence
    Precedences.Add(tkEq,        EQUALITY);
    Precedences.Add(tkNotEq,     EQUALITY);
    Precedences.Add(tkLt,        COMPARISON);
    Precedences.Add(tkGt,        COMPARISON);
    Precedences.Add(tkPlus,      TERM);
    Precedences.Add(tkMinus,     TERM);
    Precedences.Add(tkSlash,     FACTOR);
    Precedences.Add(tkAsterisk,  FACTOR);
    Precedences.Add(tkLParen,    CALL);

    // Read two tokens, so CurToken and PeekToken are both set
    NextToken;
    NextToken;

    // Register prefix functions
    RegisterPrefix(tkIdent, ParseIdentifier);
    RegisterPrefix(tkInt, ParseIntegerLiteral);
    RegisterPrefix(tkMinus, ParsePrefixExpression);
    RegisterPrefix(tkBang, ParsePrefixExpression);
    RegisterPrefix(tkTrue, ParseBooleanExpression);
    RegisterPrefix(tkFalse, ParseBooleanExpression);
    RegisterPrefix(tkNull, ParseNullExpression);
    RegisterPrefix(tkString, ParseStringLiteral);
    RegisterPrefix(tkLParen, ParseGroupedExpression);
    RegisterPrefix(tkIf, ParseIfExpression);
    RegisterPrefix(tkFunction, ParseFunctionLiteral);

    // Register infix functions
    RegisterInfix(tkPlus, ParseInfixExpression);
    RegisterInfix(tkMinus, ParseInfixExpression);
    RegisterInfix(tkSlash, ParseInfixExpression);
    RegisterInfix(tkAsterisk, ParseInfixExpression);
    RegisterInfix(tkEq, ParseInfixExpression);
    RegisterInfix(tkNotEq, ParseInfixExpression);
    RegisterInfix(tkLt, ParseInfixExpression);
    RegisterInfix(tkGt, ParseInfixExpression);
    RegisterInfix(tkLParen, ParseCallExpression);
  end;

  procedure TParser.NextToken;
  begin
    //FreeAndNil(CurToken);
    CurToken := PeekToken;
    PeekToken := L.NextToken;
  end;

  function TParser.ParseProgram: TProgram;
  var
    ASTProgram: TProgram;
    Stmt: IStatement;
    ArrSize: integer;
  begin
    ArrSize := 0;
    ASTProgram := TProgram.Create;
    while CurToken.Kind <> tkEof do
    begin
      Stmt := ParseStatement;
      if Stmt <> nil then
      begin
        Inc(ArrSize);
        SetLength(ASTProgram.Statements, ArrSize);
        ASTProgram.Statements[ArrSize-1] := Stmt;
      end;
      if CurTokenIs(tkSemicolon) then
        NextToken;
    end;
    Result := ASTProgram;
  end;

  // ParseStatement
  function TParser.ParseStatement:IStatement;
  begin
    case CurToken.Kind of
      tkLet: Exit(ParseLetStatement);
      tkReturn: Exit(ParseReturnStatement);
    else
      Result := ParseExpressionStatement;
    end;
  end;

  // ParseLetStatement
  function TParser.ParseLetStatement:TLetStatement;
  var
    Stmt: TLetStatement;
    Ident: TIdentifier;
  begin
    Stmt := TLetStatement.Create;
    Ident := TIdentifier.Create;

    Stmt.Token := CurToken;
    Match(tkLet);
    // fill Ident Node
    Ident.Token := CurToken;
    Ident.Value := CurToken.Literal;

    Stmt.Name := Ident;
    NextToken; // skip identifier token

    Match(tkAssign);

    Stmt.Value := ParseExpression(LOWEST);

    Result := Stmt;
  end;

  function TParser.ParseReturnStatement:TReturnStatement;
  var
    Stmt: TReturnStatement;
  begin
    Stmt := TReturnStatement.Create;
    Stmt.Token := CurToken;
    Match(tkReturn);
    Stmt.Value := ParseExpression(LOWEST);
    Result := Stmt;
  end;

  function TParser.CurTokenIs(Kind: TTokenKind): boolean;
  begin
    Result := CurToken.Kind = Kind;
  end;

  function TParser.CurPrecedence(Kind: TTokenKind): integer;
  var
    ResultPrecedence: integer;
  begin
    if Precedences.ContainsKey(Kind) then
    begin
      Precedences.TryGetValue(Kind, ResultPrecedence);
      Exit(ResultPrecedence);
    end;
    Result := LOWEST;
  end;

  procedure TParser.Match(Kind: TTokenKind);
  var
    ExpectedTokenStr, GotTokenStr, ErrorMsg: string;
  begin
    if CurTokenIs(Kind) then
      NextToken
    else
    begin
      ExpectedTokenStr := GetEnumName(TypeInfo(TTokenKind), ord(Kind));
      GotTokenStr := GetEnumName(TypeInfo(TTokenKind), ord(CurToken.Kind));
      ErrorMsg := Format('expected token to be %s, got %s instead',
        [ExpectedTokenStr, GotTokenStr]);
      NewError(ErrorMsg);
    end;
  end;
  function TParser.GetErrors:TErrors;
  begin
    Result := Errors;
  end;

  procedure TParser.NewError(ErrorMsg: string);
  var
    Size: integer;
  begin
    Size := Length(Errors) + 1;
    SetLength(Errors, Size);
    Errors[Size-1] := ErrorMsg;
  end;
  // Register procedures
  procedure TParser.RegisterPrefix(Kind: TTokenKind; Func: TPrefixParseFn);
  begin
    PrefixParseFns.Add(Kind, Func);
  end;
  procedure TParser.RegisterInfix(Kind: TTokenKind; Func: TInfixParseFn);
  begin
    InfixParseFns.Add(Kind, Func);
  end;

  function TParser.ParseExpressionStatement: TExpressionStatement;
  var
    Stmt: TExpressionStatement;
  begin
    Stmt := TExpressionStatement.Create;
    Stmt.Expression := ParseExpression(LOWEST);
    if CurTokenIs(tkSemicolon) then
      NextToken;
    Result := Stmt;
  end;

  function TParser.ParseExpression(Precedence: integer): IExpression;
  var
    Prefix: TPrefixParseFn;
    LeftExp: IExpression;
    Infix: TInfixParseFn;
  begin
    if PrefixParseFns.ContainsKey(CurToken.Kind) then
      PrefixParseFns.TryGetValue(CurToken.Kind, Prefix)
    else
      Exit(nil);

    // si Prefix es nil entonces retornar nil
    LeftExp := Prefix;
    while Precedence < CurPrecedence(CurToken.Kind) do
    begin
      if InfixParseFns.ContainsKey(CurToken.Kind) then
        InfixParseFns.TryGetValue(CurToken.Kind, Infix)
      else
        Exit(LeftExp);
      LeftExp := Infix(LeftExp);
    end;
    Result := LeftExp;
  end;

  function TParser.ParseIdentifier: IExpression;
  begin
    Result := TIdentifier.Create(CurToken, CurToken.Literal);
    NextToken;
  end;

  function TParser.ParseIntegerLiteral: IExpression;
  var
    Lit: TIntegerLiteral;
  begin
    Lit := TIntegerLiteral.Create;
    Lit.Token := CurToken;
    Lit.Value := StrToInt(CurToken.Literal);
    NextToken;
    Result := Lit;
  end;

  function TParser.ParseBooleanExpression: IExpression;
  var
    Exp: TBooleanLiteral;
  begin
    Exp := TBooleanLiteral.Create;
    Exp.Token := CurToken;
    if CurToken.Literal = 'true' then
      Exp.Value := true
    else
      Exp.Value := false;
    NextToken; // skip the boolean token
    Result := Exp;
  end;

  function TParser.ParseStringLiteral: IExpression;
  var
    StringLit: TStringLiteral;
  begin
    StringLit := TStringLiteral.Create;
    StringLit.Token := CurToken;
    StringLit.Value := CurToken.Literal;
    NextToken;
    Result := StringLit;
  end;

  function TParser.ParseNullExpression: IExpression;
  var
    NullExp: TNullLiteral;
  begin
    NullExp := TNullLiteral.Create;
    NullExp.Token := CurToken;
    NextToken;
    Result := NullExp;
  end;


  function TParser.ParsePrefixExpression: IExpression;
  var
    Exp: TPrefixExpression;
  begin
    Exp := TPrefixExpression.Create;
    Exp.Token := CurToken;
    Exp.Optor := CurToken.Literal;
    NextToken;
    Exp.Right := ParseExpression(PREFIX);
    Result := Exp;
  end;

  function TParser.ParseInfixExpression(Left: IExpression): IExpression;
  var
    Exp: TInfixExpression;
    CurPre: integer;
  begin
    Exp       := TInfixExpression.Create;
    Exp.Left  := Left;
    Exp.Token := CurToken;
    Exp.Optor := CurToken.Literal;
    CurPre    := CurPrecedence(CurToken.Kind);
    NextToken;
    Exp.Right := ParseExpression(CurPre);

    Result := Exp;
  end;

  function TParser.ParseGroupedExpression: IExpression;
  var
    Exp: IExpression;
  begin
    NextToken; // eat '('
    Exp := ParseExpression(LOWEST);
    Match(tkRParen);
    Result := Exp;
  end;

  function TParser.ParseIfExpression: IExpression;
  var
    IfExpression: TIfExpression;
  begin
    IfExpression := TIfExpression.Create;
    NextToken; // eat 'if' token
    Match(tkLParen); // open parenthesis (mandatory)
    IfExpression.Condition := ParseExpression(LOWEST);
    Match(tkRParen); // closing parenthesis (mandatory)
    IfExpression.Consequence := ParseBlockStatement;

    if CurTokenIs(tkElse) then
    begin
      NextToken; // eat the 'else' token
      IfExpression.Alternative := ParseBlockStatement;
    end;

    Result := IfExpression;
  end;

  function TParser.ParseBlockStatement: TBlockStatement;
  var
    BlockStmt: TBlockStatement;
    StmtSize: integer;
    StmtResult: IStatement;
  begin
    StmtSize := 0;
    BlockStmt := TBlockStatement.Create;
    Match(tkLBrace); // opening curly brace (mandatory)
    while (not CurTokenIs(tkRBrace)) and (not CurTokenIs(tkEof)) do
    begin
      StmtResult := ParseStatement;
      if StmtResult <> nil then
      begin
        Inc(StmtSize);
        SetLength(BlockStmt.Statements, StmtSize);
        BlockStmt.Statements[StmtSize-1] := StmtResult;
      end;
      if CurTokenIs(tkSemicolon) then
        NextToken;
    end;
    Match(tkRBrace); // closing curly brace (mandatory)
    Result := BlockStmt;
  end;

  function TParser.ParseFunctionLiteral: IExpression;
  var
    FunctionLit: TFunctionLiteral;
    //I: integer;
  begin
    FunctionLit := TFunctionLiteral.Create;
    FunctionLit.Token := CurToken;
    NextToken; // skip the 'fn' token
    // parsing parameters begin.
    FunctionLit.Parameters := ParseFunctionParameters;
    // parsing parameters end.
    FunctionLit.Body := ParseBlockStatement;
    Result := FunctionLit;
  end;

  function TParser.ParseFunctionParameters : TArray<TIdentifier>;
  var
    I: integer;
    Params: TArray<TIdentifier>;
  begin
    I := 1;
    Match(tkLParen); // eat '(' parenthesis

    if CurTokenIs(tkRParen) then
    begin
      NextToken; // eat the ')' parenthesis
      Exit;
    end;
    SetLength(Params, I);
    Params[I-1] := TIdentifier.Create(CurToken, CurToken.Literal);
    NextToken;
    while CurTokenIs(tkComma) do
    begin
      Match(tkComma);
      Inc(I);
      SetLength(Params, I);
      Params[I-1] := TIdentifier.Create(CurToken, CurToken.Literal);
      NextToken;
    end;
    Match(tkRParen); // eat ')' parenthesis

    Result := Params;
  end;

  function TParser.ParseCallExpression(Func: IExpression): IExpression;
  var
    CallExp: TCallExpression;
  begin
    CallExp := TCallExpression.Create;
    CallExp.Token := CurToken;
    CallExp.Func := Func;
    CallExp.Arguments := ParseCallArguments;
    Result := CallExp;
  end;
  function TParser.ParseCallArguments: TArray<IExpression>;
  var
    Args: TArray<IExpression>;
    I: integer;
  begin
    I := 1;
    NextToken; // '('
    if CurTokenIs(tkRParen) then
      Exit(Args);
    SetLength(Args, I);
    Args[I-1] := ParseExpression(LOWEST);
    while (not CurTokenIs(tkEof)) and (CurTokenIs(tkComma)) do
    begin
      NextToken; // ','
      Inc(I);
      SetLength(Args, I);
      Args[I-1] := ParseExpression(LOWEST);
    end;
    Match(tkRParen);
    Result := Args;
  end;
end.
