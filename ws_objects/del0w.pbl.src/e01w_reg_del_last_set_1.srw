$PBExportHeader$e01w_reg_del_last_set_1.srw
$PBExportComments$[parkkh] 연체자 조치사항 등록 => 일시정치처리포함
forward
global type e01w_reg_del_last_set_1 from w_a_reg_m_sql
end type
type dw_term from u_d_base within e01w_reg_del_last_set_1
end type
end forward

global type e01w_reg_del_last_set_1 from w_a_reg_m_sql
integer width = 2798
integer height = 1452
dw_term dw_term
end type
global e01w_reg_del_last_set_1 e01w_reg_del_last_set_1

type variables
e01u_dbmgr iu_db01
String is_e_termstatus, is_e_suspenstatus, is_active, is_suspendstatus
String is_term_where, is_termenable[], is_termstatus[]
//2005.08.30 juede add
String is_e_suspendconfirm_status, is_suspendconfirm_status
end variables

on e01w_reg_del_last_set_1.create
int iCurrent
call super::create
this.dw_term=create dw_term
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_term
end on

on e01w_reg_del_last_set_1.destroy
call super::destroy
destroy(this.dw_term)
end on

event open;call super::open;
/*------------------------------------------------------------------------
	Name	:	e01w_reg_del_last_set
	Desc.	: 	연체자 조치사항 등록
	Ver.	:	1.0
	Date	: 	2003.01.17
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp, ls_name[]
long li_i

//해지신청상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P221", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , is_termstatus[])
End if

//연체자해지상태코드/연체자일시정지상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("E2","F102", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_name[])
End if
is_e_termstatus = ls_name[1]
is_e_suspenstatus = ls_name[2]
//2005.08.30 juede add
is_e_suspendconfirm_status = ls_name[3]

//해지신청가능상태정보
ls_temp = fs_get_control("B0","P224", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , is_termenable[])
End if
is_term_where = ""
For li_i = 1 To UpperBound(is_termenable[])
	If is_term_where <> "" Then is_term_where += " Or "
	is_term_where += "contractmst.status = '" + is_termenable[li_i] + "'"
Next
is_term_where = "( " + is_term_where + " ) " 

//일시정지가능상태코드(개통상태)
ls_ref_desc =""
is_active = fs_get_control("B0", "P223", ls_ref_desc)

//일시정지 상태코드
ls_temp = fs_get_control("B0", "P225", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])		
is_suspendstatus = ls_name[1]
is_suspendconfirm_status = ls_name[2]

dw_cond.Object.work_date[1] = fdt_get_dbserver_now()
dw_cond.Object.gu_cd[1] = is_e_termstatus 
dw_cond.Object.gu_cd2[1] = is_e_suspendconfirm_status
end event

event close;call super::close;destroy iu_db01
end event

event ue_ok();call super::ue_ok;Long ll_row
String ls_where , ls_status1, ls_status2, ls_workdt
Integer li_delay_months, li_delay_months_to

li_delay_months =  dw_cond.Object.delay_months[1]
If li_delay_months=0 Then SetNull(li_delay_months)
li_delay_months_to = dw_cond.Object.delay_months_to[1]
If li_delay_months_to = 0 Then SetNull(li_delay_months_to)

ls_status1 = Trim( dw_cond.Object.status1[1] )

If ls_status1 = "" then
	f_msg_usr_err(200, This.Title, "현상태코드")	
	dw_cond.Setcolumn( 1 )
	dw_cond.Setfocus()
	return
End If

ls_where = " dlymst.status = '" + ls_status1 + "' "

If Not IsNull(li_delay_months) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " dlymst.DELAY_MONTHS >= " + String(li_delay_months) + " " 
End If

If Not IsNull(li_delay_months_to) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " dlymst.DELAY_MONTHS <= " + String(li_delay_months_to) + " " 
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

event type integer ue_save_sql();call super::ue_save_sql;Integer li_error
Long ll_whole, ll_row , ll_row_1
string ls_status_cd, ls_trmm, ls_term_yn, ls_where
string ls_work_dt, ls_new_status, ls_termtype, ls_payid
//2005.08.30 juede add
String ls_suspendtype, ls_suspend_yn

li_error = -1

ll_whole = dw_detail.Rowcount()
ls_work_dt = String(dw_cond.Object.work_date[1], "yyyymmdd")
ls_status_cd = Trim(dw_cond.Object.status1[1])
ls_new_status = Trim(dw_cond.Object.status2[1])
ls_termtype = Trim(dw_cond.Object.termtype[1])
ls_suspendtype = Trim(dw_cond.Object.suspendtype[1]) //2005.08.30
If IsNull(ls_status_cd) Then ls_status_cd = ""
If IsNull(ls_new_status) Then ls_new_status = ""
If IsNull(ls_work_dt) Then ls_work_dt = ""
If IsNull(ls_termtype) Then ls_termtype = ""
If IsNull(ls_suspendtype) Then ls_suspendtype = ""//2005.08.30

If ls_new_status = "" then
	f_msg_usr_err(200, This.Title, "다음상태코드")
	dw_cond.Setcolumn( 2 )
	dw_cond.Setfocus()
	return -2
End If

If ls_work_dt = "" then
	f_msg_usr_err(200, This.Title, "처리일자")
	dw_cond.Setcolumn("work_date")
	dw_cond.Setfocus()
	return -2
End If

If ls_new_status = is_e_termstatus Then
	ls_term_yn = 'Y'
	If ls_termtype = "" then
		f_msg_usr_err(200, This.Title, "해지사유")
		dw_cond.Setcolumn( 2 )
		dw_cond.Setfocus()
		return -2
	End If
End If	
//2005.08.30 juede add----일시정지처리사유
If ls_new_status = is_e_suspendconfirm_status Then
	ls_suspend_yn = 'Y'
	If ls_suspendtype = "" then
		f_msg_usr_err(200, This.Title, "일시정지사유")
		dw_cond.Setcolumn( 2 )
		dw_cond.Setfocus()
		return -2
	End If
End If	

iu_db01 = Create e01u_dbmgr

FOR ll_row = 1 TO ll_whole
	
	If dw_detail.Object.work_gb[ ll_row ] = 'N' then continue

	iu_db01.is_caller = "e01w_reg_del_last_set_1%save"
	iu_db01.is_title = This.Title
	iu_db01.idw_data[1] = dw_term	
	iu_db01.is_data[1] = ls_work_dt     		//처리일자
	iu_db01.is_data[2] = ls_new_status			//다음상태
	iu_db01.is_data[3] = dw_detail.Object.payid[ll_row]   //납입자
	iu_db01.is_data[4] = ls_termtype				//해지사유
	iu_db01.is_data[5] = is_e_termstatus   	//연체자해지신청상태코드
	iu_db01.is_data[6] = is_e_suspenstatus		//연체자일시정지상태코드
	iu_db01.is_data[7] = is_termstatus[1]     //해지신청코드
	iu_db01.is_data[8] = is_suspendstatus     //일시정시신청코드
	iu_db01.is_data[9] = ls_status_cd         //현재상태
	//2005.08.30 juede add
	iu_db01.is_data[10] = is_e_suspendconfirm_status //연체자일시정치처리상태코드 200
	iu_db01.is_data[11] = ls_suspendtype  //일시정처리지사유
	iu_db01.is_data[12] = is_suspendconfirm_status //일시정지코드 40
	

	If ls_new_status = is_e_termstatus Then

		ls_payid = dw_detail.object.payid[ll_row]
		ls_where = " customerm.payid = '" + ls_payid + "' And ( " + is_term_where + " ) "  
		
		dw_term.is_where = ls_where
		ll_row_1 = dw_term.Retrieve()
		If ll_row_1 = 0 Then 
		ElseIf ll_row_1 < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return li_error
		End If
	ElseIf ls_new_status = is_e_suspenstatus Then
		
		ls_payid = dw_detail.object.payid[ll_row]
		ls_where = " customerm.payid = '" + ls_payid + "'" + &
		           " And contractmst.status = '" + is_active + "'"  
		
		dw_term.is_where = ls_where
		ll_row_1 = dw_term.Retrieve()
		If ll_row_1 = 0 Then 
		ElseIf ll_row_1 < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return li_error
		End If
	ElseIf ls_new_status = is_e_suspendconfirm_status Then
		
		ls_payid = dw_detail.object.payid[ll_row]
		ls_where = " customerm.payid = '" + ls_payid + "'" + &
		           " And contractmst.status = '" + is_active + "'"  
		
		dw_term.is_where = ls_where
		ll_row_1 = dw_term.Retrieve()
		If ll_row_1 = 0 Then 
		ElseIf ll_row_1 < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return li_error
		End If		
		
	End If
	
	SetPointer(HourGlass!)
	iu_db01.uf_prc_db_01()
	SetPointer(Arrow!)
	If iu_db01.ii_rc = -1 Then 
		Return li_error
	end If
NEXT

Return 0
end event

type dw_cond from w_a_reg_m_sql`dw_cond within e01w_reg_del_last_set_1
integer x = 41
integer y = 40
integer width = 1614
integer height = 340
string dataobject = "e01d_cnd_del_last_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_sql`p_ok within e01w_reg_del_last_set_1
integer x = 1742
integer y = 48
end type

type p_close from w_a_reg_m_sql`p_close within e01w_reg_del_last_set_1
integer x = 2350
integer y = 48
end type

type gb_cond from w_a_reg_m_sql`gb_cond within e01w_reg_del_last_set_1
integer width = 1669
integer height = 404
end type

type p_save from w_a_reg_m_sql`p_save within e01w_reg_del_last_set_1
integer x = 2043
integer y = 48
end type

type dw_detail from w_a_reg_m_sql`dw_detail within e01w_reg_del_last_set_1
integer x = 23
integer y = 424
integer width = 2702
integer height = 908
string dataobject = "e01d_del_last"
end type

event dw_detail::ue_init;call super::ue_init;ib_sort_use = False
end event

type dw_term from u_d_base within e01w_reg_del_last_set_1
boolean visible = false
integer x = 37
integer y = 1336
integer width = 3863
integer height = 508
integer taborder = 11
boolean bringtotop = true
string dataobject = "e0dw_inq_termorder"
end type

