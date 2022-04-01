unit environment;

interface
  uses
    SysUtils,
    Generics.Collections,
    obj;

  type
    TEnvironment = class
      private
        Store: TDictionary<string, IObject>;
      public
        constructor Create;
        function GetObj(Name: string; out Found:boolean): IObject;
        function SetObj(Name: string; Val: IObject): IObject;
    end;
implementation
  constructor TEnvironment.Create;
  begin
    inherited Create;
    Store := TDictionary<string, IObject>.Create;
  end;
  function TEnvironment.GetObj(Name: string; out Found:boolean): IObject;
  var
    Obj: IObject;
  begin
    Found := false; // falso por defecto
    if Store.ContainsKey(Name) then
    begin
      Found := true;
      Store.TryGetValue(Name, Obj);
    end
    else
      Obj := nil;

    Result := Obj;
  end;
  function TEnvironment.SetObj(Name: string; Val: IObject): IObject;
  begin
    Store.Add(Name, Val);
    Result := Val;
  end;
end.
