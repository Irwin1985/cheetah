unit parser;

interface
  uses
    SysUtils,
    TypInfo,
    lexer,
    token,
    ast,
    Generics.Collections;

  const
    LOWEST      = 1;
    EQUALS      = 2; // ==
    LESSGREATER = 3; // > or <
    SUM         = 4; // +
    PRODUCT     = 5; // *
    PREFIX      = 6; // -X or !X
    CALL        = 7; // myFunction(X)

  type
    TPrefixParseFn  = reference to function: IExpression;
    TInfixParseFn   = reference to function(Left: IExpression):IExpression;
    TErrors         = array of string;
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
      function PeekTokenIs(Kind: TTokenKind): boolean;
      function CurPrecedence(Kind: TTokenKind): integer;
      procedure Match(kind: TTokenKind);
      procedure NewError(ErrorMsg: string);
      function ParseExpressionStatement: TExpressionStatement;
      function ParseExpression(Precedence: integer): IExpression;
      function ParseIdentifier: IExpression;
      function ParseIntegerLiteral: IExpression;
      function ParseBooleanExpression: IExpression;
      function ParsePrefixExpression: IExpression;
      function ParseInfixExpression(Left: IExpression): IExpression;
      function ParseGroupedExpression: IExpression;

      // Register procedures
      procedure RegisterPrefix(Kind: TTokenKind; Func: TPrefixParseFn);
      procedure RegisterInfix(Kind: TTokenKind; Func: TInfixParseFn);
    public
      function ParseProgram: TProgram;
      function GetErrors:TErrors;
    end;

  // create a new TParser
  function NewParser(Lex:TLexer):TParser;

implementation
  {Create a new Parser}
  function NewParser(Lex:TLexer):TParser;
  var
    Parser: TParser;
  begin
    Parser := TParser.Create;
    Parser.L := Lex;
    Parser.PrefixParseFns := TDictionary<TTokenKind, TPrefixParseFn>.Create;
    Parser.InfixParseFns := TDictionary<TTokenKind, TInfixParseFn>.Create;
    Parser.Precedences := TDictionary<TTokenKind, Integer>.Create;

    // Fill the token precedence
    Parser.Precedences.Add(tkEq, EQUALS);
    Parser.Precedences.Add(tkNotEq, EQUALS);
    Parser.Precedences.Add(tkLt, LESSGREATER);
    Parser.Precedences.Add(tkGt, LESSGREATER);
    Parser.Precedences.Add(tkPlus, SUM);
    Parser.Precedences.Add(tkMinus, SUM);
    Parser.Precedences.Add(tkSlash, PRODUCT);
    Parser.Precedences.Add(tkAsterisk, PRODUCT);

    // Read two tokens, so CurToken and PeekToken are both set
    Parser.NextToken;
    Parser.NextToken;

    // Register prefix functions
    Parser.RegisterPrefix(tkIdent, Parser.ParseIdentifier);
    Parser.RegisterPrefix(tkInt, Parser.ParseIntegerLiteral);
    Parser.RegisterPrefix(tkMinus, Parser.ParsePrefixExpression);
    Parser.RegisterPrefix(tkBang, Parser.ParsePrefixExpression);
    Parser.RegisterPrefix(tkTrue, Parser.ParseBooleanExpression);
    Parser.RegisterPrefix(tkFalse, Parser.ParseBooleanExpression);
    Parser.RegisterPrefix(tkLParen, Parser.ParseGroupedExpression);

    // Register infix functions
    Parser.RegisterInfix(tkPlus, Parser.ParseInfixExpression);
    Parser.RegisterInfix(tkMinus, Parser.ParseInfixExpression);
    Parser.RegisterInfix(tkSlash, Parser.ParseInfixExpression);
    Parser.RegisterInfix(tkAsterisk, Parser.ParseInfixExpression);
    Parser.RegisterInfix(tkEq, Parser.ParseInfixExpression);
    Parser.RegisterInfix(tkNotEq, Parser.ParseInfixExpression);
    Parser.RegisterInfix(tkLt, Parser.ParseInfixExpression);
    Parser.RegisterInfix(tkGt, Parser.ParseInfixExpression);

    Result := Parser;
  end;

  procedure TParser.NextToken;
  begin
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
        inc(ArrSize);
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
    Match(tkReturn);
    while CurToken.Kind <> tkSemicolon do
      NextToken;
    Result := Stmt;          
  end;

  function TParser.CurTokenIs(Kind: TTokenKind): boolean;
  begin
    Result := CurToken.Kind = Kind;
  end;

  function TParser.PeekTokenIs(Kind: TTokenKind): boolean;
  begin
    Result := PeekToken.Kind = Kind;
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
    Errors[Size] := ErrorMsg;
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
  var
    Ident: TIdentifier;
  begin
    Ident := TIdentifier.Create;
    Ident.Token := CurToken;
    Ident.Value := CurToken.Literal;
    NextToken;
    Result := Ident;
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

  function TParser.ParsePrefixExpression: IExpression;
  var
    Exp: TPrefixExpression;
    TokenPrecedence: integer;
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
end.
