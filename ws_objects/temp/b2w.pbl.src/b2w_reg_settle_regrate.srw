$PBExportHeader$b2w_reg_settle_regrate.srw
$PBExportComments$[chooys] 사업자유치수수료 Window
forward
global type b2w_reg_settle_regrate from w_a_reg_m_m
end type
end forward

global type b2w_reg_settle_regrate from w_a_reg_m_m
integer width = 3227
end type
global b2w_reg_settle_regrate b2w_reg_settle_regrate

type variables

end variables

on b2w_reg_settle_regrate.create
call super::create
end on

on b2w_reg_settle_regrate.destroy
call super::destroy
end on

event open;call super::open;//손모양 없애기
dw_detail.SetRowFocusIndicator(Off!)
end event

event ue_ok();call super::ue_ok;String ls_partner, ls_partnernm, ls_where
Long ll_row

ls_partner = Trim(dw_cond.object.partner[1])
ls_partnernm = Trim(dw_cond.object.partnernm[1])

If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_partnernm) Then ls_partnernm = ""

ls_where = ""
If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner like '" + ls_partner + "%'"
End If

If ls_partnernm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partnernm like '" + ls_partnernm + "%'"
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
Else			

End If


end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert
Integer li_tab
Long ll_master_row, ll_seq
String ls_partner, ls_levelcod

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 0 
ls_partner = Trim(dw_master.object.partner[ll_master_row])


		//Log 정보
		dw_detail.object.crt_user[al_insert_row] = gs_user_id
		dw_detail.object.updt_user[al_insert_row] = gs_user_id
		dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
			
		//자동입력
		Select seq_regcommst.nextval
		Into :ll_seq
		From dual;
		
		dw_detail.object.regseq[al_insert_row] = ll_seq
		dw_detail.object.partner[al_insert_row] = ls_partner
		
		dw_detail.object.fromdt[al_insert_row] = fdt_get_dbserver_now()

		dw_detail.SetRow(al_insert_row)
		dw_detail.ScrollToRow(al_insert_row)
		dw_detail.SetColumn("itemcod")
		
Return 0 

end event

event type integer ue_extra_save();call super::ue_extra_save;//Save Check
Integer li_rc
Long ll_master_row
b2u_check 		lu_check

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 0 

//dw_detail.Sort()

lu_check = Create b2u_check
lu_check.is_caller = "b2w_reg_settle_regrate%save"
lu_check.is_title = Title
lu_check.idw_data[1] = dw_detail
lu_check.uf_prc_check2()
li_rc = lu_check.ii_rc

//필수 항목 오류
If li_rc < 0 Then
	Destroy lu_check
	Return li_rc
End If

Destroy lu_check
Return 0 
end event

type dw_cond from w_a_reg_m_m`dw_cond within b2w_reg_settle_regrate
integer x = 41
integer y = 44
integer width = 1915
integer height = 132
string dataobject = "b2dw_cnd_reg_settle_rate"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b2w_reg_settle_regrate
integer x = 2121
integer y = 48
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b2w_reg_settle_regrate
integer x = 2423
integer y = 48
end type

type gb_cond from w_a_reg_m_m`gb_cond within b2w_reg_settle_regrate
integer width = 1957
integer height = 208
end type

type dw_master from w_a_reg_m_m`dw_master within b2w_reg_settle_regrate
integer x = 23
integer y = 236
integer width = 3127
integer height = 548
string dataobject = "b2dw_inq_settle_rate"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.partner_t
uf_init(ldwo_sort)

end event

type dw_detail from w_a_reg_m_m`dw_detail within b2w_reg_settle_regrate
integer y = 816
integer width = 3113
integer height = 828
string dataobject = "b2dw_reg_settle_rate_t1"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where
String	ls_partner
Long		ll_rows

//Set PartnerCode
ls_partner	= Trim(dw_master.Object.partner[al_select_row])

//Retrieve
If al_select_row > 0 Then
	//PartnerCode
	ls_where = "partner = '" + ls_partner + "'"
	
	dw_detail.is_where = ls_where		
	
	ll_rows = dw_detail.Retrieve()

	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

type p_insert from w_a_reg_m_m`p_insert within b2w_reg_settle_regrate
integer y = 1664
end type

type p_delete from w_a_reg_m_m`p_delete within b2w_reg_settle_regrate
integer y = 1664
end type

type p_save from w_a_reg_m_m`p_save within b2w_reg_settle_regrate
integer y = 1664
end type

type p_reset from w_a_reg_m_m`p_reset within b2w_reg_settle_regrate
integer y = 1664
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b2w_reg_settle_regrate
integer y = 780
end type

