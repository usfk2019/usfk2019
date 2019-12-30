$PBExportHeader$w_inq_scan_change_order.srw
$PBExportComments$문서마스터 조회 및 ORDER변경 및 취소요청
forward
global type w_inq_scan_change_order from w_a_reg_m_m
end type
type p_new from u_p_new within w_inq_scan_change_order
end type
type cb_cancel from commandbutton within w_inq_scan_change_order
end type
type cb_1 from commandbutton within w_inq_scan_change_order
end type
end forward

global type w_inq_scan_change_order from w_a_reg_m_m
integer width = 4256
integer height = 2588
event ue_new ( )
p_new p_new
cb_cancel cb_cancel
cb_1 cb_1
end type
global w_inq_scan_change_order w_inq_scan_change_order

type variables
String is_cus_status, is_priceplan		//Price Plan Code
String is_operator, is_operatornm
DataWindowChild idc_itemcod
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wfi_get_customerid (string as_customerid);String ls_customerid, ls_customernm

ls_customerid = as_customerid

If IsNull(ls_customerid) Then ls_customerid = " "

Select Customernm
  Into :ls_customernm
  From Customerm
 Where customerid = :ls_customerid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Customer ID(wfi_get_customerid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "고객번호가 없습니다.")
	dw_cond.object.customernm[1] =''
	dw_cond.object.customerid[1] =''
	Return -1
End If

dw_cond.object.customernm[1] = ls_customernm

Return 0

end function

on w_inq_scan_change_order.create
int iCurrent
call super::create
this.p_new=create p_new
this.cb_cancel=create cb_cancel
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
this.Control[iCurrent+2]=this.cb_cancel
this.Control[iCurrent+3]=this.cb_1
end on

on w_inq_scan_change_order.destroy
call super::destroy
destroy(this.p_new)
destroy(this.cb_cancel)
destroy(this.cb_1)
end on

event ue_ok;call super::ue_ok;string ls_partner, ls_status, ls_customerid, ls_complete_yn, ls_delete_flag
string ls_order_type, ls_user_id, ls_fdate, ls_tdate, ls_afdate, ls_atdate, ls_operator
date   ld_fdate, ld_tdate, ld_afdate, ld_atdate
double ld_u_reqno, ld_docno, ld_orderno
long   ll_row

dw_cond.accepttext()

ls_partner     = dw_cond.object.partner[1]
ls_status      = dw_cond.object.status[1]
ls_customerid  = dw_cond.object.customerid[1]
ls_complete_yn = dw_cond.object.complete_yn[1]
ls_delete_flag = dw_cond.object.delete_flag[1]
ld_fdate       = dw_cond.object.fdate[1]
ld_tdate       = dw_cond.object.tdate[1]
ld_afdate      = dw_cond.object.afdate[1]
ld_atdate      = dw_cond.object.atdate[1]
ls_user_id     = dw_cond.object.user_id[1]
ld_u_reqno     = dw_cond.object.u_reqno[1]
ld_docno       = dw_cond.object.docno[1]
ld_orderno     = dw_cond.object.orderno[1]
ls_order_type  = dw_cond.object.order_type[1]
ls_operator    = dw_cond.object.operator[1]

SELECT  TO_CHAR(:ld_fdate, 'YYYYMMDD'), TO_CHAR(:ld_tdate, 'YYYYMMDD'), &
        TO_CHAR(:ld_afdate, 'YYYYMMDD'), TO_CHAR(:ld_atdate, 'YYYYMMDD')
INTO    :ls_fdate, :ls_tdate, :ls_afdate, :ls_atdate
FROM    DUAL;

ll_row = dw_master.retrieve(ld_u_reqno, ld_docno, ls_customerid, ls_fdate, ls_tdate, &
                            ls_partner, ls_order_type, ld_orderno, ls_user_id, ls_status, &
									 ls_complete_yn, ls_delete_flag, ls_afdate, ls_atdate, ls_operator)

dw_master.SelectRow( 1, True )


if ll_row = 0 then
	dw_cond.enabled = true
	p_ok.TriggerEvent("ue_enable")
end if
end event

event ue_extra_insert;//long ll_row
//
////Insert 시 해당 row 첫번째 컬럼에 포커스
//dw_detail.SetRow(al_insert_row)
//dw_detail.ScrollToRow(al_insert_row)
//dw_detail.SetColumn("sale_modelcd")
//
//ll_row = dw_master.getrow()
//dw_detail.object.sale_modelcd[al_insert_row] = dw_master.object.code[ll_row]
//
//
////Log
//dw_detail.object.crt_user[al_insert_row] = gs_user_id
//dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
//
//
Return 0 
//
//
end event

event ue_extra_save;////Save Check
////Save
//Long ll_row, ll_rows, ll_findrow
//long ll_i, ll_zoncodcnt, i
//String ls_target_code
//Long   ll_rows1, ll_rows2
//
//ll_rows = dw_detail.RowCount()
//
//For ll_row = 1 To ll_rows
//	//ls_target_code = Trim(dw_detail.Object.target_code[ll_row])
//
////	If IsNull(ls_target_code) Then ls_target_code = ""
//	
//    //필수 항목 check 
////	If ls_target_code = "" Then
////		f_msg_usr_err(200, Title, "target code")
////		dw_detail.SetColumn("target_code")
////		dw_detail.SetRow(ll_row)
////		dw_detail.ScrollToRow(ll_row)
////		dw_detail.SetRedraw(True)
////		Return -2
////		
////	End If
//	
//
//Next
//
//
//For ll_rows1 = 1 To dw_detail.RowCount()
//
//	//Update Log
//	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
//		dw_detail.object.updt_user[ll_rows1] = gs_user_id
//		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
//	End If
//	
//Next
//
Return 0
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

event ue_reset;call super::ue_reset;dw_cond.trigger event ue_init()

dw_master.reset()
dw_detail.reset()
return 0
end event

event ue_save;int    li_rtn, li_rowno
string ls_custmerid, ls_doc_type
long   ll_u_reqno

dw_master.accepttext()
li_rowno = dw_master.getrow()

ll_u_reqno   = dw_master.object.u_reqno[li_rowno]
ls_doc_type  = dw_master.object.doc_type[li_rowno]
ls_custmerid = dw_master.object.customerid[li_rowno]

iu_cust_msg = Create u_cust_a_msg	
	
iu_cust_msg.is_pgm_name = "문서마스터 조회 및 ORDER변경 및 취소요청 등록"
iu_cust_msg.is_grp_name = "ORDER REG"
iu_cust_msg.is_data[1]  = string(ll_u_reqno)
iu_cust_msg.is_data[2]  = ls_doc_type
iu_cust_msg.is_data[3]  = ls_custmerid
	 
OpenWithParm(w_pop_scan_change_order_reg, iu_cust_msg)

Destroy iu_cust_msg	

trigger event ue_ok()

dw_master.setrow(li_rowno)
dw_master.scrollToRow(li_rowno)
dw_master.setFocus()

Return 0


end event

event open;call super::open;//dw_cond.trigger event ue_init()

end event

event ue_delete;int    li_rtn, li_rowno
string ls_custmerid, ls_doc_type
long   ll_u_reqno

dw_master.accepttext()
li_rowno = dw_master.getrow()

ll_u_reqno   = dw_master.object.u_reqno[li_rowno]
ls_doc_type  = dw_master.object.doc_type[li_rowno]
ls_custmerid = dw_master.object.customerid[li_rowno]

iu_cust_msg = Create u_cust_a_msg	
	
iu_cust_msg.is_pgm_name = "문서마스터 조회 및 ORDER변경 및 취소요청 삭제"
iu_cust_msg.is_grp_name = "ORDER DEL"
iu_cust_msg.is_data[1]  = string(ll_u_reqno)
	 
OpenWithParm(w_pop_scan_change_order_del, iu_cust_msg)

Destroy iu_cust_msg	

trigger event ue_ok()


dw_master.setrow(li_rowno)
dw_master.scrollToRow(li_rowno)
dw_master.setFocus()

Return 0


end event

event ue_insert;trigger event ue_save()

return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within w_inq_scan_change_order
integer x = 41
integer y = 52
integer width = 3511
integer height = 428
string dataobject = "d_cnd_scan_change_order"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;string ls_partner
int    li_cnt
date   ld_sysdate, ld_fdate
DataWindowChild ldwc_col

//Help Window
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"

ld_sysdate = Date(fdt_get_dbserver_now())


SELECT  ADD_MONTHS(:ld_sysdate, -3)
INTO    :ld_fdate
FROM    DUAL;

this.Object.fdate[1] = ld_fdate
this.Object.tdate[1] = Date(fdt_get_dbserver_now())

this.Object.afdate[1] = ld_fdate //Date(fdt_get_dbserver_now())
this.Object.atdate[1] = Date(fdt_get_dbserver_now())

//신청SHOP 
SELECT  COUNT(*)
INTO    :li_cnt
FROM    PARTNERMST A,
        SYSUSR1T B
WHERE   A.PARTNER  = B.EMP_GROUP
AND     B.EMP_ID   = :gs_user_id; 

if li_cnt = 0 then
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
else	
	SELECT  NVL(PARTNER,'')
	INTO    :ls_partner
	FROM    PARTNERMST A,
			  SYSUSR1T B
	WHERE   A.PARTNER  = B.EMP_GROUP
	AND     B.EMP_ID   = :gs_user_id;
	
	dw_cond.object.partner.initial= ls_partner
end if

////신청Type ALL
dw_cond.getchild("req_code", ldwc_col)
f_dddw_list2(this, 'req_code', 'ZC100')
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "codenm", "ALL")
ldwc_col.setitem(1, "code", "%")

//업무상태 ALL
dw_cond.getchild("status", ldwc_col)
f_dddw_list2(this, 'status', 'ZC200')
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "codenm", "ALL")
ldwc_col.setitem(1, "code", "%")

//신청타입 ALL
dw_cond.getchild("order_type", ldwc_col)
f_dddw_list2(this, 'order_type', 'ZC100')
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "codenm", "ALL")
ldwc_col.setitem(1, "code", "%")

//서비스신청작성자
dw_cond.getchild("operator", ldwc_col)
ldwc_col.SetTransObject(SQLCA)
ldwc_col.retrieve()
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "empnm", "ALL")
ldwc_col.setitem(1, "emp_no", "%")



end event

event dw_cond::itemchanged;call super::itemchanged;String 	ls_operator, ls_empnm

Choose Case Dwo.Name
	Case "customerid" 
   	wfi_get_customerid(data)
	
End Choose


end event

event dw_cond::doubleclicked;call super::doubleclicked;
Long li_exist
String ls_filter

Choose Case dwo.Name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			Object.customerid[row] 	= iu_cust_help.is_data[1]
			object.customernm[row] 	= iu_cust_help.is_data[2]
			is_cus_status 				= dw_cond.iu_cust_help.is_data[3]
					
			IF wfi_get_customerid(iu_cust_help.is_data[1]) = -1 Then
				return -1
			End IF
		End If	
End Choose


end event

event dw_cond::itemerror;call super::itemerror;p_reset.TriggerEvent("ue_enable")
return 1
end event

type p_ok from w_a_reg_m_m`p_ok within w_inq_scan_change_order
integer x = 3621
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within w_inq_scan_change_order
integer x = 3927
integer y = 52
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_inq_scan_change_order
integer x = 23
integer width = 3566
integer height = 500
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within w_inq_scan_change_order
integer x = 23
integer y = 640
integer width = 4169
integer height = 1140
integer taborder = 30
string dataobject = "d_inq_scan_change_order"
boolean ib_sort_use = false
end type

event dw_master::rowfocuschanged;int    li_cnt
long   ll_ureqno
string ls_doc_no, ls_intfcid

If currentrow <= 0 Then
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
	dw_detail.Reset()
	
	ll_ureqno = this.object.u_reqno[currentrow]
	ls_intfcid = dw_master.object.intfcid[currentrow]
	ls_doc_no  = dw_master.object.docno[currentrow]
	
	p_reset.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	
	dw_detail.retrieve(ll_ureqno)
	
	
//    SELECT COUNT(*)
//    INTO   :li_cnt
//    FROM   CONTRACTMST
//    WHERE  CONTRACTSEQ IN (SELECT  B.REF_CONTRACTSEQ 
//                                  FROM ORDER_DOCGROUP A, SVCORDER B 
//                                  WHERE  A.ORDERNO = B.ORDERNO
//                                  AND   A.U_REQNO = :ll_ureqno)
//    AND    STATUS = '20';      
    
	if ls_intfcid = "REQUEST" AND isnull(ls_doc_no) then
		cb_cancel.enabled = true
	ELSE 
		cb_cancel.enabled = false
	end if
	
	if ls_intfcid = "REQUEST" and  isnull(ls_doc_no) = false   then
      cb_1.enabled = true
	else
		cb_1.enabled = false
   end if
	
End If

end event

event dw_master::retrieveend;

If rowcount >= 0 Then
	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail.SetFocus()

	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
	
End If
end event

event dw_master::ue_init;call super::ue_init;dw_cond.accepttext()

//업무상태
f_dddw_list2(This, 'proc_status', 'ZC200')

//서류타입
f_dddw_list2(This, 'doc_type', 'ZC400')

//응답코드
f_dddw_list2(This, 'response_code', 'ZC700')


end event

event dw_master::clicked;call super::clicked;If row = 0 Then Return 1

trigger event rowfocuschanged(row)
end event

type dw_detail from w_a_reg_m_m`dw_detail within w_inq_scan_change_order
integer x = 23
integer y = 1824
integer width = 4169
integer height = 492
integer taborder = 40
string dataobject = "d_reg_scan_change_order"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::ue_retrieve;////dw_master cleck시 Retrieve
//String ls_where, ls_salemodelcd, ls_filter, ls_svccod
//Long ll_row, i
//
//
//
//dw_master.AcceptText()
//
//If dw_master.RowCount() > 0 Then
//	ls_salemodelcd   = Trim(dw_master.object.code[al_select_row])
//
//	If IsNull(ls_salemodelcd) Then ls_salemodelcd = ""
//
//	ls_where = ""
//
//	If ls_salemodelcd <> "" Then
//		If ls_where <> "" Then ls_where += " And "
//		ls_where += " SALE_MODELCD = '" + ls_salemodelcd + "' "
//
//	End If
//	
//	//dw_detail 조회
//	dw_detail.is_where = ls_where
//	ll_row = dw_detail.Retrieve()
//	dw_detail.SetRedraw(False)
//	If ll_row < 0 Then
//		f_msg_usr_err(2100, Title, "Retrieve()")
//		Return -2
//	End If
//	
//	For i = 1 To dw_detail.RowCount()
//		dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
//	Next
//   
//	dw_detail.SetRedraw(true)
//
//End If
//
Return 0
//
end event

event dw_detail::retrieveend;//Long ll_row, i
//String ls_filter
//Dec lc_data
//
//If rowcount > 0 Then
//	p_ok.TriggerEvent("ue_disable")
//	
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	dw_cond.Enabled = False
//		
//ElseIf rowcount = 0 Then
//	p_delete.TriggerEvent("ue_enable")
//	p_insert.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	dw_cond.SetFocus()   		//데이터 없을경우 다시 조회 할 수있도록 
//   dw_cond.Enabled = False
//
//End If
//
//
end event

event dw_detail::clicked;//DataWindowChild 	ldc_priceplan
//Integer li_exist
//string ls_svccod, ls_filter
//
//
//if row <= 0 then return
//
////가격정책 DDDW
//ls_svccod = dw_cond.object.svccod[1]
//
//
//li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
//ls_filter = "svccod = '" + ls_svccod  + "' " 
////messagebox(ls_svccod, ls_filter)
//
//
//This.object.priceplan[1] = ""
//ldc_priceplan.SetTransObject(SQLCA)
//li_exist = ldc_priceplan.Retrieve()
//ldc_priceplan.SetFilter(ls_filter)			//Filter정함
//ldc_priceplan.Filter()
////가격정책 DDDW
//
//
end event

event dw_detail::itemchanged;call super::itemchanged;//DataWindowChild 	ldc_priceplan
//Integer li_exist
//string ls_svccod, ls_filter
//
//
//if row <= 0 then return
//
////가격정책 DDDW
//ls_svccod = dw_cond.object.svccod[1]
//
//
//li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
//ls_filter = "svccod = '" + ls_svccod  + "' " 
//
//ldc_priceplan.SetTransObject(SQLCA)
//li_exist = ldc_priceplan.Retrieve()
//ldc_priceplan.SetFilter(ls_filter)			//Filter정함
//ldc_priceplan.Filter()
////가격정책 DDDW
//
//
//
end event

event dw_detail::ue_init;call super::ue_init;dw_cond.accepttext()

//Order상태 (=신청type?)
f_dddw_list2(This, 'order_type', 'ZC100')

//계약상태
f_dddw_list2(This, 'status', 'B301')


end event

type p_insert from w_a_reg_m_m`p_insert within w_inq_scan_change_order
integer y = 2336
end type

type p_delete from w_a_reg_m_m`p_delete within w_inq_scan_change_order
integer y = 2336
end type

type p_save from w_a_reg_m_m`p_save within w_inq_scan_change_order
boolean visible = false
integer x = 1509
integer y = 2332
end type

type p_reset from w_a_reg_m_m`p_reset within w_inq_scan_change_order
integer x = 617
integer y = 2336
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within w_inq_scan_change_order
integer x = 23
integer y = 1784
integer height = 36
end type

type p_new from u_p_new within w_inq_scan_change_order
boolean visible = false
integer x = 1202
integer y = 2336
integer width = 283
integer height = 96
boolean bringtotop = true
boolean originalsize = false
end type

type cb_cancel from commandbutton within w_inq_scan_change_order
integer x = 23
integer y = 524
integer width = 599
integer height = 88
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "U_ORDER 취소요청"
end type

event clicked;int    li_rowno, li_rtn, li_cnt
long   ll_ureqno, ll_req_seq, ll_rowcnt, ll_doc_type_qty
string ls_msg, ls_doc_no, ls_intfcid, ls_customerid, ls_uuser, ls_uudt, ls_doc_type
double ld_req_seq
dw_master.accepttext()

ll_rowcnt = dw_master.rowcount()

if ll_rowcnt = 0 then
	return 1
end if

ls_msg = "선택된 U_Order신청번호건에 대하여 스캔 취소 요청을 진행하겠습니까?"

li_rtn  = MessageBox("스캔취소요청", ls_msg, Exclamation!, OKCancel!, 2)

if li_rtn = 1 then
	li_rowno        = dw_master.getrow()	
	ll_ureqno       = dw_master.object.u_reqno[li_rowno]
	ls_intfcid      = dw_master.object.intfcid[li_rowno]
	ls_doc_no       = dw_master.object.docno[li_rowno]
	ls_customerid   = dw_master.object.customerid[li_rowno]
	ls_uuser        = dw_master.object.u_order_user[li_rowno]
	ls_uudt         = dw_master.object.u_orderdt[li_rowno]
	ls_doc_type     = dw_master.object.doc_type[li_rowno]
	ll_doc_type_qty = dw_master.object.doc_type_qty[li_rowno]
	
	if (ls_intfcid <> "REQUEST" OR  isnull(ls_doc_no) = FALSE) then
		messagebox('확인', '선택된 U_Cube Order번호는  취소 할수 없습니다. 1')
		return -1
	end if

	SELECT COUNT(*)
	INTO   :li_cnt
	FROM   CONTRACTMST
	WHERE  CONTRACTSEQ IN (SELECT  B.REF_CONTRACTSEQ 
								  FROM ORDER_DOCGROUP A, SVCORDER B 
								  WHERE  A.ORDERNO = B.ORDERNO
								  AND   A.U_REQNO = :ll_ureqno)
	AND    STATUS = '20';      
	
   li_cnt = 0
	
	if li_cnt = 0 then
		
			UPDATE DOC_MST
			SET    INTFCID       ='CANCEL',
					 PROC_STATUS   = '1', 
					 RESPONSE_CODE = NULL,
					 UPDT_USER     = :gs_user_id,
					 UPDTDT        = SYSDATE
			WHERE  U_REQNO       = :ll_ureqno;
		
				
			If SQLCA.SQLCode <> 0 Then		
				MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText+' DOC_MST(U)')
				ROLLBACK;
				Return 1	
			End If 
			
			SELECT SEQ_INTF_REQ_SCAN.NEXTVAL INTO :ld_req_seq FROM DUAL;
			
			If SQLCA.SQLCODE <> 0 Then
				f_msg_sql_err(SQLCA.SQLERRTEXT, "Get Sequence SEQ_ORDERNO.")
				Rollback;
				Return -1
			End If
			
			INSERT INTO INTF_REQ_SCAN (
							SEQNO, U_REQNO, INTFCID, CUSTOMERID, G_ORDERDT, G_ORDER_USER,
							DOC_TYPE, DOC_TYPE_QTY,	STATUS, CRT_USER, CRTDT, PGM_ID) 
         VALUES      ( :ld_req_seq, :ll_ureqno, 'CANCEL', :ls_customerid, :ls_uudt,:ls_uuser,
							 :ls_doc_type, :ll_doc_type_qty, '1'         , :gs_user_id, SYSDATE, :gs_pgm_id[gi_open_win_no]);

		   If SQLCA.SQLCode <> 0 Then		
				MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText+' INTF_REQ_SCAN(I)')
				ROLLBACK;
				Return 1	
			End If 
			
			COMMIT;
			messagebox('확인', '스캔 취소 요청이 완료되었습니다.!')			
			trigger event ue_ok()
	else 
		if (ls_intfcid <> "REQUEST" OR  isnull(ls_doc_no)) then
			messagebox('확인', '선택된 U_Cube Order번호는  취소 할수 없습니다. 2')
			return -1
		end if
	end if
	
end if


end event

type cb_1 from commandbutton within w_inq_scan_change_order
integer x = 649
integer y = 524
integer width = 599
integer height = 88
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "문서삭제요청"
end type

event clicked;int    li_rowno, li_rtn, li_cnt
long   ll_ureqno, ll_req_seq, ll_rowcnt
string ls_msg, ls_doc_no, ls_intfcid, ls_customerid
double ld_req_seq

ll_rowcnt = dw_master.rowcount()

dw_master.accepttext()

if ll_rowcnt = 0 then
	return 1
end if

ls_msg = "선택된 U_Order의 문서번호에 대하여 스캔 삭제 요청을 진행 하시겠습니까?"
li_rtn  = MessageBox("스캔삭제요청", ls_msg, Exclamation!, OKCancel!, 2)

if li_rtn = 1 then
	li_rowno      = dw_master.getrow()	
	ll_ureqno     = dw_master.object.u_reqno[li_rowno]
	ls_intfcid    = dw_master.object.intfcid[li_rowno]
	ls_doc_no     = dw_master.object.docno[li_rowno]
	ls_customerid = dw_master.object.customerid[li_rowno]
	
	if (ls_intfcid <> "REQUEST" OR  isnull(ls_doc_no) ) then
		messagebox('확인', '선택된 U_Cube Order번호는 삭제 할수 없습니다. ')
		return -1
	end if

	
	UPDATE DOC_MST
	SET    INTFCID       ='DELETE',
			 PROC_STATUS   = '1', 
			 RESPONSE_CODE = NULL,
			 UPDT_USER     = :gs_user_id,
			 UPDTDT        = SYSDATE
	WHERE  U_REQNO       = :ll_ureqno;
	
			
	If SQLCA.SQLCode <> 0 Then		
		MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText+' DOC_MST(U)')
		ROLLBACK;
		Return 1	
	End If 
	
	SELECT SEQ_INTF_REQ_SCAN_DEL.NEXTVAL INTO :ld_req_seq FROM DUAL;	
		
	INSERT INTO INTF_REQ_SCAN_DEL (
					SEQNO, U_REQNO, INTFCID, 
					DOCNO, CUSTOMERID, STATUS,
					CRT_USER, CRTDT, PGM_ID) 
	VALUES      (:ld_req_seq, :ll_ureqno    , 'DELETE',
	             :ls_doc_no , :ls_customerid, '1'     ,
					 :gs_user_id, SYSDATE, :gs_pgm_id[gi_open_win_no]);

	If SQLCA.SQLCode <> 0 Then		
		MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText+' INTF_REQ_SCAN(I)')
		ROLLBACK;
		Return 1	
	End If 
end if

COMMIT;
messagebox('확인', '스캔 삭제 요청이 완료되었습니다.!')			
trigger event ue_ok()


end event

