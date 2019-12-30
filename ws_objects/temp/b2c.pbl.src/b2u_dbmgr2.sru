$PBExportHeader$b2u_dbmgr2.sru
$PBExportComments$[jsha] DB
forward
global type b2u_dbmgr2 from u_cust_a_db
end type
end forward

global type b2u_dbmgr2 from u_cust_a_db
end type
global b2u_dbmgr2 b2u_dbmgr2

forward prototypes
public function decimal f_calc_range_full (long range[], long sec[], decimal fee[], string roundflag, integer index)
public function decimal f_calc_range_partial (long range[], long sec[], decimal fee[], long biltime, string roundflag, integer index)
public function decimal f_calc_bilamt (long bsec, decimal bfee, long range[], long sec[], decimal fee[], long biltime, string roundflag)
public function decimal f_calc_basic (long bsec, decimal bfee, long biltime, string roundflag)
public subroutine uf_prc_db ()
end prototypes

public function decimal f_calc_range_full (long range[], long sec[], decimal fee[], string roundflag, integer index);Dec lc_bilamt

If roundflag = 'U' Then
	lc_bilamt = Round(0.499999 + range[index]/sec[index], 0) * fee[index]
ElseIf roundflag = 'D' Then
	lc_bilamt = Truncate(range[index]/sec[index], 0) * fee[index]
Else
	lc_bilamt = Round(range[index]/sec[index], 0) * fee[index]
End If

Return lc_bilamt
end function

public function decimal f_calc_range_partial (long range[], long sec[], decimal fee[], long biltime, string roundflag, integer index);Dec lc_bilamt
Int i
Long ll_sum_range, ll_biltime

ll_sum_range = 0
For i = 1 To index - 1
	ll_sum_range += range[i]
Next

ll_biltime = biltime - ll_sum_range

If roundflag = 'U' Then
	lc_bilamt = Round(0.499999 + ll_biltime/sec[index], 0) * fee[index]
ElseIf roundflag = 'D' Then
	lc_bilamt = Truncate(ll_biltime/sec[index], 0) * fee[index]
Else
	lc_bilamt = Round(ll_biltime/sec[index], 0) * fee[index]
End If

Return lc_bilamt
end function

public function decimal f_calc_bilamt (long bsec, decimal bfee, long range[], long sec[], decimal fee[], long biltime, string roundflag);//
Dec lc_bilamt
Int i, rindex
Long ll_sum_range_a, ll_sum_range_b, pos

// 총 시간대
For i = 1 To 5
	If range[i] = 0 OR IsNull(range[i]) Then 
		rindex = i - 1
		Exit
	End If
Next

// biltime이 속해있는 시간대를 찾는다.
ll_sum_range_a = 0
For i = 1 To rindex 
	ll_sum_range_b = ll_sum_range_a + range[i]
	If ll_sum_range_a <= biltime AND biltime < ll_sum_range_b Then
		pos = i
	End If
	ll_sum_range_a += range[i]
Next

If pos = 0 Then
	pos = rindex + 1
End If

// bilamt 계산
If rindex = 0 Then	// 기본시간대의 요율만 있을 경우
	lc_bilamt = f_calc_basic(bsec, bfee, biltime, roundflag)
Else
	If pos > 0 AND pos <= rindex Then
		For i = 1 To pos - 1
			lc_bilamt += f_calc_range_full(range, sec, fee, roundflag, i)
		Next
		lc_bilamt += f_calc_range_partial(range, sec, fee, biltime, roundflag, pos)
	ElseIf pos > rindex Then
		For i = 1 To pos - 1
			lc_bilamt += f_calc_range_full(range, sec, fee, roundflag, i)
		Next
		lc_bilamt += f_calc_basic(bsec, bfee, biltime - ll_sum_range_b, roundflag)
	End If
End If

Return lc_bilamt

Return 0
end function

public function decimal f_calc_basic (long bsec, decimal bfee, long biltime, string roundflag);Dec lc_bilamt

If roundflag = 'U' Then
	lc_bilamt = Round(0.499999 + biltime/bsec, 0) * bfee
ElseIf roundflag = 'D' Then
	lc_bilamt = Truncate(biltime/bsec, 0) * bfee
Else
	lc_bilamt = Round(biltime/bsec, 0) * bfee
End If

Return lc_bilamt
end function

public subroutine uf_prc_db ();String ls_weekday, ls_dayflag, ls_wssvctype, ls_ref_desc, ls_tmcod
String ls_priceplan, ls_zoncod, ls_currency
Long ll_cnt
Long ll_range[], ll_sec[], ll_bsec, ll_unbilsec
Long ll_rowno
Dec lc_fee[], lc_bfee, lc_confee, lc_amt, lc_examt, lc_ex_val
Dec lc_fee1, lc_fee2, lc_diff
String ls_roundflag
Boolean lb_first_Row

ii_rc = -2
Choose Case is_caller
	Case "b2w_inq_wsranking%ue_create()"
	//lu_dbmgr.is_caller = "b2w_inq_wsranking%ue_create()"
	//lu_dbmgr.is_title = This.Title
	//lu_dbmgr.idt_data[1] = ldt_yyyymmddhh
	//lu_dbmgr.il_data[1] = ll_sec
	//lu_dbmgr.is_data[1] = gs_user_id
	//lu_dbmgr.is_data[2] = gs_pgm_id[gi_max_win_no]
	
	
	//*******  Table에 있는 모든 Data 삭제  ******//
	DELETE FROM wholesale_ranking;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(is_caller, "DELETE WHOLESALE_RANKING")
		Rollback;
		Return
	End If
	
	//********  출중계 서비스 타입 ('B0', 'P109')  ********//
	ls_wssvctype = fs_get_control("B0", "P109", ls_ref_desc)
	
	//*****  Day Select(작업기준일자의 요일을 구함)  *****//
	SELECT to_char(:idt_data[1], 'dy')
	INTO :ls_weekday
	FROM dual;
		
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(is_caller, "SELECT WEEKDAY")
		Rollback;
		Return
	End If
		
	SELECT count(*)
	INTO :ll_cnt
	FROM holiday
	WHERE to_char(hday, 'yyyymmdd') = to_char(idt_data[1], 'yyyymmdd');
		
	If ll_cnt = 0 Then
		If lower(ls_weekday) = 'sun' 	OR lower(ls_weekday) = '일' OR lower(ls_weekday) = 'hol' Then
			ls_dayflag = 'H'
		ElseIf lower(ls_weekday) = 'sat' OR lower(ls_weekday) = '토' Then
			ls_dayflag = 'S'
		Else 
			ls_dayflag = 'W'
		End If
	Else
		ls_dayflag = 'H'
	End If
	
	//*****  Priceplan Select(중계호 가격정책을 선택)  *****//
	DECLARE c_priceplan CURSOR FOR
		SELECT priceplanmst.priceplan, priceplanmst.currency_type
		FROM priceplanmst, svcmst
		WHERE priceplanmst.svccod = svcmst.svccod
		AND svcmst.svctype = :ls_wssvctype;
	
	//*****  Priceplan Cursor Open(출중계호 가격정책 Cursor Open)  *****//
	OPEN c_priceplan;
	
	Do While(True)
		Fetch c_priceplan
		INTO :ls_priceplan, :ls_currency;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT WHOLESALE PRICEPLAN")
			Rollback;
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			Exit;
		End If
		
		//*****  Tmcod Select(작업기준시간에 해당하는 시간대를 구함)  *****//
		DECLARE c_tmcod CURSOR FOR
		SELECT tmcod
		FROM tmcod
		WHERE opendt = (SELECT max(opendt)
								FROM	tmcod
								WHERE opendt <= :idt_data[1]
								AND	decode(substr(tmcod, 1, 1), 'X', :ls_dayflag, substr(tmcod, 1, 1)) = :ls_dayflag
								AND	opentm <= to_char(:idt_data[1], 'hh24mi')
								AND	endtm > to_char(:idt_data[1], 'hh24mi')
								AND 	priceplan = :ls_priceplan)
		AND	decode(substr(tmcod, 1, 1), 'X', :ls_dayflag, substr(tmcod, 1, 1)) = :ls_dayflag
		AND	opentm <= to_char(:idt_data[1], 'hh24mi')
		AND	endtm > to_char(:idt_data[1], 'hh24mi')
		AND 	priceplan = :ls_priceplan;
			
		Open c_tmcod;
		Do while(True)
			Fetch c_tmcod
			INTO :ls_tmcod;
				
			If SQLCA.SQLcode < 0 Then
				f_msg_sql_err(is_caller, "CURSOR c_tmcod")				
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			If LeftA(ls_tmcod,1) = 'X' Then 
				Exit
			End If
		Loop
		Close c_tmcod;
		
		//*****  Zoncod(대역 선택 Cursor)  *****//
		DECLARE c_zoncod CURSOR FOR
		SELECT zoncod
		FROM	 zoncst2
		WHERE  zoncst2.tmcod = :ls_tmcod
		AND    to_char(zoncst2.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
		AND    nvl(to_char(zoncst2.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd')
		AND    zoncst2.priceplan = :ls_priceplan;
		
		OPEN c_zoncod;
		Do While(True)
			FETCH c_zoncod
			INTO :ls_zoncod;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "OPEN CURSOR(c_zoncod)")
				Rollback;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
		
		 //*****  Rate를 구함  ******//
		  SELECT a.tmrange1,a.unitsec1,a.unitfee1,
					a.tmrange2,a.unitsec2,a.unitfee2,
					a.tmrange3,a.unitsec3,a.unitfee3,
					a.tmrange4,a.unitsec4,a.unitfee4,
					a.tmrange5,a.unitsec5,a.unitfee5,
					a.unitsec,a.unitfee,
					a.confee,a.unbilsec,a.roundflag
			INTO	:ll_range[1], :ll_sec[1], :lc_fee[1], 
					:ll_range[2], :ll_sec[2], :lc_fee[2], 
					:ll_range[3], :ll_sec[3], :lc_fee[3], 
					:ll_range[4], :ll_sec[4], :lc_fee[4], 
					:ll_range[5], :ll_sec[5], :lc_fee[5], 
					:ll_bsec, :lc_bfee,
					:lc_confee, :ll_unbilsec, :ls_roundflag
			FROM   ZONCST2 a	
			WHERE  a.tmcod = :ls_tmcod
			AND    to_char(a.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
			AND    nvl(to_char(a.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd') 				   
			AND    a.zoncod = :ls_zoncod
			AND    a.priceplan = :ls_priceplan;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ZONCST2 TABLE(PRICEPLAN)")
				Rollback;
				Return
			End If
			
			//********** 요금 계산 **********//
			If il_data[1] > ll_unbilsec Then
				lc_amt = f_calc_bilamt(ll_bsec, lc_bfee, ll_range, ll_sec, lc_fee, il_data[1], ls_roundflag)
			End If
			
			//***** Exchange Value 계산 *****//
			SELECT exchange_value
			INTO   :lc_ex_val
			FROM   currency_exchange
			WHERE  fromdt <= :idt_data[1]
			AND    nvl(todt, :idt_data[1]) >= :idt_data[1]
			AND    currency = :ls_currency;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ZONCST2 TABLE(PRICEPLAN)")
				Rollback;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				lc_ex_val = 0
			End If
			
			lc_examt = lc_amt * lc_ex_val
			
			//****** DB 저장 ******//
			INSERT INTO wholesale_ranking
				(yyyymmddhh, zoncod, priceplan, unit_sec, fee, exchange_fee, crt_user, crtdt, pgm_id)
			VALUES
				(to_char(:idt_data[1], 'yyyymmddhh24'), :ls_zoncod, :ls_priceplan, :il_data[1], :lc_amt, :lc_examt,
				 :is_data[1], sysdate, :is_data[2]);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "WHOLESALE_RANKING INSERT ERROR")
				Rollback;
				Return
			End If
			
		Loop
		CLOSE c_zoncod;
		
	Loop
	CLOSE c_priceplan;
	
	//*******************  우선순위와 차이를 구한다  ***********************//
	
	DECLARE c_zoncod2 CURSOR FOR
		SELECT zoncod 
		FROM   wholesale_ranking
		GROUP BY zoncod;
		
	OPEN c_zoncod2;
	Do While(True)
		FETCH c_zoncod2
		INTO :ls_zoncod;
	
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "OPEN CURSOR(c_zoncod2)")
			Rollback;
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
		End If
		
		DECLARE c_ranking CURSOR FOR
			SELECT priceplan, exchange_fee
			FROM   wholesale_ranking
			WHERE  zoncod = :ls_zoncod
			ORDER BY exchange_fee;
		
		OPEN c_ranking;
		
		lb_First_row = True
		ll_rowno = 0
		lc_fee1 = 0
		lc_fee2 = 0
		Do While(True)
			FETCH c_ranking
			INTO  :ls_priceplan, :lc_fee2;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "OPEN CURSOR(c_ranking)")
				Rollback;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			If lb_first_row Then
				lc_fee1 = lc_fee2
				lb_first_Row = false
			End If
			
			ll_rowno++;
			lc_diff = lc_fee2 - lc_fee1
			
			//********  DB에 순위와 차이를 저장  ********//
			UPDATE wholesale_ranking
			SET    ranking = :ll_rowno,
					 adj_ranking = :ll_rowno,
					 difference = :lc_diff
			WHERE  yyyymmddhh = to_char(:idt_data[1], 'yyyymmddhh24')
			AND    zoncod = :ls_zoncod
			AND    priceplan = :ls_priceplan;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "UPDATE ERROR(wholesale_ranking)")
				Rollback;
				Return
			End If
			
			lc_fee1 = lc_fee2
			
		Loop
		CLOSE c_ranking;
		
	Loop
	CLOSE c_zoncod2;
End Choose

Commit;

ii_rc = 0
end subroutine

on b2u_dbmgr2.create
call super::create
end on

on b2u_dbmgr2.destroy
call super::destroy
end on

