$PBExportHeader$b1w_reg_trouble_mst_v20.srw
$PBExportComments$[jsha] 민원유형등록
forward
global type b1w_reg_trouble_mst_v20 from w_a_reg_m_m
end type
end forward

global type b1w_reg_trouble_mst_v20 from w_a_reg_m_m
integer width = 3264
end type
global b1w_reg_trouble_mst_v20 b1w_reg_trouble_mst_v20

type variables
Boolean ib_new
String is_select_cod
Long il_return = 0
end variables

on b1w_reg_trouble_mst_v20.create
call super::create
end on

on b1w_reg_trouble_mst_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_selectcod, ls_category, ls_troublenm, ls_partner, ls_chkNew
Long ll_row

//ls_selectcod = Trim(dw_cond.object.selectcod[1])
ls_category = Trim(dw_cond.object.category[1])
ls_troublenm = Trim(dw_cond.object.troublenm[1])
ls_partner = Trim(dw_cond.Object.partner[1])
ls_chkNew = Trim(dw_cond.Object.chkNew[1])
//If IsNull(ls_selectcod) Then ls_selectcod = ""
If IsNull(ls_category) Then ls_category = ""
If IsNull(ls_troublenm) Then ls_troublenm = ""
If IsNull(ls_partner) Then ls_partner = ""
If ls_chkNew = 'Y' Then 
	ib_new = True
//Else 
//	ib_new = False
End If

If ib_new = True Then
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("Clicked")
	Return
Else 
	ls_where = ""
	
//	If ls_category <> "" Then
//		Choose Case ls_selectcod
//			Case "categoryA"
//				If ls_where <> "" Then ls_where += " And "
//				ls_where += "troubletypemst.troubletypea = '" + ls_category + "' "
//			Case "categoryB"
//				If ls_where <> "" Then ls_where += " And "
//				ls_where += "troubletypea.troubletypeb = '" + ls_category + "' "
//			Case "categoryC"
//				If ls_where <> "" Then ls_where += " And "
//				ls_where += "troubletypeb.troubletypec = '" + ls_category + "' "
//		End Choose		
//	End If

	If ls_category <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "troubletypemst.troubletypea = '" + ls_category + "' "
	End If
	
	If ls_troublenm <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "Upper(troubletypemst.troubletypenm) Like '%" + Upper(ls_troublenm) + "%' "
	End If
	If ls_partner <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += "troubletypemst.partner = '" + ls_partner + "' "
	End If
	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	
	If ll_row = 0 then
		f_msg_info(1000, Title, "")
		p_reset.TriggerEvent('ue_enable')
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return
	End If
	
	p_insert.TriggerEvent('ue_disable')
End If
	
end event

event open;call super::open;ib_new = False
dw_detail.SetRowFocusIndicator(off!)
p_insert.TriggerEvent("ue_disable")
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;/** For Log **/
dw_detail.object.crt_user[al_insert_row]  = gs_user_id
dw_detail.object.crtdt[al_insert_row]     = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
dw_detail.object.admodel_yn[al_insert_row]= 'N'
dw_detail.object.email_yn[al_insert_row]  = 'N'
dw_detail.object.sms_yn[al_insert_row]    = 'N'
dw_detail.Object.troubletype.protect      = 0
dw_detail.Object.troubletype.Background.Color = RGB(108,147,137)
dw_detail.Object.troubletype.Color        = RGB(255,255,255)

Return 0
end event

event type integer ue_reset();call super::ue_reset;ib_new = False
Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_troubletype, ls_troubletypenm, ls_troubletypea, ls_partner, ls_partner_auth
Long ll_row

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0

ll_row = dw_Detail.GetRow()

dw_detail.AcceptText()

ls_troubletype   = dw_detail.Object.troubletype[ll_row]
ls_troubletypenm = dw_detail.Object.troubletypenm[ll_row]
ls_troubletypea  = dw_detail.Object.troubletypea[ll_row]
ls_partner       = dw_detail.Object.partner[ll_row]
ls_partner_auth  = dw_detail.Object.partner_auth[ll_row]

If IsNull(ls_troubletype)   Then ls_troubletype   = ""
If IsNull(ls_troubletypenm) Then ls_troubletypenm = ""
If IsNull(ls_troubletypea)  Then ls_troubletypea  = ""
If IsNull(ls_partner)       Then ls_partner       = ""
If IsNull(ls_partner_auth)  Then ls_partner_auth  = ""

IF ls_troubletype = "" Then
	f_msg_usr_err(200, this.title, "민원유형코드")
	dw_detail.SetColumn("troubletype")
	dw_detail.SetFocus()
	il_return = -1
	Return -2
End If
IF ls_troubletypenm = "" Then
	f_msg_usr_err(200, This.Title, "민원유형명")
	dw_detail.SetColumn("troubletypenm")
	dw_detail.SetFocus()
	il_return = -1
	Return -2
End If
If ls_troubletypea = "" Then
	f_msg_usr_err(200, This.Title, "민원소분류")
	dw_detail.SetColumn("troubletypea")
	dw_detail.SetFocus()
	il_return = -1
	Return -2 
End If
If ls_partner_auth = "" Then
	f_msg_usr_err(200, This.Title, "처리권한")
	dw_detail.SetColumn("partner_auth")
	dw_detail.SetFocus()
	il_return = -1
	Return -2 
End If

IF dw_detail.Object.partner_auth[ll_row] = '3' THEN
	If ls_partner = "" Then
		f_msg_usr_err(200, This.Title, "수행처")
		dw_detail.SetColumn("partner")
		dw_detail.SetFocus()
	   il_return = -1
		Return -2 
	End If
END IF
il_return = 0
dw_detail.Object.updtdt[ll_row] = fdt_get_dbserver_now()
dw_detail.Object.updt_user[ll_row] = gs_user_id

Return 0
end event

event type integer ue_extra_delete();call super::ue_extra_delete;String ls_troubletype, ls_customerid
Long ll_row, ll_CNT, ll_troubleno

dw_master.AcceptText()

ll_row = dw_master.RowCount()
If ll_row = 0 Then Return 1

ls_troubletype  = trim(dw_master.Object.troubletypemst_troubletype[dw_master.GetRow()])

SELECT TROUBLENO, NVL(CUSTOMERID,' ')
  INTO :ll_troubleno, :ls_customerid
  FROM CUSTOMER_TROUBLE
 WHERE TROUBLETYPE = :ls_troubletype
   AND ROWNUM = 1;
	
IF SQLCA.SQLCODE = 0 THEN
	MESSAGEBOX('확인','접수번호 : '+STRING(ll_troubleno) +'~r~n'+'고객번호 : '+ls_customerid+'에서 사용중이므로 ~r~n삭제가 불가능합니다.' )
	Return -1
END IF
	
Return 0
end event

event type integer ue_save();call super::ue_save;If il_return = 0 THEN
	TriggerEvent("ue_reset")
	TriggerEvent("ue_ok")
End If
return 1
end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 
	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_trouble_mst_v20
integer width = 2313
string dataobject = "b1dw_cnd_reg_troublemst_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::clicked;call super::clicked;//string ls_selectcod
//
////분류선택을 선택하지 않고 category 컬럼을 클릭할 때 메세지!!
//Choose Case dwo.Name
//	Case "category"
//		ls_selectcod = This.Object.selectcod[row]
//		If IsNull(ls_selectcod) or ls_selectcod = "" Then
//			 f_msg_usr_err(9000, parent.Title, "분류선택을 먼저 선택하세요!")
//			 return -1
//		End If
//End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;////분류선택에서 대분류, 중분류, 소분류를 선택함에 따라 category 컬럼의 dddw를 바꾼다.
//Choose Case dwo.Name
//	Case "selectcod"
//		Choose Case data
//			Case "categoryA"         //소분류
//				is_select_cod = "categoryA"
//				Modify("category.dddw.name=''")
//				Modify("category.dddw.DataColumn=''")
//				Modify("category.dddw.DisplayColumn=''")
//				This.Object.category[row] = ''				
//				Modify("category.dddw.name=b1dc_dddw_troubletypea")
//				Modify("category.dddw.DataColumn='troubletypea_troubletypea'")
//				Modify("category.dddw.DisplayColumn='troubletypea_troubletypeanm'")
////				
//			Case "categoryB"			//중분류
//				is_select_cod = "categoryB"				
//				Modify("category.dddw.name=''")
//				Modify("category.dddw.DataColumn=''")
//				Modify("category.dddw.DisplayColumn=''")
//				This.Object.category[row] = ''				
//				Modify("category.dddw.name=b1dc_dddw_troubletypeb")
//				Modify("category.dddw.DataColumn='troubletypeb_troubletypeb'")
//				Modify("category.dddw.DisplayColumn='troubletypeb_troubletypebnm'")
//				 
//			Case "categoryC"			//대분류
//				is_select_cod = "categoryC"				
//				Modify("category.dddw.name=''")
//				Modify("category.dddw.DataColumn=''")
//				Modify("category.dddw.DisplayColumn=''")
//				This.Object.category[row] = ''				
//				Modify("category.dddw.name=b1dc_dddw_troubletypec")
//				Modify("category.dddw.DataColumn='troubletypec'")
//				Modify("category.dddw.DisplayColumn='troubletypecnm'")
//				
//			Case else					//분류선택 안했을 경우...
//				is_select_cod = ""				
//				Modify("category.dddw.name=''")
////				Modify("category.dddw.DataColumn=''")
////				Modify("category.dddw.DisplayColumn=''")
//				This.Object.category[row] = ''
//		End Choose
//End Choose
//
//Return 0
end event

event dw_cond::constructor;SetTransObject(SQLCA)
//f_modify_dw_title(this)

InsertRow( 0 )

Int li_i
iu_cust_help = create u_cust_a_msg
//iu_cust_help.ib_data[1] = False

Trigger Event ue_init()  // append by csh

//*****DataWindow의 Help Row의 색깔 및 Pointer 처리
ii_help_col_no = UpperBound(is_help_win)
For li_i = 1 To ii_help_col_no
//	idwo_help_col[li_i].Color = il_help_col_color
	idwo_help_col[li_i].Pointer = is_help_cur
Next

end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_trouble_mst_v20
integer x = 2885
integer y = 112
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_trouble_mst_v20
integer x = 1216
integer y = 1652
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_trouble_mst_v20
integer width = 3168
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_trouble_mst_v20
integer width = 3163
string dataobject = "b1dw_reg_troublemst_m"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.troubletypemst_troubletype_t
uf_init(ldwo_sort)
end event

event dw_master::clicked;call super::clicked;
p_insert.TriggerEvent('ue_disable')
end event

event dw_master::constructor;SetTransObject(SQLCA)
//f_modify_dw_title(this)
	
Trigger Event ue_init()
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_trouble_mst_v20
integer x = 32
integer y = 744
integer width = 3163
string dataobject = "b1dw_reg_troublemst_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String ls_troubletype, ls_where
Long ll_row

ls_troubletype = dw_master.Object.troubletypemst_troubletype[al_select_row]
ls_where = "troubletypemst.troubletype = '" + ls_troubletype + "' "

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Parent.Title, "Retrieve()")
	Return -1
End If

If ib_new = False Then
	This.Object.troubletype.protect = 1
	This.Object.troubletype.Background.Color = RGB(255, 251, 240)
	This.Object.troubletype.Color = RGB(0, 0, 0)
End If

p_insert.TriggerEvent("ue_disable")
Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;DataWindowChild ldc_troubletypeb, ldc_troubletypec
String ls_filter, ls_troubletypeb, ls_troubletypec, ls_svccod
Integer li_exist

Choose Case dwo.name
	Case "troubletypea"
//		li_exist = dw_detail.GetChild("troubletypea_troubletypeb", ldc_troubletypeb)
//		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 민원중분류")
//		ls_filter = "troubletypea.troubletypea = '" + data + "' "
//		ldc_troubletypeb.SetTransObject(SQLCA)
//		li_exist =ldc_troubletypeb.Retrieve()
//		ldc_troubletypeb.SetFilter(ls_filter)			//Filter정함
//		ldc_troubletypeb.Filter()
//		
//		If li_exist < 0 Then 				
//		  f_msg_usr_err(2100, Title, "Retrieve()")
//		  Return 1  		//선택 취소 focus는 그곳에
//		End If  
		SELECT a.troubletypeB, b.troubletypec, b.svccod
		INTO :ls_troubletypeb, :ls_Troubletypec, :ls_svccod
		FROM troubletypeA a, troubletypeb b
		WHERE a.troubletypeb = b.troubletypeb
		AND troubletypea = :data;
		
		If SQLCA.SQLCODE < 0 Then
			f_msg_sql_err(parent.Title, "SELECT ERROR troubletypeb")
			Return 1
		End If
		
		This.Object.troubletypea_troubletypeb[row] = ls_troubletypeb
		This.Object.troubletypeb_troubletypec[row] = ls_troubletypec
		This.Object.troubletypeb_svccod[row] = ls_svccod
		
	Case "partner_auth"
		If data = '3' Then
			This.Object.partner.Background.Color = RGB(108,147,137)
		   This.Object.partner.Color = RGB(255, 255, 255)
		Else
			This.Object.partner.Background.Color = RGB(255,251,240)
		   This.Object.partner.Color = RGB(000, 000, 000)
		End If
			
End Choose
		
end event

event dw_detail::retrieveend;call super::retrieveend;String ls_auth
dw_detail.Accepttext()
ls_auth = dw_detail.Object.partner_auth[1]

IF ls_auth = '3' THEN
	This.Object.partner.Background.Color = RGB(108,147,137)
	This.Object.partner.Color = RGB(255, 255, 255)
ELSE
	This.Object.partner.Background.Color = RGB(255,251,240)
	This.Object.partner.Color = RGB(000, 000, 000)
END IF
	
end event

event dw_detail::doubleclicked;//
end event

event dw_detail::constructor;SetTransObject(SQLCA)
//f_modify_dw_title(this)
	
Int li_i
iu_cust_help = create u_cust_a_msg
//iu_cust_help.ib_data[1] = False

Trigger Event ue_init()  // append by csh

//*****DataWindow의 Help Row의 색깔 및 Pointer 처리
ii_help_col_no = UpperBound(is_help_win)
For li_i = 1 To ii_help_col_no
//	idwo_help_col[li_i].Color = il_help_col_color
	idwo_help_col[li_i].Pointer = is_help_cur
Next

SetRowFocusIndicator(Hand!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_trouble_mst_v20
integer y = 1652
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_trouble_mst_v20
integer y = 1652
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_trouble_mst_v20
integer y = 1652
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_trouble_mst_v20
integer x = 919
integer y = 1652
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_trouble_mst_v20
end type

