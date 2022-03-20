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

      {Private functions}
      procedure NextToken;
      function ParseStatement:IStatement;
      function ParseLetStatement:TLetStatement;
      function ParseReturnStatement:TReturnStatement;
      function CurTokenIs(Kind: TTokenKind): boolean;
      function PeekTokenIs(Kind: TTokenKind): boolean;
      procedure Match(kind: TTokenKind);
      procedure NewError(ErrorMsg: string);
      function ParseExpressionStatement: TExpressionStatement;
      function ParseExpression(Precedence: integer): IExpression;
      function ParseIdentifier: IExpression;
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

    // Read two tokens, so CurToken and PeekToken are both set
    Parser.NextToken;
    Parser.NextToken;

    // Register parsing functions
    Parser.RegisterPrefix(tkIdent, Parser.ParseIdentifier);

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
    ASTProgram := TProgram.Create;
    while CurToken.Kind <> tkEof do
    begin
      ArrSize := 0;
      Stmt := ParseStatement;
      if Stmt <> nil then
      begin
        inc(ArrSize);
        SetLength(ASTProgram.Statements, ArrSize);
        ASTProgram.Statements[ArrSize-1] := Stmt;
      end;
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
  begin
    PrefixParseFns.TryGetValue(CurToken.Kind, Prefix);
    LeftExp := Prefix;

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
end.
