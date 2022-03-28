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
      tkString,   // "foo", 'bar'

      // Operators
      tkAssign,
      tkPlus,
      tkMinus,
      tkBang,
      tkAsterisk,
      tkSlash,

      tkLt,
      tkGt,

      tkEq,
      tkNotEq,

      // Delimiters
      tkComma,
      tkSemicolon,

      tkLParen,
      tkRParen,
      tkLBrace,
      tkRBrace,

      // Keywords
      tkFunction,
      tkLet,
      tkTrue,
      tkFalse,
      tkNull,
      tkIf,
      tkElse,
      tkReturn
      );
    TToken = class
      Kind: TTokenKind;
      Literal: string;
      constructor Create(Kind: TTokenKind; Literal: string); overload;
      function Print: string;
    end;
    function LookupIdent(ident:string):TTokenKind;

implementation
  var
    keywords: TDictionary<string, TTokenKind>;
  constructor TToken.Create(Kind: TTokenKind; Literal: string);
  begin
    Self.Kind := Kind;
    Self.Literal := Literal;
  end;
  function TToken.Print: string;
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
    keywords.Add('true', tkTrue);
    keywords.Add('false', tkFalse);
    keywords.Add('null', tkNull);
    keywords.Add('if', tkIf);
    keywords.Add('else', tkElse);
    keywords.Add('return', tkReturn);

  finalization
    FreeAndNil(keywords);

end.
