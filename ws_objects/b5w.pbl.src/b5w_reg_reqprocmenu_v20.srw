$PBExportHeader$b5w_reg_reqprocmenu_v20.srw
$PBExportComments$[khpark] 청구절차메뉴정의
forward
global type b5w_reg_reqprocmenu_v20 from w_a_reg_m
end type
end forward

global type b5w_reg_reqprocmenu_v20 from w_a_reg_m
integer width = 3438
integer height = 2020
end type
global b5w_reg_reqprocmenu_v20 b5w_reg_reqprocmenu_v20

on b5w_reg_reqprocmenu_v20.create
call super::create
end on

on b5w_reg_reqprocmenu_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_pgm_id,ls_pgm_nm,ls_call_nm1,ls_cancel_yn

//입력 조건 처리 부분
ls_pgm_id = Trim(dw_cond.Object.pgm_id[1])
ls_pgm_nm = Trim(dw_cond.Object.pgm_nm[1])
ls_call_nm1 = Trim(dw_cond.Object.call_nm1[1])
ls_cancel_yn = Trim(dw_cond.Object.cancle_yn[1])

//Error 처리부분
If IsNull(ls_pgm_id) Then ls_pgm_id = ""
If IsNull(ls_pgm_nm) Then ls_pgm_nm = ""
If IsNull(ls_call_nm1) Then ls_call_nm1 = ""
If IsNull(ls_cancel_yn) Then ls_cancel_yn = ""

//Dynamic SQL 처리부분
ls_where = ""
If ls_pgm_id <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "pgm_id like '" + ls_pgm_id + "%'"
End If

If ls_pgm_nm <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "pgm_nm like '%" + ls_pgm_nm + "%'"
End If

If ls_call_nm1 <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "call_nm1 like '%" + ls_call_nm1 + "%'"
End If

If ls_cancel_yn <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "cancel_yn = '" + ls_cancel_yn + "'"
End If

dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event type integer ue_extra_save();Long ll_row, ll_rowcount,ll_seq, ll_long
String ls_pgm_id, ls_pgm_nm, ls_call_nm1,ls_cancel_yn

//필수항목 Check
//기타 항목 Check
ll_rowcount = dw_detail.RowCount()
For ll_row = 1 To ll_rowcount
	ll_seq = dw_detail.Object.seq[ll_row]
	ls_pgm_id = Trim(dw_detail.Object.pgm_id[ll_row])
	ls_pgm_nm = Trim(dw_detail.Object.pgm_nm[ll_row])
   ls_call_nm1 = Trim(dw_detail.Object.call_nm1[ll_row])
   ls_cancel_yn = Trim(dw_detail.Object.cancel_yn[ll_row])

	If IsNull(ls_pgm_id) Then ls_pgm_id= ""
	If IsNull(ls_pgm_nm) Then ls_pgm_nm = ""
	If IsNull(ls_call_nm1) Then ls_call_nm1 = ""
	If IsNull(ls_cancel_yn) Then ls_cancel_yn = ""

	If ll_seq <= 0 Then
		f_msg_usr_err(200, Title, "Seq")
		dw_detail.SetColumn("seq")
		dw_detail.SetFocus()
		Return -2
	End If
	
	//입력한 인증KEY가 같은 인증 KEY가 있는지 check			
	CHOOSE CASE ll_row
		CASE 1  // Row가 1행일때 
			IF  ll_rowcount > 1 THEN	ll_long = dw_detail.Find(" seq = " + string(ll_seq) + "", ll_row + 1, ll_rowcount)

		CASE ll_rowcount // Row가 맨 마지막
			IF  ll_rowcount > 1 THEN	ll_long = dw_detail.Find(" seq = " + string(ll_seq) + "", 1, ll_row -1)
			
		CASE ELSE	  
			IF  ll_rowcount > 1 THEN
				ll_long = dw_detail.Find(" seq = " + string(ll_seq) + "", 1, ll_row -1)
				IF  ll_long > 0 THEN
				else
					ll_long = dw_detail.Find(" seq = " + string(ll_seq) + "", ll_row + 1, ll_rowcount)
				END IF
			END IF
	END CHOOSE
	
	If ll_long > 0 Then
	   f_msg_usr_err(9000,Title, "Seq가 중복됩니다.")
	   dw_detail.SetColumn("seq")
		dw_detail.SetFocus()
		Return -2
	End if
	
	If ls_pgm_id = "" Then
   	f_msg_usr_err(200, Title, "청구절차코드")
		dw_detail.SetColumn("pgm_id")
		dw_detail.SetFocus()
		Return -2
	End If
	If ls_pgm_nm = "" Then
		f_msg_usr_err(200, Title, "청구절차명")
		dw_detail.SetColumn("pgm_nm")
		dw_detail.SetFocus()
		Return -2
	End If
	If ls_call_nm1 = "" Then
		f_msg_usr_err(200, Title, "청구절차프로그램소스")
		dw_detail.SetColumn("call_nm1")
		dw_detail.SetFocus()
		Return -2
	End If
	If ls_cancel_yn = "" Then
		f_msg_usr_err(200, Title, "취소가능여부")
		dw_detail.SetColumn("canlcel_yn")
		dw_detail.SetFocus()
		Return -2
	End If
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_row,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[ll_row]	= gs_user_id
		dw_detail.Object.updtdt[ll_row]		= fdt_get_dbserver_now()
	END IF
	
Next

Return 0

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;////Log 정보
dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row] = gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()

RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_reqprocmenu_v20
integer x = 64
integer y = 68
integer width = 2309
integer height = 208
string dataobject = "b5d_cnd_reg_reqprocmenu_v20"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_reqprocmenu_v20
integer x = 2569
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b5w_reg_reqprocmenu_v20
integer x = 2880
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_reqprocmenu_v20
integer x = 37
integer width = 2368
integer height = 284
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_reqprocmenu_v20
integer x = 334
integer y = 1744
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_reqprocmenu_v20
integer x = 37
integer y = 1744
end type

type p_save from w_a_reg_m`p_save within b5w_reg_reqprocmenu_v20
integer x = 635
integer y = 1744
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_reqprocmenu_v20
integer x = 37
integer y = 304
integer width = 3328
integer height = 1404
string dataobject = "b5dw_reg_reqprocmenu_v20"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")

	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_reqprocmenu_v20
integer x = 1097
integer y = 1744
end type

