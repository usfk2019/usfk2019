$PBExportHeader$ubs_w_prc_cdr_reprocess.srw
$PBExportComments$[jhchoi] CDR 연결 및 재처리 - 2011.03.05
forward
global type ubs_w_prc_cdr_reprocess from w_a_prc
end type
end forward

global type ubs_w_prc_cdr_reprocess from w_a_prc
integer width = 2304
integer height = 1356
end type
global ubs_w_prc_cdr_reprocess ubs_w_prc_cdr_reprocess

type variables

end variables

on ubs_w_prc_cdr_reprocess.create
call super::create
end on

on ubs_w_prc_cdr_reprocess.destroy
call super::destroy
end on

event ue_process;STRING	ls_check,			ls_customerid,			ls_yyyymmdd_fr,		ls_yyyymmdd_to,	&
			ls_errmsg,			ls_pgm_id,				ls_validkey
LONG		ll_contractseq,	ll_new_contractseq,	ll_return		
DOUBLE	lb_count = 0

dw_input.AcceptText()

ls_check					= Trim(dw_input.Object.check[1])
ls_customerid			= Trim(dw_input.Object.customerid[1])
ll_contractseq			= dw_input.Object.contractseq[1]
ll_new_contractseq	= dw_input.Object.new_contractseq[1]
ls_validkey				= Trim(dw_input.Object.validkey[1])
ls_yyyymmdd_fr			= Trim(String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd"))
ls_yyyymmdd_to			= Trim(String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd"))
ls_pgm_id 				= gs_pgm_id[gi_open_win_no]

ll_return = -1
ls_errmsg = space(1000)

IF ls_check = '1' OR ls_check = '2'	THEN		//CDR 연결
	//처리부분...
	SQLCA.UBS_PRC_CDR_RECONNECTION(ls_check, ls_customerid, ll_contractseq, ll_new_contractseq, ls_validkey, ls_yyyymmdd_fr, ls_yyyymmdd_to, gs_user_id, ls_pgm_id, ll_return, ls_errmsg)
ELSE						//CDR 재처리
	//처리부분...
	SQLCA.UBS_PRC_CDR_REPROCESS(ls_customerid, ll_contractseq, ls_yyyymmdd_fr, ls_yyyymmdd_to, gs_user_id, ls_pgm_id, ll_return, ls_errmsg)
END IF
	
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If	

If ll_return <> 0 Then	//실패
	is_msg_process = "Fail"
	Return -1
Else				//성공
	is_msg_process = String(lb_count, "#,##0") + " Hit(s)"
	Return 0
End If


end event

event ue_input;String ls_yyyymmdd_fr, ls_yyyymmdd_to,ls_sysdate
String ls_check, ls_customerid, ls_contractseq, ls_new_contractseq, ls_validkey
Long	 ll_valid_cnt, ll_valid_new_cnt

ls_sysdate 				= string(date(fdt_get_dbserver_now())) 
ls_yyyymmdd_fr 		= String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
ls_yyyymmdd_to 		= String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")
ls_check					= Trim(dw_input.Object.check[1])
ls_customerid			= Trim(dw_input.Object.customerid[1])
ls_contractseq			= String(dw_input.Object.contractseq[1])
ls_new_contractseq	= String(dw_input.Object.new_contractseq[1])
ls_validkey				= Trim(dw_input.Object.validkey[1])

IF IsNull(ls_check)				THEN ls_check 				= ""
IF IsNull(ls_customerid)		THEN ls_customerid		= ""
IF IsNull(ls_validkey)			THEN ls_validkey			= ""
IF IsNull(ls_contractseq)		THEN ls_contractseq		= ""
IF IsNull(ls_new_contractseq)	THEN ls_new_contractseq	= ""
IF IsNull(ls_yyyymmdd_fr)		THEN ls_yyyymmdd_fr		= ""
IF IsNull(ls_yyyymmdd_to)		THEN ls_yyyymmdd_to		= ""

IF ls_check = "" THEN
	f_msg_usr_err(200, This.Title, "")
	dw_input.SetFocus()
	dw_input.SetColumn("check")
	Return -1
End If

IF ls_customerid = "" THEN
	f_msg_usr_err(200, This.Title, "")
	dw_input.SetFocus()
	dw_input.SetColumn("customerid")
	Return -1
End If

IF ls_check = '1' THEN
	IF ls_contractseq = "" THEN
		f_msg_usr_err(200, This.Title, "")
		dw_input.SetFocus()
		dw_input.SetColumn("contractseq")
		Return -1
	End If
	
	IF ls_new_contractseq = "" THEN
		f_msg_usr_err(200, This.Title, "")
		dw_input.SetFocus()
		dw_input.SetColumn("new_contractseq")
		Return -1
	End If
ELSEIF ls_check = '2' THEN
	IF ls_contractseq = "" THEN
		f_msg_usr_err(200, This.Title, "")
		dw_input.SetFocus()
		dw_input.SetColumn("contractseq")
		Return -1
	End If
	
	IF ls_validkey = "" THEN
		f_msg_usr_err(200, This.Title, "")
		dw_input.SetFocus()
		dw_input.SetColumn("validkey")
		Return -1
	End If
ELSE
	IF ls_contractseq = "" THEN
		f_msg_usr_err(200, This.Title, "")
		dw_input.SetFocus()
		dw_input.SetColumn("contractseq")
		Return -1
	End If	
END IF

SELECT NVL(VALIDKEYCNT, 0) INTO :ll_valid_cnt
FROM   PRICEPLANMST
WHERE  PRICEPLAN = (SELECT PRICEPLAN
						  FROM   CONTRACTMST
						  WHERE  CONTRACTSEQ = TO_NUMBER(:ls_contractseq));
						  
IF ll_valid_cnt = 0 THEN
	f_msg_info(200, Title, "인증키를 사용하지 않는 계약입니다. 확인바랍니다.")
	dw_input.SetFocus()
	dw_input.SetColumn("contractseq")
	Return -1
END IF	

IF ls_check = '1' THEN
	SELECT NVL(VALIDKEYCNT, 0) INTO :ll_valid_new_cnt
	FROM   PRICEPLANMST
	WHERE  PRICEPLAN = (SELECT PRICEPLAN
							  FROM   CONTRACTMST
							  WHERE  CONTRACTSEQ = TO_NUMBER(:ls_new_contractseq));
							  
	IF ll_valid_new_cnt = 0 THEN
		f_msg_info(200, Title, "인증키를 사용하지 않는 계약입니다. 확인바랍니다.")
		dw_input.SetFocus()
		dw_input.SetColumn("new_contractseq")
		Return -1
	END IF
END IF	

If ls_yyyymmdd_fr = "" Then
	f_msg_usr_err(200, This.Title, "")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_fr")
	Return -1
End If

If ls_yyyymmdd_to = "" Then
	f_msg_usr_err(200, This.Title, "")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If

If ls_yyyymmdd_fr > ls_yyyymmdd_to or ls_yyyymmdd_to >= ls_sysdate Then
	f_msg_info(100, This.Title, "")
	dw_input.SetFocus()
   dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If


Return 0


end event

event open;call super::open;DATE		ld_from,			ld_to

SELECT LAST_DAY(ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM'), 'YYYYMM'), -1)),
		 TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD')
INTO   :ld_from, :ld_to
FROM   DUAL;

dw_input.Object.check[1] = '1'
dw_input.Object.yyyymmdd_fr[1] = ld_from
dw_input.Object.yyyymmdd_to[1] = ld_to

p_ok.SetFocus()

 
end event

event ue_chg_mode;as_mode = Upper(as_mode)
Choose Case as_mode
	Case "INPUT"
		If IsValid(w_msg_wait) Then Close(w_msg_wait)
		
		p_ok.TriggerEvent("ue_enable")
		p_close.TriggerEvent("ue_enable")
		
//		dw_msg_processing.Visible = False
//		dw_msg_time.Visible = False
		
		//Change size
		This.Resize(This.Width, ln_up.BeginY + (This.Height - This.WorkSpaceHeight()))

	Case "PROCESS"
//		//Change size(다시 실행시..)
//		This.Resize(This.Width, ln_up.BeginY + (This.Height - This.WorkSpaceHeight()))

		If Not IsValid(w_msg_wait) Then Open(w_msg_wait)
		w_msg_wait.Title = "Process Name - " + This.Title
		
		p_ok.TriggerEvent("ue_disable")
		p_close.TriggerEvent("ue_disable")

//		dw_msg_time.Object.std_time[1] = dw_msg_time.Object.current_time[1]
		dw_msg_time.Object.start_time[1] = fdt_get_dbserver_now()

	Case "COMPLETED"
		If IsValid(w_msg_wait) Then Close(w_msg_wait)
		p_ok.TriggerEvent("ue_enable")
		p_close.TriggerEvent("ue_enable")

//		dw_msg_processing.Visible = True
//		dw_msg_time.SetRedraw(True)
//		dw_msg_time.Object.DataWindow.Timer_Interval = '0'

//		dw_msg_time.Visible = True
	
		//Change size
		This.Resize(This.Width, ln_down.BeginY + (This.Height - This.WorkSpaceHeight()))
	Case Else
		MessageBox("ue_chg_mode", "No Matching case statement - " + as_mode)
End Choose

end event

event ue_ok;Integer li_rc

//***** 초기화 작업 *****
SetPointer(HourGlass!)

//***** 입력 부분 *****
If dw_input.AcceptText() < 0 Then
	dw_input.SetFocus()
	Return
End If

If This.Trigger Event ue_input() < 0 Then
//	//Input Mode로
//	Trigger Event ue_chg_mode("INPUT")
	Return
End If

//실행의 확인 작업
li_rc = f_msg_ques_yesno2(il_msg_no, Title, is_msg_text, 1)

If li_rc <> 1 Then
//	//Input Mode로
//	Trigger Event ue_chg_mode("INPUT")
	Return
End If

//***** Process부분 *****
//Process Mode로
Trigger Event ue_chg_mode("PROCESS")

//Process call
li_rc = Trigger Event ue_process()

If Trigger Event ue_pre_complete() < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	//Input Mode로
	Trigger Event ue_chg_mode("INPUT")
	f_msg_info(3010, Title, This.Title)
Else
	//Completed Mode로
	Trigger Event ue_chg_mode("COMPLETED")
End If

If li_rc < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()
	f_msg_info(3010, Title, This.Title)
Else
	//COMMIT;와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()

	f_msg_info(3000, Title, This.Title)
End If

end event

type p_ok from w_a_prc`p_ok within ubs_w_prc_cdr_reprocess
integer x = 1952
integer y = 40
integer width = 288
boolean originalsize = false
end type

type dw_input from w_a_prc`dw_input within ubs_w_prc_cdr_reprocess
integer x = 41
integer width = 1824
integer height = 412
string dataobject = "ubs_dw_prc_cdr_reprocess"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_input::ue_init;This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "ssrt_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"

This.SetFocus()
This.SetRow(1)
This.SetColumn('customerid')

end event

event dw_input::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If THIS.iu_cust_help.ib_data[1] Then
			Object.customerid[row] 	= iu_cust_help.is_data[1]
			object.customernm[row] 	= iu_cust_help.is_data[2]
		End If
		
		This.Event ItemChanged(1, This.Object.customerid, iu_cust_help.is_data[1])

End Choose

Return 0 
end event

event dw_input::itemchanged;call super::itemchanged;DataWindowChild 	ldwc_contractseq,	ldwc_contractseq2
Long 					li_rc,				ll_row,		ll_row2,					li_rc2,			ll_number
String 				ls_filter,			ls_sql,		ls_customernm,			ls_check,		ls_sql2

Choose Case dwo.name
	Case "customerid"		
		
		SELECT CUSTOMERNM INTO :ls_customernm
		FROM   CUSTOMERM
		WHERE  CUSTOMERID = :data;
		
		IF IsNull(ls_customernm) THEN ls_customernm = ""
		
		IF ls_customernm = "" THEN
			f_msg_usr_err(2100, Title, "CustomerID Not Found!")
			THIS.Object.customerid[1] = ""
			THIS.Object.customernm[1] = ""
	  		Return 2  		//선택 취소 focus는 그곳에
		End If
		
		SetNull(ll_number)

		THIS.Object.customernm[1] = ls_customernm		
		THIS.Object.contractseq[1] = ll_number	
		THIS.Object.new_contractseq[1] = ll_number				
		
		
		li_rc = THIS.GetChild("contractseq", ldwc_contractseq)
		
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF	
		
		ls_sql = " SELECT A.CONTRACTSEQ, B.PRICEPLAN_DESC " + &
					" FROM   CONTRACTMST A, PRICEPLANMST B " + &
					" WHERE  A.PRICEPLAN = B.PRICEPLAN " +&
					" AND    A.CUSTOMERID = '" + data + "' " +&
					" ORDER BY A.CONTRACTSEQ ASC "
		ldwc_contractseq.SetSqlselect(ls_sql)
		ldwc_contractseq.SetTransObject(SQLCA)
		ll_row = ldwc_contractseq.Retrieve()

		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "Model Retrieve()")
			RETURN -2
		END IF					

		ls_check = This.Object.check[1]
		
		IF ls_check = '1' OR ls_check = '2' THEN //연결...
			li_rc2 = THIS.GetChild("new_contractseq", ldwc_contractseq2)
			
			IF li_rc2 = -1 THEN
				f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
				RETURN -2
			END IF	
			
			ls_sql2 = " SELECT A.CONTRACTSEQ, B.PRICEPLAN_DESC " + &
						" FROM   CONTRACTMST A, PRICEPLANMST B " + &
						" WHERE  A.PRICEPLAN = B.PRICEPLAN " +&
						" AND    A.CUSTOMERID = '" + data + "' " +&
						" ORDER BY A.CONTRACTSEQ ASC "
			ldwc_contractseq2.SetSqlselect(ls_sql2)
			ldwc_contractseq2.SetTransObject(SQLCA)
			ll_row2 = ldwc_contractseq2.Retrieve()
	
			IF ll_row2 < 0 THEN 				//디비 오류 
				f_msg_usr_err(2100, Title, "Model Retrieve()")
				RETURN -2
			END IF		
		END IF		
End Choose	
end event

type dw_msg_time from w_a_prc`dw_msg_time within ubs_w_prc_cdr_reprocess
integer y = 960
integer width = 1856
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within ubs_w_prc_cdr_reprocess
integer y = 496
integer width = 1856
end type

type ln_up from w_a_prc`ln_up within ubs_w_prc_cdr_reprocess
integer beginy = 480
integer endx = 1838
integer endy = 480
end type

type ln_down from w_a_prc`ln_down within ubs_w_prc_cdr_reprocess
integer beginy = 1240
integer endx = 1838
integer endy = 1240
end type

type p_close from w_a_prc`p_close within ubs_w_prc_cdr_reprocess
integer x = 1952
integer y = 148
integer width = 288
end type

type gb_cond from w_a_prc`gb_cond within ubs_w_prc_cdr_reprocess
integer width = 1856
integer height = 460
end type

