$PBExportHeader$b1w_reg_validkey_move.srw
$PBExportComments$[ohj] 대리점 인증key 이동처리
forward
global type b1w_reg_validkey_move from w_a_reg_m_m
end type
type p_new from u_p_new within b1w_reg_validkey_move
end type
end forward

global type b1w_reg_validkey_move from w_a_reg_m_m
integer width = 3360
event ue_new ( )
event type integer ue_save_sql ( )
p_new p_new
end type
global b1w_reg_validkey_move b1w_reg_validkey_move

type variables
String is_priceplan		//Price Plan Code
String is_status, is_prefixno, is_fr_partner, is_validkey_type
String is_levelcod
Long   il_reqqty, il_requestno, il_cnt = 0

DataWindowChild idc_itemcod
end variables

forward prototypes
public function integer wf_dropdownlist (readonly datawindow adw_obj, long al_row, string as_col)
end prototypes

event type integer ue_save_sql();Long    ll_row, ll_count, ll_seq, ll_stock_qty
String  ls_return_type, ls_partner_prefix
String  ls_tmp, ls_ref_desc, ls_result[], ls_partner
Integer li_return, li_ret, li_rc

String  ls_to_partner, ls_priceplan, ls_remark
Long    ll_reqqty_cu = 0, ll_su, ll_moveqty, ll_moveqty_cu = 0

ls_to_partner = dw_detail.Object.to_partner[1]
ll_moveqty    = dw_detail.Object.moveqty[1]
ls_remark     = dw_detail.Object.remark[1]

ll_stock_qty     = dw_master.Object.stock_qty[dw_master.getrow()]
is_fr_partner    = dw_master.Object.partner[dw_master.getrow()]
is_priceplan     = dw_master.object.priceplan[dw_master.getrow()]
is_validkey_type = dw_master.object.validkey_type[dw_master.getrow()]

If IsNull(ls_to_partner) Then ls_to_partner = ""
If IsNull(ls_remark)     Then ls_remark     = ""

If ls_to_partner = "" Then
	dw_detail.SetColumn('to_partner')
	Return -2
End If

If ll_moveqty = 0 Then
	f_msg_info(3020, Title, "이동할 인증Key 수량을 입력하세요.")
	dw_detail.SetColumn('moveqty')
	Return -2
End If

// 재고수량이 이동수량 보다 작으면 error
If ll_stock_qty < ll_moveqty Then
	If f_msg_ques_yesno2(9000, Title, "이동 가능 수량은 [ " +  string(il_cnt) + " ]입니다. 요청하신 수량만큼 이동할 수 없습니다. ~r~n " + &
	                                  " 이동 가능 수량만큼 이동하시겠습니까?", 1)    = 2 Then
												 
//	If f_msg_ques_yesno2(9000, Title, "Available transfer is [ " +  string(il_cnt) + " ]. Your request is unable to provide. ~r~n " + &
//	                                  " Do you want to transfer available quantity? ", 1)    = 2 Then
		Return -2
	Else
		//이동가능 수량으로...
		ll_moveqty_cu = ll_stock_qty
	End If
End If

If ll_moveqty_cu <> 0 Then //이동 가능수량
	ll_su = ll_moveqty_cu
	
Else //이동 요청수량만큼 할당
	ll_su = ll_moveqty
	
End If

//SEQ 인증KEY 할당 LOG
Select seq_validkey_moveno.nextval 
  into :ll_seq 
  from dual;
  
//***** 처리부분 *****
b1u_dbmgr11 iu_db

iu_db = Create b1u_dbmgr11

iu_db.is_title = Title
iu_db.is_data[1] = is_fr_partner
iu_db.is_data[2] = ls_to_partner
iu_db.is_data[3] = is_validkey_type
iu_db.is_data[4] = is_priceplan	 
iu_db.is_data[5] = ls_remark	
iu_db.is_data[6] = is_status				//인증key 이동상태 '22'
iu_db.is_data[7] = gs_user_id
iu_db.is_data[8] = gs_pgm_id[gi_open_win_no]

iu_db.il_data[1] = ll_moveqty	     		//이동요청수량
iu_db.il_data[2] = ll_su					//이동가능수량
iu_db.il_data[3] = ll_seq					//인증key 할당log

iu_db.uf_prc_db_03()
li_rc	= iu_db.ii_rc

If li_rc < 0 Then
//	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
	Destroy b1u_dbmgr11
	Return -1
End If

//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

Destroy b1u_dbmgr11

Return 0
end event

public function integer wf_dropdownlist (readonly datawindow adw_obj, long al_row, string as_col);String ls_SiteCode, ls_Doc_D1, ls_sql

dataWindowChild	dwc_child

adw_obj.GetChild (as_col, dwc_child)
dwc_child.SetTransObject (SQLCA)

adw_obj.Accepttext()

Choose Case lower (as_col)
	Case "to_partner"  			
			ls_sql  = "		SELECT PARTNER                    	          " &
					  + "      	  , PARTNERNM							          " &
					  + "  	  FROM PARTNERMST							          " &
					  + "     WHERE PARTNER_TYPE = '0'                     " &
					  + "       AND LEVELCOD    >= '" + is_levelcod   +  "'" &
					  + "       AND PARTNER     <> '" + is_fr_partner +  "'" &				  
					  
					  
		 If is_prefixno <> '000' Then
			
			ls_sql += "       AND PREFIXNO LIKE  '" + is_prefixno + "%'  "
		 End If
				 
			ls_sql += "  ORDER BY PARTNER ASC					 	          " &
				     + "         , PARTNERNM                              " 
					  
	Case "req_partner"  			
			ls_sql  = "		SELECT PARTNER                    	          " &
					  + "      	  , PARTNERNM							          " &
					  + "  	  FROM PARTNERMST							          " &
					  + "     WHERE PARTNER_TYPE = '0'                     " &
					  + "       AND LEVELCOD    >= '" + is_levelcod   +  "'" &
					  
		 If is_prefixno <> '000' Then
			
			ls_sql += "       AND PREFIXNO LIKE  '" + is_prefixno + "%'  "
		 End If
				 
			ls_sql += "  ORDER BY PARTNER ASC					 	          " &
				     + "         , PARTNERNM                              " 
	Case Else
	
		dwc_child.Retrieve ()

End Choose

If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)

dwc_child.Retrieve ()
//adw_obj.uf_MatchDDDW (as_col)

Return 0
end function

on b1w_reg_validkey_move.create
int iCurrent
call super::create
this.p_new=create p_new
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
end on

on b1w_reg_validkey_move.destroy
call super::destroy
destroy(this.p_new)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1W_reg_validkey_move
	Desc.	: 	대리점 인증key 이동할당처리
	Ver.	:	1.0
	Date	: 	2005.02.16
	Programer : ohj
--------------------------------------------------------------------------*/
String ls_temp, ls_ref_desc, ls_result[]

// 로그인한 대상의 대리점prefix와 levelcod 구하기
SELECT PREFIXNO
     , LEVELCOD
  INTO :is_prefixno
     , :is_levelcod
  FROM PARTNERMST
 WHERE PARTNER = :gs_user_group    ;

//상태코드 가져오기--인증KEY 이동 '22'
ls_temp = fs_get_control("B1","P400", ls_ref_desc)

If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

is_status = ls_result[6]

p_new.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")

dw_cond.SetFocus()
dw_cond.SetColumn("req_partner")
end event

event ue_ok();call super::ue_ok;String ls_reqdt_from, ls_reqdt_to, ls_reqstat, ls_req_partner, ls_where, ls_validkey_type
Long   ll_row, li_i

ls_validkey_type = dw_cond.object.validkey_type[1]
ls_req_partner   = dw_cond.object.req_partner[1]

If IsNull(ls_validkey_type) Then ls_validkey_type = ""
If IsNull(ls_req_partner)   Then ls_req_partner   = ""

If ls_validkey_type = "" Then
	f_msg_info(200, Title, "인증Key Type")
	dw_cond.SetFocus()
	dw_cond.SetColumn("validkey_type")
   Return 
End If

ls_where = ""

//인증key type
If ls_where <> "" Then ls_where += " And "
ls_where += " B.VALIDKEY_TYPE = '" + ls_validkey_type + "' "

If ls_where <> "" Then ls_where += " And "
ls_where += " A.LEVELCOD >= '" + is_levelcod + "' "	

If is_prefixno <> '000' Then
	
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.PREFIXNO LIKE '" + is_prefixno + "%'"
End If

//partner
If ls_req_partner <> '' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.PARTNER = '" + ls_req_partner + "'"
End If

dw_detail.ReSet()

dw_master.SetRedraw(False)

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

dw_master.SetRedraw(True)

If ll_row = 0 Then 
	
	f_msg_info(1000, Title, "")
	
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_enable")

	Return
ElseIf ll_row < 0 Then
	
	f_msg_usr_err(2100, Title, "Retrieve()")
	
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_enable")
	
   Return
Else

	//p_save.TriggerEvent("ue_disable")
	
	dw_cond.Enabled = False
	p_reset.TriggerEvent("ue_enable")
End If

dw_master.SetFocus()
dw_master.SelectRow(0, False)
dw_master.ScrollToRow(1)
dw_master.SelectRow(1, True)
end event

event resize;//2000-06-28 by kem
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)


If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_new.Y	   = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_new.Y	   = newheight - iu_cust_w_resize.ii_button_space_1
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

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_return

//ii_error_chk = -1
If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

li_return = This.Trigger Event ue_save_sql()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()

	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = This.Title
	
		iu_cust_db_app.uf_prc_db()
		
		If iu_cust_db_app.ii_rc = -1 Then
			dw_master.SetFocus()
			Return LI_ERROR
		End If
		
		f_msg_info(3010,This.Title,"Save")
		Return LI_ERROR
		
	Case Is >= 0
	
		//COMMIT와 동일한 기능
		iu_cust_db_app.is_caller = "COMMIT"
		iu_cust_db_app.is_title = This.Title
	
		iu_cust_db_app.uf_prc_db()
	
		If iu_cust_db_app.ii_rc = -1 Then
			dw_master.SetFocus()
			Return LI_ERROR
		End If
		
		 This.Trigger Event ue_ok()
		 		 
		 f_msg_info(3000,This.Title,"Save")
		 
End Choose	
	//ii_error_chk = 0
	//p_new.TriggerEvent("ue_enable")
	
Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_validkey_move
integer x = 41
integer y = 88
integer width = 2473
integer height = 116
string dataobject = "b1dw_cnd_validkey_move"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//고객 help popup
//idwo_help_col[1] = Object.partcod
//is_help_win[1] = "b1w_hlp_customerm"
//is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//String ls_parttype
//
//This.AcceptText()
//
//ls_parttype = Trim(This.Object.parttype[1])
//
//If IsNull(ls_parttype) Or ls_parttype = "" Then
//	f_msg_info(200, Title, "Group")
//	This.SetFocus()
//	This.SetColumn("parttype")
//	Return
//End If
//
//If ls_parttype = "C" Then
//	Choose Case dwo.Name
//		Case "partcod"
//			If iu_cust_help.ib_data[1] Then
//				This.Object.partcod1[row] = iu_cust_help.is_data[1]
//				This.Object.partcod[row] = iu_cust_help.is_data[2]
//			End If
//	End Choose
//	
//ElseIf ls_parttype = "S" Then
//	Choose Case dwo.Name
//		Case "partcod"
//			If iu_cust_help.ib_data[1] Then
//				This.Object.partcod1[row] = iu_cust_help.is_data[1]
//				This.Object.partcod[row] = iu_cust_help.is_data[2]
//			End If 
//
//	End Choose
//	
//ElseIf ls_parttype = "P" Then
//	Choose Case dwo.Name
//		Case "partcod"
//			If iu_cust_help.ib_data[1] Then
//				This.Object.partcod1[row] = iu_cust_help.is_data[1]
//				This.Object.partcod[row] = iu_cust_help.is_data[1]
//			End If
//
//	End Choose
//	
//End If
end event

event dw_cond::clicked;call super::clicked;wf_dropdownlist(This, This.getrow(), This.GetColumnName())
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_validkey_move
integer x = 2679
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_validkey_move
integer x = 2985
integer y = 52
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_validkey_move
integer x = 23
integer y = 8
integer width = 2565
integer height = 220
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_validkey_move
event dropdownlist pbm_dwndropdown
integer x = 23
integer y = 260
integer width = 3269
integer height = 808
string dataobject = "b1dw_cnd_reg_validkey_move"
end type

event dw_master::dropdownlist;//wf_dropdownlist(this, getrow(), this.GetColumnName())
end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.partner_t
uf_init( ldwo_sort, "A", RGB(0,0,128) )
end event

event dw_master::rowfocuschanged;call super::rowfocuschanged;String ls_ref_desc, ls_temp
String ls_result[]
Long   ll_stock_qty

If currentrow <= 0 Then
	Return
Else
	
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
	
	dw_detail.SetReDraw(False)
	
//	dw_detail.Reset()
	dw_detail.SetItem(1, 'fr_partner', '')
	dw_detail.SetItem(1, 'to_partner', '')
	dw_detail.SetItem(1, 'remark'    , '')	
	dw_detail.SetItem(1, 'moveqty'   , 0 )
	
	ll_stock_qty     = dw_master.object.stock_qty[currentrow]
	is_fr_partner    = dw_master.object.partner[currentrow]
	
	//재고수량이 0 이상일 때만 save가능
	If ll_stock_qty > 0 Then
		p_save.TriggerEvent("ue_enable")
	Else
		p_save.TriggerEvent("ue_disable")
		dw_cond.Enabled = False
	End If
	
	If dw_detail.Rowcount() < 1 Then
		dw_detail.InsertRow(0)
	End If
	
	dw_detail.SetItem(1, 'fr_partner', is_fr_partner)
	dw_detail.SetItem(1, 'moveqty'   , ll_stock_qty )

	dw_detail.SetReDraw(True)
	
	dw_detail.SetFocus()
	dw_detail.SetColumn("to_partner")
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
	
End If
end event

event dw_master::retrieveend;
If rowcount >= 0 Then
	p_ok.TriggerEvent("ue_disable")
End If
end event

event dw_master::clicked;call super::clicked;String ls_fr_partner, ls_temp, ls_ref_desc, ls_result[]
Long   ll_stock_qty
return
If row >= 1 Then 
	dw_detail.Reset()
	
	ll_stock_qty  = dw_master.object.stock_qty[row]
	ls_fr_partner = dw_master.object.partner[row]
	
	//재고수량이 0 이상일 때만 save가능
	If ll_stock_qty > 0 Then
		p_save.TriggerEvent("ue_enable")
	Else
		p_save.TriggerEvent("ue_disable")
		dw_cond.Enabled = False
	End If
	
	dw_detail.InsertRow(0)
	dw_detail.SetItem(1, 'fr_partner', ls_fr_partner)
	dw_detail.SetItem(1, 'moveqty'   , ll_stock_qty )

	dw_detail.SetFocus()
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
End If
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_validkey_move
event dropdownlist pbm_dwndropdown
integer x = 23
integer y = 1116
integer width = 3269
integer height = 500
string dataobject = "b1dw_reg_validkey_move"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_detail::dropdownlist;//wf_dropdownlist(This, This.getrow(), This.GetColumnName())
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::clicked;call super::clicked;wf_dropdownlist(This, This.getrow(), This.GetColumnName())
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_validkey_move
boolean visible = false
integer x = 1938
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_validkey_move
boolean visible = false
integer x = 2286
integer y = 1652
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_validkey_move
integer x = 55
integer y = 1656
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_validkey_move
integer x = 544
integer y = 1656
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_validkey_move
integer y = 1072
integer height = 36
end type

type p_new from u_p_new within b1w_reg_validkey_move
boolean visible = false
integer x = 910
integer y = 1660
integer width = 283
integer height = 96
boolean bringtotop = true
boolean originalsize = false
end type

