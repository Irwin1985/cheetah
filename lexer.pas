unit lexer;

interface

uses
  token;

type
  TLexer = record
    private
      Input: String;
      Position: Integer;
      ReadPosition: Integer;
      Ch: Char;
      procedure ReadChar;
      function NewToken(TokenKind: TTokenKind; Symbol: Char): TToken;
      function IsLetter(Letter:char):boolean;
      function ReadIdentifier:string;
      function ReadNumber:string;
      procedure SkipWhitespace;
      function IsSpace(c: char):boolean;
      function IsDigit(c: char):boolean;
    public
      function NextToken: TToken;
  end;
  function NewLexer(const i:string): TLexer;

implementation
  function NewLexer(const i:string): TLexer;
  var
      Lexer: TLexer;
  begin
    Lexer.Input := i;
    Lexer.Position := 0;
    Lexer.ReadPosition := 1;
    Lexer.ReadChar();
    Result := Lexer;
  end;

  procedure TLexer.ReadChar;
  begin
      if ReadPosition > Length(Input) then
          Ch := Chr(ord(0))
      else
          Ch := Input[ReadPosition];
      Position := ReadPosition;
      inc(ReadPosition);
  end;

  function TLexer.NextToken:TToken;
  var
      tok: TToken;
  begin
      SkipWhitespace;
      case Ch of
          '=': begin
              tok := NewToken(tkAssign, Ch);
          end;
          '+': begin
              tok := NewToken(tkPlus, Ch);
          end;
          '-': begin
              tok := NewToken(tkMinus, Ch);
          end;
          '!': begin
              tok := NewToken(tkBang, Ch);
          end;
          '/': begin
              tok := NewToken(tkSlash, Ch);
          end;
          '*': begin
              tok := NewToken(tkAsterisk, Ch);
          end;
          '<': begin
              tok := NewToken(tkLt, Ch);
          end;
          '>': begin
              tok := NewToken(tkGt, Ch);
          end;
          ';': begin
              tok := NewToken(tkSemiColon, Ch);
          end;
          ',': begin
              tok := NewToken(tkComma, Ch);
          end;
          '(': begin
              tok := NewToken(tkLParen, Ch);
          end;
          ')': begin
              tok := NewToken(tkRParen, Ch);
          end;
          '{': begin
              tok := NewToken(tkRBrace, Ch);
          end;
          '}': begin
              tok := NewToken(tkLBrace, Ch);
          end;
          #0: begin
              tok.Literal := '';
              tok.Kind := tkEof;
          end;
          else begin
              if IsLetter(Ch) then
              begin
                tok.Literal := ReadIdentifier;
                tok.Kind := LookupIdent(tok.Literal);
                Exit(tok);
              end
              else if IsDigit(Ch) then
              begin
                  tok.Kind := tkInt;
                  tok.Literal := ReadNumber;
                  Exit(tok);
              end
              else
                tok := NewToken(tkIllegal, Ch);
          end;
      end;
      ReadChar;
      Result := tok;
  end;

  function TLexer.NewToken(TokenKind: TTokenKind; Symbol: char): TToken;
  var
      T: TToken;
  begin
      T.Kind := TokenKind;
      T.Literal := String(Symbol);
      Result := T;
  end;

  function TLexer.IsLetter(Letter:char):boolean;
  begin
    Result := (('a' <= Letter) and (Letter >= 'z')) or (('A' <= Letter) and (Letter >= 'Z'));
  end;

  function TLexer.ReadIdentifier:string;
  var
    Pos: integer;
    Ident: String;
  begin
    Pos := Position;
    while (Ch <> #0) and (IsLetter(Ch)) do
    begin
      ReadChar;
    end;
    Ident := Copy(Input, Pos, Position-Pos);
    Result := Ident;
  end;

  function TLexer.ReadNumber: string;
  var
    Pos:Integer;
  begin
    Pos := Position;
    while (Ch <> #0) and (IsDigit(Ch)) do
      ReadChar;
    Result := Copy(Input, Pos, Position-Pos);
  end;

  procedure TLexer.SkipWhitespace;
  begin
    while (Ch <> #0) and (IsSpace(Ch)) do
      ReadChar;
  end;

  function TLexer.IsSpace(c: char):boolean;
  begin
    Result :=  (c = #9) or (c = #32) or (c = #10) or (c = #13);
  end;

  function TLexer.IsDigit(c: char):boolean;
  begin
    Result := (#48 <= c) and (c <= #57);
  end;
end.
