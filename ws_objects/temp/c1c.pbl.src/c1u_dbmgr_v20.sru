$PBExportHeader$c1u_dbmgr_v20.sru
$PBExportComments$[ssong] DB Manager
forward
global type c1u_dbmgr_v20 from u_cust_a_db
end type
end forward

global type c1u_dbmgr_v20 from u_cust_a_db
end type
global c1u_dbmgr_v20 c1u_dbmgr_v20

type variables

end variables

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();
String ls_parttype, ls_partcod, ls_areanum, ls_remark, ls_data
DateTime ld_opendt, ld_enddt
Long   ll_row

ii_rc = -1
Choose Case is_caller
	Case "b0w_prt_blacklist%ok"
//		lu_dbmgr.is_caller = "b0w_prt_blacklist%ok"
//		lu_dbmgr.is_title = Title
//    lu_dbmgr.idw_data[1] = dw_cond
//    lu_dbmgr.idw_data[2] = dw_list
		
		For ll_row = 1 To idw_data[2].RowCount()
			ls_parttype = Trim(idw_data[2].Object.parttype[ll_row])
			ls_partcod  = Trim(idw_data[2].Object.partcod[ll_row])
			ls_areanum  = Trim(idw_data[2].Object.areanum[ll_row])
			ld_opendt   = idw_data[2].Object.opendt[ll_row]
			ld_enddt    = idw_data[2].Object.enddt[ll_row]
			ls_remark   = Trim(idw_data[2].Object.remark[ll_row])
		
			
			If ls_parttype = "R" Then  //가격정책
				SELECT PRICEPLAN_DESC
				  INTO :ls_data
				  FROM PRICEPLANMST
				 WHERE PRICEPLAN = :ls_partcod ;
				 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "Select priceplanmst Table")
					ii_rc = -2
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					f_msg_info(9000, is_title, is_caller + "Select priceplanmst Table")
					ii_rc = -2
					Return
				End If
				
			ElseIf ls_parttype = "S" Then  //대리점
				SELECT PARTNERNM
				  INTO :ls_data
				  FROM PARTNERMST
				 WHERE PARTNER = :ls_partcod ;
				 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "Select Partnermst Table")
					ii_rc = -2
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					f_msg_info(9000, is_title, is_caller + "Select Partnermst Table")
					ii_rc = -2
					Return
				End If
				
			ElseIf ls_parttype = "C" Then  //고객
				SELECT CUSTOMERNM
				  INTO :ls_data
				  FROM CUSTOMERM
				 WHERE CUSTOMERID = :ls_partcod ;
				 
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "Select Customerm Table")
					ii_rc = -2
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					f_msg_info(9000, is_title, is_caller + "Select Customerm Table")
					ii_rc = -2
					Return
				End If
				
			Else   //ALL, 선불카드
				ls_data = ls_partcod
			End If
			
			idw_data[2].Object.partcod[ll_row]  = ls_data
		Next
							
End Choose
ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_02 ();String ls_customerid, ls_svccod, ls_priceplan, ls_sale_partner, ls_maintain_partner, ls_partner
String ls_chg_rtelnum, ls_validkey_loc, ls_nodeno, ls_weekday, ls_dayflag
String ls_zoncod, ls_areacod, ls_tmcod
String ls_ratetype
Long ll_contractseq, ll_curpoint, ll_prepoint, ll_frpoint, ll_cnt
Date ld_pointdt, ld_bil_fromdt, ld_bil_todt
boolean lb_zoncst2

ii_rc = -1
Choose Case is_caller
	Case "b0w_cal_rating"
//		lu_dbmgr.is_data[1] = ls_nodeno
//		lu_dbmgr.is_data[2] = ls_rtelnum
//		lu_dbmgr.is_data[3] = ls_priceplan
//		lu_dbmgr.idt_data[1] = ldt_stime

		ls_customerid = is_data[4]
		ls_sale_partner = is_data[5]
				
		//************************* Rtelnum Change ***************************//
		String ls_rtelprefix, ls_chgvalue
		
//		SELECT max(rtelprefix) rtelprefix
//		INTO :ls_rtelprefix
//		FROM chg_rtelprefix
//		WHERE :is_data[2] LIKE rtelprefix || '%';
		
		//착신번호
		SELECT max(telprefix) telprefix
		INTO :ls_rtelprefix
		FROM chg_telprefix
		WHERE type = 'R' and :is_data[2] LIKE telprefix || '%' ;		
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT CHG_RTELPREFIX TABLE(1st)")
			Return
		End If
		
		If ls_rtelprefix <> 'None' Then
//			SELECT chgvalue, rtrim(ltrim(chgvalue)) || substr(is_data[2], length(ls_rtelprefix+1), length(is_data[2]))
//			INTO :ls_chgvalue, :ls_chg_rtelnum
//			FROM chg_rtelprefix
//			WHERE rtelprefix = :ls_rtelprefix; 

			SELECT chgvalue, rtrim(ltrim(chgvalue)) || substr(is_data[2], length(ls_rtelprefix+1), length(is_data[2]))
			INTO :ls_chgvalue, :ls_chg_rtelnum
			FROM chg_telprefix
			WHERE type='R' and telprefix = :ls_rtelprefix; 
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT CHG_RTELPREFIX TABLE(2nd)")
				Return
			End If
		Else
			ls_chg_rtelnum = is_data[2]
		End If
		
		is_data[2] = ls_chg_rtelnum
		
		//************************* Start Point *********************************//
		ll_frpoint = 0
		/*
		If ld_pointdt < Date(idt_data[1]) Then
			ll_frpoint = ll_prepoint
		Else
			ll_frpoint = ll_curpoint
		End If
		*/
		//*********** use days ***************//
		
		
		//************************** Day Flag ****************************//
		SELECT to_char(:idt_data[1], 'dy')
		INTO :ls_weekday
		FROM dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT WEEKDAY")
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
		
		//************************* AreZoncod ****************************//
		SELECT zoncod, areacod
		INTO :ls_zoncod, :ls_areacod
		FROM arezoncod2
		WHERE areacod = (SELECT nvl(max(areacod), '')
								FROM	arezoncod2
								WHERE :is_data[2] LIKE areacod || '%'
								AND nodeno = :is_data[1])
		AND nodeno = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT AREZONCOD2 TABLE")
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_usr_err(9000, is_title, "지역별 대역정의에서 정의되지 않은 착신지입니다.")
			Return
		End If
		
		/******************************************************************/
		/*																						*/
		/* 									요율 구하기									*/	
		/*																						*/
		/******************************************************************/
		
		//****************** 표준 Rate ************************//
		lb_zoncst2 = false
		/** 시간대 구하기 **/
		String tmcod
		
		DECLARE c_tmcod CURSOR FOR
		SELECT tmcod
		FROM tmcod
		WHERE opendt = (SELECT max(opendt)
								FROM	tmcod
								WHERE opendt <= :idt_data[1]
								AND	decode(substr(tmcod, 1, 1), 'X', :ls_dayflag, substr(tmcod, 1, 1)) = :ls_dayflag
								AND	opentm <= to_char(:idt_data[1], 'hh24mi')
								AND	endtm > to_char(:idt_data[1], 'hh24mi')
								AND 	priceplan = 'ALL')
		AND	decode(substr(tmcod, 1, 1), 'X', :ls_dayflag, substr(tmcod, 1, 1)) = :ls_dayflag
		AND	opentm <= to_char(:idt_data[1], 'hh24mi')
		AND	endtm > to_char(:idt_data[1], 'hh24mi')
		AND 	priceplan = 'ALL';
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT TMCOD TABLE(ALL PRICEPLAN)")
			Return
		End If
		
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
			
			If LeftA(ls_tmcod, 1) = 'X' Then 
				Exit
			End If
		Loop
		Close c_tmcod;
		
		/** 표준 Rate 구하기 **/
		ls_ratetype = 'Std'
		SELECT  	a.tmrange1,a.unitsec1,a.unitfee1,
					a.tmrange2,a.unitsec2,a.unitfee2,
					a.tmrange3,a.unitsec3,a.unitfee3,
					a.tmrange4,a.unitsec4,a.unitfee4,
					a.tmrange5,a.unitsec5,a.unitfee5,
					a.unitsec,a.unitfee,
					a.mtmrange1,a.munitsec1,a.munitfee1,
					a.mtmrange2,a.munitsec2,a.munitfee2,
					a.mtmrange3,a.munitsec3,a.munitfee3,
					a.mtmrange4,a.munitsec4,a.munitfee4,
					a.mtmrange5,a.munitsec5,a.munitfee5,
					a.munitsec,a.munitfee,
					a.confee,a.unbilsec,a.roundflag
			INTO	:il_data[1], :il_data[2], :ic_data[1], 
					:il_data[3], :il_data[4], :ic_data[2], 
					:il_data[5], :il_data[6], :ic_data[3], 
					:il_data[7], :il_data[8], :ic_data[4], 
					:il_data[9], :il_data[10], :ic_data[5], 
					:il_data[11], :ic_data[6],
					:il_data[12], :il_data[13], :ic_data[7], 
					:il_data[14], :il_data[15], :ic_data[8], 
					:il_data[16], :il_data[17], :ic_data[9], 
					:il_data[18], :il_data[19], :ic_data[10], 
					:il_data[20], :il_data[21], :ic_data[11], 
					:il_data[22], :ic_data[12],
					:ic_data[13], :il_data[23], :is_data[6]
		FROM   ZONCST2 a	
		WHERE  a.frpoint <= :ll_frpoint	
		AND    a.tmcod = :ls_tmcod
		AND    to_char(a.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
		AND    nvl(to_char(a.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd') 				   
		AND    a.zoncod = :ls_zoncod
		AND    a.priceplan = 'ALL';
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT ZONCST2 TABLE(ALL PRICEPLAN)")
			Return
		ElseIf SQLCA.SQLCode <> 100 Then
			lb_zoncst2 = true
		End If
		
		is_data[7] = ls_ratetype
		
		SELECT zonnm
		INTO :is_data[9]
		FROM zone
		WHERE zoncod = :ls_zoncod;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT ZONE TABLE")
			Return
		End If
		
		SELECT codenm
		INTO :is_data[10]
		FROM syscod2t
		WHERE grcode = 'B130'
		AND	code = :ls_tmcod
		AND 	use_yn = 'Y';
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT SYSCOD2t TABLE(TMCOD)")
			Return
		End If
		
		/** 시간대 구하기2 **/
		DECLARE c_tmcod_customer CURSOR FOR
		SELECT tmcod
		FROM tmcod
		WHERE opendt = (SELECT max(opendt)
								FROM	tmcod
								WHERE opendt <= :idt_data[1]
								AND	decode(substr(tmcod, 1, 1), 'X', :ls_dayflag, substr(tmcod, 1, 1)) = :ls_dayflag
								AND	opentm <= to_char(:idt_data[1], 'hh24mi')
								AND	endtm > to_char(:idt_data[1], 'hh24mi')
								AND 	priceplan = :is_data[3])
		AND	decode(substr(tmcod, 1, 1), 'X', :ls_dayflag, substr(tmcod, 1, 1)) = :ls_dayflag
		AND	opentm <= to_char(:idt_data[1], 'hh24mi')
		AND	endtm > to_char(:idt_data[1], 'hh24mi')
		AND 	priceplan = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT TMCOD TABLE(ALL PRICEPLAN)")
			Return
		End If
		
		Open c_tmcod_customer;
		Do while(True)
			Fetch c_tmcod_customer
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
		Close c_tmcod_customer;

		/** 가격정책별 rate 구하기 **/
		SELECT count(*)
		INTO :ll_cnt
		FROM   ZONCST2 a	
		WHERE  a.frpoint <= :ll_frpoint	
		AND    a.tmcod = :ls_tmcod
		AND    to_char(a.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
		AND    nvl(to_char(a.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd') 				   
		AND    a.zoncod = :ls_zoncod
		AND    a.priceplan = :is_data[3];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT COUNT OF ZONCST2 TABLE(PRICEPLAN)")
			Return
		End If
		
		If ll_cnt > 0 Then
			ls_ratetype = 'Prc'
			SELECT  	a.tmrange1,a.unitsec1,a.unitfee1,
					a.tmrange2,a.unitsec2,a.unitfee2,
					a.tmrange3,a.unitsec3,a.unitfee3,
					a.tmrange4,a.unitsec4,a.unitfee4,
					a.tmrange5,a.unitsec5,a.unitfee5,
					a.unitsec,a.unitfee,
					a.mtmrange1,a.munitsec1,a.munitfee1,
					a.mtmrange2,a.munitsec2,a.munitfee2,
					a.mtmrange3,a.munitsec3,a.munitfee3,
					a.mtmrange4,a.munitsec4,a.munitfee4,
					a.mtmrange5,a.munitsec5,a.munitfee5,
					a.munitsec,a.munitfee,
					a.confee,a.unbilsec,a.roundflag
			INTO	:il_data[1], :il_data[2], :ic_data[1], 
					:il_data[3], :il_data[4], :ic_data[2], 
					:il_data[5], :il_data[6], :ic_data[3], 
					:il_data[7], :il_data[8], :ic_data[4], 
					:il_data[9], :il_data[10], :ic_data[5], 
					:il_data[11], :ic_data[6],
					:il_data[12], :il_data[13], :ic_data[7], 
					:il_data[14], :il_data[15], :ic_data[8], 
					:il_data[16], :il_data[17], :ic_data[9], 
					:il_data[18], :il_data[19], :ic_data[10], 
					:il_data[20], :il_data[21], :ic_data[11], 
					:il_data[22], :ic_data[12],
					:ic_data[13], :il_data[23], :is_data[6]
			FROM   ZONCST2 a	
			WHERE  a.frpoint <= :ll_frpoint	
			AND    a.tmcod = :ls_tmcod
			AND    to_char(a.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
			AND    nvl(to_char(a.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd') 				   
			AND    a.zoncod = :ls_zoncod
			AND    a.priceplan = :is_data[3];
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ZONCST2 TABLE(PRICEPLAN)")
				Return
			ElseIf SQLCA.SQLCode <> 100 Then
				lb_zoncst2 = true
			End If
			
			is_data[7] = ls_ratetype
			
			SELECT priceplan_desc
			INTO :is_data[8]
			FROM priceplanmst
			WHERE priceplan = :is_data[3];
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT PRICEPLANMST TABLE(PRICEPLAN)")
				Return
			End If
			
			//is_data[5] = ls_priceplan
			
			SELECT zonnm
			INTO :is_data[9]
			FROM zone
			WHERE zoncod = :ls_zoncod;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ZONE TABLE")
				Return
			End If
			
			SELECT codenm
			INTO :is_data[10]
			FROM syscod2t
			WHERE grcode = 'B130'
			AND	code = :ls_tmcod
			AND 	use_yn = 'Y';
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT SYSCOD2t TABLE(TMCOD)")
				Return
			End If
		
		End If
			
		/** 대리점별 Rate 구하기 **/
		SELECT count(*)
		INTO :ll_cnt
		FROM particular_zoncst a
		WHERE  a.parttype = 'P'
		AND	 a.frpoint <= :ll_frpoint	
		AND    a.tmcod = :ls_tmcod
		AND    to_char(a.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
		AND    nvl(to_char(a.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd') 				   
		AND    decode(a.zoncod, 'ALL', :ls_zoncod, a.zoncod) = :ls_zoncod
		AND    a.partcod = :ls_sale_partner;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT COUNT OF PARTICULAR_ZONCST TABLE(PARTNER)")
			Return
		End If
		
		If ll_cnt > 0 Then
			ls_ratetype = 'Ptn'
			SELECT  	a.tmrange1,a.unitsec1,a.unitfee1,
					a.tmrange2,a.unitsec2,a.unitfee2,
					a.tmrange3,a.unitsec3,a.unitfee3,
					a.tmrange4,a.unitsec4,a.unitfee4,
					a.tmrange5,a.unitsec5,a.unitfee5,
					a.unitsec,a.unitfee,
					a.mtmrange1,a.munitsec1,a.munitfee1,
					a.mtmrange2,a.munitsec2,a.munitfee2,
					a.mtmrange3,a.munitsec3,a.munitfee3,
					a.mtmrange4,a.munitsec4,a.munitfee4,
					a.mtmrange5,a.munitsec5,a.munitfee5,
					a.munitsec,a.munitfee,
					a.confee,a.unbilsec,a.roundflag
			INTO	:il_data[1], :il_data[2], :ic_data[1], 
					:il_data[3], :il_data[4], :ic_data[2], 
					:il_data[5], :il_data[6], :ic_data[3], 
					:il_data[7], :il_data[8], :ic_data[4], 
					:il_data[9], :il_data[10], :ic_data[5], 
					:il_data[11], :ic_data[6],
					:il_data[12], :il_data[13], :ic_data[7], 
					:il_data[14], :il_data[15], :ic_data[8], 
					:il_data[16], :il_data[17], :ic_data[9], 
					:il_data[18], :il_data[19], :ic_data[10], 
					:il_data[20], :il_data[21], :ic_data[11], 
					:il_data[22], :ic_data[12],
					:ic_data[13], :il_data[23], :is_data[6]
			FROM   particular_zoncst a
			WHERE  a.parttype = 'P'
			AND	 a.frpoint <= :ll_frpoint	
			AND    a.tmcod = :ls_tmcod
			AND    to_char(a.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
			AND    nvl(to_char(a.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd') 				   
			AND    decode(a.zoncod, 'ALL', :ls_zoncod, a.zoncod) = :ls_zoncod
			AND    a.partcod = :ls_sale_partner;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT PARTICULAR_ZONCST TABLE(PARTNER)")
				Return
			ElseIf SQLCA.SQLCode <> 100 Then
				lb_zoncst2 = true
			End If
			
			is_data[7] = ls_ratetype
			
			SELECT partnernm
			INTO :is_data[8]
			FROM partnermst
			WHERE partner = :ls_sale_partner;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT PARTNERMST TABLE")
				Return
			End If
			//is_data[5] = ls_sale_partner
			
			
			SELECT zonnm
			INTO :is_data[9]
			FROM zone
			WHERE zoncod = :ls_zoncod;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ZONE TABLE")
				Return
			End If
		
			SELECT codenm
			INTO :is_data[10]
			FROM syscod2t
			WHERE grcode = 'B130'
			AND	code = :ls_tmcod
			AND 	use_yn = 'Y';
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT SYSCOD2t TABLE(TMCOD)")
				Return
			End If
			
			ii_rc = 0
			Return
			
		End If
		
		/** customer별 Rate 구하기 **/
		SELECT count(*)
		INTO :ll_cnt
		FROM particular_zoncst a
		WHERE  a.parttype = 'C'
		AND	 a.frpoint <= :ll_frpoint	
		AND    a.tmcod = :ls_tmcod
		AND    to_char(a.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
		AND    nvl(to_char(a.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd') 				   
		AND    decode(a.zoncod, 'ALL', :ls_zoncod, a.zoncod) = :ls_zoncod
		AND    a.partcod = :ls_customerid;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT COUNT OF PARTICULAR_ZONCST TABLE(Customer)")
			Return
		End If
		
		If ll_cnt > 0 Then
			ls_ratetype = 'Cus'
			SELECT  	a.tmrange1,a.unitsec1,a.unitfee1,
					a.tmrange2,a.unitsec2,a.unitfee2,
					a.tmrange3,a.unitsec3,a.unitfee3,
					a.tmrange4,a.unitsec4,a.unitfee4,
					a.tmrange5,a.unitsec5,a.unitfee5,
					a.unitsec,a.unitfee,
					a.mtmrange1,a.munitsec1,a.munitfee1,
					a.mtmrange2,a.munitsec2,a.munitfee2,
					a.mtmrange3,a.munitsec3,a.munitfee3,
					a.mtmrange4,a.munitsec4,a.munitfee4,
					a.mtmrange5,a.munitsec5,a.munitfee5,
					a.munitsec,a.munitfee,
					a.confee,a.unbilsec,a.roundflag
			INTO	:il_data[1], :il_data[2], :ic_data[1], 
					:il_data[3], :il_data[4], :ic_data[2], 
					:il_data[5], :il_data[6], :ic_data[3], 
					:il_data[7], :il_data[8], :ic_data[4], 
					:il_data[9], :il_data[10], :ic_data[5], 
					:il_data[11], :ic_data[6],
					:il_data[12], :il_data[13], :ic_data[7], 
					:il_data[14], :il_data[15], :ic_data[8], 
					:il_data[16], :il_data[17], :ic_data[9], 
					:il_data[18], :il_data[19], :ic_data[10], 
					:il_data[20], :il_data[21], :ic_data[11], 
					:il_data[22], :ic_data[12],
					:ic_data[13], :il_data[23], :is_data[6]
			FROM   particular_zoncst a
			WHERE  a.parttype = 'C'
			AND	 a.frpoint <= :ll_frpoint	
			AND    a.tmcod = :ls_tmcod
			AND    to_char(a.opendt,'yyyymmdd') <= to_char(:idt_data[1],'yyyymmdd')
			AND    nvl(to_char(a.enddt,'yyyymmdd'),to_char(:idt_data[1],'yyyymmdd')) >= to_char(:idt_data[1],'yyyymmdd') 				   
			AND    decode(a.zoncod, 'ALL', :ls_zoncod, a.zoncod) = :ls_zoncod
			AND    a.partcod = :ls_customerid;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT PARTICULAR_ZONCST TABLE(Customer)")
				Return
			ElseIf SQLCA.SQLCode <> 100 Then
				lb_zoncst2 = true
			End If
			
			is_data[7] = ls_ratetype
			is_data[8] = ls_customerid
			
			SELECT zonnm
			INTO :is_data[9]
			FROM zone
			WHERE zoncod = :ls_zoncod;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ZONE TABLE")
				Return
			End If
		
			SELECT codenm
			INTO :is_data[10]
			FROM syscod2t
			WHERE grcode = 'B130'
			AND	code = :ls_tmcod
			AND 	use_yn = 'Y';
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT SYSCOD2t TABLE(TMCOD)")
				Return
			End If
			
			ii_rc = 0
			Return
			
		End If
				
End Choose
If Not(lb_zoncst2) Then
	f_msg_usr_err(9000, is_title, "요율정보가 존재하지 않습니다.")
	Return
End If

ii_rc = 0
Return
end subroutine

public subroutine uf_prc_db ();String ls_zoncod
Long   ll_cnt = 0, li_result

ii_rc = -1
Choose Case is_caller
	Case "c1w_reg_standard_zone%display"
//		lu_dbmgr.is_caller = "b0w_reg_standard_zone%display"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = data

		Select areanm, areagroup, countrycod
		Into	:is_data[2], :is_data[3], :is_data[4]
		From areamst
		Where areacod = :is_data[1];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "Select areamst Table")
			RollBack;
			Return
		End If	
		
	Case "c1w_inq_zoncst3_enddt_popup_v20%update"
//		lu_dbmgr.is_caller = "b0w_reg_standard_zone%display"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = data	

		ls_zoncod = is_data[3]		
      If isnull(ls_zoncod) Then ls_zoncod = ''
		
		ll_cnt = 0
		If ls_zoncod <> '' then
			select count(zoncod)
			  into :ll_cnt
			  from zoncst2
			 where svccod    = :is_data[1]
				and priceplan = :is_data[2]
				and zoncod    = :is_data[3]
				and enddt     is null
				and opendt   <= :id_data[1] ;
		Else
			select count(zoncod)
			  into :ll_cnt
			  from zoncst2
			 where svccod    = :is_data[1]
				and priceplan = :is_data[2]
				and enddt     is null
				and opendt   <= :id_data[1] ;
		End If
		If ll_cnt > 0 Then
			li_result = f_msg_ques_yesno2(9000,is_title, "해당하는 대역요율을 일괄종료처리 하시겠습니까? ", 2)
			If li_result = 2 Then
				Return
			End If
		Else
			f_msg_info(9000, is_title, "일괄종료처리 할 대역요율이 없습니다.")
			Return
		End If
		
		If ls_zoncod <> '' then
			update zoncst2 
			   set enddt     = :id_data[1]
				  , updtdt    = sysdate			  
			 where svccod    = :is_data[1]
				and priceplan = :is_data[2]
				and zoncod    = :is_data[3]
				and enddt     is null
				and opendt   <= :id_data[1] ;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "update zoncst2 Table")
				RollBack;
				Return
			End If				
		Else
			update zoncst2
			   set enddt     = :id_data[1]
				  , updtdt    = sysdate
			 where svccod    = :is_data[1]
				and priceplan = :is_data[2]
				and enddt     is null
				and opendt   <= :id_data[1] ;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "update zoncst2 Table zoncod all")
				RollBack;
				Return
			End If	
		End If
		
End Choose
ii_rc = 0
Return 
end subroutine

on c1u_dbmgr_v20.create
call super::create
end on

on c1u_dbmgr_v20.destroy
call super::destroy
end on

