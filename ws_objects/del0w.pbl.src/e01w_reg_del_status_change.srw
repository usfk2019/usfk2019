$PBExportHeader$e01w_reg_del_status_change.srw
$PBExportComments$[parkkh] 연체자 상태변화 등록
forward
global type e01w_reg_del_status_change from w_a_reg_m_m3
end type
end forward

global type e01w_reg_del_status_change from w_a_reg_m_m3
integer width = 3095
integer height = 2108
end type
global e01w_reg_del_status_change e01w_reg_del_status_change

type variables
String is_payid, is_del_status
long il_Seq
e01u_dbmgr iu_db01


end variables

on e01w_reg_del_status_change.create
call super::create
end on

on e01w_reg_del_status_change.destroy
call super::destroy
end on

event close;call super::close;destroy iu_db01

end event

event open;call super::open;String ls_ref_desc

iu_db01 = Create e01u_dbmgr
is_del_status = fs_get_control("E2", "F101", ls_ref_desc)

end event

event ue_extra_delete(ref integer ai_return);call super::ue_extra_delete;string ls_status_cd, ls_current
long ll_row
dwItemStatus ldw_status

iu_db01.is_caller = "e01w_reg_del_status_change%status_cd"
iu_db01.is_title = This.Title
iu_db01.uf_prc_db()
If iu_db01.ii_rc = -1 Then 	
	Return
End If

ls_status_cd  = iu_db01.is_data[1]
ll_row = dw_detail.getrow()
ls_current = dw_detail.object.dlydet_status[ ll_row ]

if ls_status_cd = ls_current and dw_detail.object.work_gb[ ll_row ] = 'Y' then
	dw_detail.ScrollToRow(ll_row)
	dw_detail.Setrow(ll_row )
	
	f_msg_usr_err(1300,this.title,"연체발생 처리 불가")
	ai_return = -1
	Return
Else
	ldw_status = dw_detail.GetItemStatus(ll_row, 0, Primary!)
	If ldw_status = NotModified! Or ldw_status = DataModified! Then
		dw_detail.ScrollToRow(ll_row)
		dw_detail.Setrow(ll_row )
		
		f_msg_usr_err(1300,this.title,"기존 상태변화내역 삭제 불가")
		ai_return = -1
		Return
	End If
	
end if
end event

event ue_extra_insert(long al_insert_row, ref integer ai_return);call super::ue_extra_insert;
ai_return = -1

il_seq = il_seq + 1
dw_detail.Object.payid[al_insert_row] = is_payid
dw_detail.Object.seq[al_insert_row] = il_seq
//Log 정보
dw_detail.object.dlydet_crt_user[al_insert_row] = gs_user_id
dw_detail.object.dlydet_crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.dlydet_updt_user[al_insert_row] = gs_user_id
dw_detail.object.dlydet_updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.dlydet_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

ai_return = 0

end event

event ue_extra_save(ref integer ai_return);
string ls_work
long ll_row,ll_k

ll_row = dw_detail.rowcount()
ls_work = dw_detail.object.work_gb[ ll_row ]
For ll_k = 1 to ll_row
	If dw_detail.object.work_gb[ ll_k ] = 'N' and dw_detail.object.dlydet_status[ ll_k ] = is_del_status then
		dw_detail.Setfocus()
		dw_detail.ScrollToRow(ll_k)
	   dw_detail.Setrow(ll_k)	
		f_msg_usr_err(1200,this.title,"연체발생 처리 불가")
	   ai_return = -1
	   Return
   end if
next

For ll_k = 1 to ll_row
	//log 정보
   If dw_detail.GetItemStatus(ll_k, 0, Primary!) = DataModified! THEN
		dw_detail.object.dlydet_updt_user[ll_k] = gs_user_id
		dw_detail.object.dlydet_updtdt[ll_k] = fdt_get_dbserver_now()
		dw_detail.object.dlydet_pgm_id[ll_k] = gs_pgm_id[gi_open_win_no]	
	End If
Next
end event

event ue_ok_after();call super::ue_ok_after;String ls_where
String ls_payid , ls_name , ls_status, ls_delay_months 
long ll_row
Integer li_delay_months, li_delay_months_to

li_delay_months =  dw_cond.Object.delay_months[1]
If li_delay_months=0 Then SetNull(li_delay_months)
li_delay_months_to = dw_cond.Object.delay_months_to[1]
If li_delay_months_to = 0 Then SetNull(li_delay_months_to)

ls_payid = trim( dw_cond.Object.payid[1] )
ls_name = trim( dw_cond.Object.name[1] )
ls_status = trim( dw_cond.object.status_cd[1] )
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_name) Then ls_name = ""
If IsNull(ls_status) Then ls_status = ""

ls_where = ""
If ls_payid <> "" then
	ls_where += " dlymst.payid = '" + ls_payid + "' "
end If	

//If ls_name <> "" Then
//	If ls_where <> "" then ls_where += " and "
//	ls_where += " paymst.marknm like '%"+ ls_name + "%' "
//end If

If ls_status <> "" Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " dlymst.status = '" + ls_status + "' "
end If

If Not IsNull(li_delay_months) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " dlymst.DELAY_MONTHS >= " + String(li_delay_months) + " " 
End If
If Not IsNull(li_delay_months_to) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " dlymst.DELAY_MONTHS <= " + String(li_delay_months_to) + " " 
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
IF ll_row > 0 THEN
	p_ok.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = FALSE
ELSE
	IF ll_row = 0 THEN
		f_msg_info(1000, This.Title, "")
	ELSEIF ll_row < 0 THEN
		f_msg_usr_err(2100, This.Title, "Function Failed")
	END IF

	dw_cond.SetFocus()
END IF
end event

event ue_save_after(ref integer ai_return);call super::ue_save_after;
iu_db01.is_caller = "e01w_reg_del_status_change%ue_save_after"
iu_db01.is_title = This.Title
iu_db01.is_data[1] = is_payid

iu_db01.uf_prc_db()

If iu_db01.ii_rc = -1 Then
	ai_return = -1
End If


end event

type dw_cond from w_a_reg_m_m3`dw_cond within e01w_reg_del_status_change
integer y = 40
integer width = 1778
integer height = 212
string dataobject = "e01d_cnd_reg_status_change"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m3`p_ok within e01w_reg_del_status_change
integer x = 1934
integer y = 48
end type

type p_close from w_a_reg_m_m3`p_close within e01w_reg_del_status_change
integer x = 2240
integer y = 48
end type

type gb_cond from w_a_reg_m_m3`gb_cond within e01w_reg_del_status_change
integer width = 1833
integer height = 264
end type

type dw_master from w_a_reg_m_m3`dw_master within e01w_reg_del_status_change
integer x = 23
integer y = 296
integer width = 2999
integer height = 568
string dataobject = "e01d_reg_status_change_master"
end type

event dw_master::ue_select;call super::ue_select;//	
//Long ll_selected_row 
//Integer li_return, li_ret
//
//ll_selected_row = GetSelectedRow( 0 )
//
////If dw_detail.ModifiedCount() > 0 or &
////	dw_detail.DeletedCount() > 0 or &
// if dw_detail2.ModifiedCount() > 0 or &
//	dw_detail2.DeletedCount() > 0 then
//	
//	li_ret = MessageBox( "알림", "수정된 자료가 있습니다. 저장하시겠습니까? " , question!, YesNo! , 1 )
//	CHOOSE CASE li_ret
//		CASE 1
//			li_ret = Parent.Event ue_save()
//			If isnull( li_ret ) or li_ret < 0 then return
//		CASE 2
//		CASE ELSE
//			Return
//	END CHOOSE
//		
//end If
//	
//dw_detail.Event ue_retrieve(ll_selected_row,li_return)
//If li_return < 0 Then
//	Return
//End If
//
//dw_detail2.Event ue_retrieve(ll_selected_row,li_return)
//If li_return < 0 Then
//	Return
//End If
//
end event

event dw_master::constructor;call super::constructor;ib_sort_use = True
end event

event dw_master::ue_init;call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.payid_t
uf_init(ldwo_SORT)

end event

type dw_detail from w_a_reg_m_m3`dw_detail within e01w_reg_del_status_change
integer x = 18
integer y = 1176
integer width = 3127
integer height = 580
string dataobject = "e01d_reg_del_status_change_det1"
end type

event dw_detail::clicked;call super::clicked;//long ll_row
//string ls_work
//
//ll_row = dw_detail.getrow()
//ls_work = dw_detail.object.work_gb[ll_row]
//
//if ls_work = "Y" then
//	dw_detail.object.dlydet_status.protect = 1
//else
//	dw_detail.object.dlydet_status.protect = 0
//end if


end event

event dw_detail::constructor;call super::constructor;SetRowfocusIndicator(Off!)
end event

event dw_detail::ue_init;call super::ue_init;ib_delete = True 
ib_insert = True


end event

event dw_detail::ue_retrieve(long al_select_row, ref integer ai_return);call super::ue_retrieve;String ls_where
string ls_payid
string ls_status_cd, ls_current
long ll_row, ll_whole
is_where = ""

if al_select_row > 0 then
	ls_payid = dw_master.Object.payid[ al_select_row ]
else 
	ls_payid = ''
End If

is_payid = ls_payid  // 저장시 사후처리를 위해 사용 

ls_where = " dlydet.payid = '" + ls_payid + "' "

ls_where += " and dlystscod.status_flag  = '1' "   // 상태코드 일반만 파라미터

is_where = ls_where
ai_return = dw_detail.Retrieve()

/*마지막 seq 가져오기*/
iu_db01.is_caller = "e01w_reg_del_status_change%lastseq"
iu_db01.is_title = This.Title
iu_db01.is_data[1] = is_payid
iu_db01.uf_prc_db()
If iu_db01.ii_rc = -1 Then 	
	Return
End If	
il_seq  = iu_db01.il_data[1]


iu_db01.is_caller = "e01w_reg_del_status_change%status_cd"
iu_db01.is_title = This.Title
iu_db01.uf_prc_db()
If iu_db01.ii_rc = -1 Then 	
	Return
End If

ls_status_cd  = iu_db01.is_data[1]
ll_whole = dw_detail.Rowcount()

FOR ll_row = 1 TO ll_whole
//	ll_row = dw_detail.getrow()
	ls_current = dw_detail.object.dlydet_status[ ll_row ]
	if ls_status_cd = ls_current then
		 dw_detail.object.work_gb[ ll_row ] = 'Y'
	else
		 dw_detail.object.work_gb[ ll_row ] = 'N'
	end if
	dw_detail.SetItemStatus(ll_row, "work_gb", Primary!, NotModified!)
NEXT

//Focus Control
dw_detail.InsertRow(ll_whole + 1)
dw_detail.ScrollToRow(ll_whole + 1)
dw_detail.DeleteRow(ll_whole + 1)
dw_detail.SetItemStatus(0, 0, Primary!, NotModified!)
end event

type p_insert from w_a_reg_m_m3`p_insert within e01w_reg_del_status_change
integer y = 1784
end type

type p_delete from w_a_reg_m_m3`p_delete within e01w_reg_del_status_change
integer y = 1784
end type

type p_save from w_a_reg_m_m3`p_save within e01w_reg_del_status_change
integer y = 1784
end type

type p_reset from w_a_reg_m_m3`p_reset within e01w_reg_del_status_change
integer y = 1784
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within e01w_reg_del_status_change
integer x = 23
integer y = 892
integer width = 3127
integer height = 256
string dataobject = "e01d_reg_del_status_change_det2"
boolean hsplitscroll = false
end type

event dw_detail2::constructor;call super::constructor;SetRowfocusIndicator(Off!)
end event

event dw_detail2::ue_retrieve;call super::ue_retrieve;String ls_where
string ls_payid
is_where = ""
if al_select_row > 0 then
	ls_payid = dw_master.Object.payid[ al_select_row ]
else 
	ls_payid = ""
End If

ls_where = " dlydet.payid = '" + ls_payid + "' "

ls_where += " and dlystscod.status_flag <> '1' "   // 상태코드 일반만 파라미터 ?

is_where = ls_where
ai_return = dw_detail2.Retrieve()



end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within e01w_reg_del_status_change
integer x = 14
integer y = 864
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within e01w_reg_del_status_change
integer x = 14
integer y = 1140
integer height = 40
end type

