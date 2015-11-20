unit DjilbMetricsUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
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
    procedure FormShow(Sender: TObject);
    procedure DoneButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
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

procedure TForm1.DoneButtonClick(Sender: TObject);

 function NotEndOfLine(const EndPart,CodeLine: string; var CurrentPosInLine: integer):boolean;
 var k: integer;
 begin
  result:=False;
  for k:=1 to length(EndPart) do
   if CodeLine[CurrentPosInLine+k-1]<>EndPart[k] then
    result:=True;
 end;

 procedure UselessExect(const EndPart,CodeLine: string; var CurrentPosInLine: integer; var Condition: boolean);
 begin
  while (CurrentPosInLine<length(CodeLine)-length(EndPart)+1) and (NotEndOfLine(EndPart,CodeLine,CurrentPosInLine)) do
   inc(CurrentPosInLine);
  if not(NotEndOfLine(EndPart,CodeLine,CurrentPosInLine)) then
  begin
   CurrentPosInLine:=CurrentPosInLine+length(EndPart)-1;
   Condition:=True;
  end
  else
   CurrentPosInLine:=length(CodeLine);
 end;

 function CheckLet(const CodeLine: string; var CurrentPosInLine: integer): boolean;
 begin
  result:=False;
  case CodeLine[CurrentPosInLine] of
   '''' : begin
           inc(CurrentPosInLine);
           UselessExect('''',CodeLine,CurrentPosInLine,result);
          end;
   '"'  : begin
           inc(CurrentPosInLine);
           UselessExect('"',CodeLine,CurrentPosInLine,result);
          end;
   '/'  : if CodeLine[CurrentPosInLine+1]='*' then
           begin
            inc(CurrentPosInLine);
            UselessExect('*/',CodeLine,CurrentPosInLine,result);
           end
           else
            if CodeLine[CurrentPosInLine+1]='/' then
            begin
             result:=True;
             CurrentPosInLine:=length(CodeLine);
            end;
  else
   result:=True;
  end;
 end;

 procedure ExectCodeLine(var Condition: boolean; var OperCount,IfCount,CycleCount: integer; const CodeLine: string; var Bracket: TBrackRec);
 var i: integer;
     Lexeme: string;

  function UpLet(const Let: char): char;
  var k: integer;
  begin
   result:=Let;
   if ord(result) in [92..122] then
      for k:=1 to 32 do
       dec(result);
  end;

 begin
  i:=1;
  while i<length(CodeLine)+1 do
  begin
   if Condition then
   begin
    Lexeme:='';
    while (CodeLine[i] in ['a'..'z','A'..'Z']) and (i<length(CodeLine)+1) do
    begin
     Lexeme:=Lexeme+UpLet(CodeLine[i]);
     inc(i);
    end;
    if (CodeLine[i]=' ') and (Lexeme='IF') then
    begin
     if not(Bracket.OpenFlag) then
      Bracket.OpenFlag:=True;
     inc(IfCount);
    end
    else
     if ((Lexeme='FOR') and ((CodeLine[i]='(') or (CodeLine[i]=' '))) or ((Lexeme='WHILE') and ((CodeLine[i]=' ') or (CodeLine[i]='('))) then
       inc(CycleCount)
     else
      if CodeLine[i]=';' then
      begin
       if Bracket.BracketNum=0 then
        Bracket.OpenFlag:=False;
       inc(OperCount);
      end;
    if Bracket.OpenFlag then
     case CodeLine[i] of
      '{' : inc(Bracket.BracketNum);
      '}' : dec(Bracket.BracketNum);
     end;
    Condition:=CheckLet(CodeLine,i);
   end
   else
    UselessExect('*/',CodeLine,i,Condition);
   inc(i);
  end;
 end;

 procedure DjilbMetrcs;
 var i,IfCount,CycleCount,OperCount,MaxIfIn: integer;
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
  for i:=0 to CodeMemo.Lines.Count do
  begin
   ExectCodeLine(Condition,OperCount,IfCount,CycleCount,CodeMemo.Lines.Strings[i],Bracket);
   if Bracket.BracketNum>MaxIfIn then
    MaxIfIn:=Bracket.BracketNum;
  end;
  MaxIfInEdit.Text:=IntToStr(MaxIfIn);
  IfEdit.Text:=IntToStr(IfCount);
  CycleEdit.Text:=IntToStr(CycleCount);
  if (IfCount+CycleCount+OperCount)<>0 then
  begin
   GenOperCount:=Ifcount/(IfCount+CycleCount+OperCount);
   SumEdit.Text:=FloatToStr(GenOperCount);
  end
  else
   SumEdit.Text:='0';
 end;

begin
 DjilbMetrcs();
end;

end.
