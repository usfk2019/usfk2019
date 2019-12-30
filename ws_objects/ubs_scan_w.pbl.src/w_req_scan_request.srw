$PBExportHeader$w_req_scan_request.srw
$PBExportComments$스캔신청
forward
global type w_req_scan_request from w_a_reg_m
end type
type cb_1 from commandbutton within w_req_scan_request
end type
end forward

global type w_req_scan_request from w_a_reg_m
integer width = 3959
integer height = 2468
cb_1 cb_1
end type
global w_req_scan_request w_req_scan_request

type variables
String is_cur_gu, is_jiro, is_card, is_bank, is_inv_method, is_cus_status
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

event ue_ok;call super::ue_ok;//조회
String  ls_customerid, ls_partner, ls_order_type, ls_status,  ls_fdate, ls_tdate, ls_operator
Long    ll_row  , ll_cnt
Boolean lb_check, lb_check1
date    ld_fdate, ld_tdate
dw_cond.accepTtext()

//신규 등록
ls_partner     = dw_cond.object.partner[1]
ls_customerid  = Trim(dw_cond.object.customerid[1])
ls_order_type  = dw_cond.object.req_code[1]
ls_status      = dw_cond.object.status[1]
ld_fdate       = dw_cond.object.fdate[1]
ld_tdate       = dw_cond.object.tdate[1]
ls_operator    = dw_cond.object.operator[1]

SELECT TO_CHAR(:ld_fdate, 'YYYYMMDD'), TO_CHAR(:ld_tdate, 'YYYYMMDD')
INTO   :ls_fdate, :ls_tdate
FROM   dual;  

If IsNull(ls_customerid) Then ls_customerid = ""

ll_row = dw_detail.Retrieve(ls_partner, ls_customerid, ls_order_type, ls_fdate, ls_tdate, ls_status, ls_operator)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
	dw_cond.enabled = true
	p_ok.TriggerEvent("ue_enable")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If

dw_detail.trigger event ue_init()
end event

on w_req_scan_request.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on w_req_scan_request.destroy
call super::destroy
destroy(this.cb_1)
end on

event open;call super::open;dw_cond.trigger event ue_init()

end event

event ue_reset;call super::ue_reset;dw_cond.trigger event ue_init()

dw_detail.reset()
return 0
end event

event closequery;return 0

end event

type dw_cond from w_a_reg_m`dw_cond within w_req_scan_request
integer y = 52
integer width = 3173
integer height = 352
string dataobject = "d_cnd_scan_request"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

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

event dw_cond::itemchanged;call super::itemchanged;
Choose Case Dwo.Name
	Case "customerid" 
   	wfi_get_customerid(data)
		
	case "request_cd"
		if data = '1' then 
			dw_detail.DataObject = "d_req_scan_request_01"
			dw_detail.SetTransObject(SQLCA)
			cb_1.enabled = true
		else
			dw_detail.DataObject = "d_req_scan_request_02"
			dw_detail.SetTransObject(SQLCA)
			cb_1.enabled = false
		end if
		
		dw_detail.trigger event ue_init()

End Choose
end event

event dw_cond::ue_init;call super::ue_init;int    li_cnt
string ls_partner
DataWindowChild ldwc_col

//Help Window
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"


dw_cond.Object.fdate[1] = Date(fdt_get_dbserver_now())
dw_cond.Object.tdate[1] = Date(fdt_get_dbserver_now())

dw_detail.DataObject = "d_req_scan_request_01"
dw_detail.SetTransObject(SQLCA)
cb_1.enabled = true

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

//서비스신청작성자
dw_cond.getchild("operator", ldwc_col)
ldwc_col.SetTransObject(SQLCA)
ldwc_col.retrieve()
ldwc_col.insertrow(1)
ldwc_col.setitem(1, "empnm", "ALL")
ldwc_col.setitem(1, "emp_no", "%")





end event

type p_ok from w_a_reg_m`p_ok within w_req_scan_request
integer x = 3291
end type

type p_close from w_a_reg_m`p_close within w_req_scan_request
integer x = 3598
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within w_req_scan_request
integer width = 3232
integer height = 424
end type

type p_delete from w_a_reg_m`p_delete within w_req_scan_request
boolean visible = false
integer x = 951
integer y = 2236
end type

type p_insert from w_a_reg_m`p_insert within w_req_scan_request
boolean visible = false
integer y = 2236
end type

type p_save from w_a_reg_m`p_save within w_req_scan_request
boolean visible = false
integer x = 338
integer y = 2236
end type

type dw_detail from w_a_reg_m`dw_detail within w_req_scan_request
integer y = 444
integer width = 3845
integer height = 1752
string dataobject = "d_req_scan_request_01"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::ue_init;call super::ue_init;dw_cond.accepttext()

//신청TYPE 
f_dddw_list2(This, 'order_type', 'ZC100')

//업무상태
f_dddw_list2(This, 'proc_status', 'ZC200')

//계약상태
f_dddw_list2(This, 'status', 'B300')

//묶음그룹
f_dddw_list2(This, 'group_cd', 'ZC300')
end event

event dw_detail::itemchanged;call super::itemchanged;int    i, li_gubn, li_rowcnt, li_gubn2
string ls_customerid, ls_customerid2

this.accepttext()

li_rowcnt = this.rowcount()

if row = 0 then return

CHOOSE CASE dwo.name
	CASE "gubn" 
		li_gubn       = this.object.gubn[row]
		if li_gubn = 0 then
			
			ls_customerid = this.object.customerid[row]
		
			for i = 1 to li_rowcnt
				li_gubn2 = this.object.gubn[i]
				if li_gubn2 = 0 then
					ls_customerid2 = this.object.customerid[i]
					if ls_customerid = ls_customerid2 then
						this.setitem(i, 'gubn', 1)
					end if
				end if
			next
		end if
END CHOOSE
end event

type p_reset from w_a_reg_m`p_reset within w_req_scan_request
integer x = 645
integer y = 2236
end type

type cb_1 from commandbutton within w_req_scan_request
integer x = 3287
integer y = 328
integer width = 366
integer height = 92
integer taborder = 11
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "스캔요청"
end type

event clicked;int    li_rtn, li_rowcnt, i, li_ucube_cnt = 0, li_cust_cnt = 0, li_order_cnt = 0
string ls_msg, ls_check, ls_cust_id, ls_group_cd, ls_doc_type
string ls_pre_cust_id ='', ls_pre_group_cd='', ls_pre_doc_type=''
string ls_crt_user, ls_orderdt
double ll_req_seq, ll_pre_req_seq, ll_order_no, ll_pre_order_no,  ll_doc_type_qty
double ll_req_seq2
datetime  ld_orderdt

dw_detail.accepttext()

li_rowcnt = dw_detail.rowcount()

if li_rowcnt = 0 then
	return 0
end if

ls_msg = "선택한 Order에 대한 스캔요청을 하시겠습니까?"

li_rtn  = MessageBox("Result", ls_msg, Exclamation!, OKCancel!, 2)

if li_rtn = 1 then       //스캔요청

	dw_detail.SetSort('gubn D, customerid A, group_cd A, doc_type A')
	dw_detail.Sort()
	
	for i = 1 to li_rowcnt
		ls_check = string(dw_detail.object.gubn[i])

		if ls_check = '1' then  //체크 row 
		
			ls_cust_id      = dw_detail.object.customerid[i] 
			ls_group_cd     = string(dw_detail.object.group_cd[i] )
			ls_doc_type     = dw_detail.object.doc_type[i] 
			ll_order_no     = dw_detail.object.orderno[i] 
			ld_orderdt      = dw_detail.object.orderdt[i]
			ls_crt_user     = dw_detail.object.crt_user[i] 
			ll_doc_type_qty = dw_detail.object.doc_type_qty[i] 
			
			SELECT  TO_CHAR(:ld_orderdt, 'YYYYMMDD')
			INTO    :ls_orderdt
			FROM    DUAL;
			
			if isnull(ls_cust_id) or isnull(ls_group_cd) or isnull(ls_doc_type) or isnull(ll_order_no) then
				messagebox('확인', '스캔요청을 할 수없습니다.(등록필수값없음) 전산실로 문의해주세요')
				return -1
			end if
			
			if ls_pre_cust_id ='' or ls_pre_group_cd='' or ls_pre_doc_type='' then
				//UBS신청번호 채번 1번row 무조건 채번
				SELECT SEQ_U_REQNO.NEXTVAL INTO :ll_req_seq FROM DUAL;

				li_ucube_cnt = 1
				li_cust_cnt  = 1
				
				INSERT INTO ORDER_DOCGROUP (
							   ORDERNO, U_REQNO, CRT_USER, 
							   UPDT_USER, CRTDT, UPDTDT, 
							   PGM_ID) 
				VALUES      ( :ll_order_no, :ll_req_seq, :gs_user_id,
							     NULL, SYSDATE, NULL, :gs_pgm_id[gi_open_win_no]);
				If SQLCA.SQLCode <> 0 Then		//For Programer
					MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(ORDER_DOCGROUP_1)')
					ROLLBACK;
					Return 1
				End If 		
			//DOC_MST INSERT
				INSERT INTO DOC_MST (
								U_REQNO, CUSTOMERID, U_ORDERDT, 
								U_ORDER_USER, DOC_TYPE, DOC_TYPE_QTY, 
								DOCNO, DOC_REG_QTY, REG_CLOSE_YN, 
								INTFCID, PROC_STATUS, DELETE_FLAG, 
								CRT_USER, UPDT_USER, CRTDT, 
								UPDTDT, PGM_ID) 
				VALUES 		(:ll_req_seq , :ls_cust_id, :ls_orderdt,
								 :ls_crt_user, :ls_doc_type,:ll_doc_type_qty ,
								 NULL, NULL, NULL,
								 'REQUEST'	 , '1'   , NULL,
								 :gs_user_id , NULL, SYSDATE,
								 NULL        , :gs_pgm_id[gi_open_win_no]);
								 
				If SQLCA.SQLCode <> 0 Then		//For Programer
					MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(DOC_MST_1)')
					ROLLBACK;
					Return 1
				End If
								 
				//INTF_REQ_SCAN 	
				SELECT SEQ_INTF_REQ_SCAN.NEXTVAL INTO :ll_req_seq2 FROM DUAL;
				
				//INTF_REQ_SCAN INSERT	
				INSERT INTO INTF_REQ_SCAN (
								SEQNO, U_REQNO, INTFCID, 
								CUSTOMERID, G_ORDERDT, G_ORDER_USER, 
								DOCGROUP, DOCNO, DOC_TYPE, 
								DOC_TYPE_QTY, DOC_REG_QTY, PROC_CLOSE_YN, 
								STATUS, RESPONSE_CODE, CRT_USER, 
								UPDT_USER, CRTDT, UPDTDT, 
								PGM_ID) 
				VALUES      (:ll_req_seq2    , :ll_req_seq, 'REQUEST',
								 :ls_cust_id     , :ls_orderdt, :ls_crt_user,
								 :ls_group_cd    , NULL       ,:ls_doc_type ,
								 :ll_doc_type_qty, NULL, NULL,
								 '1'             , NULL, :gs_user_id,
								 NULL, SYSDATE, NULL, :gs_pgm_id[gi_open_win_no]);
				
				If SQLCA.SQLCode <> 0 Then		//For Programer
					MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(INTF_REQ_SCAN_1)')
					ROLLBACK;
					Return 1
				End If		
												  
				ls_pre_cust_id  = ls_cust_id
				ls_pre_group_cd = ls_group_cd
				ls_pre_doc_type = ls_doc_type
				ll_pre_req_seq  = ll_req_seq
				ll_pre_order_no = ll_order_no

			else
												  
				if ls_cust_id = ls_pre_cust_id and ls_group_cd = ls_pre_group_cd and ls_doc_type = ls_pre_doc_type then
					//custmerid, doc_type, 묶음그룹 같은건
					if ll_order_no > ll_pre_order_no then
						//ORDERNO가 가장큰값의 SVCORDER.ORDERDT, SVCORDER.CRT_USER 값업데이트
						UPDATE DOC_MST
						SET    U_ORDERDT = :ls_orderdt,
								 CRT_USER  = :gs_user_id
						WHERE  U_REQNO   = :ll_pre_req_seq;
						
						If SQLCA.SQLCode <> 0 Then		//For Programer
							MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(DOC_MST_U)')
							ROLLBACK;
							Return 1
						End If
					end if
					
					INSERT INTO ORDER_DOCGROUP (
							   	ORDERNO, U_REQNO, CRT_USER, 
							   	UPDT_USER, CRTDT, UPDTDT, 
							   	PGM_ID) 
					VALUES      ( :ll_order_no, :ll_pre_req_seq, :gs_user_id,
							      NULL, SYSDATE, NULL, :gs_pgm_id[gi_open_win_no]);
									
					If SQLCA.SQLCode <> 0 Then		//For Programer
						MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(ORDER_DOCGROUP_2)')
						ROLLBACK;
						Return 1
					End If
					
				else
					//custmerid, doc_type, 묶음그룹 같은것 기준으로 채번 하나라도 다를 경우 채번
					SELECT SEQ_U_REQNO.NEXTVAL INTO :ll_req_seq FROM DUAL;
					
					li_ucube_cnt = li_ucube_cnt + 1
					
					//ORDER_DOCGROUP INSERT
					INSERT INTO ORDER_DOCGROUP (
									ORDERNO, U_REQNO, CRT_USER, 
									UPDT_USER, CRTDT, UPDTDT, 
									PGM_ID) 
					VALUES   	(:ll_order_no, :ll_req_seq, :gs_user_id,
									NULL, SYSDATE, NULL, :gs_pgm_id[gi_open_win_no]);
									
					If SQLCA.SQLCode <> 0 Then		//For Programer
						MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(ORDER_DOCGROUP_3)')
						ROLLBACK;
						Return 1
					End If
									 
					//DOC_MST INSERT
					INSERT INTO DOC_MST (
									U_REQNO, CUSTOMERID, U_ORDERDT, 
									U_ORDER_USER, DOC_TYPE, DOC_TYPE_QTY, 
									DOCNO, DOC_REG_QTY, REG_CLOSE_YN, 
									INTFCID, PROC_STATUS, DELETE_FLAG, 
									CRT_USER, UPDT_USER, CRTDT, 
									UPDTDT, PGM_ID) 
					VALUES 		(:ll_req_seq , :ls_cust_id, :ls_orderdt,
									 :ls_crt_user, :ls_doc_type,:ll_doc_type_qty ,
									 NULL, NULL, NULL,
									 'REQUEST'	 , '1'   , NULL,
									 :gs_user_id , NULL, SYSDATE,
									 NULL        , :gs_pgm_id[gi_open_win_no]);
									 
					If SQLCA.SQLCode <> 0 Then		//For Programer
						MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(DOC_MST)')
						ROLLBACK;
						Return 1
					End If
									 
					//INTF_REQ_SCAN 	
					SELECT SEQ_INTF_REQ_SCAN.NEXTVAL INTO :ll_req_seq2 FROM DUAL;
					
					//INTF_REQ_SCAN INSERT	
					INSERT INTO INTF_REQ_SCAN (
									SEQNO, U_REQNO, INTFCID, 
									CUSTOMERID, G_ORDERDT, G_ORDER_USER, 
									DOCGROUP, DOCNO, DOC_TYPE, 
									DOC_TYPE_QTY, DOC_REG_QTY, PROC_CLOSE_YN, 
									STATUS, RESPONSE_CODE, CRT_USER, 
									UPDT_USER, CRTDT, UPDTDT, 
									PGM_ID) 
               VALUES      (:ll_req_seq2    , :ll_req_seq, 'REQUEST',
									 :ls_cust_id     , :ls_orderdt, :ls_crt_user,
									 :ls_group_cd    , NULL       ,:ls_doc_type ,
									 :ll_doc_type_qty, NULL, NULL,
									 '1'             , NULL, :gs_user_id,
									 NULL, SYSDATE, NULL, :gs_pgm_id[gi_open_win_no]);
					
					If SQLCA.SQLCode <> 0 Then		//For Programer
						MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText + '(INTF_REQ_SCAN)')
						ROLLBACK;
						Return 1
					End If	
					
					if ls_pre_cust_id <> ls_cust_id then
					li_cust_cnt = li_cust_cnt + 1
					end if	
				end if
			end if
			
			ls_pre_cust_id  = ls_cust_id
			ls_pre_group_cd = ls_group_cd
			ls_pre_doc_type = ls_doc_type
			ll_pre_req_seq  = ll_req_seq
			li_order_cnt    =  li_order_cnt + 1
		end if
	next
	
	COMMIT;
	
	//결과 팝업 
	iu_cust_msg = Create u_cust_a_msg	
	
	iu_cust_msg.is_pgm_name = "스캔 요청 결과"
	iu_cust_msg.is_grp_name = "Scan Request"
	iu_cust_msg.is_data[1]  = string(li_ucube_cnt)
	iu_cust_msg.is_data[2]  = string(li_cust_cnt)
	iu_cust_msg.is_data[3]  = string(li_order_cnt)
	 
 	OpenWithParm(w_pop_scan_request, iu_cust_msg)
	Destroy iu_cust_msg	
	
	dw_cond.object.request_cd[1] = '2'
	dw_cond.trigger event itemchanged(1, dw_cond.object.request_cd, '2')
	
	trigger event ue_ok()
end if


end event

