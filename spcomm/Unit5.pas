unit Unit5;

interface
uses SysUtils,Windows, Messages, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SPComm, ExtCtrls, Buttons, ComCtrls,IniFiles,IdStream,
  Menus,Registry, JvHidControllerClass, IdBaseComponent, IdComponent,
  IdTCPServer, IdTCPConnection, IdTCPClient, Mask, winsock, IdIPWatch,
  IdAntiFreezeBase, IdAntiFreeze, CheckLst, Sockets, DB, DBClient,
  MConnect, SConnect, IdThread, IdHTTP, wininet, WinSkinData,Unit2,Unit3, Unit1;
type
  THashOutArray = array[0..31] of byte;
  T2longwordArray = array[0..1] of LongWord;

  procedure SHA256Init();
  procedure SHA256Update(datain:array of Byte; datalen : LongWord);
  function SHA256Final():THashOutArray;

const
    K: array[0..64-1] of LongWord = (
        $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5,
        $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
        $d807aa98, $12835b01, $243185be, $550c7dc3,
        $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174,
        $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc,
        $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
        $983e5152, $a831c66d, $b00327c8, $bf597fc7,
        $c6e00bf3, $d5a79147, $06ca6351, $14292967,
        $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13,
        $650a7354, $766a0abb, $81c2c92e, $92722c85,
        $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3,
        $d192e819, $d6990624, $f40e3585, $106aa070,
        $19a4c116, $1e376c08, $2748774c, $34b0bcb5,
        $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3,
        $748f82ee, $78a5636f, $84c87814, $8cc70208,
        $90befffa, $a4506ceb, $bef9a3f7, $c67178f2
      );

    padding : array [0..64-1] of Byte = (
       $80, $00, $00, $00, $00, $00, $00, $00,
       $00, $00, $00, $00, $00, $00, $00, $00,
       $00, $00, $00, $00, $00, $00, $00, $00,
       $00, $00, $00, $00, $00, $00, $00, $00,
       $00, $00, $00, $00, $00, $00, $00, $00,
       $00, $00, $00, $00, $00, $00, $00, $00,
       $00, $00, $00, $00, $00, $00, $00, $00,
       $00, $00, $00, $00, $00, $00, $00, $00
      );
implementation
var
  global_buf:array[0..63] of Byte;
  global_hash:array[0..7] of LongWord;
  global_totallen : UInt64;
  global_bufferlength:LongWord;


function ROTL(x,n:longword):longword;
  function myshl(m,k:longword):longword;
  begin
      Result := (((m) and $FFFFFFFF) shl k)
  end;
var
  a,b:longword;
begin
    a := 0;
    b := 0;
    a := myshl(x,n);
    b := (x) shr (32 - n);
    Result := a or b;
end;

function ROTR(x,n:longword):longword;
  function myshr(m,k:longword):longword;
  begin
      Result := (((m) and $FFFFFFFF) shr k)
  end;
var
  a,b:longword;
begin
    a := 0;
    b := 0;
    a := myshr(x,n);
    b := (x) shl (32 - n);
    Result := a or b;
end;

function Ch(x, y, z: LongWord):LongWord;
begin
    Result := ((z) xor ((x) and ((y) xor (z))));
end;

function Maj(x, y, z: LongWord):LongWord;
begin
    Result := (((x) and ((y) or (z))) or ((y) and (z)));
end;

function SIGMA0(x:LongWord):LongWord;
var
  a,b,c:LongWord;
begin
    a := ROTR(x, 2);
    b := ROTR(x, 13);
    C := ROTR(x, 22);
    Result := a xor b xor c;
end;

function SIGMA1(x:LongWord):LongWord;
var
  a,b,c:LongWord;
begin
    a := ROTR(x, 6);
    b := ROTR(x, 11);
    C := ROTR(x, 25);
    Result := a xor b xor c;
end;

function SIGMA2(x:LongWord):LongWord;
var
  a,b,c:LongWord;
begin
    a := ROTR(x, 7);
    b := ROTR(x, 18);
    C := x shr 3;
    Result := a xor b xor c;
end;

function SIGMA3(x:LongWord):LongWord;
var
  a,b,c:LongWord;
begin
    a := ROTR(x, 17);
    b := ROTR(x, 19);
    C := x shr 10;
    Result := a xor b xor c;
end;

function BYTESWAP(x:LongWord):LongWord;
var
    a,b:LongWord;
begin
    a := ROTR(x, 8) and $ff00ff00;
    b := ROTL(x, 8) and $00ff00ff;
    Result := a or b;
end;

function BYTESWAP64(x:UINT64):T2longwordArray;
var
  a, b : LongWord;
begin
    a := x shr 32;
    b := LongWord(x);

    //Result := (uint64(BYTESWAP(b)) shl 32 ) or (uint64(BYTESWAP(a)));
    result[0] := BYTESWAP(b);
    Result[1] := BYTESWAP(a);
end;

procedure SHA256Init();
begin
  global_totallen := 0;
  global_hash[0] := $6a09e667;
  global_hash[1] := $bb67ae85;
  global_hash[2] := $3c6ef372;
  global_hash[3] := $a54ff53a;
  global_hash[4] := $510e527f;
  global_hash[5] := $9b05688c;
  global_hash[6] := $1f83d9ab;
  global_hash[7] := $5be0cd19;
  global_bufferlength := 0;
end;

procedure SHA256Guts(cbuf:array of LongWord);
var
  tmp, i : LongWord;
  W:array[0..63] of LongWord;
  W16:Pointer;
  a,b,c,d,e,f,g,h,t1,t2:LongWord;
begin
    for i := 0 to 15 do
    begin
        tmp := cbuf[i];
        W[i] := BYTESWAP(tmp);
    end;

    for i:=0 to 47 do
    begin
        W[16+i] := SIGMA3(W[14+i]) + W[9+i] + SIGMA2(W[1+i]) + W[0+i];
    end;

    a := global_hash[0];
    b := global_hash[1];
    c := global_hash[2];
    d := global_hash[3];
    e := global_hash[4];
    f := global_hash[5];
    g := global_hash[6];
    h := global_hash[7];

    for i:=0 to 63 do
    begin
        t1 := h + SIGMA1(e) + Ch(e,f,g) + K[i] + W[i];
        t2 := SIGMA0(a) + Maj(a, b, c);
        h := g;
        g := f;
        f := e;
        e := d + t1;
        d := c;
        c := b;
        b := a;
        a := t1 + t2;
    end;

     global_hash[0] :=  global_hash[0] + a;
     global_hash[1] :=  global_hash[1] + b;
     global_hash[2] :=  global_hash[2] + c;
     global_hash[3] :=  global_hash[3] + d;
     global_hash[4] :=  global_hash[4] + e;
     global_hash[5] :=  global_hash[5] + f;
     global_hash[6] :=  global_hash[6] + g;
     global_hash[7] :=  global_hash[7] + h;
end;

procedure SHA256Update(datain:array of Byte; datalen : LongWord);
var
    bufferBytesLeft, bytesToCopy, finish_len, i, needBurn: LongWord;
    buftmp:array[0..63] of LongWord;
    resultstr:string;
begin
    finish_len := 0;
    needBurn := 0;

    while (datalen > 0) do
    begin
        bufferBytesLeft := 64 - global_bufferLength;

        bytesToCopy := bufferBytesLeft;

        if bytesToCopy > datalen then
            bytesToCopy := datalen;

        for i := 0 to bytestocopy-1 do
        begin
            global_buf[global_bufferlength+i] := datain[i+finish_len];
        end;
        global_totallen := global_totallen + bytesToCopy * 8;
        finish_len := finish_len + bytesToCopy;
        global_bufferlength := global_bufferlength + bytesToCopy;

        datalen:= datalen - bytesToCopy;

        if global_bufferlength = 64 then
        begin
            for i:= 0 to 15 do
            begin
                buftmp[i] := (global_buf[i*4]) or (global_buf[i*4+1] shl 8) or
                              (global_buf[i*4+2] shl 16) or (global_buf[i*4+3] shl 24);

                //resultstr := resultstr + inttohex(buftmp[i], 8)+ ' ';
            end;
            //form1.memo1.lines.add('buftmp: '+resultstr);

            SHA256Guts((buftmp));
            global_bufferlength := 0;
            NEEDbURN := 1;
        end;
    end;

    if needBurn = 1 then
        Exit;
end;

function SHA256Final():THashOutArray;
var
  bytesToPad:LongWord;
  lengthPad:T2longwordArray;
  i:LongWord;
  lentmp:array [0..63] of Byte;
  hashout:array [0..63] of LongWord;
begin
    bytesToPad := 120 - global_bufferLength;
    if (bytesToPad > 64) then
        bytesToPad := bytesToPad-64;

    //form1.memo1.lines.add('global_totalLen: ' + IntToStr(global_totalLen));
    lengthPad := BYTESWAP64(global_totalLen);
    //form1.memo1.lines.add('lengthPad: $' + IntToHex(lengthPad[0], 8) +' '+ IntToHex(lengthPad[1], 8));
    for i := 0 to 7 do
    begin
        lentmp[i] := lengthPad[1 - i div 4] shr ((i mod 4)*8);
        //form1.memo1.lines.add('lentmp['+inttostr(i)+']=' + IntTohex(lentmp[i], 2));
    end;
    SHA256Update (padding, bytesToPad);
    SHA256Update (lentmp, 8);

    for i:= 0 to 7 do
    begin
        Result[i*4] := (global_hash[i] shr 24) and $000000FF;
        Result[i*4+1] := ((global_hash[i]) shr 16) and $000000FF;
        Result[i*4+2] := ((global_hash[i]) shr 8) and $000000FF;
        Result[i*4+3] := ((global_hash[i])) and $000000FF;
    end;
end;




end.
