$PBExportHeader$w_inq_scan_rescan.srw
$PBExportComments$스캔신청결과 조회 및 재처리
forward
global type w_inq_scan_rescan from w_a_reg_m_m
end type
type p_new from u_p_new within w_inq_scan_rescan
end type
type cb_1 from commandbutton within w_inq_scan_rescan
end type
end forward

global type w_inq_scan_rescan from w_a_reg_m_m
integer width = 4370
integer height = 2812
event ue_new ( )
p_new p_new
cb_1 cb_1
end type
global w_inq_scan_rescan w_inq_scan_rescan

type variables
String is_priceplan, is_cus_status		//Price Plan Code
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

on w_inq_scan_rescan.create
int iCurrent
call super::create
this.p_new=create p_new
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
this.Control[iCurrent+2]=this.cb_1
end on

on w_inq_scan_rescan.destroy
call super::destroy
destroy(this.p_new)
destroy(this.cb_1)
end on

event open;call super::open;dw_cond.trigger event ue_init()

end event

event ue_ok;call super::ue_ok;string ls_docno, ls_partner, ls_user_id, ls_status, ls_customerid, ls_fdate, ls_tdate
string ls_ufdate, ls_utdate, ls_response, ls_intfcid, ls_operator
long   ll_u_reqno, ll_orderno, ll_row
date   ld_fdate, ld_tdate, ld_ufdate, ld_utdate

dw_cond.accepttext()

ll_u_reqno    = dw_cond.object.u_reqno[1] 
ll_orderno    = dw_cond.object.orderno[1]

ls_docno      = dw_cond.object.docno[1]
ls_partner    = dw_cond.object.partner[1]
ls_user_id    = dw_cond.object.u_user_id[1]
ls_status     = dw_cond.object.status[1]
ls_customerid = dw_cond.object.customerid[1]
ls_response   = dw_cond.object.response_code[1]
ls_intfcid    = dw_cond.object.intfcid[1]

ld_fdate      = dw_cond.object.fdate[1]
ld_tdate      = dw_cond.object.tdate[1]
ld_ufdate     = dw_cond.object.ufdate[1]
ld_utdate     = dw_cond.object.utdate[1]
ls_operator   = dw_cond.object.operator[1]

//요청사항
SELECT TO_CHAR(:ld_fdate, 'YYYYMMDD'), TO_CHAR(:ld_tdate, 'YYYYMMDD'), &
       TO_CHAR(:ld_ufdate,  'YYYYMMDD'), TO_CHAR(:ld_utdate, 'YYYYMMDD')
INTO   :ls_fdate, :ls_tdate, :ls_ufdate, :ls_utdate		 
FROM   dual;  

//Retrieve
ll_row = dw_master.Retrieve(ll_u_reqno, ls_customerid, ls_docno, ls_ufdate, ls_utdate, &
                   ls_user_id, ls_fdate, ls_tdate, ls_intfcid, ls_status, ll_orderno, &
						 ls_partner, ls_response, ls_operator)

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

event ue_save;//Constant Int LI_ERROR = -1
////Int li_return
//
////ii_error_chk = -1
//If dw_detail.AcceptText() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
//End if
//
//If This.Trigger Event ue_extra_save() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
//End if
//
//If dw_detail.Update() < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//	
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail.SetFocus()
//		Return LI_ERROR
//	End If
//	f_msg_info(3010,This.Title,"Save")
//	Return LI_ERROR
//Else
//	//COMMIT와 동일한 기능
//	iu_cust_db_app.is_caller = "COMMIT"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail.SetFocus()
//		Return LI_ERROR
//	End If
//	
//	 dw_detail.ResetUpdate()
//	 dw_detail.ReSet()
//    This.Trigger Event ue_ok()
//	 
//	f_msg_info(3000,This.Title,"Save")
//End if
//
////ii_error_chk = 0
////p_new.TriggerEvent("ue_enable")
//
Return 0
//
end event

type dw_cond from w_a_reg_m_m`dw_cond within w_inq_scan_rescan
integer x = 46
integer y = 44
integer width = 3648
integer height = 368
string dataobject = "d_cnd_scan_rescan"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;int    li_cnt
string ls_partner, ls_partnernm
date   ld_sysdate, ld_ufdate
DataWindowChild ldwc_col

//Help Window
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"

ld_sysdate = Date(fdt_get_dbserver_now())

SELECT  ADD_MONTHS(:ld_sysdate, -3)
INTO    :ld_ufdate
FROM    DUAL;

this.Object.ufdate[1] = ld_ufdate
this.Object.utdate[1] = Date(fdt_get_dbserver_now())

this.Object.fdate[1] = ld_ufdate //Date(fdt_get_dbserver_now())
this.Object.tdate[1] = Date(fdt_get_dbserver_now())

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

////연동상태 ALL
dw_cond.getchild("status", ldwc_col)
f_dddw_list2(this, 'status', 'ZC200')
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "codenm", "ALL")
ldwc_col.setitem(1, "code", "%")

//응답코드
dw_cond.getchild("response_code", ldwc_col)
f_dddw_list2(this, 'response_code', 'ZC700')
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

event dw_cond::itemchanged;String 	ls_operator, ls_empnm

Choose Case Dwo.Name
	Case "customerid" 
   	wfi_get_customerid(data)
	case "u_reqno", "docno"
		if isnull(data) then data =" "
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

event dw_cond::itemerror;call super::itemerror;
p_reset.TriggerEvent("ue_enable")
return 1
end event

type p_ok from w_a_reg_m_m`p_ok within w_inq_scan_rescan
integer x = 3735
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within w_inq_scan_rescan
integer x = 4041
integer y = 52
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_inq_scan_rescan
integer x = 23
integer width = 3694
integer height = 428
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within w_inq_scan_rescan
integer x = 23
integer y = 460
integer width = 4288
integer height = 1344
integer taborder = 30
string dataobject = "d_inq_scan_rescan"
boolean ib_sort_use = false
end type

event dw_master::ue_init;call super::ue_init;dw_cond.accepttext()

//상태
f_dddw_list2(This, 'status', 'ZC200')


//응답코드
f_dddw_list2(This, 'response_code', 'ZC700')


end event

event dw_master::rowfocuschanged;long    ll_u_reqno
string  ls_response_code

If currentrow <= 0 Then
	
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
	dw_detail.Reset()
	
	ll_u_reqno       = this.object.u_reqno[currentrow]
	ls_response_code = this.object.response_code[currentrow]
	
	if ls_response_code = 'F' then
		cb_1.enabled = true
	else
		cb_1.enabled = false
	end if
	
	dw_detail.retrieve(ll_u_reqno)
	
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

event dw_master::doubleclicked;
//If row = 0 Then Return 1


end event

event dw_master::clicked;call super::clicked;int  li_row 

If row = 0 Then Return 1

trigger event rowfocuschanged(row)





end event

type dw_detail from w_a_reg_m_m`dw_detail within w_inq_scan_rescan
integer x = 23
integer y = 1840
integer width = 4288
integer height = 716
integer taborder = 40
string dataobject = "d_reg_scan_rescan"
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

event dw_detail::ue_init;call super::ue_init;
//응답코드
f_dddw_list2(This, 'response_code', 'ZC700')


end event

type p_insert from w_a_reg_m_m`p_insert within w_inq_scan_rescan
boolean visible = false
integer y = 2568
end type

type p_delete from w_a_reg_m_m`p_delete within w_inq_scan_rescan
boolean visible = false
integer y = 2568
end type

type p_save from w_a_reg_m_m`p_save within w_inq_scan_rescan
boolean visible = false
integer x = 617
integer y = 2568
end type

type p_reset from w_a_reg_m_m`p_reset within w_inq_scan_rescan
integer x = 1202
integer y = 2568
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within w_inq_scan_rescan
integer x = 23
integer y = 1804
integer height = 36
end type

type p_new from u_p_new within w_inq_scan_rescan
boolean visible = false
integer x = 910
integer y = 2568
integer width = 283
integer height = 96
boolean bringtotop = true
boolean originalsize = false
end type

type cb_1 from commandbutton within w_inq_scan_rescan
integer x = 3744
integer y = 296
integer width = 517
integer height = 92
integer taborder = 21
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "재처리"
end type

event clicked;int     li_rowno, li_rowcnt, li_rtn
long    ll_req_seq
string  ls_intfcid, ls_msg
double  ld_req_seq2

dw_master.accepttext()

li_rowcnt  = dw_master.rowcount()

if li_rowcnt = 0 then
	return 0
end if

li_rowno  = dw_master.getrow()

ll_req_seq = dw_master.object.u_reqno[li_rowno]
ls_intfcid = dw_master.object.intfcid[li_rowno]

ld_req_seq2 = dw_master.object.seqno[li_rowno]

ls_msg = "전문ID: " + ls_intfcid  + "~r~n Ucube 요청번호 " + string(ll_req_seq) +&
         "번을 재요청 처리를 진행하겠습니까?"


li_rtn  = MessageBox("Result", ls_msg, Exclamation!, OKCancel!, 2)


if li_rtn = 1 then  
	UPDATE INTF_REQ_SCAN
	SET    STATUS        = '1',
	       RESPONSE_CODE = NULL,
			 TRY_CNT       = 0,
			 UPDTDT        = SYSDATE,
			 UPDT_USER     = :gs_user_id
   WHERE  SEQNO         = :ld_req_seq2
	AND    U_REQNO       = :ll_req_seq;
	
	If SQLCA.SQLCode <> 0 Then		
		MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(INTF_REQ_SCAN(U))')
		ROLLBACK;
		Return 1
	End If		
end if

COMMIT;

messagebox('확인', '재요청 처리가 완료되었습니다.!')

trigger event ue_ok()
	
end event

