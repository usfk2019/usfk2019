$PBExportHeader$e01w_reg_del_batch.srw
$PBExportComments$[parkkh] 연체자처리방안일괄등록
forward
global type e01w_reg_del_batch from w_a_reg_m_sql
end type
end forward

global type e01w_reg_del_batch from w_a_reg_m_sql
integer width = 3195
integer height = 2028
end type
global e01w_reg_del_batch e01w_reg_del_batch

type variables
e01u_dbmgr iu_db01
end variables

on e01w_reg_del_batch.create
call super::create
end on

on e01w_reg_del_batch.destroy
call super::destroy
end on

event open;call super::open;dw_cond.Object.work_date[1]  = fdt_get_dbserver_now()
end event

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where , 			ls_workdt,				ls_status_cd, &
			ls_last_reqdtfr, 	ls_last_reqdtto, 		ls_dlyamt, 		ls_chargeby, &
			ls_base,				ls_inv,					ls_customerid
Integer 	li_delay_months, 	li_delay_months_to

li_delay_months 		=  dw_cond.Object.delay_months[1]
If li_delay_months =0 Then SetNull(li_delay_months)

li_delay_months_to 	= dw_cond.Object.delay_months_to[1]
If li_delay_months_to = 0 Then SetNull(li_delay_months_to)

ls_status_cd 		= dw_cond.object.status_current[1]
ls_workdt 			= String(dw_cond.Object.work_date[1], "yyyymmdd")
ls_last_reqdtfr 	= String(dw_cond.Object.last_reqdtfr[1], "yyyymm")
ls_last_reqdtto 	= String(dw_cond.Object.last_reqdtto[1], "yyyymm")
ls_dlyamt 			= String(dw_cond.Object.dlyamt[1])
ls_chargeby 		= Trim(dw_cond.Object.chargeby[1])

ls_base 				= Trim(dw_cond.Object.base[1])
ls_inv 				= Trim(dw_cond.Object.inv[1])
ls_customerid 		= Trim(dw_cond.Object.customerid[1])
If IsNull(ls_base) 				Then ls_base 				= ""
If IsNull(ls_inv) 				Then ls_inv 				= ""
If IsNull(ls_customerid) 		Then ls_customerid 		= ""


If IsNull(ls_dlyamt) 		Then ls_dlyamt 		= ""
If IsNull(ls_chargeby) 		Then ls_chargeby 		= ""
If IsNull(ls_status_cd) 	Then ls_status_cd 	= ""
If IsNull(ls_workdt) 		Then ls_workdt 		= ""

If ls_status_cd = "" Then
	f_msg_usr_err(200, This.Title, "현상태코드")
	dw_cond.Setcolumn(1)
	dw_cond.Setfocus()
	return
end If

ls_where = ""

If ls_status_cd <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where = " A.STATUS = '" + ls_status_cd + "' "
End If
If ls_chargeby <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " B.pay_method = '" + ls_chargeby + "' "
End If
If Not IsNull(li_delay_months) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " A.DELAY_MONTHS >= " + String(li_delay_months) + " " 
End If
If Not IsNull(li_delay_months_to) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " A.DELAY_MONTHS <= " + String(li_delay_months_to) + " " 
End If
If ls_dlyamt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.amount >= " + ls_dlyamt + " "
End If
If ls_last_reqdtfr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(A.lastreqdt,'yyyymm') >= '" + ls_last_reqdtfr + "' "
End If
If ls_last_reqdtto <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(A.lastreqdt,'yyyymm') <= '" + ls_last_reqdtto + "' "
End If


//ADD 조건  - 2006-12-06
// FROM 정희찬
If ls_base <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " C.basecod = '" + ls_base + "' "
End If
If ls_inv <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " C.CTYPE2 = '" + ls_inv + "' "
End If

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.PAYID = '" + ls_customerid + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If

end event

event type integer ue_save_sql();call super::ue_save_sql;Long 		ll_whole, 			ll_row 
string 	ls_status_cd2, 	ls_status_cd
string 	ls_work_dt, 		ls_remark

iu_db01 			= Create e01u_dbmgr 
ls_work_dt 		= String( dw_cond.Object.work_date[1], "yyyymmdd" )
ls_status_cd 	= dw_cond.object.status_current[1]
ls_status_cd2 	= dw_cond.object.status_next[1]

If IsNull(ls_work_dt) 		Then ls_work_dt 		= ""
If IsNull(ls_status_cd) 	Then ls_status_cd 	= ""
If IsNull(ls_status_cd2) 	Then ls_status_cd2 	= ""

If ls_status_cd2 = "" Then
	f_msg_usr_err(200, This.Title, "다음상태코드")
	dw_cond.Setcolumn( 2 )
	dw_cond.Setfocus()
	return -1
end If
If ls_work_dt = "" Then
	f_msg_usr_err(200, This.Title, "처리일자")
	dw_cond.Setcolumn( "work_date" )
	dw_cond.Setfocus()
	return -1
end If

ll_whole = dw_detail.Rowcount()

FOR ll_row = 1 TO ll_whole
	
	If dw_detail.Object.work_gb[ ll_row ] = 'N' then continue
	
	ls_remark =  Trim(dw_detail.Object.remark[ ll_row ])

	iu_db01.is_caller = "e01w_reg_del_batch%save"
	iu_db01.is_title = This.Title
	iu_db01.is_data[1] = ls_work_dt			//처리일자
	iu_db01.is_data[2] = ls_status_cd2		//다음상태
	iu_db01.is_data[3] = dw_detail.Object.payid[ ll_row ]  //payid
	iu_db01.is_data[4] = ls_status_cd      //현재상태
	iu_db01.is_data[5] = ls_remark     		//비고 -- 2006-12-14 add
	
	iu_db01.il_data[1] = Long(dw_detail.Object.amount[ ll_row ])

	SetPointer(HourGlass!)
	iu_db01.uf_prc_db()
	SetPointer(Arrow!)

	If iu_db01.ii_rc = -1 Then 
		Return iu_db01.ii_rc
	end If
		
NEXT

Return iu_db01.ii_rc

end event

event close;call super::close;destroy iu_db01
end event

type dw_cond from w_a_reg_m_sql`dw_cond within e01w_reg_del_batch
integer x = 41
integer y = 40
integer width = 2190
integer height = 448
string dataobject = "e01d_cnd_reg_del_batch"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::ue_init();call super::ue_init;String ls_emp_grp,		ls_basecod
This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"


select emp_group   into :ls_emp_grp  from sysusr1t 
 where emp_id =  :gs_user_id ;
//
IF IsNull(ls_emp_grp) then ls_emp_grp = ''

IF ls_emp_grp <> '' then
	select basecod 	  INTO :ls_basecod	  FROM partnermst
	 WHERE basecod = :ls_emp_grp    ;
	 
	 IF sqlca.sqlcode <> 0 OR IsNull(ls_basecod) then ls_basecod = '000000'
EnD IF
dw_cond.reset()


end event

type p_ok from w_a_reg_m_sql`p_ok within e01w_reg_del_batch
integer x = 2272
integer y = 48
end type

type p_close from w_a_reg_m_sql`p_close within e01w_reg_del_batch
integer x = 2857
integer y = 48
end type

type gb_cond from w_a_reg_m_sql`gb_cond within e01w_reg_del_batch
integer width = 2208
integer height = 504
end type

type p_save from w_a_reg_m_sql`p_save within e01w_reg_del_batch
integer x = 2565
integer y = 48
end type

type dw_detail from w_a_reg_m_sql`dw_detail within e01w_reg_del_batch
integer x = 23
integer y = 512
integer width = 3099
string dataobject = "e01d_reg_del_batch"
end type

event dw_detail::ue_init;call super::ue_init;ib_sort_use = False
end event

