//Run Mode v3(1.7.1.1) by Savage

uses database;
	
const
	DB_ID = 1;
	DB_NAME = 'runmode.db';
	COLOR_1 = $6495ed;
	COLOR_2 = $F0E68C;
	PATH_TO_FILES = '/home/shared_data/';
	USED_IP_TIME = 8;//hours
	
type tCheckPoint = Record
	X, Y: Single;
end;

type tRecord = Record
	X, Y: Single;
end;
	
var
	_CheckPoint: array of tCheckPoint;
	_Laps: Byte;
	_ReplayTime, _WorldTextLoop, _ReplayTime2, _WorldTextLoop2: Integer;
	_LapsPassed, _CheckPointPassed: array[1..32] of Byte;
	_Timer: array[1..32] of TDateTime;
	{$IFDEF RUN_MODE_DEBUG}
		_PingRespawn: array[1..32] of Integer;
	{$ENDIF}
	_ShowTimer, _RKill, _LoggedIn, _JustDied, _FlightMode, _GodMode: array[1..32] of Boolean;
	_EliteList, _UsedIP: TStringList;
	_Record: array[1..32] of array of tRecord;
	_Replay, _Replay2: array of tRecord;
	_ScoreId, _ReplayInfo, _ReplayInfo2: String;
	_EditMode: Boolean;
	_LastPosX, _LastPosY: array[1..32] of Single;
	
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

{$IFDEF CLIMB}
	procedure RecountAllStats;
	var
		PosCounter: Integer;
		MapName, NewMapName: String;
	begin
		if Not DB_Update(DB_ID, 'UPDATE Accounts SET Gold = 0, Silver = 0, Bronze = 0, NoMedal = 0, Points = 0;') then
			WriteLn('RunModeError14: '+DB_Error);
		
		if Not DB_Query(DB_ID, 'SELECT Account, Map FROM Scores ORDER BY Map, Time, Date;') then
			WriteLn('RunModeError15: '+DB_Error)
		else begin
			DB_Update(DB_ID, 'BEGIN TRANSACTION;');
			While DB_NextRow(DB_ID) Do begin
				
				NewMapName := DB_GetString(DB_ID, 1);
				
				if Game.MapsList.GetMapIdByName(NewMapName) = -1 then//Do not count maps that are not in maplist
					Continue;
				
				if MapName <> NewMapName then begin
					MapName := NewMapName;
					PosCounter := 0;
				end;
				
				Inc(PosCounter, 1);
				
				if PosCounter = 1 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET Gold = Gold + 1, Points = Points + 12 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError16: '+DB_Error);
				
				if PosCounter = 2 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET Silver = Silver + 1, Points = Points + 6 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError17: '+DB_Error);
				
				if PosCounter = 3 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET Bronze = Bronze + 1, Points = Points + 3 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError18: '+DB_Error);
				
				if PosCounter > 3 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 1 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError19: '+DB_Error);
						
			end;
			DB_Update(DB_ID, 'COMMIT;');
		end;
			
		DB_FinishQuery(DB_ID);
	end;
{$ELSE}
	procedure RecountAllStats;
	var
		PosCounter: Integer;
		MapName, NewMapName: String;
	begin
		if Not DB_Update(DB_ID, 'UPDATE Accounts SET Gold = 0, Silver = 0, Bronze = 0, NoMedal = 0, Points = 0;') then
			WriteLn('RunModeError1: '+DB_Error);
		
		if Not DB_Query(DB_ID, 'SELECT Account, Map FROM Scores ORDER BY Map, Time, Date;') then
			WriteLn('RunModeError2: '+DB_Error)
		else begin
			DB_Update(DB_ID, 'BEGIN TRANSACTION;');
			While DB_NextRow(DB_ID) Do begin
				
				NewMapName := DB_GetString(DB_ID, 1);
				
				if Game.MapsList.GetMapIdByName(NewMapName) = -1 then//Do not count maps that are not in maplist
					Continue;
				
				if MapName <> NewMapName then begin
					MapName := NewMapName;
					PosCounter := 0;
				end;
				
				Inc(PosCounter, 1);
				
				if PosCounter = 1 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET Gold = Gold + 1, Points = Points + 25 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError3: '+DB_Error);
				
				if PosCounter = 2 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET Silver = Silver + 1, Points = Points + 20 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError4: '+DB_Error);
				
				if PosCounter = 3 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET Bronze = Bronze + 1, Points = Points + 15 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError5: '+DB_Error);
				
				if PosCounter = 4 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 10 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError6: '+DB_Error);
						
				if PosCounter = 5 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 7 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError7: '+DB_Error);
				
				if PosCounter = 6 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 5 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError8: '+DB_Error);
						
				if PosCounter = 7 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 4 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError9: '+DB_Error);
						
				if PosCounter = 8 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 3 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError10: '+DB_Error);
						
				if PosCounter = 9 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 2 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError11: '+DB_Error);
						
				if PosCounter = 10 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1, Points = Points + 1 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError12: '+DB_Error);
				
				if PosCounter > 10 then
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET NoMedal = NoMedal + 1 WHERE Name = '''+EscapeApostrophe(DB_GetString(DB_ID, 0))+''';') then
						WriteLn('RunModeError13: '+DB_Error);
				
			end;
			DB_Update(DB_ID, 'COMMIT;');
		end;
			
		DB_FinishQuery(DB_ID);
	end;
{$ENDIF}

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
	
	if Not DB_Query(DB_ID, 'SELECT Name, Gold, Silver, Bronze, NoMedal, Points FROM Accounts ORDER BY Points DESC LIMIT 20;') then
		WriteLn('RunModeError20: '+DB_Error)
	else
		While DB_NextRow(DB_ID) Do Begin
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
	if Not DB_Query(DB_ID, 'SELECT Time FROM Scores WHERE Map = '''+EscapeApostrophe(MapName)+''' ORDER BY Time, Date;') then
		WriteLn('RunModeError21: '+DB_Error)
	else begin
		if Not DB_NextRow(DB_ID) then
			Result := -1
		else
			Result := DB_GetDouble(DB_ID, 0);
		DB_FinishQuery(DB_ID);
	end;
end;

function PlayerBestTime(Account, MapName: String): TDateTime;
begin
	if Not DB_Query(DB_ID, 'SELECT Time, Id FROM Scores WHERE Account = '''+EscapeApostrophe(Account)+''' AND Map = '''+EscapeApostrophe(MapName)+''' LIMIT 1;') then
		WriteLn('RunModeError22: '+DB_Error)
	else begin
		if Not DB_NextRow(DB_ID) then
			Result := -1
		else begin
			Result := DB_GetDouble(DB_ID, 0);
			_ScoreId := DB_GetString(DB_ID, 1);
		end;
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
begin
	if Ticks mod 6 = 0 then begin
		if Length(_Replay) > 0 then begin
			if _WorldTextLoop = 240 then
				_WorldTextLoop := 200;
			
			Inc(_WorldTextLoop, 1);
			
			if _ReplayTime < Length(_Replay) then begin
				Inc(_ReplayTime, 1);
				Players.WorldText(_WorldTextLoop, '.', 240, $FF0000, 0.15, _Replay[_ReplayTime-1].X+30*-0.15, _Replay[_ReplayTime-1].Y+140*-0.15);
				Players.BigText(10, _ReplayInfo+' '+IntToStr(_ReplayTime)+'/'+IntToStr(Length(_Replay)), 120, $FF0000, 0.05, 5, 340);
				
				if (_ReplayTime = Length(_Replay)) and (Length(_Replay2) = 0) then
					_ReplayTime := 0;
			end;
		end;
		
		if Length(_Replay2) > 0 then begin
			if _WorldTextLoop2 = 190 then
				_WorldTextLoop2 := 150;
			
			Inc(_WorldTextLoop2, 1);
			
			if _ReplayTime2 < Length(_Replay2) then begin
				Inc(_ReplayTime2, 1);
				Players.WorldText(_WorldTextLoop2, '.', 240, $0000FF, 0.15, _Replay2[_ReplayTime2-1].X+30*-0.15, _Replay2[_ReplayTime2-1].Y+140*-0.15);
				Players.BigText(11, _ReplayInfo2+' '+IntToStr(_ReplayTime2)+'/'+IntToStr(Length(_Replay2)), 120, $0000FF, 0.05, 5, 360);
			end;
			
			if (_ReplayTime2 = Length(_Replay2)) and (_ReplayTime = Length(_Replay)) then begin
				_ReplayTime2 := 0;
				_ReplayTime := 0;
			end;
		end;
	end;
	
	for i := 1 to 32 do
		if Players[i].Active then begin
			
			if Ticks mod 6 = 0 then
				if Players[i].Alive then
					if Length(_Record[i]) > 0 then begin
						if Distance(_Record[i][High(_Record[i])].X, _Record[i][High(_Record[i])].Y, Players[i].X, Players[i].Y) >= 300 then begin
							Players[i].Damage(i, 150);
							Players.WriteConsole('Offmap bug, lag or teleport cheat detected, player '+Players[i].Name+' has been killed', $FF0000);
							exit;
						end;
						
						SetLength(_Record[i], Length(_Record[i])+1);
						_Record[i][High(_Record[i])].X := Players[i].X;
						_Record[i][High(_Record[i])].Y := Players[i].Y;
					end;
			
			if _ShowTimer[i] then
				if _Laps = 0 then
					Players[i].BigText(3, ShowTime(Now - _Timer[i])+#10+IntToStr(Trunc(21.6*sqrt(Players[i].VelX*Players[i].VelX + Players[i].VelY*Players[i].VelY)))+'km/h', 120, $FFFFFF, 0.1, 320, 360)
				else
					Players[i].BigText(3, ShowTime(Now - _Timer[i])+#10+'Lap: '+IntToStr(_LapsPassed[i]+1)+'/'+IntToStr(_Laps)+#10+IntToStr(Trunc(21.6*sqrt(Players[i].VelX*Players[i].VelX + Players[i].VelY*Players[i].VelY)))+'km/h', 120, $FFFFFF, 0.1, 320, 360);
			
			if length(_CheckPoint) > 1 then begin
				for j := 0 to High(_CheckPoint) do begin
					
					if (Players[i].Alive) and (not _EditMode) and (not _FlightMode[i]) and (not _GodMode[i]) then begin
					
						if _Laps = 0 then begin
							if (_CheckPointPassed[i] <> 0) and (_CheckPointPassed[i] = j) and (Distance(_CheckPoint[j].X, _CheckPoint[j].Y, Players[i].X, Players[i].Y) <= 30) and (Now - _Timer[i] >= 1.0/86400) then
								if j <> High(_CheckPoint) then
									_CheckPointPassed[i] := j+1
								else begin
									Timer := Now - _Timer[i];
									{$IFDEF RUN_MODE_DEBUG}
										Players[i].WriteConsole('Respawn Ping: '+IntToStr(_PingRespawn[i])+', Finish Ping: '+IntToStr(Players[i].Ping), $FF0000);
										if _PingRespawn[i] >= Players[i].Ping then
											Players[i].WriteConsole('Ping Compensated Time: '+ShowTime(Timer - (1.0/86400000*Players[i].Ping)), $FF0000)
										else
											Players[i].WriteConsole('Ping Compensated Time: '+ShowTime(Timer - (1.0/86400000*_PingRespawn[i])), $FF0000);
									{$ENDIF}
								end;
						end else
							if (_CheckPointPassed[i] <> 0) and (_CheckPointPassed[i] = j) and (Distance(_CheckPoint[j].X, _CheckPoint[j].Y, Players[i].X, Players[i].Y) <= 30) and (Now - _Timer[i] >= 1.0/86400) then
								_CheckPointPassed[i] := j+1;
						
					end;
						
					if Ticks mod 15 = 0 then
						if j+1 = _CheckPointPassed[i] then
							Players[i].WorldText(j, IntToStr(j+1), 120, $00FF00, 0.3, _CheckPoint[j].X+65*-0.3, _CheckPoint[j].Y+120*-0.3)
						else
							Players[i].WorldText(j, IntToStr(j+1), 120, $FF0000, 0.3, _CheckPoint[j].X+65*-0.3, _CheckPoint[j].Y+120*-0.3);
						
				end;
				
				if (Players[i].Alive) and (not _EditMode) and (not _FlightMode[i]) and (not _GodMode[i]) then
					if (_CheckPointPassed[i] = Length(_CheckPoint)) and (Distance(_CheckPoint[0].X, _CheckPoint[0].Y, Players[i].X, Players[i].Y) <= 30) then begin
						Inc(_LapsPassed[i], 1);
						if _LapsPassed[i] = _Laps then begin
							Timer := Now - _Timer[i];
							{$IFDEF RUN_MODE_DEBUG}
								Players[i].WriteConsole('Respawn Ping: '+IntToStr(_PingRespawn[i])+', Finish Ping: '+IntToStr(Players[i].Ping), $FF0000);
							{$ENDIF}
						end else
							_CheckPointPassed[i] := 1;
					end;
				
			end else
				if length(_CheckPoint) = 1 then
					if _CheckPointPassed[i] = 1 then
						Players[i].WorldText(0, '1', 120, $00FF00, 0.3, _CheckPoint[0].X+65*-0.3, _CheckPoint[0].Y+120*-0.3)
					else
						Players[i].WorldText(0, '1', 120, $FF0000, 0.3, _CheckPoint[0].X+65*-0.3, _CheckPoint[0].Y+120*-0.3);
			
			if Timer > 0 then begin
				if Not DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Players[i].Name)+''' LIMIT 1;') then
					WriteLn('RunModeError23: '+DB_Error)
				else begin
					
					if DB_NextRow(DB_ID) then begin //If account was found
						TempTime := MapBestTime(Game.CurrentMap);
						if TempTime = -1 then begin
							
							Players.WriteConsole('[1] First score by '+Players[i].Name+': '+ShowTime(Timer), $FFD700);
							
							if _LoggedIn[i] then begin
								
								DB_Update(DB_ID, 'BEGIN TRANSACTION;');
								
									if Not DB_Update(DB_ID, 'INSERT INTO Scores(Account, Map, Date, Time) VALUES('''+EscapeApostrophe(Players[i].Name)+''', '''+EscapeApostrophe(Game.CurrentMap)+''', '+FloatToStr(Now)+', '+FloatToStr(Timer)+');') then //Add score
										WriteLn('RunModeError24: '+DB_Error)
									else begin
									
										if Not DB_Query(DB_ID, 'SELECT last_insert_rowid();') then
											WriteLn('RunModeError25: '+DB_Error)
										else begin
										
											DB_NextRow(DB_ID);
											
											if Not DB_Update(DB_ID, 'CREATE TABLE '''+DB_GetString(DB_ID, 0)+'''(Id INTEGER PRIMARY KEY, PosX Double, PosY Double);') then begin
												WriteLn('RunModeError26: '+DB_Error);
												Players.WriteConsole('RunModeError27: '+DB_Error, $FF0000);
											end else
												begin
													
													for j := 0 to High(_Record[i]) do
														if Not DB_Update(DB_ID, 'INSERT INTO '''+DB_GetString(DB_ID, 0)+'''(PosX, PosY) VALUES('+FloatToStr(_Record[i][j].X)+', '+FloatToStr(_Record[i][j].Y)+');') then
															WriteLn('RunModeError28: '+DB_Error);
													
												end;
												
										end;
										
									end;
								
								DB_Update(DB_ID, 'COMMIT;');
								
							end else
								Players.WriteConsole('Player '+Players[i].Name+' isn''t logged in - score wasn''t recorded', COLOR_1);
							
						end else
							begin
								TempTime2 := PlayerBestTime(Players[i].Name, Game.CurrentMap);
								
								if TempTime2 = -1 then begin
									
									DB_Update(DB_ID, 'BEGIN TRANSACTION;');
									
										if Not DB_Update(DB_ID, 'INSERT INTO Scores(Account, Map, Date, Time) VALUES('''+EscapeApostrophe(Players[i].Name)+''', '''+EscapeApostrophe(Game.CurrentMap)+''', '+FloatToStr(Now)+', '+FloatToStr(Timer)+');') then //Add score
											WriteLn('RunModeError29: '+DB_Error)
										else begin
									
											if Not DB_Query(DB_ID, 'SELECT last_insert_rowid();') then
												WriteLn('RunModeError30: '+DB_Error)
											else begin
											
												DB_NextRow(DB_ID);
												
												if Not DB_Update(DB_ID, 'CREATE TABLE '''+DB_GetString(DB_ID, 0)+'''(Id INTEGER PRIMARY KEY, PosX Double, PosY Double);') then begin
													WriteLn('RunModeError31: '+DB_Error);
													Players.WriteConsole('RunModeError32: '+DB_Error, $FF0000);
												end else
													begin
														
														for j := 0 to High(_Record[i]) do
															if Not DB_Update(DB_ID, 'INSERT INTO '''+DB_GetString(DB_ID, 0)+'''(PosX, PosY) VALUES('+FloatToStr(_Record[i][j].X)+', '+FloatToStr(_Record[i][j].Y)+');') then
																WriteLn('RunModeError33: '+DB_Error);
														
													end;
													
											end;
										
										end;
										
										if Not DB_Query(DB_ID, 'SELECT Account FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date;') then //Find position
											WriteLn('RunModeError34: '+DB_Error)
										else
											While DB_NextRow(DB_ID) Do begin
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
										
									if _LoggedIn[i] then
										DB_Update(DB_ID, 'COMMIT;')
									else begin
										DB_FinishQuery(DB_ID);
										DB_Update(DB_ID, 'ROLLBACK;');
										Players.WriteConsole('Player '+Players[i].Name+' isn''t logged in - score wasn''t recorded', COLOR_1);
									end;
										
								end else
									if Timer >= TempTime2 then
										Players.WriteConsole(ShowTime(Timer)+', Time was slower than '+Players[i].Name+'''s best by: '+ShowTime(Timer - TempTime2), COLOR_1)
									else begin
											
										DB_FinishQuery(DB_ID);
										
										DB_Update(DB_ID, 'BEGIN TRANSACTION;');
										
											if Not DB_Update(DB_ID, 'DROP TABLE '''+_ScoreId+''';') then
												WriteLn('RunModeError35: '+DB_Error);
											
											if Not DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Players[i].Name)+''' AND Map = '''+EscapeApostrophe(Game.CurrentMap)+''';') then //Del score
												WriteLn('RunModeError36: '+DB_Error);
												
											if Not DB_Update(DB_ID, 'INSERT INTO Scores(Account, Map, Date, Time) VALUES('''+EscapeApostrophe(Players[i].Name)+''', '''+EscapeApostrophe(Game.CurrentMap)+''', '+FloatToStr(Now)+', '+FloatToStr(Timer)+');') then //Add score
												WriteLn('RunModeError37: '+DB_Error)
											else begin
									
												if Not DB_Query(DB_ID, 'SELECT last_insert_rowid();') then
													WriteLn('RunModeError38: '+DB_Error)
												else begin
												
													DB_NextRow(DB_ID);
													
													if Not DB_Update(DB_ID, 'CREATE TABLE '''+DB_GetString(DB_ID, 0)+'''(Id INTEGER PRIMARY KEY, PosX Double, PosY Double);') then begin
														WriteLn('RunModeError39: '+DB_Error);
														Players.WriteConsole('RunModeError40: '+DB_Error, $FF0000);
													end else
														begin
															
															for j := 0 to High(_Record[i]) do
																if Not DB_Update(DB_ID, 'INSERT INTO '''+DB_GetString(DB_ID, 0)+'''(PosX, PosY) VALUES('+FloatToStr(_Record[i][j].X)+', '+FloatToStr(_Record[i][j].Y)+');') then
																	WriteLn('RunModeError41: '+DB_Error);
															
														end;
														
												end;
										
											end;
											
											if Not DB_Query(DB_ID, 'SELECT Account FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date;') then //Find position
												WriteLn('RunModeError42: '+DB_Error)
											else
												While DB_NextRow(DB_ID) Do begin
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
											
										if _LoggedIn[i] then
											DB_Update(DB_ID, 'COMMIT;')
										else begin
											DB_FinishQuery(DB_ID);
											DB_Update(DB_ID, 'ROLLBACK;');
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
								
								DB_Update(DB_ID, 'BEGIN TRANSACTION;');
								
									if Not DB_Update(DB_ID, 'INSERT INTO Scores(Account, Map, Date, Time) VALUES('''+EscapeApostrophe(Players[i].Name)+''', '''+EscapeApostrophe(Game.CurrentMap)+''', '+FloatToStr(Now)+', '+FloatToStr(Timer)+');') then //Add score
										WriteLn('RunModeError43: '+DB_Error);
									
									if Not DB_Query(DB_ID, 'SELECT Account FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date;') then //Find position
										WriteLn('RunModeError44: '+DB_Error)
									else
										While DB_NextRow(DB_ID) Do begin
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
								
								DB_FinishQuery(DB_ID);
								DB_Update(DB_ID, 'ROLLBACK;');
								
							end;
							Players.WriteConsole('Unregistered nickname: '+Players[i].Name+' - score wasn''t recorded', COLOR_1);
						end;
						
					DB_FinishQuery(DB_ID);
				end;
				
				Players[i].Damage(i, 150);
				Timer := 0;
			end;
			
			if _FlightMode[i] then begin
				Players[i].SetVelocity(0, 0);
				
				if Players[i].KeyJetpack then begin
					Players[i].Move(Players[i].MouseAimX, Players[i].MouseAimY);
					_LastPosX[i] := Players[i].MouseAimX;
					_LastPosY[i] := Players[i].MouseAimY;
				end else
					Players[i].Move(_LastPosX[i], _LastPosY[i]);
			end;
			
			if Ticks mod 3 = 0 then
				if (Players[i].KeyReload) and (_RKill[i]) and (not _EditMode) and (not _FlightMode[i]) and (not _GodMode[i]) then
					if length(_CheckPoint) <= 1 then
						Players[i].BigText(5, 'Checkpoints error', 120, $FF0000, 0.1, 320, 300)
					else
						Players[i].Damage(i, 150);
			
			//1 SEC INTERVAL LOOP
			if Ticks mod 60 = 0 then begin
				
				if _FlightMode[i] then
					Players[i].BigText(9, 'Flight', 120, COLOR_1, 0.1, 320, 150);
					
				if _GodMode[i] then
					Players[i].BigText(8, 'God', 120, COLOR_1, 0.1, 320, 180);
				
				if _EditMode then
					Players[i].BigText(7, 'EditMode', 120, COLOR_1, 0.1, 320, 210);
				
				if (not _LoggedIn[i]) and (Players[i].Team <> 5) then
					Players[i].BigText(4, 'Not logged in', 120, $FF0000, 0.1, 320, 240);
				
				if (Players[i].Alive) and (not _EditMode) and (not _FlightMode[i]) and (not _GodMode[i]) then
					if _CheckPointPassed[i] = 0 then
						Players[i].BigText(6, 'Press "Reload Key" to start', 120, COLOR_1, 0.1, 320, 270);
				
			end;
			//END OF 1 SEC INTERVAL LOOP
			
		end;
		
	if Ticks mod(3600*3) = 0 then
		Players.WriteConsole('!help - All you want to know, our Discord: https://discord.gg/Jr8CFQu', Random(0, 16777215+1));
	
	if Ticks mod(3600*40) = 0 then
		Players.WriteConsole('Official Soldat Discord: https://discord.gg/v9t82C9', Random(0, 16777215+1));
	
	if Ticks mod(3600*12) = 0 then begin
		Players.WriteConsole('Want to optimize your run & improve your time? Type !rme for more info', $c53159);
	end;
	
	if Ticks mod(216000*USED_IP_TIME) = 0 then begin
		_UsedIP.Clear;
		{$IFDEF RUN_MODE_DEBUG}
			WriteLn('RunMode: _UsedIP.Clear');
		{$ENDIF}
	end;
end;

function OnAdminCommand(Player: TActivePlayer; Command: string): boolean;
var
	i: Integer;
	StrToIntConv, StrToIntConv2: Integer;
	TimeStart: TDateTime;
	Ini: TIniFile;
	TempStrL: TStringList;
	TempX, TempY: Single;
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
	
	if Command = '/admcmds' then begin
		Player.WriteConsole('Commands for admins 1/2:', $FFFF00);
		Player.WriteConsole('RunMode:', COLOR_1);
		Player.WriteConsole('/recountallstats - Recounts all medals and creates new elite list', COLOR_2);
		Player.WriteConsole('/delacc <name> - Deletes certain account and it''s replays', COLOR_2);
		Player.WriteConsole('/delid <id> - Deletes certain score and it''s replay', COLOR_2);
		Player.WriteConsole('/emode - Enable/Disable editing mode for checkpoints', COLOR_2);
		Player.WriteConsole('/fmode - Enable/Disable flight mode (Enables god mode)', COLOR_2);
		Player.WriteConsole('/gmode - Enable/Disable god mode (Disables flight mode)', COLOR_2);
		Player.WriteConsole('/swap <cp1> <cp2> - Swaps checkpoints'' position', COLOR_2);
		Player.WriteConsole('/cpadd - Creates new checkpoint', COLOR_2);
		Player.WriteConsole('/cpdel - Deletes last checkpoint', COLOR_2);
		Player.WriteConsole('/cplaps <amount> - Sets amount of laps', COLOR_2);
		Player.WriteConsole('/cpsave - Saves current checkpoints'' setting', COLOR_2);
		Player.WriteConsole('/replay <id> - Replays certain score', COLOR_2);
		Player.WriteConsole('/replay2 <id> <id> - Replays two scores at the same time', COLOR_2);
		Player.WriteConsole('/replaystop - Stops all replays', COLOR_2);
		Player.WriteConsole('PlayersDB:', COLOR_1);
		Player.WriteConsole('/checkid <playerid(1-32)> - Check all nicks and entries for certain hwid', COLOR_2);
		Player.WriteConsole('/checknick <nick> - Check all hwids and entries for certain nick', COLOR_2);
		Player.WriteConsole('/checkhw <hwid> - Check all nicks and entries for certain hwid', COLOR_2);
		Player.WriteConsole('/admcmds2 - Commands for admins 2/2', $FFFF00);
	end;
	
	if Command = '/admcmds2' then begin
		Player.WriteConsole('Commands for admins 2/2:', $FFFF00);
		Player.WriteConsole('MapListReader:', COLOR_1);
		Player.WriteConsole('/createsortedmaplist - Create sorted MapList if current one is outdated', COLOR_2);
		Player.WriteConsole('/addmap <map name> - Add map to MapList (Default Soldat command)', COLOR_2);
		Player.WriteConsole('/delmap <map name> - Remove map from MapList (Default Soldat command)', COLOR_2);
		Player.WriteConsole('MapListRandomizer:', COLOR_1);
		Player.WriteConsole('/mlrand - Randomizes MapList', COLOR_2);
	end;
	
	if (Copy(Command, 1, 8) = '/delacc ') and (Copy(Command, 9, Length(Command)) <> nil) then
		if DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''' LIMIT 1;') then begin
		
			if DB_NextRow(DB_ID) then begin
				
				for i := 1 to 32 do
					if (Players[i].Active) and (Players[i].Name = Copy(Command, 9, Length(Command))) then
						_LoggedIn[i] := FALSE;
				
				DB_Update(DB_ID, 'BEGIN TRANSACTION;');
				
					TempStrL := File.CreateStringList;
					
					if Not DB_Query(DB_ID, 'SELECT Id FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') then
						Player.WriteConsole('RunModeError45: '+DB_Error, COLOR_1)
					else
						While DB_NextRow(DB_ID) Do
							TempStrL.Append(DB_GetString(DB_ID, 0));
							
					DB_FinishQuery(DB_ID);
						
					for i := 0 to TempStrL.Count-1 do
						if Not DB_Update(DB_ID, 'DROP TABLE '''+TempStrL[i]+''';') then
							Player.WriteConsole('RunModeError46: '+DB_Error, COLOR_1);
					
					TempStrL.Free;
					
					if Not DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') then
						Player.WriteConsole('RunModeError47: '+DB_Error, COLOR_1);
					
					if Not DB_Update(DB_ID, 'DELETE FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') then
						Player.WriteConsole('RunModeError48: '+DB_Error, COLOR_1);
				
				DB_Update(DB_ID, 'COMMIT;');
				
				Player.WriteConsole('Account "'+Copy(Command, 9, Length(Command))+'" has been deleted', COLOR_1);
				
			end else
				Player.WriteConsole('Account "'+Copy(Command, 9, Length(Command))+'" doesn''t exists', COLOR_1);
				
			DB_FinishQuery(DB_ID);
			
		end else
			Player.WriteConsole('RunModeError49: '+DB_Error, COLOR_1);
	
	if (Copy(Command, 1, 7) = '/delid ') and (Copy(Command, 8, Length(Command)) <> nil) then begin
		if Not DB_Update(DB_ID, 'DELETE FROM Scores WHERE Id = '''+EscapeApostrophe(Copy(Command, 8, Length(Command)))+''';') then
			Player.WriteConsole('RunModeError50: '+DB_Error, COLOR_1)
		else
			Player.WriteConsole('Score with Id '+Copy(Command, 8, Length(Command))+' has been deleted', COLOR_1);
		
		if Not DB_Update(DB_ID, 'DROP TABLE '''+EscapeApostrophe(Copy(Command, 8, Length(Command)))+''';') then
			Player.WriteConsole('RunModeError51: '+DB_Error, COLOR_1)
		else
			Player.WriteConsole('Replay with Id '+Copy(Command, 8, Length(Command))+' has been deleted', COLOR_1);
	end;
	
	if Command = '/fmode' then begin
		
		_LapsPassed[Player.ID] := 0;
		_CheckPointPassed[Player.ID] := 0;
		SetLength(_Record[Player.ID], 0);
		
		if _FlightMode[Player.ID] then begin
			_FlightMode[Player.ID] := False;
			Player.WriteConsole('Flight mode has been disabled', COLOR_1);
		end else
			begin
				_GodMode[Player.ID] := True;
				_FlightMode[Player.ID] := True;
				_LastPosX[Player.ID] := Player.X;
				_LastPosY[Player.ID] := Player.Y;
				Player.WriteConsole('Flight mode has been enabled', COLOR_1);
			end;
	end;
	
	if Command = '/gmode' then begin
		
		_LapsPassed[Player.ID] := 0;
		_CheckPointPassed[Player.ID] := 0;
		
		if _GodMode[Player.ID] then begin
			_FlightMode[Player.ID] := False;
			_GodMode[Player.ID] := False;
			Player.WriteConsole('God mode has been disabled', COLOR_1);
		end else
			begin
				_GodMode[Player.ID] := True;
				Player.WriteConsole('God mode has been enabled', COLOR_1);
			end;
	end;
	
	if Command = '/emode' then begin
		
		for i := 1 to 32 do begin
			_LapsPassed[i] := 0;
			_CheckPointPassed[i] := 0;
		end;
		
		if _EditMode then begin
			_EditMode := False;
			Players.WriteConsole('Editing mode has been disabled', COLOR_1);
		end else
			begin
				_EditMode := True;
				Players.WriteConsole('Editing mode has been enabled', COLOR_1);
			end;
	end;
	
	if (Copy(Command, 1, 6) = '/swap ') or (Command = '/swap') then
		if Copy(Command, 7, length(Command)) <> nil then begin
			Try
				StrToIntConv := StrToInt(GetPiece(Command, ' ', 1));
				StrToIntConv2 := StrToInt(GetPiece(Command, ' ', 2));
				if (StrToIntConv <= length(_CheckPoint)) and (StrToIntConv2 <= length(_CheckPoint)) and (StrToIntConv > 0) and (StrToIntConv2 > 0) then begin
					
					TempX := _CheckPoint[StrToIntConv-1].X;
					TempY := _CheckPoint[StrToIntConv-1].Y;
					
					_CheckPoint[StrToIntConv-1].X := _CheckPoint[StrToIntConv2-1].X;
					_CheckPoint[StrToIntConv-1].Y := _CheckPoint[StrToIntConv2-1].Y;
					
					_CheckPoint[StrToIntConv2-1].X := TempX;
					_CheckPoint[StrToIntConv2-1].Y := TempY;
					
					Player.WriteConsole('Checkpoints "'+GetPiece(Command, ' ', 1)+'" and "'+GetPiece(Command, ' ', 2)+'" have been swapped', COLOR_1);
					
				end else
					Player.WriteConsole('Out of bounds', COLOR_1);
			Except
				Player.WriteConsole('Invalid parameters', COLOR_1);
			end;
		end else
			Player.WriteConsole('Lack of parameters for command "/swap <cp1> <cp2>"', COLOR_2);
	
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
			
			Player.WriteConsole('Checkpoints'' setting saved', $00FF00);
		end;
	
	if (Copy(Command, 1, 8) = '/replay ') and (Length(Command)>8) then begin
		Delete(Command, 1, 8);
		
		Players.WriteConsole('Loading replay '+Command+'...', COLOR_1);
		
		if Not DB_Query(DB_ID, 'SELECT PosX, PosY FROM '''+EscapeApostrophe(Command)+''';') then
			Players.WriteConsole('RunModeError52: '+DB_Error, COLOR_1)
		else begin
			SetLength(_Replay, 0);
			_ReplayTime := 0;
			
			While DB_NextRow(DB_ID) Do begin
				SetLength(_Replay, Length(_Replay)+1);
				_Replay[High(_Replay)].X := DB_GetDouble(DB_ID, 0);
				_Replay[High(_Replay)].Y := DB_GetDouble(DB_ID, 1);
			end;
			
			if Length(_Replay) > 0 then begin
				
				DB_FinishQuery(DB_ID);
				
				if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT 1+(SELECT count(*) FROM Scores a WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' AND (a.Time < b.Time OR (a.Time = b.Time AND a.Date < b.Date))) AS Position, Time, Date, Id, Account FROM Scores b WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') WHERE Id = '''+EscapeApostrophe(Command)+''' LIMIT 1;') then
					WriteLn('RunModeError112: '+DB_Error)
				else
					if Not DB_NextRow(DB_ID) then begin
						Players.WriteConsole('Score for current map with ID '+Command+' not found', COLOR_2);
						_ReplayInfo := 'Wrong replay ID for current map';
					end else
						_ReplayInfo := '['+DB_GetString(DB_ID, 0)+'] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+DB_GetString(DB_ID, 4)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']';
				
				Players.WriteConsole('Replay loaded', COLOR_1);
				_WorldTextLoop := 200;
			end else
				Players.WriteConsole('Empty replay', COLOR_1);
		end;
		
		DB_FinishQuery(DB_ID);
	end;
	
	if (Copy(Command, 1, 9) = '/replay2 ') and (Length(Command)>9) then begin
		Delete(Command, 1, 9);
		
		Players.WriteConsole('Loading replays '+GetPiece(Command, ' ', 0)+'(red), '+GetPiece(Command, ' ', 1)+'(blue)...', COLOR_1);
		
		if Not DB_Query(DB_ID, 'SELECT PosX, PosY FROM '''+EscapeApostrophe(GetPiece(Command, ' ', 0))+''';') then
			Players.WriteConsole('RunModeError111: '+DB_Error, COLOR_1)
		else begin
			SetLength(_Replay, 0);
			_ReplayTime := 0;
			
			While DB_NextRow(DB_ID) Do begin
				SetLength(_Replay, Length(_Replay)+1);
				_Replay[High(_Replay)].X := DB_GetDouble(DB_ID, 0);
				_Replay[High(_Replay)].Y := DB_GetDouble(DB_ID, 1);
			end;
			
			if Length(_Replay) > 0 then begin
				
				DB_FinishQuery(DB_ID);
				
				if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT 1+(SELECT count(*) FROM Scores a WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' AND (a.Time < b.Time OR (a.Time = b.Time AND a.Date < b.Date))) AS Position, Time, Date, Id, Account FROM Scores b WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') WHERE Id = '''+EscapeApostrophe(GetPiece(Command, ' ', 0))+''' LIMIT 1;') then
					WriteLn('RunModeError112: '+DB_Error)
				else
					if Not DB_NextRow(DB_ID) then begin
						Players.WriteConsole('Score for current map with ID '+GetPiece(Command, ' ', 0)+' not found', COLOR_2);
						_ReplayInfo := 'Wrong replay ID for current map';
					end else
						_ReplayInfo := '['+DB_GetString(DB_ID, 0)+'] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+DB_GetString(DB_ID, 4)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']';
				
				Players.WriteConsole('Replay loaded', COLOR_1);
				_WorldTextLoop := 200;
			end else
				Players.WriteConsole('Empty replay', COLOR_1);
		end;
		
		DB_FinishQuery(DB_ID);
		
		if Not DB_Query(DB_ID, 'SELECT PosX, PosY FROM '''+EscapeApostrophe(GetPiece(Command, ' ', 1))+''';') then
			Players.WriteConsole('RunModeError112: '+DB_Error, COLOR_1)
		else begin
			SetLength(_Replay2, 0);
			_ReplayTime2 := 0;
			
			While DB_NextRow(DB_ID) Do begin
				SetLength(_Replay2, Length(_Replay2)+1);
				_Replay2[High(_Replay2)].X := DB_GetDouble(DB_ID, 0);
				_Replay2[High(_Replay2)].Y := DB_GetDouble(DB_ID, 1);
			end;
			
			if Length(_Replay2) > 0 then begin
				
				DB_FinishQuery(DB_ID);
				
				if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT 1+(SELECT count(*) FROM Scores a WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' AND (a.Time < b.Time OR (a.Time = b.Time AND a.Date < b.Date))) AS Position, Time, Date, Id, Account FROM Scores b WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') WHERE Id = '''+EscapeApostrophe(GetPiece(Command, ' ', 1))+''' LIMIT 1;') then
					WriteLn('RunModeError113: '+DB_Error)
				else
					if Not DB_NextRow(DB_ID) then begin
						Players.WriteConsole('Score for current map with ID '+GetPiece(Command, ' ', 1)+' not found', COLOR_2);
						_ReplayInfo2 := 'Wrong replay ID for current map';
					end else
						_ReplayInfo2 := '['+DB_GetString(DB_ID, 0)+'] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+DB_GetString(DB_ID, 4)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']';
				
				Players.WriteConsole('Replay2 loaded', COLOR_1);
				_WorldTextLoop2 := 150;
			end else
				Players.WriteConsole('Empty replay2', COLOR_1);
		end;
		
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/replaystop' then begin
		SetLength(_Replay, 0);
		_ReplayTime := 0;
		
		SetLength(_Replay2, 0);
		_ReplayTime2 := 0;
		
		Players.WriteConsole('All Replays stopped', COLOR_1);
	end;
	
//TEST ZONE
	
	if Command = '/lastscores' then begin
		Player.WriteConsole('Last 20 scores', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Account, Map, Date, Time FROM Scores ORDER BY Date DESC LIMIT 20;') then
			WriteLn('RunModeError53: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 1)+', Time: '+FloatToStr(DB_GetDouble(DB_ID, 3))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if (Copy(Command, 1, 8) = '/last30 ') and (Copy(Command, 9, Length(Command)) <> nil) then begin
		Player.WriteConsole(Copy(Command, 9, Length(Command))+'''s last 30 scores', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Map, Date, Time FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''' ORDER BY Date DESC LIMIT 30;') then
			WriteLn('RunModeError61: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 0)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 2))+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/disttest' then begin
		Players.WorldText(100, '.', 180, $FF0000, 0.15, Player.X, Player.Y);
		Players.WorldText(101, '.', 180, $00FF00, 0.15, Player.X+300, Player.Y);
	end;
	
	if Command = '/test4' then begin
		if Not DB_Query(DB_ID, 'SELECT Account, Map, Date, Time FROM Scores WHERE Time < 1.0/86400;') then
			WriteLn('RunModeError59: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				WriteLn('Map: '+DB_GetString(DB_ID, 1)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 3))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2)));
		DB_FinishQuery(DB_ID);
	end;
	
	{if Command = '/changenick' then begin
		if Not DB_Update(DB_ID, 'UPDATE Accounts SET Name = ''~>2Fast|`HaSte.|'' WHERE Name = ''bp.Energy'';') then
			Player.WriteConsole('RunModeError54: '+DB_Error, COLOR_1);
		if Not DB_Update(DB_ID, 'UPDATE Scores SET Account = ''~>2Fast|`HaSte.|'' WHERE Account = ''bp.Energy'';') then
			Player.WriteConsole('RunModeError55: '+DB_Error, COLOR_1);
	end;}
	
	{if Command = '/changemap' then begin
		if Not DB_Update(DB_ID, 'UPDATE Scores SET Map = ''s1_claustro'' WHERE Map = ''l1_claustro'';') then
			Player.WriteConsole('RunModeError56: '+DB_Error, COLOR_1);
	end;}
	
	{if Command = '/delbugtime' then begin
		if Not DB_Update(DB_ID, 'DELETE FROM Scores WHERE Time < 1.0/86400;') then
			Player.WriteConsole('RunModeError57: '+DB_Error, COLOR_1);
	end;}
	
	{if Command = '/delall' then begin
		if Not DB_Update(DB_ID, 'DELETE FROM Scores;') then
			Player.WriteConsole('RunModeError58: '+DB_Error, COLOR_1);
	end;}
	
	{if Command = '/query123' then begin
		DatabaseUpdate(DB_ID, 'ALTER TABLE Accounts ADD COLUMN Email TEXT;');
		DatabaseUpdate(DB_ID, 'ALTER TABLE Accounts ADD COLUMN Bookmarks TEXT;');
		DatabaseUpdate(DB_ID, 'ALTER TABLE Accounts ADD COLUMN PremiumExpiry DOUBLE;');
	end;}
	
	{if Command = '/delaero' then begin
		if Not DB_Update(DB_ID, 'DELETE FROM Scores WHERE Map = ''Aero'';') then
			Player.WriteConsole('RunModeError60: '+DB_Error, COLOR_1);
	end;}
	
end else
begin//TCP Admin
	
	if (Copy(Command, 1, 8) = '/delacc ') and (Copy(Command, 9, Length(Command)) <> nil) then
		if DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''' LIMIT 1;') then begin
		
			if DB_NextRow(DB_ID) then begin
				
				for i := 1 to 32 do
					if (Players[i].Active) and (Players[i].Name = Copy(Command, 9, Length(Command))) then
						_LoggedIn[i] := FALSE;
				
				DB_Update(DB_ID, 'BEGIN TRANSACTION;');
				
					TempStrL := File.CreateStringList;
					
					if Not DB_Query(DB_ID, 'SELECT Id FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') then
						WriteLn('RunModeError62: '+DB_Error)
					else
						While DB_NextRow(DB_ID) Do
							TempStrL.Append(DB_GetString(DB_ID, 0));
							
					DB_FinishQuery(DB_ID);
						
					for i := 0 to TempStrL.Count-1 do
						if Not DB_Update(DB_ID, 'DROP TABLE '''+TempStrL[i]+''';') then
							WriteLn('RunModeError63: '+DB_Error);
					
					TempStrL.Free;
					
					if Not DB_Update(DB_ID, 'DELETE FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') then
						WriteLn('RunModeError64: '+DB_Error);
					
					if Not DB_Update(DB_ID, 'DELETE FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Command, 9, Length(Command)))+''';') then
						WriteLn('RunModeError65: '+DB_Error);
				
				DB_Update(DB_ID, 'COMMIT;');
				
				WriteLn('Account "'+Copy(Command, 9, Length(Command))+'" has been deleted');
				
			end else
				WriteLn('Account "'+Copy(Command, 9, Length(Command))+'" doesn''t exists');
				
			DB_FinishQuery(DB_ID);
			
		end else
			WriteLn('RunModeError66: '+DB_Error);
	
	if (Copy(Command, 1, 7) = '/delid ') and (Copy(Command, 8, Length(Command)) <> nil) then begin
		if Not DB_Update(DB_ID, 'DELETE FROM Scores WHERE Id = '''+EscapeApostrophe(Copy(Command, 8, Length(Command)))+''';') then
			WriteLn('RunModeError67: '+DB_Error)
		else
			WriteLn('Score with Id '+Copy(Command, 8, Length(Command))+' has been deleted');
		
		if Not DB_Update(DB_ID, 'DROP TABLE '''+EscapeApostrophe(Copy(Command, 8, Length(Command)))+''';') then
			WriteLn('RunModeError68: '+DB_Error)
		else
			WriteLn('Replay with Id '+Copy(Command, 8, Length(Command))+' has been deleted');
	end;
	
end;
end;

function OnPlayerCommand(Player: TActivePlayer; Command: String): Boolean;
var
	TempNumber: Byte;
	MailTemplate, Bookmarks: TStringList;
	GeneratedCode, TempString: String;
	TempPChar: PChar;
	PosCounter: Integer;
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
		if Not DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError69: '+DB_Error)
		else begin
			if Not DB_NextRow(DB_ID) then begin
				if Not DB_Update(DB_ID, 'INSERT INTO Accounts(Name, Password, Hwid, Date) VALUES('''+EscapeApostrophe(Player.Name)+''', '''+EscapeApostrophe(Copy(Command, 10, Length(Command)))+''', '''+EscapeApostrophe(Player.HWID)+''', '+FloatToStr(Now)+');') then
					WriteLn('RunModeError70: '+DB_Error)
				else begin
					Player.WriteConsole('Account successfully created, remember your nickname and password!', COLOR_1);
					Player.WriteConsole('Now login for the first time with command /login <password>', COLOR_1);
				end;
			end else
				Player.WriteConsole('Account with that nickname already exists', COLOR_1);
			DB_FinishQuery(DB_ID);
		end;
			
	if (Copy(Command, 1, 7) = '/login ') and (Copy(Command, 8, Length(Command)) <> nil) then
		if Not DB_Query(DB_ID, 'SELECT Password FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError71: '+DB_Error)
		else begin
			if Not DB_NextRow(DB_ID) then
				Player.WriteConsole('Account with that nickname doesn''t exists', COLOR_1)
			else
				if String(DB_GetString(DB_ID, 0)) = Copy(Command, 8, Length(Command)) then begin
					Player.WriteConsole('You have successfully logged in!', COLOR_1);
					_LoggedIn[Player.ID] := TRUE;
				end else
					Player.WriteConsole('Wrong password', COLOR_1);
			DB_FinishQuery(DB_ID);
		end;
		
	if Command = '/logout' then begin
		_LoggedIn[Player.ID] := FALSE;
		Player.WriteConsole('You have logged out', COLOR_1);
	end;
		
	if (Copy(Command, 1, 7) = '/thief ') or (Command = '/thief') then
	if Copy(Command, 8, length(Command)) <> nil then begin
		Try
			TempNumber := StrToInt(GetPiece(Command, ' ', 1));
			if (TempNumber > 0) and (TempNumber < 33) then begin
				if TempNumber <> Player.ID then begin
					if Players[TempNumber].Active then begin
						if TempNumber > 9 then begin
							if Not DB_Query(DB_ID, 'SELECT Password FROM Accounts WHERE Name = '''+EscapeApostrophe(Players[TempNumber].Name)+''' LIMIT 1;') then
								WriteLn('RunModeError72: '+DB_Error)
							else begin
								if DB_NextRow(DB_ID) then begin
									if String(DB_GetString(DB_ID, 0)) = Copy(Command, 11, Length(Command)) then
										Players[TempNumber].Ban(1, 'You were banned for 1min due to occupying registered nickname')
									else
										Player.WriteConsole('"'+Copy(Command, 11, Length(Command))+'" is wrong password', COLOR_1);
								end else
									Player.WriteConsole('Account with nickname "'+Players[TempNumber].Name+'" doesn''t exists', COLOR_1);
								DB_FinishQuery(DB_ID);
							end;
						end else
							if Not DB_Query(DB_ID, 'SELECT Password FROM Accounts WHERE Name = '''+EscapeApostrophe(Players[TempNumber].Name)+''' LIMIT 1;') then
								WriteLn('RunModeError73: '+DB_Error)
							else begin
								if DB_NextRow(DB_ID) then begin
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
		if Not DB_Query(DB_ID, 'SELECT Date, Hwid, AutoLoginHwid FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError74: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
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
	
	if (Copy(Command, 1, 9) = '/addmail ') or (Command = '/addmail') then
		if ExecRegExpr('^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$', Copy(Command, 10, length(Command))) then begin
			
			if Not DB_Query(DB_ID, 'SELECT Email FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
				WriteLn('RunModeError75: '+DB_Error)
			else
				if Not DB_NextRow(DB_ID) then
					Player.WriteConsole('Unregistered nickname', COLOR_2)
				else
					if _LoggedIn[Player.ID] then begin
						
						if Not DB_Query(DB_ID, 'SELECT Email FROM Accounts WHERE Email = '''+EscapeApostrophe(Copy(Command, 10, length(Command)))+''' LIMIT 1;') then
							WriteLn('RunModeError75: '+DB_Error)
						else
							if Not DB_NextRow(DB_ID) then begin
						
								if _UsedIP.IndexOf(Player.IP) <> -1 then
									Player.WriteConsole('You can send only 1 e-mail every '+IntToStr(USED_IP_TIME)+iif(USED_IP_TIME > 1, ' hours', ' hour')+' for 1 IP', COLOR_2)
								else
									if not File.Exists(PATH_TO_FILES+'mail.txt') then begin
										
										GeneratedCode := MD5(FloatToStr(Now));
										
										if Not DB_Update(DB_ID, 'UPDATE Accounts SET Email = '''+EscapeApostrophe(GeneratedCode+' '+Copy(Command, 10, length(Command)))+''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') then
											WriteLn('RunModeError96: '+DB_Error)
										else begin
										
											MailTemplate := File.CreateStringList;
											MailTemplate.Append('To: '+Copy(Command, 10, length(Command)));
											MailTemplate.Append('Subject: Midgard e-mail confirmation');
											MailTemplate.Append('');
											MailTemplate.Append('Hello!');
											MailTemplate.Append('');
											MailTemplate.Append('Please confirm your e-mail by entering this command on our server:');
											MailTemplate.Append('/confirmemail '+GeneratedCode);
											MailTemplate.Append('');
											MailTemplate.Append('Details');
											MailTemplate.Append('Player Name: '+Player.Name);
											MailTemplate.Append('Player IP: '+Player.IP);
											MailTemplate.Append('');
											MailTemplate.Append('Best regards');
											MailTemplate.Append('Midgard Team');
											MailTemplate.SaveToFile(PATH_TO_FILES+'mail.txt');
											MailTemplate.Free;
											
											Player.WriteConsole('Confirmation code has been sent to your mailbox', $4B7575);
											
											_UsedIP.Append(Player.IP);
											
										end;
										
									end else Player.WriteConsole('Post office is busy, please wait at least 1min...', $FF0000);
								
							end else Player.WriteConsole('This e-mail is already confirmed', $FF0000);
						
					end else
						Player.WriteConsole('You''re not logged in', COLOR_2);
						
			DB_FinishQuery(DB_ID);
		end else Player.WriteConsole('Wrong e-mail format', $FF0000);
	
	if (Copy(Command, 1, 14) = '/confirmemail ') or (Command = '/confirmemail') then
		if Copy(Command, 15, length(Command)) <> nil then begin
			
			if Not DB_Query(DB_ID, 'SELECT Email FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
				WriteLn('RunModeError75: '+DB_Error)
			else
				if Not DB_NextRow(DB_ID) then
					Player.WriteConsole('Unregistered nickname', COLOR_2)
				else
					if _LoggedIn[Player.ID] then begin
						
						TempString := DB_GetString(DB_ID, 0);
						
						if TempString <> nil then begin
							
							if not ExecRegExpr('^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$', TempString) then begin
								
								if Copy(TempString, 1, 32) = Copy(Command, 15, Length(Command)) then begin
									
									if Not DB_Update(DB_ID, 'UPDATE Accounts SET Email = '''+EscapeApostrophe(Copy(TempString, 34, Length(TempString)))+''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') then
										WriteLn('RunModeError76: '+DB_Error)
									else
										Player.WriteConsole('E-mail confirmation successful', COLOR_1);
									
								end else Player.WriteConsole('Invalid code', COLOR_2);
								
							end else Player.WriteConsole('Your e-mail is already confirmed', COLOR_2);
							
						end else Player.WriteConsole('You have no e-mail to be confirmed', COLOR_2);
						
					end else Player.WriteConsole('You''re not logged in', COLOR_2);
					
			DB_FinishQuery(DB_ID);
		end else Player.WriteConsole('You have to enter the code that has been sent to your mailbox (/confirmemail <code>)', $FF0000);
	
	if (Copy(Command, 1, 12) = '/passremind ') or (Command = '/passremind') then
		if Copy(Command, 13, length(Command)) <> nil then begin
			if Not DB_Query(DB_ID, 'SELECT Password, Email FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
				WriteLn('RunModeError75: '+DB_Error)
			else
				if Not DB_NextRow(DB_ID) then
					Player.WriteConsole('Unregistered nickname', COLOR_2)
				else begin
					
					TempString := DB_GetString(DB_ID, 1);
					
					if ExecRegExpr('^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$', TempString) then begin
						
						if Copy(Command, 13, length(Command)) = TempString then begin
							
							if _UsedIP.IndexOf(Player.IP) = -1 then begin
								
								MailTemplate := File.CreateStringList;
								MailTemplate.Append('To: '+TempString);
								MailTemplate.Append('Subject: Midgard password reminder');
								MailTemplate.Append('');
								MailTemplate.Append('Hello!');
								MailTemplate.Append('');
								MailTemplate.Append('Your password: '+DB_GetString(DB_ID, 0));
								MailTemplate.Append('');
								MailTemplate.Append('Best regards');
								MailTemplate.Append('Midgard Team');
								MailTemplate.SaveToFile(PATH_TO_FILES+'mail.txt');
								MailTemplate.Free;
								
								Player.WriteConsole('Password has been sent to your mailbox', $4B7575);
								
								_UsedIP.Append(Player.IP);
								
							end else Player.WriteConsole('You can send only 1 e-mail every '+IntToStr(USED_IP_TIME)+iif(USED_IP_TIME > 1, ' hours', ' hour')+' for 1 IP', COLOR_2);
							
						end else Player.WriteConsole('Wrong e-mail', $FF0000);
						
					end else Player.WriteConsole('You have no confirmed e-mail', COLOR_2);
					
				end;
			DB_FinishQuery(DB_ID);
		end else Player.WriteConsole('You have to enter the e-mail assigned to this account (/passremind <e-mail>)', $FF0000);
	
	if Command = '/maildel' then begin
		if Not DB_Query(DB_ID, 'SELECT Email FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError77: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET Email = '''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') then
						WriteLn('RunModeError78: '+DB_Error)
					else
						Player.WriteConsole('You''ve deleted your e-mail', COLOR_1);
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/aladd' then begin
		if Not DB_Query(DB_ID, 'SELECT Name FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError75: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET AutoLoginHwid = '''+EscapeApostrophe(Player.HWID)+''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') then
						WriteLn('RunModeError76: '+DB_Error)
					else
						Player.WriteConsole('You''ve set this machine "'+Player.HWID+'" for auto login', COLOR_1);
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/aldel' then begin
		if Not DB_Query(DB_ID, 'SELECT AutoLoginHwid FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError77: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					if Not DB_Update(DB_ID, 'UPDATE Accounts SET AutoLoginHwid = '''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') then
						WriteLn('RunModeError78: '+DB_Error)
					else
						Player.WriteConsole('You''ve deleted machine "'+DB_GetString(DB_ID, 0)+'" for auto login', COLOR_1);
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/bmadd' then begin
		if Not DB_Query(DB_ID, 'SELECT Bookmarks FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError75: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					
					TempPChar := DB_GetString(DB_ID, 0);
					
					Bookmarks := File.CreateStringList;
					Bookmarks.SetText(TempPChar);
					
					if Bookmarks.Count < 10 then begin
						
						Bookmarks.Append(Game.CurrentMap);
						
						if Not DB_Update(DB_ID, 'UPDATE Accounts SET Bookmarks = '''+EscapeApostrophe(Bookmarks.GetText)+''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') then
							WriteLn('RunModeError76: '+DB_Error)
						else
							Player.WriteConsole('Added map "'+Game.CurrentMap+'" to bookmarks', COLOR_1);
							
					end else
						Player.WriteConsole('Bookmarks limit reached', COLOR_2);
					
					Bookmarks.Free;
					
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/bmdel' then begin
		if Not DB_Query(DB_ID, 'SELECT Bookmarks FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError75: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					
					TempPChar := DB_GetString(DB_ID, 0);
					
					if TempPChar <> nil then begin
						
						Bookmarks := File.CreateStringList;
						Bookmarks.SetText(TempPChar);
						TempString := Bookmarks[Bookmarks.Count-1];
						Bookmarks.Delete(Bookmarks.Count-1);
						
						if Not DB_Update(DB_ID, 'UPDATE Accounts SET Bookmarks = '''+EscapeApostrophe(Bookmarks.GetText)+''' WHERE Name = '''+EscapeApostrophe(Player.Name)+''';') then
							WriteLn('RunModeError76: '+DB_Error)
						else
							Player.WriteConsole('Deleted map "'+TempString+'" from bookmarks', COLOR_1);
						
						Bookmarks.Free;
						
					end else
						Player.WriteConsole('Bookmarks are already cleared', COLOR_2);
					
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Command = '/bmlist' then begin
		if Not DB_Query(DB_ID, 'SELECT Bookmarks FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError75: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Player.WriteConsole('Unregistered nickname', COLOR_2)
			else
				if _LoggedIn[Player.ID] then begin
					
					TempPChar := DB_GetString(DB_ID, 0);
					
					Bookmarks := File.CreateStringList;
					Bookmarks.SetText(TempPChar);
					
					Player.WriteConsole('Your bookmarks:', COLOR_1);
					
					for PosCounter := 0 to Bookmarks.Count-1 do
						Player.WriteConsole(Bookmarks[PosCounter], COLOR_2);
					
					Bookmarks.Free;
					
				end else
					Player.WriteConsole('You''re not logged in', COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
end;

procedure OnPlayerSpeak(Player: TActivePlayer; Text: String);
var
	PosCounter, j: Integer;
	TempString: String;
	TopName, TopAmount: TStringList;
begin
	if Copy(Text, 1, 1) = '/' then
		Player.WriteConsole('DO NOT TYPE "/" COMMANDS IN CHAT CONSOLE, PRESS "/" KEY TO ENABLE COMMANDS CONSOLE', $FF0000);
	
	if Text = '!help' then begin
		Player.WriteConsole('Welcome to Run Mode!', COLOR_1);
		Player.WriteConsole('First of all, You have to make an account with command /account <password>,', COLOR_2);
		Player.WriteConsole('otherwise Your scores won''t be recorded.', COLOR_2);
		Player.WriteConsole('Please read !rules and !commands.', COLOR_2);
		Player.WriteConsole('Medals are recounted on map change.', COLOR_2);
	end;
	
	if Text = '!commands' then begin
		Player.WriteConsole('Run Mode commands 1/2:', COLOR_1);
		Player.WriteConsole('!whois - Shows connected admins', COLOR_2);
		Player.WriteConsole('!admin/nick - Call connected TCP admin', COLOR_2);
		Player.WriteConsole('!track <nickname> - Check ping of certain player', COLOR_2);
		Player.WriteConsole('!v - Start vote for next map', COLOR_2);
		Player.WriteConsole('!ultv - Ultimate Vote commands', COLOR_2);
		Player.WriteConsole('!elite - Shows 20 best players', COLOR_2);
		Player.WriteConsole('!top <map name> - Shows 3 best scores of certain map', COLOR_2);
		Player.WriteConsole('!top10|20 <map name> - Shows 10|20 best scores of certain map', COLOR_2);
		Player.WriteConsole('!scores - Shows online players'' scores', COLOR_2);
		Player.WriteConsole('!score <nickname> - Shows certain player''s score on current map', COLOR_2);
		Player.WriteConsole('!last10|20scores - Shows last 10|20 scores', COLOR_2);
		Player.WriteConsole('!last10|20 <nickname> - Shows last 10|20 scores of certain player', COLOR_2);
		Player.WriteConsole('!mlr - MapListReader commands', COLOR_2);
		Player.WriteConsole('!player <nickname> - Shows stats of certain player', COLOR_2);
		Player.WriteConsole('!report <text> - Sends an e-mail to Midgard Admins', COLOR_2);
		Player.WriteConsole('!mcommands - E-mail commands', COLOR_2);
		Player.WriteConsole('!commands2 - Run Mode commands 2/2', COLOR_2);
		Player.WriteConsole('/admcmds - Commands for admins 1/2', $FFFF00);
		Player.WriteConsole('/admcmds2 - Commands for admins 2/2', $FFFF00);
		Player.WriteConsole('!rme - Essential resource to optimize your runs & improve your times', $c53159);
	end;
	
	if Text = '!commands2' then begin
		Player.WriteConsole('Run Mode commands 2/2:', COLOR_1);
		Player.WriteConsole('/settings - Shows your account settings', COLOR_2);
		Player.WriteConsole('/aladd - Set your machine to auto login', COLOR_2);
		Player.WriteConsole('/aldel - Delete machine for auto login', COLOR_2);
		Player.WriteConsole('/timer - Enable/Disable timer', COLOR_2);
		Player.WriteConsole('/ron - Make "Reload Key" to reset the timer (Default)', COLOR_2);
		Player.WriteConsole('/roff - Disable "Reload Key" function', COLOR_2);
		Player.WriteConsole('/account <password> - Create an account', COLOR_2);
		Player.WriteConsole('/login <password> - Login to your account', COLOR_2);
		Player.WriteConsole('/logout - Logout from your account', COLOR_2);
		Player.WriteConsole('/thief <id> <password> - Kick the player who''s taking your nickname', COLOR_2);
	end;
	
	if Text = '!rme' then begin
		Player.WriteConsole('Visit the Runmode Movement Encyclopedia: https://bit.ly/2XLin0c', $c53159);
		Player.WriteConsole('If you have any suggestions/questions, contact rusty via Discord @rusty#6917', $c53159);
	end;
	
	if Text = '!mcommands' then begin
		Player.WriteConsole('E-mail commands:', COLOR_1);
		Player.WriteConsole('/addmail <e-mail> - Adds e-mail for your account', COLOR_2);
		Player.WriteConsole('/confirmemail <code> - Confirms your e-mail', COLOR_2);
		Player.WriteConsole('/passremind <e-mail> - Reminds your password', COLOR_2);
		Player.WriteConsole('/maildel - Deletes your e-mail', COLOR_2);
	end;
	
	if Text = '!ultv' then begin
		Player.WriteConsole('Ultimate Vote commands:', COLOR_1);
		Player.WriteConsole('!map - Shows previous, current and next map name', COLOR_2);
		Player.WriteConsole('/votemap <mapname> - Starts vote for certain map', COLOR_2);
		Player.WriteConsole('/votekick <playerid> - Starts vote to ban certain player for 1 hour', COLOR_2);
		Player.WriteConsole('/voteres - Starts vote to restart current map', COLOR_2);
		Player.WriteConsole('/voteprev - Starts vote for previous map', COLOR_2);
		Player.WriteConsole('/votenext - Disabled, use !v instead', COLOR_2);
		Player.WriteConsole('Type /yes to accept or /no to reject the vote', COLOR_2);
	end;
	
	if Text = '!mlr' then begin
		Player.WriteConsole('MapListReader commands:', COLOR_1);
		Player.WriteConsole('/maplist - Show MapList', COLOR_2);
		Player.WriteConsole('/smaplist - Show sorted MapList', COLOR_2);
		Player.WriteConsole('/searchmap <pattern> - Show all maps containing searched pattern', COLOR_2);
		Player.WriteConsole('/showmapid - Show map index from MapList in SearchResult, do it before searching', COLOR_2);
		Player.WriteConsole('/page <number> - Change page to <number>, type "/page 0" to close', COLOR_2);
		Player.WriteConsole('You can also hold "Crouch"(forward) or "Jump"(back) key to change page', COLOR_2);
	end;
	
	{if Text = '!rules' then begin
		Player.WriteConsole('Run Mode rules:', COLOR_1);
		Player.WriteConsole('DO NOT troll.', COLOR_2);
		Player.WriteConsole('DO NOT call admins without a reason.', COLOR_2);
		Player.WriteConsole('DO NOT spam.', COLOR_2);
		Player.WriteConsole('DO NOT cheat.', COLOR_2);
		Player.WriteConsole('DO NOT verbal abuse other players, don''t be racist.', COLOR_2);
		Player.WriteConsole('Have fun and good luck!', COLOR_2);
	end;}
	
	if Text = '!player' then begin
		Players.WriteConsole(Player.Name+'''s stats', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Gold, Silver, Bronze, NoMedal, Points FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError79: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Players.WriteConsole('Unregistered nickname', COLOR_2)
			else begin
				Players.WriteConsole('Scores: '+IntToStr(DB_GetLong(DB_ID, 0)+DB_GetLong(DB_ID, 1)+DB_GetLong(DB_ID, 2)+DB_GetLong(DB_ID, 3)), COLOR_2);
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
		if Not DB_Query(DB_ID, 'SELECT Gold, Silver, Bronze, NoMedal, Points FROM Accounts WHERE Name = '''+EscapeApostrophe(Copy(Text, 9, Length(Text)))+''' LIMIT 1;') then
			WriteLn('RunModeError80: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Players.WriteConsole('Unregistered nickname', COLOR_2)
			else begin
				Players.WriteConsole('Scores: '+IntToStr(DB_GetLong(DB_ID, 0)+DB_GetLong(DB_ID, 1)+DB_GetLong(DB_ID, 2)+DB_GetLong(DB_ID, 3)), COLOR_2);
				Players.WriteConsole('Points: '+DB_GetString(DB_ID, 4), COLOR_2);
				Players.WriteConsole('Gold: '+DB_GetString(DB_ID, 0), $FFD700);
				Players.WriteConsole('Silver: '+DB_GetString(DB_ID, 1), $C0C0C0);
				Players.WriteConsole('Bronze: '+DB_GetString(DB_ID, 2), $F4A460);
				Players.WriteConsole('NoMedal: '+DB_GetString(DB_ID, 3), COLOR_2);
			end;
		DB_FinishQuery(DB_ID);
	end;
	
	if Text = '!scores' then begin
		TopName := File.CreateStringList;
		TopAmount := File.CreateStringList;
		Player.WriteConsole('Online players'' scores', COLOR_1);
		for PosCounter := 1 to 32 do
			if Players[PosCounter].Active then begin
				//Does not work, sqlite ver. too old :( ? if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT ROW_NUMBER () OVER (ORDER BY Time, Date) Position, Time, Date, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') AS ScoresResultSet WHERE Account = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
				if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT 1+(SELECT count(*) FROM Scores a WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' AND (a.Time < b.Time OR (a.Time = b.Time AND a.Date < b.Date))) AS Position, Time, Date, Id, Account FROM Scores b WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') WHERE Account = '''+EscapeApostrophe(Players[PosCounter].Name)+''' LIMIT 1;') then
					WriteLn('RunModeError110: '+DB_Error)
				else
					if DB_NextRow(DB_ID) then begin
						TopName.Append(ShowTime(DB_GetDouble(DB_ID, 1))+' by '+Players[PosCounter].Name+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']');
						TopAmount.Append(DB_GetString(DB_ID, 0));
						
						for j := TopName.Count-1 downto 1 do
							if StrToInt(TopAmount[j]) < StrToInt(TopAmount[j-1]) then begin
								TopName.Exchange(j-1, j);
								TopAmount.Exchange(j-1, j);
							end else break;
					end;
				DB_FinishQuery(DB_ID);
			end;
		
		for PosCounter := 0 to TopName.Count-1 do
			case StrToInt(TopAmount[PosCounter]) of
				1 : Player.WriteConsole('[1] '+TopName[PosCounter], $FFD700);
				2 : Player.WriteConsole('[2] '+TopName[PosCounter], $C0C0C0);
				3 : Player.WriteConsole('[3] '+TopName[PosCounter], $F4A460);
				else Player.WriteConsole('['+TopAmount[PosCounter]+'] '+TopName[PosCounter], COLOR_1);
			end;
		
		TopName.Free;
		TopAmount.Free;
	end;
	
	if Text = '!score' then begin
		Players.WriteConsole(Player.Name+'''s score', COLOR_1);
		//Does not work, sqlite ver. too old :( ? if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT ROW_NUMBER () OVER (ORDER BY Time, Date) Position, Time, Date, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') AS ScoresResultSet WHERE Account = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
		if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT 1+(SELECT count(*) FROM Scores a WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' AND (a.Time < b.Time OR (a.Time = b.Time AND a.Date < b.Date))) AS Position, Time, Date, Id, Account FROM Scores b WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') WHERE Account = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
			WriteLn('RunModeError108: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Players.WriteConsole('Score not found', COLOR_2)
			else
				case DB_GetLong(DB_ID, 0) of
					1 : Players.WriteConsole('[1] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+Player.Name+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']', $FFD700);
					2 : Players.WriteConsole('[2] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+Player.Name+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']', $C0C0C0);
					3 : Players.WriteConsole('[3] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+Player.Name+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']', $F4A460);
					else Players.WriteConsole('['+DB_GetString(DB_ID, 0)+'] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+Player.Name+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']', COLOR_1);
				end;
		DB_FinishQuery(DB_ID);
	end;
	
	if (Copy(Text, 1, 7) = '!score ') and (Copy(Text, 8, Length(Text)) <> nil) then begin
		TempString := Copy(Text, 8, Length(Text));
		Players.WriteConsole(TempString+'''s score', COLOR_1);
		//Does not work, sqlite ver. too old :( ? if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT ROW_NUMBER () OVER (ORDER BY Time, Date) Position, Time, Date, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') AS ScoresResultSet WHERE Account = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
		if Not DB_Query(DB_ID, 'SELECT * FROM (SELECT 1+(SELECT count(*) FROM Scores a WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' AND (a.Time < b.Time OR (a.Time = b.Time AND a.Date < b.Date))) AS Position, Time, Date, Id, Account FROM Scores b WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''') WHERE Account = '''+EscapeApostrophe(TempString)+''' LIMIT 1;') then
			WriteLn('RunModeError109: '+DB_Error)
		else
			if Not DB_NextRow(DB_ID) then
				Players.WriteConsole('Score not found', COLOR_2)
			else
				case DB_GetLong(DB_ID, 0) of
					1 : Players.WriteConsole('[1] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+TempString+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']', $FFD700);
					2 : Players.WriteConsole('[2] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+TempString+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']', $C0C0C0);
					3 : Players.WriteConsole('[3] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+TempString+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']', $F4A460);
					else Players.WriteConsole('['+DB_GetString(DB_ID, 0)+'] '+ShowTime(DB_GetDouble(DB_ID, 1))+' by '+TempString+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2))+' ['+DB_GetString(DB_ID, 3)+']', COLOR_1);
				end;
		DB_FinishQuery(DB_ID);
	end;
	
	if Text = '!top' then begin
		Players.WriteConsole(Game.CurrentMap+' TOP3', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date LIMIT 3;') then
			WriteLn('RunModeError81: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) Do begin
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
		if Not DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Copy(Text, 6, Length(Text)))+''' ORDER BY Time, Date LIMIT 3;') then
			WriteLn('RunModeError82: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) Do begin
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
		if Not DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date LIMIT 10;') then
			WriteLn('RunModeError83: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) Do begin
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
		if Not DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Copy(Text, 8, Length(Text)))+''' ORDER BY Time, Date LIMIT 10;') then
			WriteLn('RunModeError84: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) Do begin
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
	
	if Text = '!top20' then begin
		Player.WriteConsole(Game.CurrentMap+' TOP20', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Game.CurrentMap)+''' ORDER BY Time, Date LIMIT 20;') then
			WriteLn('RunModeError83: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) Do begin
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
	
	if (Copy(Text, 1, 7) = '!top20 ') and (Copy(Text, 8, Length(Text)) <> nil) then begin
		Player.WriteConsole(Copy(Text, 8, Length(Text))+' TOP20', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Account, Date, Time, Id FROM Scores WHERE Map = '''+EscapeApostrophe(Copy(Text, 8, Length(Text)))+''' ORDER BY Time, Date LIMIT 20;') then
			WriteLn('RunModeError84: '+DB_Error)
		else begin
			While DB_NextRow(DB_ID) Do begin
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
	
	if Text = '!last10scores' then begin
		Player.WriteConsole('Last 10 scores', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Account, Map, Date, Time FROM Scores ORDER BY Date DESC LIMIT 10;') then
			WriteLn('RunModeError85: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 1)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 3))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Text = '!last20scores' then begin
		Player.WriteConsole('Last 20 scores', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Account, Map, Date, Time FROM Scores ORDER BY Date DESC LIMIT 20;') then
			WriteLn('RunModeError85: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 1)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 3))+' by '+DB_GetString(DB_ID, 0)+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 2)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	{$IFDEF CLIMB}
		if Text = '!elite' then begin
			Player.WriteConsole('Points: Gold-12, Silver-6, Bronze-3, NoMedal-1', COLOR_1);
			for PosCounter := 0 to _EliteList.Count-1 do
				Player.WriteConsole(_EliteList[PosCounter], COLOR_2);
		end;
	{$ELSE}
		if Text = '!elite' then begin
			Player.WriteConsole('Points: Gold-25, Silver-20, Bronze-15, UpTo10th-10, 7, 5, 4, 3, 2, 1', COLOR_1);
			for PosCounter := 0 to _EliteList.Count-1 do
				Player.WriteConsole(_EliteList[PosCounter], COLOR_2);
		end;
	{$ENDIF}
	
	if Text = '!last10' then begin
		Player.WriteConsole(Player.Name+'''s last 10 scores', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Map, Date, Time FROM Scores WHERE Account = '''+EscapeApostrophe(Player.Name)+''' ORDER BY Date DESC LIMIT 10;') then
			WriteLn('RunModeError86: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 0)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 2))+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if (Copy(Text, 1, 8) = '!last10 ') and (Copy(Text, 9, Length(Text)) <> nil) then begin
		Player.WriteConsole(Copy(Text, 9, Length(Text))+'''s last 10 scores', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Map, Date, Time FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Text, 9, Length(Text)))+''' ORDER BY Date DESC LIMIT 10;') then
			WriteLn('RunModeError87: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 0)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 2))+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if Text = '!last20' then begin
		Player.WriteConsole(Player.Name+'''s last 20 scores', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Map, Date, Time FROM Scores WHERE Account = '''+EscapeApostrophe(Player.Name)+''' ORDER BY Date DESC LIMIT 20;') then
			WriteLn('RunModeError86: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 0)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 2))+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
	
	if (Copy(Text, 1, 8) = '!last20 ') and (Copy(Text, 9, Length(Text)) <> nil) then begin
		Player.WriteConsole(Copy(Text, 9, Length(Text))+'''s last 20 scores', COLOR_1);
		if Not DB_Query(DB_ID, 'SELECT Map, Date, Time FROM Scores WHERE Account = '''+EscapeApostrophe(Copy(Text, 9, Length(Text)))+''' ORDER BY Date DESC LIMIT 20;') then
			WriteLn('RunModeError87: '+DB_Error)
		else
			While DB_NextRow(DB_ID) Do
				Player.WriteConsole('Map: '+DB_GetString(DB_ID, 0)+', Time: '+ShowTime(DB_GetDouble(DB_ID, 2))+' on '+FormatDateTime('yyyy.mm.dd hh:nn:ss', DB_GetDouble(DB_ID, 1)), COLOR_2);
		DB_FinishQuery(DB_ID);
	end;
end;

procedure OnJoin(Player: TActivePlayer; Team: TTeam);
begin
	if Not DB_Query(DB_ID, 'SELECT AutoLoginHwid FROM Accounts WHERE Name = '''+EscapeApostrophe(Player.Name)+''' LIMIT 1;') then
		WriteLn('RunModeError88: '+DB_Error)
	else begin
		if DB_NextRow(DB_ID) then begin
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
	
	Player.WriteConsole('Remember to disable weapons'' menu to start faster (Tab key)', Random(0, 16777215+1));
end;

procedure OnJoinSpec(Player: TActivePlayer; Team: TTeam);
begin
	SetLength(_Record[Player.ID], 0);
	_JustDied[Player.ID] := False;
end;

procedure OnLeave(Player: TActivePlayer; Kicked: Boolean);
begin
	_ShowTimer[Player.ID] := FALSE;
	_LoggedIn[Player.ID] := FALSE;
	SetLength(_Record[Player.ID], 0);
	_JustDied[Player.ID] := False;
	_GodMode[Player.ID] := False;
	_FlightMode[Player.ID] := False;
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
	
	//Stop Replays
	SetLength(_Replay, 0);
	_ReplayTime := 0;
		
	SetLength(_Replay2, 0);
	_ReplayTime2 := 0;
	
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
	if (BulletId = 255) or (Shooter.ID = Victim.ID) then
		Result := Damage
	else
		Result := 0;
		
	if _GodMode[Victim.ID] then begin
		if Damage*-1 = Abs(Damage) then
			Result := Damage
		else
			Result := 0;
			
		if Victim.Health - Damage <= 0 then begin
			Victim.BigText(8, 'God', 120, $FF0000, 0.12, 320, 180);
			Victim.Health := 150;
		end;
	end;
end;

procedure OnKill(Killer, Victim: TActivePlayer; BulletId: Byte);
begin
	_JustDied[Victim.ID] := True;
end;

function OnBeforeRespawn(Player: TActivePlayer): TVector;
begin
	if length(_CheckPoint) > 1 then begin
		Result.X := _CheckPoint[0].X;
		Result.Y := _CheckPoint[0].Y;
	end;
end;

procedure OnAfterRespawn(Player: TActivePlayer);
begin
	if length(_CheckPoint) > 1 then begin
		if _JustDied[Player.ID] then begin
			SetLength(_Record[Player.ID], 1);
			_Record[Player.ID][0].X := Player.X;
			_Record[Player.ID][0].Y := Player.Y;
			_LapsPassed[Player.ID] := 0;
			_CheckPointPassed[Player.ID] := 1;
			_Timer[Player.ID] := Now;
			{$IFDEF RUN_MODE_DEBUG}
				_PingRespawn[Player.ID] := Player.Ping;
			{$ENDIF}
			_JustDied[Player.ID] := False;
		end else
			begin
				SetLength(_Record[Player.ID], 0);
				_LapsPassed[Player.ID] := 0;
				_CheckPointPassed[Player.ID] := 0;
			end;
	end else
		Player.BigText(5, 'Checkpoints error', 120, $FF0000, 0.1, 320, 300);
end;

procedure Init;
var
	i: Byte;
	DBFile: TFileStream;
	Query: String;
begin
	if not File.Exists(DB_NAME) then begin
		DBFile := File.CreateFileStream;
		DBFile.SaveToFile(DB_NAME);
		DBFile.Free;
		WriteLn('Database "'+DB_NAME+'" has been created');
		if DatabaseOpen(DB_ID, DB_NAME, '', '', DB_Plugin_SQLite) then begin
			Query := 'CREATE TABLE Accounts(Id INTEGER PRIMARY KEY,';
			Query := Query+'Name TEXT,';
			Query := Query+'Password TEXT,';
			Query := Query+'Hwid TEXT,';
			Query := Query+'Date DOUBLE,';
			Query := Query+'Gold INTEGER DEFAULT 0,';
			Query := Query+'Silver INTEGER DEFAULT 0,';
			Query := Query+'Bronze INTEGER DEFAULT 0,';
			Query := Query+'NoMedal INTEGER DEFAULT 0,';
			Query := Query+'AutoLoginHwid TEXT,';
			Query := Query+'Points INTEGER DEFAULT 0,';
			Query := Query+'Email TEXT,';
			Query := Query+'Bookmarks TEXT,';
			Query := Query+'PremiumExpiry DOUBLE);';
			DatabaseUpdate(DB_ID, Query);
			DatabaseUpdate(DB_ID, 'CREATE TABLE Scores(Id INTEGER PRIMARY KEY, Account TEXT, Map TEXT, Date DOUBLE, Time DOUBLE);');
		end;
	end else
		DatabaseOpen(DB_ID, DB_NAME, '', '', DB_Plugin_SQLite);
	
	_UsedIP := File.CreateStringList;
	//RecountAllStats;
	_EliteList := File.CreateStringList;
	GenerateEliteList;
	
	for i := 1 to 32 do begin
		_RKill[i] := TRUE;
		Players[i].Team := 5;
		Players[i].OnCommand := @OnPlayerCommand;
		Players[i].OnSpeak := @OnPlayerSpeak;
		Players[i].OnDamage := @OnDamage;
		Players[i].OnKill := @OnKill;
		Players[i].OnBeforeRespawn := @OnBeforeRespawn;
		Players[i].OnAfterRespawn := @OnAfterRespawn;
	end;
	
	Game.OnAdminCommand := @OnAdminCommand;
	Game.Teams[5].OnJoin := @OnJoinSpec;
	Game.OnJoin := @OnJoin;
	Game.OnLeave := @OnLeave;
	Game.OnClockTick := @Clock;
	Game.TickThreshold := 1;
	
	Map.OnBeforeMapChange := @OnBeforeMapChange;
	Map.OnAfterMapChange := @OnAfterMapChange;
end;

begin
	Init;
	Players.WriteConsole('Run Mode v3(1.7.1.1) by Savage', Random(0, 16777215+1));
end.
