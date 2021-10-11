unit Rf;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, Menus, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    rTitleBar : THandle;
    Center    : TPoint;
    CapY   : Integer;
    Circum    : Double;
    SB1       : TSpeedButton;
    RL, RR    : Double;
    procedure TitleBar(Act : Boolean);
    procedure WMNCHITTEST(var Msg: TWMNCHitTest);
      message WM_NCHITTEST;
    procedure WMNCACTIVATE(var Msg: TWMNCACTIVATE);
      message WM_NCACTIVATE;
    procedure WMSetText(var Msg: TWMSetText);
      message WM_SETTEXT;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

CONST
  TitlColors : ARRAY[Boolean] OF TColor =
    (clInactiveCaption, clActiveCaption);
  TxtColors : ARRAY[Boolean] OF TColor =
    (clInactiveCaptionText, clCaptionText);

procedure TForm1.FormCreate(Sender: TObject);
VAR
  rTemp, rTemp2    : THandle;
  Vertices : array [0..2] OF TPoint;
  X, Y     : INteger;
begin
  Caption := 'OOOH! Doughnuts!';
  BorderStyle := bsNone; {required}
  IF Width > Height THEN Width := Height
  ELSE Height := Width;  {harder to calc if width <> height}
  Center  := Point(Width DIV 2, Height DIV 2);
  CapY := GetSystemMetrics(SM_CYCAPTION)+8;
  rTemp := CreateEllipticRgn(0, 0, Width, Height);
  rTemp2 := CreateEllipticRgn((Width DIV 4), (Height DIV 4),
    3*(Width DIV 4), 3*(Height DIV 4));
  CombineRgn(rTemp, rTemp, rTemp2, RGN_DIFF);
  SetWindowRgn(Handle, rTemp, True);
  DeleteObject(rTemp2);
  rTitleBar  := CreateEllipticRgn(4, 4, Width-4, Height-4);
  rTemp := CreateEllipticRgn(CapY, CapY, Width-CapY, Height-CapY);
  CombineRgn(rTitleBar, rTitleBar, rTemp, RGN_DIFF);
  Vertices[0] := Point(0,0);
  Vertices[1] := Point(Width, 0);
  Vertices[2] := Point(Width DIV 2, Height DIV 2);
  rTemp := CreatePolygonRgn(Vertices, 3, ALTERNATE);
  CombineRgn(rTitleBar, rTitleBar, rTemp, RGN_AND);
  DeleteObject(rTemp);
  RL := ArcTan(Width / Height);
  RR := -RL + (22 / Center.X);
  X := Center.X-Round((Center.X-1-(CapY DIV 2))*Sin(RR));
  Y := Center.Y-Round((Center.Y-1-(CapY DIV 2))*Cos(RR));
  SB1 := TSpeedButton.Create(Self);
  WITH SB1 DO
    BEGIN
      Parent     := Self;
      Left       := X;
      Top        := Y;
      Width      := 14;
      Height     := 14;
      OnClick    := Button1Click;
      Caption    := 'X';
      Font.Style := [fsBold];
    END;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
End;

procedure TForm1.WMNCHITTEST(var Msg: TWMNCHitTest);
begin
  Inherited;
  WITH Msg DO
    WITH ScreenToClient(Point(XPos,YPos)) DO
      IF PtInRegion(rTitleBar, X, Y) AND
       (NOT PtInRect(SB1.BoundsRect, Point(X,Y))) THEN
        Result := htCaption;
end;

procedure TForm1.WMNCActivate(var Msg: TWMncActivate);
begin
  Inherited;
  TitleBar(Msg.Active);
end;

procedure TForm1.WMSetText(var Msg: TWMSetText);
begin
  Inherited;
  TitleBar(Active);
end;

procedure TForm1.TitleBar(Act: Boolean);
VAR
  TF      : TLogFont;
  R       : Double;
  N, X, Y : Integer;
begin
  IF Center.X = 0 THEN Exit;
  WITH Canvas DO
    begin
      Brush.Style := bsSolid;
      Brush.Color := TitlColors[Act];
      PaintRgn(Handle, rTitleBar);
      R  := RL;
      Brush.Color := TitlColors[Act];
      Font.Name := 'Arial';
      Font.Size := 12;
      Font.Color := TxtColors[Act];
      Font.Style := [fsBold];
      GetObject(Font.Handle, SizeOf(TLogFont), @TF);
      FOR N := 1 TO Length(Caption) DO
        BEGIN
          X := Center.X-Round((Center.X-6)*Sin(R));
          Y := Center.Y-Round((Center.Y-6)*Cos(R));
          TF.lfEscapement := Round(R * 1800 / pi);
          Font.Handle := CreateFontIndirect(TF);
          TextOut(X, Y, Caption[N]);
          R := R - (((TextWidth(Caption[N]))+2) / Center.X);
          IF R < RR THEN Break;
        END;
      Font.Name := 'MS Sans Serif';
      Font.Size := 8;
      Font.Color := clWindowText;
      Font.Style := [];
    end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  WITH Canvas DO
    BEGIN
      Pen.Color := clBlack;
      Brush.Style := bsClear;
      Pen.Width := 1;
      Pen.Color := clWhite;
      Arc(1, 1, Width-1, Height-1, Width, 0, 0, Height);
      Arc((Width DIV 4)-1, (Height DIV 4)-1,
        3*(Width DIV 4)+1, 3*(Height DIV 4)+1, 0, Height, Width, 0);
      Pen.Color := clBlack;
      Arc(1, 1, Width-1, Height-1, 0, Height, Width, 0);
      Arc((Width DIV 4)-1, (Height DIV 4)-1,
        3*(Width DIV 4)+1, 3*(Height DIV 4)+1, Width, 0, 0, Height);
      TitleBar(Active);
    END;
end;

end.
