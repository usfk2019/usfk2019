$PBExportHeader$b2w_reg_partnerrefill_limit.srw
$PBExportComments$[y.k.min] 대리점한도관리
forward
global type b2w_reg_partnerrefill_limit from w_a_reg_m_sql
end type
end forward

global type b2w_reg_partnerrefill_limit from w_a_reg_m_sql
integer width = 3122
integer height = 2296
end type
global b2w_reg_partnerrefill_limit b2w_reg_partnerrefill_limit

on b2w_reg_partnerrefill_limit.create
call super::create
end on

on b2w_reg_partnerrefill_limit.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_partner
Dec{2} lc_tot_credit, lc_tot_samt, lc_tot_balance

ls_partner	= Trim( dw_cond.Object.partner[1] )

IF( IsNull(ls_partner) ) THEN ls_partner = ""

If ls_partner = "" Then
	f_msg_usr_err(200, Title, "대리점")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

//Dynamic SQL
IF ls_partner <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "partner = '" + ls_partner + "' "
END IF

SELECT tot_credit, tot_samt, (tot_credit - tot_samt) tot_balance
INTO :lc_tot_credit, :lc_tot_samt, :lc_tot_balance
FROM partnermst
WHERE partner = :ls_partner;

// 총한도액, 한도사용액, 한도잔액 보여주기
dw_detail.Modify ( "tot_credit_t.text= '" + String(lc_tot_credit, "##,###,##0.00") + "' " )
dw_detail.Modify ( "tot_samt_t.text='" + String(lc_tot_samt, "##,###,##0.00") + "'" )
dw_detail.Modify ( "tot_balance_t.text='" + String(lc_tot_balance, "##,###,##0.00") + "'" )

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF

p_save.TriggerEvent("ue_enable")

end event

event open;call super::open;p_save.TriggerEvent("ue_enable")
end event

event ue_save();Integer li_return
String ls_partner, ls_where
Dec{2} lc_tot_credit, lc_tot_samt, lc_tot_balance

If dw_cond.AcceptText() < 1 Then//???
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

If dw_detail.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	Return
End IF


li_return = This.Trigger Event ue_save_sql()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "대리점충전한도관리처리")
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3000, This.Title, "대리점충전한도관리 처리완료")
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			//dw_detail.Reset()
			
			ls_partner	= Trim( dw_cond.Object.partner[1] )
			
			SELECT tot_credit, tot_samt, (tot_credit - tot_samt) tot_balance
			INTO :lc_tot_credit, :lc_tot_samt, :lc_tot_balance
			FROM partnermst
			WHERE partner = :ls_partner;
			
			// 총한도액, 한도사용액, 한도잔액 보여주기
			dw_detail.Modify ( "tot_credit_t.text= '" + String(lc_tot_credit, "##,###,##0.00") + "' " )
			dw_detail.Modify ( "tot_samt_t.text='" + String(lc_tot_samt, "##,###,##0.00") + "'" )
			dw_detail.Modify ( "tot_balance_t.text='" + String(lc_tot_balance, "##,###,##0.00") + "'" )
			
			dw_detail.Retrieve()
		End If
End Choose


end event

event type integer ue_save_sql();call super::ue_save_sql;String ls_where
Long ll_row
String ls_tmp, ls_work_type, ls_remark, ls_partner, ls_plusminus
Integer li_return, li_ret, li_rc
Dec{2} lc_work_amt

ls_partner = dw_cond.Object.partner[1]
ls_work_type = dw_cond.Object.work_type[1]
lc_work_amt = dw_cond.Object.work_amt[1]
ls_remark = dw_cond.Object.remark[1]
ls_plusminus = dw_cond.Object.plmi[1]

If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_work_type) Then ls_work_type = ""
If IsNull(lc_work_amt) Then lc_work_amt = 0
If IsNull(ls_remark) Then ls_remark = ""

If ls_partner = "" Then
	f_msg_usr_err(200, Title, "대리점")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return -2
End If

If ls_work_type = "" Then
	f_msg_usr_err(200, Title, "유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("work_type")
	Return -2
End If

If lc_work_amt = 0 Then
	f_msg_usr_err(200, Title, "금액")
	dw_cond.SetFocus()
	dw_cond.SetColumn("work_amt")
	Return -2
End If

If lc_work_amt < 0 Then
	f_msg_usr_err(201, Title, "금액")
	dw_cond.SetFocus()
	dw_cond.SetColumn("work_amt")
	Return -2
End If


IF ls_plusminus = "1" THEN
	lc_work_amt = lc_work_amt * -1
END IF
	

//***** 처리부분 *****
b2u_dbmgr iu_db

iu_db = Create b2u_dbmgr

iu_db.is_title = Title

iu_db.is_data[1] = ls_partner			//대리점
iu_db.is_data[2] = ls_work_type		//유형
iu_db.is_data[3] = ls_remark	   	//비고
iu_db.is_data[4] = gs_user_id
iu_db.ic_data[1] = lc_work_amt		//금액

iu_db.idw_data[1] = dw_detail

iu_db.uf_prc_db_01()
li_rc	= iu_db.ii_rc


Destroy iu_db
Return li_rc

end event

type dw_cond from w_a_reg_m_sql`dw_cond within b2w_reg_partnerrefill_limit
integer width = 1792
integer height = 664
string dataobject = "b2dw_cnd_reg_partnerrefill_limit"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_sql`p_ok within b2w_reg_partnerrefill_limit
integer x = 1984
end type

type p_close from w_a_reg_m_sql`p_close within b2w_reg_partnerrefill_limit
integer y = 52
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b2w_reg_partnerrefill_limit
integer width = 1856
integer height = 744
end type

type p_save from w_a_reg_m_sql`p_save within b2w_reg_partnerrefill_limit
integer x = 2286
integer y = 52
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b2w_reg_partnerrefill_limit
integer y = 784
string dataobject = "b2dw_reg_partnerrefill_limit"
boolean ib_sort_use = false
end type

