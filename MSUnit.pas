unit MSUnit;

interface
 
uses
  Windows, Messages, SysUtils, 

Variants, Classes, Graphics, 

Controls, Forms,
  Dialogs, StdCtrls, XPMan;

type
  TBrackRec=Record
             BracketNum: integer;
             OpenFlag: boolean;
            end;
  TForm1 = class(TForm)
    CodeMemo: TMemo;
    IfEdit: TEdit;
    DoneButton: TButton;
    CycleEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SumEdit: TEdit;
    Label3: TLabel;
    XPManifest1: TXPManifest;
    MaxIfInEdit: TEdit;
    Label4: TLabel;
    procedure FormShow(Sender: 

TObject);
    procedure DoneButtonClick

(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: 

TObject);
var F: TextFile;
    S: string;
    i: integer;

begin
 assignfile(F,'D:\MS\codef.txt');
 Reset(F);
 i:=0;
 while not(EOF(F)) do
 begin
  Readln(F,S);
  CodeMemo.Lines.Strings[i]:=S;
  inc(i);
 end;
 CloseFile(F);
end;

procedure TForm1.DoneButtonClick

(Sender: TObject);
var IfCount, CycleCount,i,j,k: 

integer;
    S: string;
    L: char;
    Flag: boolean;

 function NotEnd(const 

EndPart,Str: string; var TempPos: 

integer):boolean;
 var k: integer;
 begin
  result:=False;
  for k:=1 to length(EndPart) do
   if Str[TempPos+k-1]<>EndPart[k] 

then
    result:=True;
 end;

 procedure UselessExect(const 

EndPart,Str: string; var TempPos: 

integer; var Condition: boolean);
 begin
  while (TempPos<length(Str)-

length(EndPart)+1) and (NotEnd

(EndPart,Str,TempPos)) do
   inc(TempPos);
  if not(NotEnd

(EndPart,Str,TempPos)) then
  begin
   TempPos:=TempPos+length

(EndPart)-1;
   Condition:=True;
  end
  else
   TempPos:=length(Str);
 end;

 function CheckLet(const Str: 

string; var TempPos: integer): 

boolean;
 begin
  result:=False;
  case Str[TempPos] of
   '''' : begin
           inc(TempPos);
           UselessExect

('''',Str,TempPos,result);
          end;
   '"'  : begin
           inc(TempPos);
           UselessExect

('"',Str,TempPos,result);
          end;
   '/'  : if Str[TempPos+1]='*' 

then
           begin
            inc(TempPos);
            UselessExect

('*/',Str,TempPos,result);
           end
           else
            if Str[TempPos+1]='/' 

then
            begin
             result:=True;
             TempPos:=length(Str);
            end;
  else
   result:=True;
  end;
 end;

 procedure ExectStr(var Condition: 

boolean; var 

OperCount,IfCount,CycleCount: 

integer; const Str: string; var 

Bracket: TBrackRec);
 var i: integer;
     Lex: string;

  function UpLet(const Let: char): 

char;
  var k: integer;
  begin
   result:=Let;
   if ord(result) in [92..122] 

then
      for k:=1 to 32 do
       dec(result);
  end;

 begin
  i:=1;
  while i<length(Str)+1 do
  begin
   if Condition then
   begin
    Lex:='';
    while (Str[i] in 

['a'..'z','A'..'Z']) and 

(i<length(Str)+1) do
    begin
     Lex:=Lex+UpLet(Str[i]);
     inc(i);
    end;
    if (Str[i]=' ') and (Lex='IF') 

then
    begin
     if not(Bracket.OpenFlag) then
      Bracket.OpenFlag:=True;
     inc(IfCount);
    end
    else
     if ((Lex='FOR') and ((Str[i]

='(') or (Str[i]=' '))) or 

((Lex='WHILE') and ((Str[i]=' ') 

or (Str[i]='('))) then
       inc(CycleCount)
     else
      if Str[i]=';' then
      begin
       if Bracket.BracketNum=0 

then
        Bracket.OpenFlag:=False;
       inc(OperCount);
      end;
    if (Str[i]='{') and 

(Bracket.OpenFlag) then
     inc(Bracket.BracketNum);
    if (Str[i]='}') and 

(Bracket.OpenFlag) then
     dec(Bracket.BracketNum);
    Condition:=CheckLet(Str,i);
   end
   else
    UselessExect

('*/',Str,i,Condition);
   inc(i);
  end;
 end;

 procedure DjilbMetr;
 var 

i,IfCount,CycleCount,OperCount,Max

IfIn: integer;
     Condition: boolean;
     GenOperCount: extended;
     Bracket: TBrackRec;
 begin
  Condition:=True;
  IfCount:=0;
  OperCount:=0;
  CycleCount:=0;
  Bracket.BracketNum:=0;
  Bracket.OpenFlag:=False;
  MaxIfIn:=0;
  for i:=0 to CodeMemo.Lines.Count 

do
  begin
   ExectStr

(Condition,OperCount,IfCount,Cycle

Count,CodeMemo.Lines.Strings

[i],Bracket);
   if Bracket.BracketNum>MaxIfIn 

then
    MaxIfIn:=Bracket.BracketNum;
  end;  
  MaxIfInEdit.Text:=IntToStr

(MaxIfIn);
  IfEdit.Text:=IntToStr(IfCount);
  CycleEdit.Text:=IntToStr

(CycleCount);
  if (IfCount+CycleCount

+OperCount)<>0 then
  begin
   GenOperCount:=Ifcount/(IfCount

+CycleCount+OperCount);
   SumEdit.Text:=FloatToStr

(GenOperCount);
  end
  else
   SumEdit.Text:='0';
 end;

begin
 DjilbMetr();
end;

end.
