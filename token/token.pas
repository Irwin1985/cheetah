{$mode objfpc}{$H+}{$J-}
unit token;
interface    
    procedure SayHello(const who: String);
implementation
    procedure SayHello(const who: String);
    begin
      Writeln('Hola ' + who);
    end;
end.