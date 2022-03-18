unit lexer;

interface

uses
  token;

type
  TLexer = record
    private
       Input: string;
       Position: Integer;
       ReadPosition: Integer;
       Ch: Char;
       procedure ReadChar;
       function NewToken(TokenKind: TTokenKind; Symbol: Char): TToken;
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
      case Ch of
          '=': begin
              tok := NewToken(tkAssign, Ch);
          end;
          ';': begin
              tok := NewToken(tkSemiColon, Ch);
          end;
          '(': begin
              tok := NewToken(tkLParen, Ch);
          end;
          ')': begin
              tok := NewToken(tkRParen, Ch);
          end;
          ',': begin
              tok := NewToken(tkComma, Ch);
          end;
          '+': begin
              tok := NewToken(tkPlus, Ch);
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
end.
