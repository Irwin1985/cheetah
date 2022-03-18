unit token;

interface
  uses
    SysUtils, TypInfo;
  type
    TTokenKind = (
      tkIllegal,
      tkEof,

      // Identifiers + Literals
      tkIdent,    // add, foobar, x, y, ...
      tkInt,      // 1343456

      // Operators
      tkAssign,
      tkPlus,

      // Delimiters
      tkComma,
      tkSemicolon,

      tkLParen,
      tkRParen,
      tkLBrace,
      tkRBrace,

      // Keywords
      tkFunction,
      tkLet
      );
    TToken = record
      Kind: TTokenKind;
      Literal: string;
      function ToString: string;
    end;

implementation
  function TToken.ToString: string;
  begin
    Result := Format('Token(%s, ''%s'')', [GetEnumName(TypeInfo(TTokenKind), Ord(Kind)), Literal]);
  end;
end.
