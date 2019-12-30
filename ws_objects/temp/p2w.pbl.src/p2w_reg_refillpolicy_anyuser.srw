$PBExportHeader$p2w_reg_refillpolicy_anyuser.srw
$PBExportComments$[ceusee] 판매금액 Rate 등록
forward
global type p2w_reg_refillpolicy_anyuser from w_a_reg_m_m
end type
type p_all from u_p_all within p2w_reg_refillpolicy_anyuser
end type
end forward

global type p2w_reg_refillpolicy_anyuser from w_a_reg_m_m
event ue_all ( )
p_all p_all
end type
global p2w_reg_refillpolicy_anyuser p2w_reg_refillpolicy_anyuser

type variables
String is_partner		//partner code
String  is_mode
end variables

event ue_all();//모든 고객을 할때. 첫번째 Row에 "All" 
Long ll_row
ll_row=dw_detail.GetRow()

dw_detail.object.priceplan[ll_row] = "ALL"
//is_mode = 'all'
Return
end event

on p2w_reg_refillpolicy_anyuser.create
int iCurrent
call super::create
this.p_all=create p_all
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_all
end on

on p2w_reg_refillpolicy_anyuser.destroy
call super::destroy
destroy(this.p_all)
end on

event ue_ok();call super::ue_ok;String ls_where, ls_partner, ls_priceplan, ls_union
Long ll_row

ls_partner = Trim(dw_cond.object.partner[1])
//ls_priceplan = Trim(dw_cond.object.priceplan[1])
If IsNull(ls_partner) Then ls_partner = ""
//If IsNull(ls_priceplan) Then ls_priceplan = ""

If ls_partner <> "" Then
	If ls_partner <> "ALL" Then
		dw_master.DataObject =  "p2dw_inq_reg_refillpolicy_2"
		dw_master.SetTransObject(SQLCA)
		dw_master.is_where = ls_where			
		If ls_where <> "" Then ls_where += " And "
		ls_where += "partner = '" + ls_partner + "' "
	ElseIf ls_partner = "ALL" Then
		dw_master.DataObject =  "p2dw_inq_reg_refillpolicy_all"
		dw_master.SetTransObject(SQLCA)
	End If
End If


dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "Partner Master")
	This.Trigger Event ue_reset()		//찾기가 없으면 resert
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;////Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("priceplan")

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]

//Price Plan Code Setting
dw_detail.object.partner[al_insert_row] = is_partner
dw_detail.object.fromdt[al_insert_row]    = Date(fdt_get_dbserver_now())


is_mode = "insert"

//dw_detail.object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())
Return 0 


end event

event type integer ue_extra_save();Long ll_row, i
String ls_sort, ls_partner, ls_priceplan, ls_fromdt
String ls_partner_old, ls_priceplan_old, ls_fromdt_old
Dec{2}  lc_from_amt, lc_to_amt, lc_from_amt_old, lc_to_amt_old


ll_row = dw_detail.RowCount()
//정리하기 위해서 Sort
dw_detail.SetRedraw(False)
ls_sort = "partner, priceplan, Stirng(fromdt, 'yyyymmdd'), fromamt"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
ls_partner_old = ""
ls_priceplan_old = ""
ls_fromdt_old = ""
	


For i = 1 To ll_row
	ls_partner = Trim(dw_detail.object.partner[i])
	ls_priceplan = Trim(dw_detail.object.priceplan[i])
	ls_fromdt = String(dw_detail.object.fromdt[i], 'yyyymmdd')
	lc_from_amt = dw_detail.object.fromamt[i]
	lc_to_amt = dw_detail.object.toamt[i]
	If IsNull(lc_to_amt)  Then lc_to_amt = 999999999
	If IsNull(ls_partner) Then ls_partner = ""
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	If IsNull(ls_fromdt) Then ls_fromdt = ""
	
	If ls_partner = "" Then
		f_msg_usr_err(200, Title, "대리점")
		dw_detail.SetColumn("partner")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		Return -2
	End If
   
	If ls_priceplan = "" Then
		f_msg_usr_err(200, Title, "가격정책")
		dw_detail.SetColumn("priceplan")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		Return -2
	End If
	
	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "적용시작일")
		dw_detail.SetColumn("fromdt")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		Return -2
	End If
	
//   	 ohj 2005.1.21 추가  0 도 입력가능하게
//	If lc_from_amt = 0 Or IsNull(lc_from_amt) Then
	If lc_from_amt < 0 Or IsNull(lc_from_amt) Then
		f_msg_usr_err(200, Title, "기준금액 From(>=)")
		dw_detail.SetColumn("fromamt")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		Return -2
	
   ElseIf lc_from_amt >= lc_to_amt Then
		If lc_from_amt <> 0 Then		
			f_msg_usr_err(201, Title, "기준금액 From < 기준금액 To")
			dw_detail.SetColumn("toamt")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			Return -2
		End If
	End If
	
	
	
	//날짜가 같으면 금액 범위 비교
	If ls_partner = ls_partner_old and ls_priceplan = ls_priceplan_old and ls_fromdt = ls_fromdt_old Then
		If lc_from_amt >= lc_from_amt_old and lc_from_amt < lc_to_amt_old  Then
			f_msg_usr_err(9000, title,"기준금액을 이미 등록하셨습니다.")
			dw_detail.SetColumn("fromamt")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			Return -2
		
   	End If
	End If
	
 lc_from_amt_old = lc_from_amt
 lc_to_amt_old = lc_to_amt
 ls_partner_old = ls_partner 
 ls_priceplan_old = ls_priceplan  
 ls_fromdt_old = ls_fromdt
Next

dw_detail.SetRedraw(True)
Return 0 
end event

event type integer ue_save();call super::ue_save;
is_mode = "init"

Return 0
end event

event type integer ue_delete();call super::ue_delete;
is_mode = "delete"

Return 0
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If


p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_all.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

dw_master.DataObject =  "p2dw_inq_reg_refillpolicy"
dw_master.SetTransObject(SQLCA)

//ii_error_chk = 0
Return 0

is_mode = "init"

Return 0
end event

event type integer ue_insert();////////////////////////////////////////////////////////////
//
// 수정내용 : master에 data 없으면 insert 못함
//
// 수 정 자 : 권 정 민
//
// 수 정 일 : 2004.08.30
//
////////////////////////////////////////////////////////////

Constant Int LI_ERROR = -1
Long ll_row,	ll_cnt

dw_master.AcceptText()

ll_cnt = dw_master.RowCount()

IF ll_cnt < 1 THEN
	f_msg_usr_err(9000, Title, "입력이 불가능합니다.")
	RETURN -1
END IF

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if

Return 0
//ii_error_chk = 0
end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
CALL w_a_m_master::resize

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_all.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_all.Y	= newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

type dw_cond from w_a_reg_m_m`dw_cond within p2w_reg_refillpolicy_anyuser
integer x = 37
integer y = 44
integer width = 1353
integer height = 164
string dataobject = "p2dw_cnd_refillpolicy_anyuser"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within p2w_reg_refillpolicy_anyuser
integer x = 1541
integer y = 40
end type

type p_close from w_a_reg_m_m`p_close within p2w_reg_refillpolicy_anyuser
integer x = 1847
integer y = 40
end type

type gb_cond from w_a_reg_m_m`gb_cond within p2w_reg_refillpolicy_anyuser
integer x = 23
integer y = 4
integer width = 1394
integer height = 208
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within p2w_reg_refillpolicy_anyuser
integer x = 23
integer y = 256
integer height = 448
integer taborder = 30
string dataobject = "p2dw_inq_reg_refillpolicy"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.partner_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within p2w_reg_refillpolicy_anyuser
integer x = 23
integer y = 740
integer height = 888
integer taborder = 40
string dataobject = "p2dw_reg_refillpolicy_anyuser"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_svccod, ls_filter, ls_method
String ls_type
Long ll_row, i
Integer li_cnt
DataWindowChild ldc

is_partner = Trim(dw_master.object.partner[al_select_row])
If IsNull(is_partner) Then is_partner = ""

ls_where = ""

If is_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner = '" + is_partner + "' "
End If


//dw_detail 조회
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
dw_detail.SetRedraw(False)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If


dw_detail.SetRedraw(True)
p_all.TriggerEvent("ue_enable")
Return 0
/////////////////////////////////////////////
//If rowcount = 0 Then
//	p_delete.TriggerEvent("ue_enable")
//	p_insert.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	dw_cond.Enabled = False
//End If
end event

event dw_detail::itemchanged;call super::itemchanged;////과금 방식이 바뀜에 따라
//Long ll_null
//String ls_fromdt
//
//SetNull(ll_null)
//If dwo.name = "todt" Then
//	//적용종료일 체크
////	ls_fromdt	= Trim(String(dw_detail.Object.fromdt[row],'yyyymmdd'))
////		
////	If data <> "" Then
////		If ls_fromdt > data Then
////			f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
////			dw_detail.setColumn("todt")
////			dw_detail.setRow(row)
////			dw_detail.scrollToRow(row)
////			dw_detail.setFocus()
////			Return -1
////		End If
////	End If
//	
//ElseIf dwo.name = "method" Then
//	//월정액
//	If data = is_Month  Then 
//		This.Object.tmp[row] = "M"
//		
//		This.Object.basicrange[row] = ll_null
//		This.Object.unit[row]       = ll_null
//		This.Object.basicamt[row]   = ll_null
//		This.Object.addunit[row]    = 0
//		This.Object.unitcharge[row] = 0
//		This.Object.suspamt[row]    = 0
//	End If
//	
//	//시간단위
//	If data = is_Time Then
//		This.Object.tmp[row] = "T"
//		
//		This.Object.basicrange[row] = 0
//		This.Object.unit[row]       = 0
//		This.Object.basicamt[row]   = 0
//		This.Object.addunit[row]    = 0
//		This.Object.unitcharge[row] = 0
//		This.Object.suspamt[row]    = 0
//	End If
//	
//	//건단위
//	If data = is_Hit Then 
//		This.Object.tmp[row] = "C"
//		
//		This.Object.basicrange[row] = 0
//		This.Object.unit[row]       = 0
//		This.Object.basicamt[row]   = 0
//		This.Object.addunit[row]    = 0
//		This.Object.unitcharge[row] = 0
//		This.Object.suspamt[row]    = 0
//	End If
//		
//	//Packet단위
//	If data = is_Packet Then
//		This.Object.tmp[row] = "P"
//		
//		This.Object.basicrange[row] = 0
//		This.Object.unit[row]       = 0
//		This.Object.basicamt[row]   = 0
//		This.Object.addunit[row]    = 0
//		This.Object.unitcharge[row] = 0
//		This.Object.suspamt[row]    = 0
//	End If
//	
//	//금액한도월정액
//	If data = is_DC Then
//		This.Object.tmp[row] = "D"
//		
//		This.Object.basicrange[row] = 0
//		This.Object.unit[row]       = 0
//		This.Object.basicamt[row]   = 0
//		This.Object.addunit[row]    = ll_null
//		This.Object.unitcharge[row] = ll_null
//		This.Object.suspamt[row]    = 0
//	End If
//	
//	//시간한도월정액
//	If data = is_Sec Then
//		This.Object.tmp[row] = "S"
//		
//		This.Object.basicrange[row] = 0
//		This.Object.unit[row]       = 0
//		This.Object.basicamt[row]   = 0
//		This.Object.addunit[row]    = ll_null
//		This.Object.unitcharge[row] = ll_null
//		This.Object.suspamt[row]    = 0
//	End If
//	
//	//판매
//	If data = is_EA Then
//		This.Object.tmp[row] = "E"
//		
//		This.Object.basicrange[row] = ll_null
//		This.Object.unit[row]       = ll_null
//		This.Object.basicamt[row]   = ll_null
//		This.Object.addunit[row]    = 0
//		This.Object.unitcharge[row] = 0
//		This.Object.suspamt[row]    = ll_null
//	End If
// End If
end event

type p_insert from w_a_reg_m_m`p_insert within p2w_reg_refillpolicy_anyuser
end type

type p_delete from w_a_reg_m_m`p_delete within p2w_reg_refillpolicy_anyuser
integer y = 1656
end type

type p_save from w_a_reg_m_m`p_save within p2w_reg_refillpolicy_anyuser
integer x = 617
integer y = 1656
end type

type p_reset from w_a_reg_m_m`p_reset within p2w_reg_refillpolicy_anyuser
integer x = 1353
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within p2w_reg_refillpolicy_anyuser
integer y = 708
end type

type p_all from u_p_all within p2w_reg_refillpolicy_anyuser
integer x = 910
integer y = 1656
boolean bringtotop = true
boolean enabled = false
end type

