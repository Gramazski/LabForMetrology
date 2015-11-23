unit MSUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan;

const Letters=['a'..'z','A'..'Z'];
const Digits=['0'..'9'];
const Operators=';';
const TextLine=['"',''''];
const Comments=['/','*'];
const Spaces=' ';
const KeyWords: array [1..5] of string=('if','else','while','do','for');
const ShortKeyWords=['i','e','w','d','f'];

type
  TBrackRec=Record
             BracketSum: integer;
             OpenFlag: boolean;
            end;
  //TCodeCondition=['MultilineComment','LineComment','WorkoingCode'];
 { TLexeme=Record
           Token: string;
           TokenClass: }
  TSetOfChar=set of char;
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
  CodeCondition: string;

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

 function SeparateFromLine(var CodeLine: string; const SetOfValidSymbols: TSetOfChar):string;
 var i: integer;
 begin
  i:=1;
  while (CodeLine[i] in SetOfValidSymbols) and (i<length(CodeLine)+1) do
   inc(i);
  result:=Copy(CodeLine,1,i-1);
 end;

 function GetLexeme(var CodeLine: string):string;
 begin
  case CodeLine[1] of
   'a'..'z','A'..'Z' : result:=SeparateFromLine(CodeLine,Letters+Digits);
   '0'..'9' : result:=SeparateFromLine(CodeLine,Digits);
   '/','*' : result:=SeparateFromLine(CodeLine,Comments);
  else
   result:=CodeLine[1];
  end;
  Delete(CodeLine,1,length(result));
 end;

 procedure ExecuteLexeme(var Lexeme,CodeLine: string; var TransformedCode: string);
 var ModifiedLexeme: char;

  function DefineTokenClass(var Token,CodeLine: string):char;

   function CompareWithKeyWords(var Token: string):boolean;
   var i: integer;
   begin
    result:=False;
    for i:=1 to 5 do
     if Token=KeyWords[i] then
      result:=True;
   end;

   procedure SetCommentCondition(var Token: string);
   begin
    if length(Token)>1 then
     case Token[2] of
      '*' : CodeCondition:='MultilineComment';
      '/' : CodeCondition:='LineComment';
     end
    else
     if (Token[1] in TextLine) then
      CodeCondition:='TextLine';
   end;

  begin
   result:='N';
   case Token[1] of
    'a'..'z','A'..'Z' : if CompareWithKeyWords(Token) then result:=Token[1];
    ';' : result:='S';
    '{' : result:='O';
    '}' : result:='C';
    '/','''','"' : SetCommentCondition(Token);
   end;
  end;

 begin
  ModifiedLexeme:=DefineTokenClass(Lexeme,CodeLine);
  if ModifiedLexeme<>'N' then
   TransformedCode:=TransformedCode+ModifiedLexeme;
 end;

 procedure ExecuteUnusebleCode(var CodeLine: string; const EndSymbol: string);
 var Lexeme: string;
     i: integer;
 begin
  i:=0;
  while i<length(CodeLine) do
  begin
   Lexeme:=GetLexeme(CodeLine);
   if (Lexeme=EndSymbol) then
   begin
    CodeCondition:='WorkingCode';
    i:=length(CodeLine);
   end;
  end;
 end;

 procedure ExecuteTransformedCode(var TransformedCode: string; var MaxIfIn,IfCount,OperatorsCount: integer);
 var CurrentPosition,IfIncludingCount: integer;
     IfIncluding: TBrackRec;

  procedure EndOfIncluding(var IfIncludind: TBrackRec; var IfIncludingCount,MaxIfIn: integer);
  begin
   if IfIncludingCount>MaxIfIn then
    MaxIfIn:=IfIncludingCount;
   IfIncluding.OpenFlag:=False;
   IfIncludingCount:=0;
  end;

 begin
  IfIncludingCount:=0;
  IfIncluding.OpenFlag:=False;
  IfIncluding.BracketSum:=0;
  CurrentPosition:=1;
  while CurrentPosition<length(TransformedCode)+1 do
  begin
    case TransformedCode[CurrentPosition] of
     'i' : begin
                if (IfIncluding.OpenFlag) then
                 inc(IfIncludingCount)
                else
                 IfIncluding.OpenFlag:=True;
                inc(IfCount);
                inc(OperatorsCount);
               end;
     'e' : begin
                if not(IfIncluding.OpenFlag) then
                 IfIncluding.OpenFlag:=True;
                inc(OperatorsCount);
               end;
     'w','d','f' : begin
                    inc(OperatorsCount);
                   end;
     'O' : if (IfIncluding.OpenFlag) then
            inc(IfIncluding.BracketSum);
     'C' : begin
            if (IfIncluding.OpenFlag) then
             dec(IfIncluding.BracketSum);
            if IfIncluding.BracketSum=0 then
             EndOfIncluding(IfIncluding,IfIncludingCount,MaxIfIn);
           end;
     'S' : begin
            if IfIncluding.BracketSum=0 then
             EndOfIncluding(IfIncluding,IfIncludingCount,MaxIfIn);
            inc(OperatorsCount);
           end;
    end;
   inc(CurrentPosition);
  end;
  EndOfIncluding(IfIncluding,IfIncludingCount,MaxIfIn);
 end;

 procedure DjilbMetrcs;
 var i,IfCount,CycleCount,OperatorsCount,MaxIfIn: integer;
     Condition: boolean;
     GenOperCount: extended;
     CodeLine,TransformedCode,Lexeme: string;
 begin
  Condition:=True;
  TransformedCode:='';
  IfCount:=0;
  OperatorsCount:=0;
  CycleCount:=0;
  MaxIfIn:=0;
  CodeCondition:='WorkingCode';
  for i:=0 to CodeMemo.Lines.Count do
  begin
   CodeLine:=CodeMemo.Lines.Strings[i];
   while length(CodeLine)>0 do
   begin
    if CodeCondition='WorkingCode' then
    begin
     Lexeme:=GetLexeme(CodeLine);
     ExecuteLexeme(Lexeme,CodeLine,TransformedCode);
    end
    else
    begin
     if CodeCondition='LineComment' then
     begin
      CodeCondition:='WorkingCode';
      Delete(CodeLine,1,length(CodeLine));
     end;
     if CodeCondition='TextLine' then
      ExecuteUnusebleCode(CodeLine,'"');
     if CodeCondition='MultilineComment' then
      ExecuteUnusebleCode(CodeLine,'*/');
    end;
   end;
  end;
  ExecuteTransformedCode(TransformedCode,MaxIfIn,IfCount,OperatorsCount);
  MaxIfInEdit.Text:=IntToStr(MaxIfIn);
  IfEdit.Text:=IntToStr(IfCount);
  CycleEdit.Text:=TransformedCode;
  if OperatorsCount<>0 then
  begin
   GenOperCount:=IfCount/OperatorsCount;
   SumEdit.Text:=FloatToStr(GenOperCount);
  end
  else
   SumEdit.Text:='0';
 end;

begin
 DjilbMetrcs();
end;

end.
