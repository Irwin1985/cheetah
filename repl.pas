unit repl;

interface
  uses
    SysUtils, token, lexer, parser, ast;
const
  PROMPT = '>>';
  procedure Start;
  procedure PrintErrors(Errors: TErrors);

implementation
  procedure Start;
  var
    Line: string;
    Lex: TLexer;
    Par: TParser;
    ASTProgram: TProgram;
  begin
    while True do
    begin
      Write(PROMPT);
      Readln(Line);
      if Length(Line) = 0 then
          continue;
      try
        Lex := NewLexer(Line);
        Par := NewParser(Lex);
        ASTProgram := Par.ParseProgram();
        if Length(Par.GetErrors) > 0 then
          PrintErrors(Par.GetErrors);
        Writeln(ASTProgram.ToString);
      finally
        FreeAndNil(ASTProgram);
      end;
    end;
  end;
  procedure PrintErrors(Errors: TErrors);
  var
    ErrorMsg: string;
  begin
    for ErrorMsg in Errors do
      Writeln('ERROR: ' + ErrorMsg);
  end;
end.
