$PBExportHeader$w_reg_control_desc2.srw
$PBExportComments$Different Code Table(from w_a_reg_m_m)
forward
global type w_reg_control_desc2 from w_a_reg_m_m
end type
type mle_note from multilineedit within w_reg_control_desc2
end type
end forward

global type w_reg_control_desc2 from w_a_reg_m_m
integer width = 3109
integer height = 2064
mle_note mle_note
end type
global w_reg_control_desc2 w_reg_control_desc2

type variables
String is_pgmid
end variables

event ue_ok();call super::ue_ok;Long ll_row
Int li_return

String ls_code, ls_codenm, ls_where, ls_concd
String ls_module, ls_ref_no, ls_ref_desc

//파라미터값: G100 (Group code) 
ls_ref_desc = ""
ls_concd = fs_get_control("00", "G300", ls_ref_desc)

ls_code = Trim(String(dw_cond.Object.code[1]))
ls_module = Trim(String(dw_cond.Object.module[1]))
ls_ref_no = Trim(String(dw_cond.Object.ref_no[1]))
ls_ref_desc = Trim(String(dw_cond.Object.ref_desc[1]))
ls_codenm = Trim(String(dw_cond.Object.codenm[1]))

If IsNull(ls_code) Then ls_code = ''
If IsNull(ls_module) Then ls_module = ''
If IsNull(ls_ref_no) Then ls_ref_no = ''
If IsNull(ls_ref_desc) Then ls_ref_desc = ''
If IsNull(ls_codenm) Then ls_codenm = ''

ls_where = " EXISTS (SELECT 1 FROM SYSCTL1T P " + &
						  " WHERE C.CODE = P.GRCD " + &
						  "	AND P.MODULE LIKE  '" + ls_module + "%" + "'" + &
						  "	AND P.REF_NO LIKE '" + ls_ref_no + "%" + "'" + &
						  "	AND P.REF_DESC LIKE '%" + ls_ref_desc + "%" + "'" + ")" + &
				  " AND C.GRCODE = '" + ls_concd +"'" + &
				  " AND C.CODE like '" + ls_code + "%" + "'" + &
				  " AND C.CODENM LIKE '%" + ls_codenm + "%" + "'" 
						  
// '" + ls_concd + "'"
dw_master.is_where = ls_where

ll_row = dw_master.Retrieve()

If ll_row <= 0 Then
	Beep(1)
	
	If ll_row = 0 Then
		f_msg_usr_err(1100,This.Title,"CODE OR DESC")
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100,This.Title,"DATAWINDOW RETRIEVE()")
	End if
	
	dw_cond.SetFocus()
	dw_cond.SetColumn("code")
	Return
End if


end event

on w_reg_control_desc2.create
int iCurrent
call super::create
this.mle_note=create mle_note
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.mle_note
end on

on w_reg_control_desc2.destroy
call super::destroy
destroy(this.mle_note)
end on

event open;call super::open;is_pgmid = iu_cust_msg.is_pgm_id

mle_note.Visible = False
end event

event type integer ue_extra_save();call super::ue_extra_save;//Date ld_now
Integer	li_return
Long		ll_mrow_cnt, ll_row_cnt
String	ls_module, ls_ref_no, ls_ref_desc
String	ls_pgm_id, ls_pgm_item, ls_chg_item, ls_old, ls_new

////***** Record when modified or created ****
//Read today & current time
//iu_cust_db_app.is_caller = "NOW"
//iu_cust_db_app.is_title = This.Title
//
//iu_cust_db_app.uf_prc_db()
//
//If iu_cust_db_app.ii_rc = -1 Then Return
//
//ld_now = Date(iu_cust_db_app.idt_data[1])
//

//Record
ll_row_cnt = dw_detail.RowCount()
Do While ll_mrow_cnt <= ll_row_cnt
	ll_mrow_cnt = dw_detail.GetNextModified(ll_mrow_cnt, Primary!)
	If ll_mrow_cnt > 0 Then
//		dw_detail.Object.reg_dt[ll_mrow_cnt] = ld_now

		//SYSTEM LOG를 남긴다.(pgm_id, '|', module+':'+ref_no+' '+ref_desc)
		ls_module = Trim(dw_detail.Object.module[ll_mrow_cnt])
		ls_ref_no = Trim(dw_detail.Object.ref_no[ll_mrow_cnt])
		ls_ref_desc = Trim(dw_detail.Object.ref_desc[ll_mrow_cnt])
		ls_old = Trim(dw_detail.Object.ref_content.Primary.Original[ll_mrow_cnt])
		ls_new = Trim(dw_detail.Object.ref_content.Primary.Current[ll_mrow_cnt])

		If IsNull(ls_module) Then ls_module = ""
		If IsNull(ls_ref_no) Then ls_ref_no = ""
		If IsNull(ls_ref_desc) Then ls_ref_desc = ""
		If IsNull(ls_old) Then ls_old = ""
		If IsNull(ls_new) Then ls_new = ""

		ls_pgm_id = is_pgmid
		ls_pgm_item = "|"
		ls_chg_item = ls_module + ":" + ls_ref_no + " " + ls_ref_desc
		li_return = fi_set_systemlog(ls_pgm_id, ls_pgm_item, ls_chg_item, ls_old, ls_new)
		If li_return < 0 Then Return -1
	Else
		ll_mrow_cnt = ll_row_cnt + 1
	End If
Loop

Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within w_reg_control_desc2
integer x = 41
integer width = 2341
integer height = 260
string dataobject = "d_cnd_control_desc2"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m_m`p_ok within w_reg_control_desc2
integer x = 2441
integer y = 44
end type

type p_close from w_a_reg_m_m`p_close within w_reg_control_desc2
integer x = 2743
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_reg_control_desc2
integer height = 332
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within w_reg_control_desc2
event ue_dwnmousemove pbm_dwnmousemove
integer x = 41
integer y = 348
integer height = 568
integer taborder = 30
string dataobject = "d_inq_code_detail1"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.code_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within w_reg_control_desc2
event ue_dwnmousemove pbm_dwnmousemove
integer y = 956
integer height = 832
integer taborder = 40
string dataobject = "d_reg_control_desc1"
end type

event dw_detail::ue_dwnmousemove;// NOTE 도움말
String ls_note
Long ll_row

Choose Case dwo.name
	Case "note" 
		This.AcceptText()
		ls_note = Trim(This.Object.note[Row])

		If IsNull(ls_note) Then ls_note = ""
		
		If ls_note <> "" then

			mle_note.Position()
			mle_note.text = ls_note
//		   mle_note.width = Len(mle_note.text) * (PixelsToUnits(-mle_note.textsize * 0.7, XPixelsToUnits!)) 
//		   mle_note.Height = 1.6 * PixelsToUnits(-mle_note.textsize, YPixelsToUnits!) 
			mle_note.x = This.PointerX()
			mle_note.y = This.PointerY()
			mle_note.BringToTop = True
			mle_note.Visible = True
		Else 
			mle_note.visible =False
		End If
End Choose
end event

event type integer dw_detail::ue_retrieve(long al_select_row);String ls_code, ls_module, ls_ref_no, ls_ref_desc, ls_codenm, ls_where

String ls_code_mst, ls_concd

ls_ref_desc = ""
ls_concd = fs_get_control("00", "G300", ls_ref_desc)

ls_code = Trim(String(dw_cond.Object.code[1]))
ls_module = Trim(String(dw_cond.Object.module[1]))
ls_ref_no = Trim(String(dw_cond.Object.ref_no[1]))
ls_ref_desc = Trim(String(dw_cond.Object.ref_desc[1]))
ls_codenm = Trim(String(dw_cond.Object.codenm[1]))

If IsNull(ls_code) Then ls_code = ''
If IsNull(ls_module) Then ls_module = ''
If IsNull(ls_ref_no) Then ls_ref_no = ''
If IsNull(ls_ref_desc) Then ls_ref_desc = ''
If IsNull(ls_codenm) Then ls_codenm = ''


ls_code_mst = dw_master.Object.code[al_select_row]

ls_where = " EXISTS (SELECT 1 FROM SYSCOD2T C " + &
						  " WHERE P.GRCD = C.CODE " + &
							 " AND C.GRCODE = '" + ls_concd +"'" + &
							 " AND C.CODE like '" + ls_code + "%" + "'" + &
							 " AND C.CODENM LIKE '" + ls_codenm + "%" + "'" + ")" + & 
			  "	AND P.MODULE LIKE  '" + ls_module + "%" + "'" + &
			  "	AND P.REF_NO LIKE '" + ls_ref_no + "%" + "'" + &
			  "	AND P.REF_DESC LIKE '" + ls_ref_desc + "%" + "'" + &
			  "   AND P.GRCD LIKE '" + ls_code_mst + "%" + "'"

dw_detail.is_where = ls_where

If dw_detail.Retrieve() < 0 Then
	Return -1
End If

Return 0
end event

event dw_detail::constructor;call super::constructor;DataWindowChild ldc_grcd

Int li_exist
String ls_ref_desc, ls_concd

//파라미터값: G100 (Group code) 
ls_ref_desc = ""
ls_concd = fs_get_control("00", "G300", ls_ref_desc)

li_exist = This.GetChild("grcd", ldc_grcd)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Group Code")
ldc_grcd.SetTransObject(SQLCA)
li_exist =ldc_grcd.Retrieve(ls_concd)

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 1
End If  
end event

event dw_detail::clicked;call super::clicked;//PopUp Window Open
Choose Case dwo.name
	Case "note" 
		This.AcceptText()
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "Modfied Note of System Control"
		iu_cust_msg.is_grp_name = "System Control"
		iu_cust_msg.idw_data[1] = dw_detail
		iu_cust_msg.is_data[1] = Trim(dw_detail.object.note[Row])
		iu_cust_msg.il_data[1] = Row
		OpenWithParm(w_req_control_popup, iu_cust_msg)
End Choose
end event

type p_insert from w_a_reg_m_m`p_insert within w_reg_control_desc2
integer x = 37
integer y = 1832
end type

type p_delete from w_a_reg_m_m`p_delete within w_reg_control_desc2
integer x = 329
integer y = 1832
end type

type p_save from w_a_reg_m_m`p_save within w_reg_control_desc2
integer x = 626
integer y = 1832
end type

type p_reset from w_a_reg_m_m`p_reset within w_reg_control_desc2
integer x = 1367
integer y = 1832
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within w_reg_control_desc2
integer x = 32
integer y = 920
end type

type mle_note from multilineedit within w_reg_control_desc2
boolean visible = false
integer x = 1339
integer y = 692
integer width = 1403
integer height = 376
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean displayonly = true
end type

