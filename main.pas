{$mode objfpc}{$H+}{$J-}{$modeswitch advancedrecords}
program main;
uses 
    token in 'token/token.pas',
    lexer in 'lexer/lexer.pas';
var
    Lexer2: TLexer;
    T: TToken;
begin
    Lexer2 := NewLexer('=+(){},;');
    T := Lexer2.NextToken();
    Writeln(T.Kind);
end.