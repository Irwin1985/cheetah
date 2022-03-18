unit token;

interface
  uses
    SysUtils, TypInfo, Generics.Collections;
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
      tkMinus,
      tkBang,
      tkAsterisk,
      tkSlash,

      tkLt,
      tkGt,

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
    function LookupIdent(ident:string):TTokenKind;

implementation
  var
    keywords: TDictionary<string, TTokenKind>;

  function TToken.ToString: string;
  begin
    Result := Format('Token(%s, ''%s'')', [GetEnumName(TypeInfo(TTokenKind), Ord(Kind)), Literal]);
  end;
  function LookupIdent(ident: string):TTokenKind;
  var
    tkValue: TTokenKind;
  begin
    if keywords.ContainsKey(ident) then
    begin
      keywords.TryGetValue(ident, tkValue);
      Result := tkValue;
    end
    else
      Result := tkIdent;
  end;

  initialization
    keywords := TDictionary<string, TTokenKind>.Create;
    keywords.Add('fn', tkFunction);
    keywords.Add('let', tkLet);

  finalization
    FreeAndNil(keywords);

end.
