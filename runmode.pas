//Run Mode 0.9 by Savage

{LIBDB}
// =====================================
//          C O N S T A N T S
// =====================================
{ Database plugins enumeration
  for the DB_Open() function   }
Const DB_Plugin_ODBC       = 1;
Const DB_Plugin_SQLite     = 2;
Const DB_Plugin_PostgreSQL = 3;

{ Database column types enumeration 
  for the DB_ColumnType() function  }
Const DB_Type_Double = 1;
Const DB_Type_Float  = 2;
Const DB_Type_Long   = 3;
Const DB_Type_String = 4;

// =====================================
//        D E C L A R A T I O N S
// =====================================
Procedure DB_Close(DatabaseID: Integer);
External 'DB_Close@libdb-0.2.so cdecl';

Function DB_ColumnName(DatabaseID, Column: Integer): PChar;
External 'DB_ColumnName@libdb-0.2.so cdecl';

Function DB_ColumnSize(DatabaseID, Column: Integer): Integer;
External 'DB_ColumnSize@libdb-0.2.so cdecl';

Function DB_ColumnType(DatabaseID, Column: Integer): Integer;
External 'DB_ColumnType@libdb-0.2.so cdecl';

Function DB_Columns(DatabaseID: Integer): Integer;
External 'DB_Columns@libdb-0.2.so cdecl';

Function DB_Error(): PChar;
External 'DB_Error@libdb-0.2.so cdecl';

Function DB_Query(DatabaseID: Integer; Query: PChar): Integer;
External 'DB_Query@libdb-0.2.so cdecl';

Function DB_Update(DatabaseID: Integer; Query: PChar): Integer;
External 'DB_Update@libdb-0.2.so cdecl';

Procedure DB_FinishQuery(DatabaseID: Integer);
External 'DB_FinishQuery@libdb-0.2.so cdecl';

Function DB_FirstRow(DatabaseID: Integer): Integer;
External 'DB_FirstRow@libdb-0.2.so cdecl';

Function DB_GetDouble(DatabaseID, Column: Integer): Double;
External 'DB_GetDouble@libdb-0.2.so cdecl';

Function DB_GetFloat(DatabaseID, Column: Integer): Single;
External 'DB_GetFloat@libdb-0.2.so cdecl';

Function DB_GetLong(DatabaseID, Column: Integer): LongInt;
External 'DB_GetLong@libdb-0.2.so cdecl';

Function DB_GetString(DatabaseID, Column: Integer): PChar;
External 'DB_GetString@libdb-0.2.so cdecl';

Function DB_IsDatabase(DatabaseID: Integer): Integer;
External 'DB_IsDatabase@libdb-0.2.so cdecl';

Function DB_NextRow(DatabaseID: Integer): Integer;
External 'DB_NextRow@libdb-0.2.so cdecl';

Function DB_Open(DatabaseID: Integer; DatabaseName, User, Password: PChar; Plugin: Integer): Integer;
External 'DB_Open@libdb-0.2.so cdecl';

Function DB_ExamineDrivers(): Integer;
External 'DB_ExamineDrivers@libdb-0.2.so cdecl';

Function DB_NextDriver(): Integer;
External 'DB_NextDriver@libdb-0.2.so cdecl';

Function DB_DriverDescription(): PChar;
External 'DB_DriverDescription@libdb-0.2.so cdecl';

Function DB_DriverName(): PChar;
External 'DB_DriverName@libdb-0.2.so cdecl';

Function DB_GetVersion(): Integer;
External 'DB_GetVersion@libdb-0.2.so cdecl';
	
const
	DB_ID = 1;
	DB_NAME = 'runmode.db';
	COLOR_1 = $6495ed;
	COLOR_2 = $F0E68C;
	
type tCheckPoint = Record
	X, Y: Single;
end;
	
var
	_CheckPoint: array of tCheckPoint;
	_Laps: Byte;
	_LapsPassed, _CheckPointPassed: array[1..32] of Byte;
	_Timer: array[1..32] of TDateTime;
	_ShowTimer, _RKill, _LoggedIn: array[1..32] of Boolean;
	_EliteList: TStringList;
	
function EscapeApostrophe(Source: String): String;
begin
	Result := ReplaceRegExpr('''', Source, '''''', FALSE);
end;

function GetPiece(Source, Delimiter: String; Number: Byte): String;
var
	TempStrL: TStringList;
begin
	Try
		TempStrL := File.CreateStringList;
		SplitRegExpr(Delimiter, Source, TempStrL);
		Result := TempStrL[Number];
	Except
		Result := '';
	Finally
		TempStrL.Free;
	end;
end;

procedure RecountAllStats;
var
	PosCounter: Integer;
	MapName: String;
begin
	if DB_Update(DB_ID, 'UPDATE Accounts SET Gold = 0, Silver = 0, Bronze = 0, NoMedal = 0, Points = 0;') = 0 then
		WriteLn('Error: '+DB_Error);
	
	if DB_Query(DB_ID, 'SELECT Account, Map FROM Scores ORDER BY Map, Time, Date;') = 0 then
		WriteLn('Error: '+DB_Error)
	else begin
		DB_Update(DB_ID, 'BEGIN TRANSACTION;');
		While DB_NextRow(DB_ID) <> 0 Do begin
			
			if MapName <> String(DB_GetString(DB_ID, 1)) then begin
				MapName := DB_GetString(DB_ID, 1);
				PosCounter := 0;
			end;
			
			Inc(PosCounter, 1);
			
			if PosCounter = 1 then
				if DB_Update(DB_ID, 'UPDATE Accounts SET Gold = Gold + 1, Points = Points + 12 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') = 0 then
					WriteLn('Error: '+DB_Error);
			
			if PosCounter = 2 then
				if DB_Update(DB_ID, 'UPDATE Accounts SET Silver = Silver + 1, Points = Points + 6 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') = 0 then
					WriteLn('Error: '+DB_Error);
			
			if PosCounter = 3 then
				if DB_Update(DB_ID, 'UPDATE Accounts SET Bronze = Bronze + 1, Points = Points + 3 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') = 0 then
					WriteLn('Error: '+DB_Error);
			
			if PosCounter > 3 then
				if DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 1 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') = 0 then
					WriteLn('Error: '+DB_Error);
					
		end;
		DB_Update(DB_ID, 'COMMIT;');
	end;
		
	DB_FinishQuery(DB_ID);
end;

procedure GenerateEliteList;
var
	i, j, TempNumber: Integer;
	TempTable: array[0..6] of TStringList;
	TempString: String;
begin
	_EliteList.Clear;
	
	for i := 0 to 6 do
		TempTable[i] := File.CreateStringList;
	
	TempTable[0].Append('|Position');
	TempTable[0].Append('|');
	TempTable[1].Append('|Name');
	TempTable[1].Append('');
	TempTable[2].Append('|Gold');
	TempTable[2].Append('');
	TempTable[3].Append('|Silver');
	TempTable[3].Append('');
	TempTable[4].Append('|Bronze');
	TempTable[4].Append('');
	TempTable[5].Append('|NoMedal');
	TempTable[5].Append('');
	TempTable[6].Append('|Points');
	TempTable[6].Append('');
	
	if DB_Query(DB_ID, 'SELECT Name, Gold, Silver, Bronze, NoMedal, Points FROM Accounts ORDER BY Points DESC LIMIT 20;') = 0 then
		WriteLn('Error: '+DB_Error)
	else
		While DB_NextRow(DB_ID) <> 0 Do Begin
			Inc(TempNumber, 1);
			
			TempTable[0].Append('|'+IntToStr(TempNumber));
			TempTable[1].Append('|'+DB_GetString(DB_ID, 0));
			TempTable[2].Append('|'+DB_GetString(DB_ID, 1));
			TempTable[3].Append('|'+DB_GetString(DB_ID, 2));
			TempTable[4].Append('|'+DB_GetString(DB_ID, 3));
			TempTable[5].Append('|'+DB_GetString(DB_ID, 4));
			TempTable[6].Append('|'+DB_GetString(DB_ID, 5));
		end;
	
	TempNumber := 0;
	
	for j := 0 to 6 do begin
		
		TempNumber := 0;
		
		for i := 0 to TempTable[j].Count-1 do
			if length(TempTable[j][i]) > TempNumber then
				TempNumber := length(TempTable[j][i]);
		
		for i := 0 to TempTable[j].Count-1 do begin
			TempString := TempTable[j][i];
			While length(TempString) < TempNumber do
				if i = 1 then
					Insert('-', TempString, Length(TempString)+1)
				else
					Insert(' ', TempString, Length(TempString)+1);
			TempTable[j][i] := TempString;
		end;
		
	end;
	
	TempNumber := Length(TempTable[0][0])+Length(TempTable[1][0])+Length(TempTable[2][0])+Length(TempTable[3][0])+Length(TempTable[4][0])+Length(TempTable[5][0])+Length(TempTable[6][0])+1;
	
	TempString := '-';
	While length(TempString) < TempNumber do
		Insert('-', TempString, Length(TempString)+1);
	_EliteList.Append(TempString);
	
	for i := 0 to TempTable[0].Count-1 do
		_EliteList.Append(TempTable[0][i]+TempTable[1][i]+TempTable[2][i]+TempTable[3][i]+TempTable[4][i]+TempTable[5][i]+TempTable[6][i]+'|');
		
	_EliteList.Append(TempString);
	
	DB_FinishQuery(DB_ID);
	
	for i := 0 to 6 do
		TempTable[i].Free;
end;

function MapBestTime(MapName: String): TDateTime;
begin
	if DB_Query(DB_ID, 'SELECT Time FROM Scores WHERE Map = '''+EscapeApostrophe(MapName)+''' ORDER BY Time, Date;') = 0 then
		WriteLn('Error: '+DB_Error)
	else begin
		if DB_FirstRow(DB_ID) = 0 then
			Result := -1
		else
			Result := DB_GetDouble(DB_ID, 0);
		DB_FinishQuery(DB_ID);
	end;
end;

function PlayerBestTime(Account, MapName: String): TDateTime;
begin
	if DB_Query(DB_ID, 'SELECT Time FROM Scores WHERE Account = '''+EscapeApostrophe(Account)+''' AND Map = '''+EscapeApostrophe(MapName)+''' LIMIT 1;') = 0 then
		WriteLn('Error: '+DB_Error)
	else begin
		if DB_FirstRow(DB_ID) = 0 then
			Result := -1
		else
			Result := DB_GetDouble(DB_ID, 0);
		DB_FinishQuery(DB_ID);
	end;
end;

function ShowTime(DaysPassed: TDateTime): String;
begin
	DaysPassed := Abs(DaysPassed);
	if Trunc(DaysPassed) > 0 then
		Result := IntToStr(Trunc(DaysPassed))+' '+iif(Trunc(DaysPassed) = 1, 'day', 'days')+', '+FormatDateTime('hh:nn:ss.zzz', DaysPassed)
	else
		if DaysPassed >= 1.0/24 then
			Result := FormatDateTime('hh:nn:ss.zzz', DaysPassed)
		else
			if DaysPassed >= 1.0/1440 then
				Result := FormatDateTime('nn:ss.zzz', DaysPassed)
			else
				if DaysPassed >= 1.0/86400 then
					Result := FormatDateTime('ss.zzz', DaysPassed)
				else
					if DaysPassed >= 1.0/86400000 then
						Result := FormatDateTime('zzz', DaysPassed)
					else
						Result := '000';
end;

procedure Clock(Ticks: Integer);
var
	i: Byte;
	j, PosCounter: Integer;
	TempTime, TempTime2, Timer: TDateTime;
	RunComplete: Boolean;
begin
	for i := 1 to 32 do
		if Players[i].Active then begin
			
			if _ShowTimer[i] then
				Players[i].BigText(3, ShowTime(Now - _Timer[i])+#10+'Laps: '+IntToStr(_LapsPassed[i])+'/'+IntToStr(_Laps), 180, $FFFFFF, 0.1, 320, 360);
			
			if length(_CheckPoint) > 1 then begin
				for j := 0 to High(_CheckPoint) do begin
					
					if _Laps = 0 then begin
						if (_CheckPointPassed[i] <> 0) and (_CheckPointPassed[i] = j) and (Distance(_CheckPoint[j].X, _CheckPoint[j].Y, Players[i].X, Players[i].Y) <= 30) and (Now - _Timer[i] >= 1.0/86400) then
							if j <> High(_CheckPoint) then
								_CheckPointPassed[i] := j+1
							else
								RunComplete := True;
					end else
						if (_CheckPointPassed[i] <> 0) and (_CheckPointPassed[i] = j) and (Distance(_CheckPoint[j].X, _CheckPoint[j].Y, Players[i].X, Players[i].Y) <= 30) and (Now - _Timer[i] >= 1.0/86400) then
							_CheckPointPassed[i] := j+1;
						
					if Ticks mod 15 = 0 then
						if j+1 = _CheckPointPassed[i] then
							Players[i].WorldText(j, IntToStr(j+1), 120, $00FF00, 0.3, _CheckPoint[j].X+(30*(0-0.3)), _CheckPoint[j].Y+(160*(0-0.3)))
						else
							Players[i].WorldText(j, IntToStr(j+1), 120, $FF0000, 0.3, _CheckPoint[j].X+(30*(0-0.3)), _CheckPoint[j].Y+(160*(0-0.3)));
						
				end;
				
				if (_CheckPointPassed[i] = Length(_CheckPoint)) and (Distance(_CheckPoint[0].X, _CheckPoint[0].Y, Players[i].X, Players[i].Y) <= 30) then begin
					Inc(_LapsPassed[i], 1);
					if _LapsPassed[i] = _Laps then
						RunComplete := True
					else
						_CheckPointPassed[i] := 1;
				end;
				
			end;
			
			if RunComplete then begin
				if DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Players[i].Name)+''' LIMIT 1;') = 0 then
					WriteLn('Error: '+DB_Error)
				else begin
					
					Timer := Now - _Timer[i];
					
					if DB_FirstRow(DB_ID) = 1 then begin //If account was found
						TempTime := MapBestTime(Game.CurrentMap);
						if TempTime = -1 then begin
							
							Players.WriteConsole('[1] First score by '+Players[i].Name+': '+ShowTime(Timer), $FFD700);
							
							if _LoggedIn[i] then begin
								if DB_Update(DB_ID, 'INSERT INTO Scores(Account, Map, Date, Time) VALUES('''+EscapeApostrophe(Players[i].Name)+''', '''+EscapeApostrophe(Game.CurrentMap)+''', '+FloatToStr(Now)+', '+FloatToStr(Timer)+');') = 0 then //Add cap
									WriteLn('Error: '+DB_Error);
							end else
								Players.WriteConsole('Player '+Players[i].Name+' isn''t logged in - score wasn''t recorded', COLOR_1);
							
						end else
							begin
								TempTime2 := PlayerBestTime(Players[i].Name, Game.CurrentMap);
								
								if TempTime2 = -1 then begin
									
									if DB_Update(DB_ID, 'INSERT INTO Scores(Account, Map, Date, Time) VALUES('''+EscapeApostrophe(Players[i].Name)+''', '''+EscapeApostrophe(Game.CurrentMap)+''', '+FloatToStr(Now)+', '+FloatToStr(Timer)+');') = 0 then //Add cap
									WriteLn('Error: '+DB_Error);
								
									if DB_Query(DB_ID, 'SELECT Account FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date;') = 0 then //Find position
										WriteLn('Error: '+DB_Error)
									else
										While DB_NextRow(DB_ID) <> 0 Do begin
											Inc(PosCounter, 1);
											if Players[i].Name = String(DB_GetString(DB_ID, 0)) then
												break;
										end;
									
									if PosCounter = 1 then
										Players.WriteConsole('[1] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: Not found, Map''s best time: -'+ShowTime(Timer - TempTime), $FFD700);
										
									if PosCounter = 2 then
										Players.WriteConsole('[2] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: Not found, Map''s best time: +'+ShowTime(Timer - TempTime), $C0C0C0);
										
									if PosCounter = 3 then
										Players.WriteConsole('[3] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: Not found, Map''s best time: +'+ShowTime(Timer - TempTime), $F4A460);
										
									if PosCounter > 3 then
										Players.WriteConsole('['+IntToStr(PosCounter)+'] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: Not found, Map''s best time: +'+ShowTime(Timer - TempTime), COLOR_1);
									
									if not _LoggedIn[i] then begin
										if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Players[i].Name)+''' AND Map = '''+EscapeApostrophe(Game.CurrentMap)+''';') = 0 then //Del cap
											WriteLn('Error: '+DB_Error);
										Players.WriteConsole('Player '+Players[i].Name+' isn''t logged in - score wasn''t recorded', COLOR_1);
									end;
										
								end else
									if Timer >= TempTime2 then
										Players.WriteConsole(ShowTime(Timer)+', Time was slower than '+Players[i].Name+'''s best by: '+ShowTime(Timer - TempTime2), COLOR_1)
									else begin
										
										if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Players[i].Name)+''' AND Map = '''+EscapeApostrophe(Game.CurrentMap)+''';') = 0 then //Del cap
											WriteLn('Error: '+DB_Error);
											
										if DB_Update(DB_ID, 'INSERT INTO Scores(Account, Map, Date, Time) VALUES('''+EscapeApostrophe(Players[i].Name)+''', '''+EscapeApostrophe(Game.CurrentMap)+''', '+FloatToStr(Now)+', '+FloatToStr(Timer)+');') = 0 then //Add cap
											WriteLn('Error: '+DB_Error);
										
										if DB_Query(DB_ID, 'SELECT Account FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date;') = 0 then //Find position
											WriteLn('Error: '+DB_Error)
										else
											While DB_NextRow(DB_ID) <> 0 Do begin
												Inc(PosCounter, 1);
												if Players[i].Name = String(DB_GetString(DB_ID, 0)) then
													break;
											end;
										
										if PosCounter = 1 then
											Players.WriteConsole('[1] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: -'+ShowTime(Timer - TempTime2)+', Map''s best time: -'+ShowTime(Timer - TempTime), $FFD700);
											
										if PosCounter = 2 then
											Players.WriteConsole('[2] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: -'+ShowTime(Timer - TempTime2)+', Map''s best time: +'+ShowTime(Timer - TempTime), $C0C0C0);
											
										if PosCounter = 3 then
											Players.WriteConsole('[3] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: -'+ShowTime(Timer - TempTime2)+', Map''s best time: +'+ShowTime(Timer - TempTime), $F4A460);
											
										if PosCounter > 3 then
											Players.WriteConsole('['+IntToStr(PosCounter)+'] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: -'+ShowTime(Timer - TempTime2)+', Map''s best time: +'+ShowTime(Timer - TempTime), COLOR_1);
										
										if not _LoggedIn[i] then begin
											if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Players[i].Name)+''' AND Map = '''+EscapeApostrophe(Game.CurrentMap)+''';') = 0 then //Del cap
												WriteLn('Error: '+DB_Error);
											Players.WriteConsole('Player '+Players[i].Name+' isn''t logged in - score wasn''t recorded', COLOR_1);
										end;
										
									end;
							end;
					end else
						begin //If account wasn't found
							TempTime := MapBestTime(Game.CurrentMap);
							if TempTime = -1 then
								Players.WriteConsole('[1] First score by '+Players[i].Name+': '+ShowTime(Timer), $FFD700)
							else begin
								
								if DB_Update(DB_ID, 'INSERT INTO Scores(Account, Map, Date, Time) VALUES('''+EscapeApostrophe(Players[i].Name)+''', '''+EscapeApostrophe(Game.CurrentMap)+''', '+FloatToStr(Now)+', '+FloatToStr(Timer)+');') = 0 then //Add cap
									WriteLn('Error: '+DB_Error);
								
								if DB_Query(DB_ID, 'SELECT Account FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date;') = 0 then //Find position
									WriteLn('Error: '+DB_Error)
								else
									While DB_NextRow(DB_ID) <> 0 Do begin
										Inc(PosCounter, 1);
										if Players[i].Name = String(DB_GetString(DB_ID, 0)) then
											break;
									end;
								
								if PosCounter = 1 then
									Players.WriteConsole('[1] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: Not found, Map''s best time: -'+ShowTime(Timer - TempTime), $FFD700);
									
								if PosCounter = 2 then
									Players.WriteConsole('[2] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: Not found, Map''s best time: +'+ShowTime(Timer - TempTime), $C0C0C0);
									
								if PosCounter = 3 then
									Players.WriteConsole('[3] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: Not found, Map''s best time: +'+ShowTime(Timer - TempTime), $F4A460);
									
								if PosCounter > 3 then
									Players.WriteConsole('['+IntToStr(PosCounter)+'] '+ShowTime(Timer)+', '+Players[i].Name+'''s best time: Not found, Map''s best time: +'+ShowTime(Timer - TempTime), COLOR_1);
								
								if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Players[i].Name)+''' AND Map = '''+EscapeApostrophe(Game.CurrentMap)+''';') = 0 then //Del cap
									WriteLn('Error: '+DB_Error);
								
							end;
							Players.WriteConsole('Unregistered nickname: '+Players[i].Name+' - score wasn''t recorded', COLOR_1);
						end;
						
					DB_FinishQuery(DB_ID);
				end;
			
				Players[i].ChangeTeam(Players[i].Team, TJoinSilent);
				_LapsPassed[i] := 0;
				_CheckPointPassed[i] := 1;
				_Timer[i] := Now;
				RunComplete := False;
			end;
			
			if Ticks mod 15 = 0 then
				if (Players[i].KeyReload) and (_RKill[i]) then
					if length(_CheckPoint) <= 1 then
						Players[i].BigText(5, 'Checkpoints error', 120, $FF0000, 0.1, 320, 300)
					else
						Players[i].Damage(i, 150);
			
			//1 SEC INTERVAL LOOP
			if Ticks mod 60 = 0 then begin
				
				if not _LoggedIn[i] then
					Players[i].BigText(4, 'Not logged in', 180, $FF0000, 0.1, 320, 240);
				
			end;
			//END OF 1 SEC INTERVAL LOOP
			
		end;
		
	if Ticks mod(3600*3) = 0 then
		Players.WriteConsole('!help - All you want to know', COLOR_1);
end;

function OnAdminCommand(Player: TActivePlayer; Command: string): boolean;
var
	i, StrToIntConv: Byte;
	TimeStart: TDateTime;
	Ini: TIniFile;
begin
Result := False;

	if Command = '/recountallstats' then begin
		Players.WriteConsole('Recounting medals...', COLOR_1);
		TimeStart  := Now;
		RecountAllStats;
		Players.WriteConsole('Done in '+ShowTime(Now - TimeStart), COLOR_1);
	
		Players.WriteConsole('Generating elite list...', COLOR_2);
		TimeStart  := Now;
		GenerateEliteList;
		Players.WriteConsole('Done in '+ShowTime(Now - TimeStart), COLOR_2);
	end;

if Player <> nil then begin//In-Game Admin

	if (Copy(Command, 1, 8) = '/delacc ') and (Copy(Command, 9, Length(Command)) <> nil) then
		if DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''' LIMIT 1;') = 0 then
			Player.WriteConsole('Error: '+DB_Error, COLOR_1)
		else begin
			if DB_FirstRow(DB_ID) <> 0 then begin
				
				for i := 1 to 32 do
					if (Players[i].Active) and (Players[i].Name = Copy(Command, 9, Length(Command))) then
						_LoggedIn[i] := FALSE;
				
				if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') = 0 then
					Player.WriteConsole('Error: '+DB_Error, COLOR_1);
				
				if DB_Update(DB_ID, 'DELETE FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') = 0 then
					Player.WriteConsole('Error: '+DB_Error, COLOR_1)
				else
					Player.WriteConsole('Account "'+Copy(Command, 9, Length(Command))+'" has been deleted', COLOR_1);
					
			end else
				Player.WriteConsole('Account "'+Copy(Command, 9, Length(Command))+'" doesn''t exists', COLOR_1);
				
			DB_FinishQuery(DB_ID);
		end;
	
	if (Copy(Command, 1, 7) = '/delid ') and (Copy(Command, 8, Length(Command)) <> nil) then
		if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Id = '''+EscapeApostrophe(Copy(Command, 8, Length(Command)))+''';') = 0 then
			Player.WriteConsole('Error: '+DB_Error, COLOR_1)
		else
			Player.WriteConsole('Score with Id '+Copy(Command, 8, Length(Command))+' has been deleted', COLOR_1);
	
	if Command = '/cpadd' then begin
		for i := 1 to 32 do begin
			_LapsPassed[i] := 0;
			_CheckPointPassed[i] := 0;
		end;
		SetLength(_CheckPoint, Length(_CheckPoint)+1);
		_CheckPoint[High(_CheckPoint)].X := Player.X;
		_CheckPoint[High(_CheckPoint)].Y := Player.Y;
	end;
	
	if Command = '/cpdel' then
		if High(_CheckPoint) <> -1 then begin
			for i := 1 to 32 do begin
				_LapsPassed[i] := 0;
				_CheckPointPassed[i] := 0;
			end;
			SetLength(_CheckPoint, High(_CheckPoint));
		end else
			Player.WriteConsole('All checkpoints has been deleted', $FF0000);
	
	if (Copy(Command, 1, 8) = '/cplaps ') and (Length(Command)>8) then begin
		Delete(Command, 1, 8);
		try
			StrToIntConv := StrToInt(Command);
		except
			Player.WriteConsole('Invalid integer', $FF0000);
			exit;
		end;
		
		for i := 1 to 32 do begin
			_LapsPassed[i] := 0;
			_CheckPointPassed[i] := 0;
		end;
		
		_Laps := StrToIntConv;
		
	end;
	
	if Command = '/cpsave' then
		if length(_CheckPoint) <= 1 then
			Player.WriteConsole('Not enough checkpoints', $FF0000)
		else begin
			Ini := File.CreateINI('~/maps_config.ini');
			Ini.CaseSensitive := True;
			
			if Ini.SectionExists(Game.CurrentMap) then
				Ini.EraseSection(Game.CurrentMap);
			
			for i := 0 to High(_CheckPoint) do begin
				Ini.WriteFloat(Game.CurrentMap, IntToStr(i)+'X', _CheckPoint[i].X);
				Ini.WriteFloat(Game.CurrentMap, IntToStr(i)+'Y', _CheckPoint[i].Y);
			end;
			
			Ini.WriteInteger(Game.CurrentMap, 'Laps', _Laps);
			
			Ini.Free;
		end;
	
	if Command = '/lastcaps' then begin
		Player.WriteConsole('Last 20 caps', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Account, Map, Date, Time FROM Scores ORDER BY Date DESC LIMIT 20;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			While DB_NextRow(DB_ID) <> 0 Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 1)+', Time: '+FloatToStr(DB_GetDouble(DB_ID, 3))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/acccol' then begin
		if DB_Query(DB_ID, 'SELECT * FROM Accounts;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			Player.WriteConsole('Accounts table columns: '+IntToStr(DB_Columns(DB_ID)), COLOR_1);
			for i := 0 to DB_Columns(DB_ID)-1 do
				Player.WriteConsole(DB_ColumnName(DB_ID, i)+', Type: '+IntToStr(DB_ColumnType(DB_ID, i)), COLOR_2);
		end;
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/scocol' then begin
		if DB_Query(DB_ID, 'SELECT * FROM Scores;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			Player.WriteConsole('Scores table columns: '+IntToStr(DB_Columns(DB_ID)), COLOR_1);
			for i := 0 to DB_Columns(DB_ID)-1 do
				Player.WriteConsole(DB_ColumnName(DB_ID, i)+', Type: '+IntToStr(DB_ColumnType(DB_ID, i)), COLOR_2);
		end;
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/changenick' then begin
		if DB_Update(DB_ID, 'UPDATE Accounts SET Name = ''~>2Fast|`HaSte.|'' WHERE Name = ''bp.Energy'';') = 0 then
			Player.WriteConsole('Error: '+DB_Error, COLOR_1);
		if DB_Update(DB_ID, 'UPDATE Scores SET Account = ''~>2Fast|`HaSte.|'' WHERE Account = ''bp.Energy'';') = 0 then
			Player.WriteConsole('Error: '+DB_Error, COLOR_1);
	end;
	
	if Command = '/delbugtime' then begin
		if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Time < 1.0/86400;') = 0 then
			Player.WriteConsole('Error: '+DB_Error, COLOR_1);
	end;
	
	if Command = '/delall' then begin
		if DB_Update(DB_ID, 'DELETE FROM Scores;') = 0 then
			Player.WriteConsole('Error: '+DB_Error, COLOR_1);
	end;
	
	if Command = '/test4' then begin
		if DB_Query(DB_ID, 'SELECT Account, Map, Date, Time FROM Scores WHERE Time < 1.0/86400;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			While DB_NextRow(DB_ID) <> 0 Do
				WriteLn('Map: '+DB_GetString(DB_ID, 1)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 3))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2)));
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/delarena2' then begin
		if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Map = ''Arena2'';') = 0 then
			Player.WriteConsole('Error: '+DB_Error, COLOR_1);
	end;
	
	if (Copy(Command, 1, 8) = '/last30 ') and (Copy(Command, 9, Length(Command)) <> nil) then begin
		Player.WriteConsole(Copy(Command, 9, Length(Command))+'''s last 30 caps', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Map, Date, Time FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''' ORDER BY Date DESC LIMIT 30;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			While DB_NextRow(DB_ID) <> 0 Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 0)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 2))+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
end else
begin//TCP Admin
	
	if (Copy(Command, 1, 8) = '/delacc ') and (Copy(Command, 9, Length(Command)) <> nil) then
		if DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''' LIMIT 1;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			if DB_FirstRow(DB_ID) <> 0 then begin
				
				for i := 1 to 32 do
					if (Players[i].Active) and (Players[i].Name = Copy(Command, 9, Length(Command))) then
						_LoggedIn[i] := FALSE;
				
				if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') = 0 then
					WriteLn('Error: '+DB_Error);
				
				if DB_Update(DB_ID, 'DELETE FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') = 0 then
					WriteLn('Error: '+DB_Error)
				else
					WriteLn('Account "'+Copy(Command, 9, Length(Command))+'" has been deleted');
					
			end else
				WriteLn('Account "'+Copy(Command, 9, Length(Command))+'" doesn''t exists');
				
			DB_FinishQuery(DB_ID);
		end;
	
	if (Copy(Command, 1, 7) = '/delid ') and (Copy(Command, 8, Length(Command)) <> nil) then
		if DB_Update(DB_ID, 'DELETE FROM Scores WHERE Id = '''+EscapeApostrophe(Copy(Command, 8, Length(Command)))+''';') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			WriteLn('Score with Id '+Copy(Command, 8, Length(Command))+' has been deleted');
	
end;
end;

function OnPlayerCommand(Player: TActivePlayer; Command: String): Boolean;
var
	TempNumber: Byte;
begin
Result := False;

	if Command = '/timer' then
		if _ShowTimer[Player.ID] then
			_ShowTimer[Player.ID] := FALSE
		else
			_ShowTimer[Player.ID] := TRUE;
			
	if Command = '/ron' then begin
		_RKill[Player.ID] := TRUE;
		Player.WriteConsole('"R" kill enabled', COLOR_1);
	end;
	
	if Command = '/roff' then begin
		_RKill[Player.ID] := FALSE;
		Player.WriteConsole('"R" kill disabled', COLOR_1);
	end;
	
	if (Copy(Command, 1, 9) = '/account ') and (Copy(Command, 10, Length(Command)) <> nil) then
		if DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			if DB_FirstRow(DB_ID) = 0 then begin
				if DB_Update(DB_ID, 'INSERT INTO Accounts(Name, Password, Hwid, Date) VALUES('''+EscapeApostrophe(Player.Name)+''', '''+EscapeApostrophe(Copy(Command, 10, Length(Command)))+''', '''+EscapeApostrophe(Player.HWID)+''', '+FloatToStr(Now)+');') = 0 then
					WriteLn('Error: '+DB_Error)
				else begin
					Player.WriteConsole('Account successfully created, remember your nickname and password!', COLOR_1);
					Player.WriteConsole('Now login for the first time with command /login <password>', COLOR_1);
				end;
			end else
				Player.WriteConsole('Account with that nickname already exists', COLOR_1);
			DB_FinishQuery(DB_ID);
		end;
			
	if (Copy(Command, 1, 7) = '/login ') and (Copy(Command, 8, Length(Command)) <> nil) then
		if DB_Query(DB_ID, 'SELECT Password FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			if DB_FirstRow(DB_ID) = 0 then
				Player.WriteConsole('Account with that nickname doesn''t exists', COLOR_1)
			else
				if String(DB_GetString(DB_ID, 0)) = Copy(Command, 8, Length(Command)) then begin
					Player.WriteConsole('You have successfully logged in!', COLOR_1);
					_LoggedIn[Player.ID] := TRUE;
				end else
					Player.WriteConsole('Wrong password', COLOR_1);
			DB_FinishQuery(DB_ID);
		end;
		
	if (Copy(Command, 1, 7) = '/thief ') or (Command = '/thief') then
	if Copy(Command, 8, length(Command)) <> nil then begin
		Try
			TempNumber := StrToInt(GetPiece(Command, ' ', 1));
			if (TempNumber > 0) and (TempNumber < 33) then begin
				if TempNumber <> Player.ID then begin
					if Players[TempNumber].Active then begin
						if TempNumber > 9 then begin
							if DB_Query(DB_ID, 'SELECT Password FROM Accounts WHERE Name = '''+EscapeApostrophe(Players[TempNumber].Name)+''' LIMIT 1;') = 0 then
								WriteLn('Error: '+DB_Error)
							else begin
								if DB_FirstRow(DB_ID) = 1 then begin
									if String(DB_GetString(DB_ID, 0)) = Copy(Command, 11, Length(Command)) then
										Players[TempNumber].Ban(1, 'You were banned for 1min due to occupying registered nickname')
									else
										Player.WriteConsole('"'+Copy(Command, 11, Length(Command))+'" is wrong password', COLOR_1);
								end else
									Player.WriteConsole('Account with nickname "'+Players[TempNumber].Name+'" doesn''t exists', COLOR_1);
								DB_FinishQuery(DB_ID);
							end;
						end else
							if DB_Query(DB_ID, 'SELECT Password FROM Accounts WHERE Name = '''+EscapeApostrophe(Players[TempNumber].Name)+''' LIMIT 1;') = 0 then
								WriteLn('Error: '+DB_Error)
							else begin
								if DB_FirstRow(DB_ID) = 1 then begin
									if String(DB_GetString(DB_ID, 0)) = Copy(Command, 10, Length(Command)) then
										Players[TempNumber].Ban(1, 'You were banned for 1min due to occupying registered nickname')
									else
										Player.WriteConsole('"'+Copy(Command, 10, Length(Command))+'" is wrong password', COLOR_1);
								end else
									Player.WriteConsole('Account with nickname "'+Players[TempNumber].Name+'" doesn''t exists', COLOR_1);
								DB_FinishQuery(DB_ID);
							end;
					end else
						Player.WriteConsole('Player with id "'+IntToStr(TempNumber)+'" doesn''t exists', COLOR_1);
				end else
					Player.WriteConsole('You can''t kick yourself', COLOR_1);
			end else
				Player.WriteConsole('ID has to be from 1 to 32', COLOR_1);
		Except
			Player.WriteConsole('"'+GetPiece(Command, ' ', 1)+'" is invalid integer', COLOR_1);
		end;
	end else
		Player.WriteConsole('If you want to kick nickname thief you have to type his id(/+F1) and account password (/thief <id> <password>)', COLOR_2);
	
	if Command = '/settings' then begin
		if DB_Query(DB_ID, 'SELECT Date, Hwid, AutoLoginHwid FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			if DB_FirstRow(DB_ID) = 0 then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					Player.WriteConsole(Player.Name+'''s account settings:', COLOR_1);
					Player.WriteConsole('Created: '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 0)), COLOR_2);
					Player.WriteConsole('Original machine: '+DB_GetString(DB_ID, 1), COLOR_2);
					Player.WriteConsole('Auto login machine: '+DB_GetString(DB_ID, 2), COLOR_2);
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/aladd' then begin
		if DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			if DB_FirstRow(DB_ID) = 0 then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					if DB_Update(DB_ID, 'UPDATE Accounts SET AutoLoginHwid = '''+EscapeApostrophe(Player.HWID)+''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') = 0 then
						WriteLn('Error: '+DB_Error);
					Player.WriteConsole('You''ve set this machine "'+Player.HWID+'" for auto login', COLOR_1);
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/aldel' then begin
		if DB_Query(DB_ID, 'SELECT AutoLoginHwid FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			if DB_FirstRow(DB_ID) = 0 then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					if DB_Update(DB_ID, 'UPDATE Accounts SET AutoLoginHwid = '''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') = 0 then
						WriteLn('Error: '+DB_Error);
					Player.WriteConsole('You''ve deleted machine "'+DB_GetString(DB_ID, 0)+'" for auto login', COLOR_1);
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
end;

procedure OnPlayerSpeak(Player: TActivePlayer; Text: String);
var
	PosCounter: Integer;
begin
	if Text = '!help' then begin
		Player.WriteConsole('Welcome to Run Mode!', COLOR_1);
		Player.WriteConsole('First of all, You have to make an account with command /account <password>,', COLOR_2);
		Player.WriteConsole('otherwise Your scores won''t be recorded.', COLOR_2);
		Player.WriteConsole('Please read !rules and !commands.', COLOR_2);
		Player.WriteConsole('Medals are recounted on map change.', COLOR_2);
	end;
	
	if Text = '!commands' then begin
		Player.WriteConsole('Run Mode commands:', COLOR_1);
		Player.WriteConsole('!whois - Shows connected admins', COLOR_2);
		Player.WriteConsole('!admin/nick - Call connected TCP admin', COLOR_2);
		Player.WriteConsole('!v - Start vote for next map', COLOR_2);
		Player.WriteConsole('!elite - Shows 10 best players', COLOR_2);
		Player.WriteConsole('!top <map name> - Shows 3 best times of certain map', COLOR_2);
		Player.WriteConsole('!top10 <map name> - Shows 10 best times of certain map', COLOR_2);
		Player.WriteConsole('!lastcaps - Shows last 10 caps', COLOR_2);
		Player.WriteConsole('!last10 <nickname> - Shows last 10 caps of certain player', COLOR_2);
		Player.WriteConsole('!mlr - MapListReader commands', COLOR_2);
		Player.WriteConsole('!player <nickname> - Shows stats of certain player', COLOR_2);
		Player.WriteConsole('/settings - Shows your account settings', COLOR_2);
		Player.WriteConsole('/aladd - Set your machine to auto login', COLOR_2);
		Player.WriteConsole('/aldel - Delete machine for auto login', COLOR_2);
		Player.WriteConsole('/timer - Enable/Disable timer', COLOR_2);
		Player.WriteConsole('/ron - Make "Reload Key" to reset the timer (Default)', COLOR_2);
		Player.WriteConsole('/roff - Disable "Reload Key" function', COLOR_2);
		Player.WriteConsole('/account <password> - Create an account', COLOR_2);
		Player.WriteConsole('/login <password> - Login to your account', COLOR_2);
		Player.WriteConsole('/thief <id> <password> - kick the player who''s taking your nickname', COLOR_2);
	end;
	
	if Text = '!mlr' then begin
		Player.WriteConsole('MapListReader commands:', COLOR_1);
		Player.WriteConsole('/maplist - Show MapList', COLOR_2);
		Player.WriteConsole('/smaplist - Show sorted MapList', COLOR_2);
		Player.WriteConsole('/searchmap <pattern> - Show all maps containing searched pattern', COLOR_2);
		Player.WriteConsole('/showmapid - Show map index from MapList in SearchResult, do it before searching', COLOR_2);
		Player.WriteConsole('/page <number> - Change page to <number>, type "/page 0" to close', COLOR_2);
		Player.WriteConsole('You can also hold "Crouch"(forward) or "Jump"(back) key to change page', COLOR_2);
		Player.WriteConsole('Admin commands:', COLOR_1);
		Player.WriteConsole('/createsortedmaplist - Create sorted MapList if current one is outdated', COLOR_2);
		Player.WriteConsole('/addmap <map name> - Add map to MapList (Default Soldat command)', COLOR_2);
		Player.WriteConsole('/delmap <map name> - Remove map from MapList (Default Soldat command)', COLOR_2);
	end;
	
	if Text = '!rules' then begin
		Player.WriteConsole('Run Mode rules:', COLOR_1);
		Player.WriteConsole('1. DO NOT troll.', COLOR_2);
		Player.WriteConsole('4. DO NOT call admins without a reason.', COLOR_2);
		Player.WriteConsole('5. DO NOT spam.', COLOR_2);
		Player.WriteConsole('6. DO NOT cheat.', COLOR_2);
		Player.WriteConsole('7. DO NOT verbal abuse other players, don''t be racist.', COLOR_2);
		Player.WriteConsole('8. Have fun and good luck!', COLOR_2);
	end;
	
	if Text = '!player' then begin
		Players.WriteConsole(Player.Name+'''s stats', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Gold, Silver, Bronze, NoMedal, Points FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			if DB_FirstRow(DB_ID) = 0 then
				Players.WriteConsole('Unregistered nickname', COLOR_2)
			else begin
				Players.WriteConsole('Caps: '+IntToStr(DB_GetLong(DB_ID, 0)+DB_GetLong(DB_ID, 1)+DB_GetLong(DB_ID, 2)+DB_GetLong(DB_ID, 3)), COLOR_2);
				Players.WriteConsole('Points: '+DB_GetString(DB_ID, 4), COLOR_2);
				Players.WriteConsole('Gold: '+DB_GetString(DB_ID, 0), $FFD700);
				Players.WriteConsole('Silver: '+DB_GetString(DB_ID, 1), $C0C0C0);
				Players.WriteConsole('Bronze: '+DB_GetString(DB_ID, 2), $F4A460);
				Players.WriteConsole('NoMedal: '+DB_GetString(DB_ID, 3), COLOR_2);
			end;
		DB_FinishQuery(DB_ID);
	end;
	
	if (Copy(Text, 1, 8) = '!player ') and (Copy(Text, 9, Length(Text)) <> nil) then begin
		Players.WriteConsole(Copy(Text, 9, Length(Text))+'''s stats', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Gold, Silver, Bronze, NoMedal, Points FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Text, 9, Length(Text)))+''' LIMIT 1;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			if DB_FirstRow(DB_ID) = 0 then
				Players.WriteConsole('Unregistered nickname', COLOR_2)
			else begin
				Players.WriteConsole('Caps: '+IntToStr(DB_GetLong(DB_ID, 0)+DB_GetLong(DB_ID, 1)+DB_GetLong(DB_ID, 2)+DB_GetLong(DB_ID, 3)), COLOR_2);
				Players.WriteConsole('Points: '+DB_GetString(DB_ID, 4), COLOR_2);
				Players.WriteConsole('Gold: '+DB_GetString(DB_ID, 0), $FFD700);
				Players.WriteConsole('Silver: '+DB_GetString(DB_ID, 1), $C0C0C0);
				Players.WriteConsole('Bronze: '+DB_GetString(DB_ID, 2), $F4A460);
				Players.WriteConsole('NoMedal: '+DB_GetString(DB_ID, 3), COLOR_2);
			end;
		DB_FinishQuery(DB_ID);
	end;
	
	if Text = '!top' then begin
		Players.WriteConsole(Game.CurrentMap+' TOP3', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date LIMIT 3;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) <> 0 Do begin
				Inc(PosCounter, 1);
				
				if PosCounter = 1 then
					Players.WriteConsole('[1] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $FFD700);
						
				if PosCounter = 2 then
					Players.WriteConsole('[2] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $C0C0C0);
					
				if PosCounter = 3 then
					Players.WriteConsole('[3] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $F4A460);
				
			end;
			DB_FinishQuery(DB_ID);
		end;
	end;
	
	if (Copy(Text, 1, 5) = '!top ') and (Copy(Text, 6, Length(Text)) <> nil) then begin
		Players.WriteConsole(Copy(Text, 6, Length(Text))+' TOP3', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Copy(Text, 6, Length(Text)))+''' ORDER BY Time, Date LIMIT 3;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) <> 0 Do begin
				Inc(PosCounter, 1);
				
				if PosCounter = 1 then
					Players.WriteConsole('[1] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $FFD700);
						
				if PosCounter = 2 then
					Players.WriteConsole('[2] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $C0C0C0);
					
				if PosCounter = 3 then
					Players.WriteConsole('[3] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $F4A460);
				
			end;
			DB_FinishQuery(DB_ID);
		end;
	end;
	
	if Text = '!top10' then begin
		Player.WriteConsole(Game.CurrentMap+' TOP10', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date LIMIT 10;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) <> 0 Do begin
				Inc(PosCounter, 1);
				
				if PosCounter = 1 then
					Player.WriteConsole('[1] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $FFD700);
						
				if PosCounter = 2 then
					Player.WriteConsole('[2] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $C0C0C0);
					
				if PosCounter = 3 then
					Player.WriteConsole('[3] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $F4A460);
				
				if PosCounter > 3 then
					Player.WriteConsole('['+IntToStr(PosCounter)+'] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', COLOR_1);
				
			end;
			DB_FinishQuery(DB_ID);
		end;
	end;
	
	if (Copy(Text, 1, 7) = '!top10 ') and (Copy(Text, 8, Length(Text)) <> nil) then begin
		Player.WriteConsole(Copy(Text, 8, Length(Text))+' TOP10', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Copy(Text, 8, Length(Text)))+''' ORDER BY Time, Date LIMIT 10;') = 0 then
			WriteLn('Error: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) <> 0 Do begin
				Inc(PosCounter, 1);
				
				if PosCounter = 1 then
					Player.WriteConsole('[1] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $FFD700);
						
				if PosCounter = 2 then
					Player.WriteConsole('[2] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $C0C0C0);
					
				if PosCounter = 3 then
					Player.WriteConsole('[3] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', $F4A460);
				
				if PosCounter > 3 then
					Player.WriteConsole('['+IntToStr(PosCounter)+'] '+ShowTime(DB_GetDouble(DB_ID, 2))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1))+' ['+DB_GetString(DB_ID, 3)+']', COLOR_1);
				
			end;
			DB_FinishQuery(DB_ID);
		end;
	end;
	
	if Text = '!lastcaps' then begin
		Player.WriteConsole('Last 10 caps', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Account, Map, Date, Time FROM Scores ORDER BY Date DESC LIMIT 10;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			While DB_NextRow(DB_ID) <> 0 Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 1)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 3))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Text = '!elite' then begin
		Player.WriteConsole('Points: Gold-12, Silver-6, Bronze-3, NoMedal-1', COLOR_1);
		for PosCounter := 0 to _EliteList.Count-1 do
			Player.WriteConsole(_EliteList[PosCounter], COLOR_2);
	end;
	
	if Text = '!last10' then begin
		Player.WriteConsole(Player.Name+'''s last 10 caps', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Map, Date, Time FROM Scores WHERE Account = '''+EscapeApostrophe(Player.Name)+''' ORDER BY Date DESC LIMIT 10;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			While DB_NextRow(DB_ID) <> 0 Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 0)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 2))+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if (Copy(Text, 1, 8) = '!last10 ') and (Copy(Text, 9, Length(Text)) <> nil) then begin
		Player.WriteConsole(Copy(Text, 9, Length(Text))+'''s last 10 caps', COLOR_1);
		if DB_Query(DB_ID, 'SELECT Map, Date, Time FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Text, 9, Length(Text)))+''' ORDER BY Date DESC LIMIT 10;') = 0 then
			WriteLn('Error: '+DB_Error)
		else
			While DB_NextRow(DB_ID) <> 0 Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 0)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 2))+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
end;

procedure OnJoin(Player: TActivePlayer; Team: TTeam);
begin
	if DB_Query(DB_ID, 'SELECT AutoLoginHwid FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') = 0 then
		WriteLn('Error: '+DB_Error)
	else begin
		if DB_FirstRow(DB_ID) = 1 then begin
			if String(DB_GetString(DB_ID, 0)) = Player.HWID then begin
				Player.WriteConsole('Auto login machine - logged in', COLOR_1);
				_LoggedIn[Player.ID] := TRUE;
			end else
				Player.WriteConsole('Account with that nickname already exists, type /login <password> to login', COLOR_1);
		end else
			begin
				Player.WriteConsole('Welcome, Account with your nickname wasn''t found', COLOR_2);
				Player.WriteConsole('Register it in order to save your scores, type /account <password>', COLOR_2);
				Player.WriteConsole('Hold "Reload Key" to start running', $00FF00);
				Player.WriteConsole('Read !help for more informations', COLOR_1);
			end;
		DB_FinishQuery(DB_ID);
	end;
end;

procedure OnLeave(Player: TActivePlayer; Kicked: Boolean);
begin
	_ShowTimer[Player.ID] := FALSE;
	_LoggedIn[Player.ID] := FALSE;
	_LapsPassed[Player.ID] := 0;
	_CheckPointPassed[Player.ID] := 0;
end;

procedure OnBeforeMapChange(Next: String);
var
	TimeStart: TDateTime;
	i: Byte;
begin
	for i := 1 to 32 do begin
		_LapsPassed[i] := 0;
		_CheckPointPassed[i] := 0;
	end;
	SetLength(_CheckPoint, 0);
	_Laps := 0;
	
	Players.WriteConsole('Recounting medals...', COLOR_1);
	TimeStart  := Now;
	RecountAllStats;
	Players.WriteConsole('Done in '+ShowTime(Now - TimeStart), COLOR_1);
	
	Players.WriteConsole('Generating elite list...', COLOR_2);
	TimeStart  := Now;
	GenerateEliteList;
	Players.WriteConsole('Done in '+ShowTime(Now - TimeStart), COLOR_2);
end;

procedure OnAfterMapChange(Next: string);
var
	Ini: TIniFile;
	TempStrL: TStringList;
	i: Integer;
	SpawnATeam, SpawnAFlag, SpawnBFlag: Boolean;
begin
	Ini := File.CreateINI('~/maps_config.ini');
	Ini.CaseSensitive := True;
	
	if Ini.SectionExists(Game.CurrentMap) then begin
		
		Players.WriteConsole('Map''s checkpoints found - loading...', COLOR_1);
		
		TempStrL := File.CreateStringList;
		Ini.ReadSection(Game.CurrentMap, TempStrL);
		
		SetLength(_CheckPoint, (TempStrL.Count-1)/2);
		
		for i := 0 to High(_CheckPoint) do begin
			_CheckPoint[i].X := Ini.ReadFloat(Game.CurrentMap, IntToStr(i)+'X', 0);
			_CheckPoint[i].Y := Ini.ReadFloat(Game.CurrentMap, IntToStr(i)+'Y', 0);
		end;
		
		_Laps := Ini.ReadInteger(Game.CurrentMap, 'Laps', 0);
		
		if _Laps < 1 then
			Players.WriteConsole('Checkpoints loaded - Sprint', COLOR_2)
		else
			Players.WriteConsole('Checkpoints loaded - Circuit', COLOR_2);
		
		TempStrL.Free;
		
	end else
		begin
			Players.WriteConsole('Map''s checkpoints not found', COLOR_1);
			Players.WriteConsole('Trying to load default from alpha team and flags spawn points...', COLOR_1);
			SetLength(_CheckPoint, 3);
			for i := 1 to 255 do begin
				
				if not Map.Spawns[i].Active then
					break;
					
				if (Map.Spawns[i].Style = 1) and (not SpawnATeam) then begin
					SpawnATeam := True;
					_CheckPoint[0].X := Map.Spawns[i].X;
					_CheckPoint[0].Y := Map.Spawns[i].Y;
				end;
				
				if (Map.Spawns[i].Style = 6) and (not SpawnBFlag) then begin
					SpawnBFlag := True;
					_CheckPoint[1].X := Map.Spawns[i].X;
					_CheckPoint[1].Y := Map.Spawns[i].Y;
				end;
				
				if (Map.Spawns[i].Style = 5) and (not SpawnAFlag) then begin
					SpawnAFlag := True;
					_CheckPoint[2].X := Map.Spawns[i].X;
					_CheckPoint[2].Y := Map.Spawns[i].Y;
				end;
				
			end;
			
			if not SpawnATeam then
				Players.WriteConsole('Alpha Team spawn is missing', COLOR_1);
			
			if not SpawnBFlag then
				Players.WriteConsole('Bravo Flag spawn is missing', COLOR_1);
			
			if not SpawnAFlag then
				Players.WriteConsole('Alpha Flag spawn is missing', COLOR_1);
			
			if SpawnATeam and SpawnBFlag and SpawnAFlag then begin
				_Laps := 0;
				Players.WriteConsole('Default checkpoints loaded - Sprint', COLOR_2);
			end else
				SetLength(_CheckPoint, 0);
				
		end;
		
	Ini.Free;
end;

function OnDamage(Shooter, Victim: TActivePlayer; Damage: Single; BulletId: Byte): Single;
begin
	if (Victim.Health - Damage) <= 0 then begin
		Victim.Health := 150;
		Victim.BigText(5, 'Death', 120, $FF0000, 0.1, 320, 300);
		if length(_CheckPoint) > 1 then begin
			Victim.ChangeTeam(Victim.Team, TJoinSilent);
			_LapsPassed[Victim.ID] := 0;
			_CheckPointPassed[Victim.ID] := 1;
			_Timer[Victim.ID] := Now;
		end;
	end else
		Result := Damage;
end;

procedure OnAfterRespawn(Player: TActivePlayer);
begin
	if length(_CheckPoint) > 1 then
		Player.Move(_CheckPoint[0].X, _CheckPoint[0].Y);
end;

procedure Init;
var
	i: Byte;
	DBFile: TFileStream;
begin
	if not File.Exists(DB_NAME) then begin
		DBFile := File.CreateFileStream;
		DBFile.SaveToFile(DB_NAME);
		DBFile.Free;
		WriteLn('Database "'+DB_NAME+'" has been created');
		if DB_Open(DB_ID, DB_NAME, '', '', DB_Plugin_SQLite) <> 0 then begin
			if DB_Update(DB_ID, 'CREATE TABLE Accounts(Id INTEGER PRIMARY KEY, Name TEXT, Password TEXT, Hwid TEXT, Date DOUBLE, Gold INTEGER DEFAULT 0, Silver INTEGER DEFAULT 0, Bronze INTEGER DEFAULT 0, NoMedal INTEGER DEFAULT 0, AutoLoginHwid TEXT, Points INTEGER DEFAULT 0);') = 0 then
				WriteLn('Error: '+DB_Error);
			if DB_Update(DB_ID, 'CREATE TABLE Scores(Id INTEGER PRIMARY KEY, Account TEXT, Map TEXT, Date DOUBLE, Time DOUBLE);') = 0 then
				WriteLn('Error: '+DB_Error);
		end else
			WriteLn('Error: '+DB_Error);
	end else
		if DB_Open(DB_ID, DB_NAME, '', '', DB_Plugin_SQLite) = 0 then
			WriteLn('Error: '+DB_Error);
	
	//RecountAllStats;
	_EliteList := File.CreateStringList;
	GenerateEliteList;
	
	for i := 1 to 32 do begin
		_RKill[i] := TRUE;
		Players[i].Team := 5;
		Players[i].OnCommand := @OnPlayerCommand;
		Players[i].OnSpeak := @OnPlayerSpeak;
		Players[i].OnDamage := @OnDamage;
		Players[i].OnAfterRespawn := @OnAfterRespawn;
	end;
	
	Game.OnAdminCommand := @OnAdminCommand;
	Game.OnJoin := @OnJoin;
	Game.OnLeave := @OnLeave;
	Game.OnClockTick := @Clock;
	Game.TickThreshold := 1;
	
	Map.OnBeforeMapChange := @OnBeforeMapChange;
	Map.OnAfterMapChange := @OnAfterMapChange;
end;

begin
	Init;
end.
