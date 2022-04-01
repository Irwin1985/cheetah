unit repl;

interface
  uses
    SysUtils,
    token,
    lexer,
    parser,
    ast,
    obj,
    evaluator,
    environment;
const
  PROMPT = '>>';
  procedure Start;
  procedure PrintErrors(Errors: TErrors);

implementation
  var
    MonkeyFace: TArray<string>;

  procedure Start;
  var
    Line: string;
    Lex: TLexer;
    Par: TParser;
    ASTProgram: TProgram;
    Evaluated: IObject;
    Env: TEnvironment;
  begin
    Env := TEnvironment.Create;
    while True do
    begin
      Write(PROMPT);
      Readln(Line);
      if Length(Line) = 0 then
          continue;
      try
        Lex := TLexer.Create(Line);
        Par := TParser.Create(Lex);
        ASTProgram := Par.ParseProgram();
        if Length(Par.GetErrors) > 0 then
          PrintErrors(Par.GetErrors);
        Evaluated := Eval(ASTProgram, Env);
        if Evaluated <> nil then
          Writeln(Evaluated.Inspect);

      finally
        FreeAndNil(Lex);
        FreeAndNil(Par);
      end;
    end;
    FreeAndNil(Env);
    FreeAndNil(ASTProgram);
  end;

  procedure PrintErrors(Errors: TErrors);
  var
    ErrorMsg: string;
    I: Integer;
  begin
    for I := Low(MonkeyFace) to High(MonkeyFace) do
      Writeln(MonkeyFace[I]);
    Writeln('Woops! We ran into some monkey business here!');
    Writeln('Parse errors:');
    for ErrorMsg in Errors do
      Writeln('ERROR: ' + ErrorMsg);
  end;

  initialization
    SetLength(MonkeyFace, 11);
    MonkeyFace[0]  := '            __,__';
    MonkeyFace[1]  := '   .--.  .-"     "-.  .--.';
    MonkeyFace[2]  := '  / .. \/  .-. .-.  \/ .. \';
    MonkeyFace[3]  := ' | |  ''|  /   Y   \  |''  | |';
    MonkeyFace[4]  := ' | \   \  \ 0 | 0 /  /   / |';
    MonkeyFace[5]  := '  \ ''- ,\.-"""""""-./, -'' /';
    MonkeyFace[6]  := '   ''''-'' /_   ^ ^   _\ ''-''''';
    MonkeyFace[7]  := '       |  \._   _./  |';
    MonkeyFace[8]  := '       \   \ ''~'' /   /';
    MonkeyFace[9]  := '        ''._ ''-=-'' _.''';
    MonkeyFace[10] := '           ''-----''';
end.
