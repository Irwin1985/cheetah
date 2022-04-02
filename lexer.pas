unit lexer;

interface

uses
  token;

type
  TLexer = class(TObject)
    private
      Input: String;
      Position: Integer;
      ReadPosition: Integer;
      Ch: Char;
      FTok : TToken;
      procedure ReadChar;
      function  PeekChar:char;
      function  NewToken(TokenKind: TTokenKind; Symbol: Char): TToken;
      function  IsLetter(Letter:char):boolean;
      function  ReadIdentifier:string;
      function  ReadNumber:string;
      function  ReadString:string;
      procedure SkipWhitespace;
      function  IsSpace(c: char):boolean;
      function  IsDigit(c: char):boolean;
    public
      constructor Create(const Input: string); overload;
      function NextToken: TToken;
  end;

implementation

  constructor TLexer.Create(const Input: string);
  begin
    Self.Input := Input;
    Self.Position := 0;
    Self.ReadPosition := 1;
    Self.ReadChar();
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

  function TLexer.PeekChar: Char;
  begin
    if ReadPosition > Length(Input) then
      Exit(#0);
    Result := Input[ReadPosition];
  end;
  
  function TLexer.NextToken:TToken;
  begin
      FTok := TToken.Create;
      SkipWhitespace;
      case Ch of
          '=': begin
            if PeekChar() = '=' then 
            begin
              ReadChar;
              FTok.Kind := tkEq;
              FTok.Literal := '==';
            end
            else
              FTok := NewToken(tkAssign, Ch);
          end;
          '+': begin
              FTok := NewToken(tkPlus, Ch);
          end;
          '-': begin
              FTok := NewToken(tkMinus, Ch);
          end;
          '!': begin
            if PeekChar() = '=' then
            begin
              ReadChar; // skip '!'
              FTok.Kind := tkNotEq;
              FTok.Literal := '!=';
            end
            else
              FTok := NewToken(tkBang, Ch);
          end;
          '/': begin
              FTok := NewToken(tkSlash, Ch);
          end;
          '*': begin
              FTok := NewToken(tkAsterisk, Ch);
          end;
          '<': begin
              FTok := NewToken(tkLt, Ch);
          end;
          '>': begin
              FTok := NewToken(tkGt, Ch);
          end;
          ';': begin
              FTok := NewToken(tkSemiColon, Ch);
          end;
          ',': begin
              FTok := NewToken(tkComma, Ch);
          end;
          '(': begin
              FTok := NewToken(tkLParen, Ch);
          end;
          ')': begin
              FTok := NewToken(tkRParen, Ch);
          end;
          '{': begin
              FTok := NewToken(tkLBrace, Ch);
          end;
          '}': begin
              FTok := NewToken(tkRBrace, Ch);
          end;
          '''', '"': begin // string support
            FTok.Kind := tkString;
            FTok.Literal := ReadString;
          end;
          #0: begin
              FTok.Literal := '';
              FTok.Kind := tkEof;
          end;
          else begin
              if IsLetter(Ch) then
              begin
                FTok.Literal := ReadIdentifier;
                FTok.Kind := LookupIdent(FTok.Literal);
                Exit(FTok);
              end
              else if IsDigit(Ch) then
              begin
                  FTok.Kind := tkInt;
                  FTok.Literal := ReadNumber;
                  Exit(FTok);
              end
              else
                FTok := NewToken(tkIllegal, Ch);
          end;
      end;
      ReadChar;
      Result := FTok;
  end;

  function TLexer.NewToken(TokenKind: TTokenKind; Symbol: char): TToken;
  begin
      Result := TToken.Create(TokenKind, String(Symbol));
  end;

  function TLexer.IsLetter(Letter:char):boolean;
  begin
    Result := Letter in ['a'..'z', 'A'..'Z', '_'];
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

  function TLexer.ReadString: string;
  var
    DelimStr: char;
    PosIni: integer;
  begin
    DelimStr := Ch;
    ReadChar; // skip string delimiter
    PosIni := Position;
    // TODO: add support for escaping characters.
    // also check for unterminated strings.
    while (Ch <> #0) and (Ch <> DelimStr) do
      ReadChar;
    Result := Copy(Input, PosIni, Position-PosIni);
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
