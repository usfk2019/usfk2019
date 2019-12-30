$PBExportHeader$w_term_cust_info.srw
$PBExportComments$해지DB고객정보조회
forward
global type w_term_cust_info from w_a_reg_m_tm2
end type
type p_view from u_p_view within w_term_cust_info
end type
type p_active from picture within w_term_cust_info
end type
type cb_comment from commandbutton within w_term_cust_info
end type
type cb_bill from commandbutton within w_term_cust_info
end type
type p_active_mobile from picturebutton within w_term_cust_info
end type
end forward

global type w_term_cust_info from w_a_reg_m_tm2
integer width = 4082
integer height = 2428
event ue_view ( )
event ue_active ( )
event ue_request ( )
event ue_clip ( string as_value )
p_view p_view
p_active p_active
cb_comment cb_comment
cb_bill cb_bill
p_active_mobile p_active_mobile
end type
global w_term_cust_info w_term_cust_info

type variables
Boolean ib_new, ib_billing, ib_ctype3
String is_check
String is_method, is_credit, is_inv_method, is_status, is_select_cod
Long il_row, il_mst_row
String is_pay_method_ori, is_receiptcod          //결재방법(origin), 신청접수처
String is_drawingtype[], is_drawingresult[]		 //출금이체신청유형, 출금이체신청결과
string is_drawingtype_ori, is_drawingresult_ori  //출금이체신청유형(origin), 출금이체신청결과(origin)
String is_receiptcod_ori, is_resultcod_ori       //신청접수처(origin), 신청결과코드(origin)
String is_bank_ori, is_acctno_ori, is_acct_owner_ori, is_acct_ssno_ori //은행,계좌번호,예금주, 예금주민번호(origin)
datetime id_drawingreqdt_ori, id_receiptdt_ori 	 //이체신청일자(origin), 신청접수일자(origin)
String is_chg_flag                               //pay_method변경flag
String is_bank_chg_ori							       //자동이체 정보 변경(origin)
datetime idt_sysdate
string is_drawingtype_bef, is_drawingresult_bef  //출금이체신청유형(before), 출금이체신청결과(before)
String is_receiptcod_bef, is_resultcod_bef       //신청접수처(before), 신청결과코드(before)
String is_bank_bef, is_acctno_bef, is_acct_owner_bef, is_acct_ssno_bef //은행,계좌번호,예금주, 예금주민번호(before)
datetime id_drawingreqdt_bef, id_receiptdt_bef 	 //이체신청일자(before), 신청접수일자(before)
String is_bonsa, is_bonsa_prefix
//Currency_type
String is_currency_old, is_payid_old
//선불제 svctype
String is_svctype_pre, is_card_prefix_yn

//dw child
DataWindowChild idc_itemcod



TRANSACTION SQLCA_TERM
end variables

forward prototypes
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[])
public function integer wf_paymethod_chg_check ()
public function integer wfi_get_payid (string as_customerid, ref boolean ab_check)
public function integer wf_authority_check ()
end prototypes

event ue_view();String ls_customerid, ls_where
Long i, ll_master_row

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row <> 0 Then
	If ll_master_row < 0 Then Return 
	ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
End If

If ls_customerid = "" Then Return

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_id 	= gs_pgm_id[gi_open_win_no]
iu_cust_msg.is_pgm_name = "고객정보등록"
iu_cust_msg.is_grp_name = "청구및사용내역상세조회"

iu_cust_msg.is_data[1]  = ls_customerid
iu_cust_msg.is_data[2]  = gs_pgm_id[gi_open_win_no] 	//Pgm ID


OpenWithParm(b1w_inq_inv_detail_pop, iu_cust_msg, gw_mdi_frame)

end event

event ue_request();IF il_mst_row > 0 then
	gs_CID = dw_master.Object.customerm_customerid[il_mst_row]
	gs_onOff = '1'
ELSE
	gs_CID = ""
	gs_onOff = '0'
	
END IF
f_call_menu("b1w_1_reg_svc_actorder_v20_sams")

end event

event ue_clip;Clipboard(as_value)
end event

public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check);//선불 고객인지 확인
String ls_ctype3
ab_check = False
	
	select ctype3 
	into :ls_ctype3
	from customerm
	where customerid = :as_customerid;
	
	//Error
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err("선불고객", "Select customerm Table")
		Return 0
	End If
	
	If ls_ctype3 = "0" Then
		ab_check = True
		
	
	Else
		ab_check = False
		
	End If
 
Return 0
end function

public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[]);Long ll_rows
String ls_zoncod

If as_zoncod = "" Then as_zoncod = "%"
ll_rows = 0

DECLARE cur_get_arezoncod CURSOR FOR
SELECT distinct zoncod
FROM arezoncod2
WHERE zoncod like :as_zoncod;

If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(Title, ":CURSOR cur_get_arezoncod")
	Return -1
End If

OPEN cur_get_arezoncod;
Do While(True)
	FETCH cur_get_arezoncod
	INTO :ls_zoncod;
			
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(Title, ":cur_get_arezoncod")
		CLOSE cur_get_arezoncod;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	ll_rows += 1
	as_arezoncod[ll_rows] = ls_zoncod
	
Loop
CLOSE cur_get_arezoncod;

Return ll_rows
end function

public function integer wf_paymethod_chg_check ();String ls_drawingresult, ls_drawingtype

//신청결과=처리중
IF is_drawingresult_ori = is_drawingresult[3] Then
	is_chg_flag = 'N'			//pay_method 변경 Flag 
	return 2
End If

//신청유형=변경, 신청결과=미처리
IF is_drawingtype_ori = is_drawingtype[3] Then
	IF is_drawingresult_ori = is_drawingtype[2] Then
		is_chg_flag = 'N'       //pay_method 변경 Flag 
		return 2
	End If
End If

is_chg_flag = 'Y'
				
return 0
end function

public function integer wfi_get_payid (string as_customerid, ref boolean ab_check);//납입자랑 고객과 같은지 확인
String ls_payid
ab_check = False

Select payid
Into :ls_payid
From customerm
Where customerid = :as_customerid;

//Error
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err("납입자", "Select customerm Table")
	Return 0
End If

If ls_payid <> as_customerid Then
	ab_check = True					//같지 않음
Else
	ab_check = False					//같음
	
End If
Return 0

end function

public function integer wf_authority_check ();integer li_cnt

Select count(*) into :li_cnt
from Termcust.Syscod2t
where grcode = 'TERMUSER'
   and code = :gs_user_id;
	
if li_cnt = 0 then
	messagebox("확인","조회/처리 권한이 없습니다. 관리자에게 문의하세요")
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	return -1
end if
	
return 0
end function

on w_term_cust_info.create
int iCurrent
call super::create
this.p_view=create p_view
this.p_active=create p_active
this.cb_comment=create cb_comment
this.cb_bill=create cb_bill
this.p_active_mobile=create p_active_mobile
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_view
this.Control[iCurrent+2]=this.p_active
this.Control[iCurrent+3]=this.cb_comment
this.Control[iCurrent+4]=this.cb_bill
this.Control[iCurrent+5]=this.p_active_mobile
end on

on w_term_cust_info.destroy
call super::destroy
destroy(this.p_view)
destroy(this.p_active)
destroy(this.cb_comment)
destroy(this.cb_bill)
destroy(this.p_active_mobile)
end on

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b1w_reg_customer_c
	Desc.	:	고객 정보 등록(선불&후불)
	Ver	: 	1.0
	Date	: 	2003.10.21
	Prgromer : Park Kyung Haeem)
---------------------------------------------------------------------------*/

//TRANSACTION SQLCA_TERM
SQLCA_TERM = CREATE TRANSACTION 
SQLCA_TERM.DBMS  = "O84 ORACLE 8.0.4"
SQLCA_TERM.SERVERNAME =SQLCA.ServerName
SQLCA_TERM.LogId = "termcust"
SQLCA_TERM.LOGPASS = "termcust123"
SQLCA_TERM.AUTOCOMMIT = FALSE
CONNECT USING SQLCA_TERM;

IF SQLCA_TERM.SQLCODE < 0 THEN
	DISCONNECT USING SQLCA_TERM;
	DESTROY SQLCA_TERM;
	MESSAGEBOX("SQLCA_TERM CONNECT ERROR", "연결에 실패하였습니다. 관리자에게 문의하시기 바랍니다")
	RETURN
END IF



String ls_ref_desc, ls_temp, ls_name[], ls_customerid
string ls_shop_type


ib_new 			= False
ib_billing 		= False
ib_ctype3		= False		//선불 고객여부
is_check 		= ""
is_method 		= ""
is_credit 		= ""
is_inv_method 	= ""

//손모양 없애기
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[5].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[6].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[7].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[8].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[9].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[10].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[11].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[12].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[13].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[14].SetRowFocusIndicator(off!)
//
////결제 정보
////카드 정보 가져오기
ls_ref_desc 	= ""
is_method 		= fs_get_control("B0", "P131", ls_ref_desc)
is_credit 		= fs_get_control("B0", "P131", ls_ref_desc)
is_inv_method 	= fs_get_control("B0", "P132", ls_ref_desc)  //E-mail 로 발송
is_status 		= fs_get_control("B0", "P202", ls_ref_desc)    //등록상태

//선불제서비스TYPE
is_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)

//출금이체 신청유형(1.없음(0);2.신규(1);3.변경(2);4.해지(3);5.임의해지(7))
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("B7", "A320", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_drawingtype[])

//출금이체 신청결과(1.없음(0);2.신청(1);3.처리중(2);4.처리성공(S);5.처리실패(F))
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("B7", "A330", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_drawingresult[])

//출금이체 신청접수처
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("B7", "A300", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", ls_name[])
is_receiptcod 	= ls_name[2]

idt_sysdate 	= fdt_get_dbserver_now()    //sysdatetime
//본사 코드 본사 prefix
is_bonsa        = fs_get_control("A1", "C102", ls_ref_desc)  
is_bonsa_prefix = fs_get_control("A1", "C101", ls_ref_desc)  

//신용카드prefix 사용여부... y이면-> 카드번호 입력시 자동으로 카드사 setting, edit 불가
is_card_prefix_yn = fs_get_control("00", "Z930", ls_ref_desc)  


dw_cond.SetFocus()
dw_cond.setColumn("customerid")

ls_customerid = iu_cust_msg.is_call_name[2]

select SHOP_TYPE
into  :ls_shop_type
from sams.partnermst
where partner = :gs_shopid; // partner

//ls_shop_type = 'TECH'

// shop_type(PARTNERMST)에 따라 BILL버튼 DISPLAY여부
//if ls_shop_type = 'TECH' then
//	cb_bill.visible = 	false
//else
//	cb_bill.visible = 	true
//end if

IF IsNull(ls_customerid) THEN ls_customerid = ""

IF ls_customerid <> ""THEN
	dw_cond.Object.customerid[1] = ls_customerid	
	p_ok.TriggerEvent(Clicked!)	
END IF

//p_view.TriggerEvent("ue_disable")
end event

event ue_ok;call super::ue_ok;// SSRT용 변환 작업 //
// 2006.04.12 22:15 
// hcjung
//2006-6-01 Modify By 1hera

//dw_cond 조회
String 	ls_customerid, 	ls_firstname,		ls_lastname,		ls_memberid
String 	ls_mailid, 			ls_bil_email,		ls_buildingno,		ls_roomno, 		&
			ls_homephone,		ls_new, 				ls_where,			ls_cellphone,	&
			ls_mac,				ls_validkey
Long 		ll_row
Integer 	li_ret


dw_master.settransobject(SQLCA_TERM)

dw_cond.AcceptText()

ls_customerid	= Trim(dw_cond.object.customerid[1])
ls_memberid		= Trim(dw_cond.object.memberid[1])
ls_firstname 	= Trim(dw_cond.object.firstname[1])
ls_lastname		= Trim(dw_cond.object.lastname[1])


//권한체크
li_ret = wf_authority_check()
if li_ret < 0 then return


IF ls_new = "Y" THEN
	ib_new = True
ELSE
	ib_new = False
END IF

//CUSTOMER.LOG 에 기록 남기기...
IF ib_new = False THEN
	INSERT INTO TERMCUST.CUSTOMER_LOG
		( EMP_ID, ACTION, TIMESTAMP, MEMBERID, CUSTOMERID,
		  FIRSTNAME, LASTNAME, VALIDKEY, EMAIL, HOMEPHONE,
		  CELLPHONE, BUILDINGNO, ROOMNO, MACADDRESS )
	VALUES
		( :gs_user_id, 'OK', SYSDATE, :ls_memberid, :ls_customerid,
		  :ls_firstname, :ls_lastname, :ls_validkey, :ls_mailid, :ls_homephone,
		  :ls_cellphone, :ls_buildingno, :ls_roomno, :ls_mac );
	
	IF sqlca_term.sqlcode < 0 THEN
		ROLLBACK;
	ELSE
		COMMIT;
	END IF		
END IF

ll_row = dw_master.Retrieve(ls_customerid, ls_memberid, ls_firstname, ls_lastname)


If ll_row = 0 Then
	f_msg_info(1000, Title, "")
	p_view.TriggerEvent("ue_disable")			
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	p_view.TriggerEvent("ue_disable")			
	Return
Else			
	//검색을 찾으면 Tab를 활성화 시킨다.
	il_mst_row 			=  1
	tab_1.Trigger Event SelectionChanged(1, 1)
	tab_1.Enabled = True
End If
end event

event ue_reset;//초기화
Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

li_tab_index = tab_1.SelectedTab

////Reset 문제
//If tab_1.ib_tabpage_check[li_tab_index] = True Then
//	tab_1.idw_tabpage[li_tab_index].AcceptText() 
//
//	If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
//		(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
//		
//		li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
//					,Question!,YesNo!)
//		If li_rc <> 1 Then
//			Return LI_ERROR
//		End If
//	End If
//End If
	
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_view.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_cond.ReSet()
dw_cond.InsertRow(0)
dw_master.Reset()
For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
Next
dw_cond.Enabled = True
//dw_cond.InsertRow(0)
dw_cond.SetColumn("memberid")

ib_new 			= False
is_chg_flag  	= 'Y'
il_mst_row 		= 0

Return 0 
end event

event ue_extra_insert;call super::ue_extra_insert;////Insert
//b1u_check lu_check	
//Integer 	li_rc, 			li_tab
//Long 		ll_master_row
//String 	ls_customerid, ls_ref_desc, ls_reqnum_dw, ls_name[], ls_lastnm, ls_firstnm, &
//			ls_customernm, ls_basecod
//Boolean 	lb_check1
//
//li_tab 	= ai_selected_tab
//lu_check = create b1u_check
//
//ll_master_row = dw_master.GetSelectedRow(0)
//If ll_master_row <> 0 Then
//	If ll_master_row < 0 Then Return -1
//	ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
//	ls_lastnm 	= Trim(dw_master.object.lastname[ll_master_row])
//	IF IsNULL(ls_lastnm) then ls_lastnm = ""
//	ls_firstnm 	= Trim(dw_master.object.firstname[ll_master_row])
//	IF IsNULL(ls_firstnm) then ls_firstnm = ""
//	IF ls_firstnm <> "" then
//		ls_customernm =  ls_lastnm + ' '  + ls_lastnm
//	ELSE
//		ls_customernm =  ls_lastnm
//	END IF
//End If
//
//Choose Case li_tab
//	Case 1		//Tab 1 고객정보
//		If ib_new = True Then
//
//			ls_ref_desc 	= ""
//			ls_reqnum_dw 	= fs_get_control("B0", "P200", ls_ref_desc)
//			If ls_reqnum_dw = "" Then Return -1
//			fi_cut_string(ls_reqnum_dw, ";", ls_name[])
//			tab_1.idw_tabpage[li_tab].object.status[li_tab] 		= ls_name[1]
//			
//			ls_ref_desc 	= ""
//			ls_reqnum_dw 	= fs_get_control("C1", "A100", ls_ref_desc)
//			IF  ls_reqnum_dw <> '' THEN 
//				fi_cut_string(ls_reqnum_dw, ";", ls_name[])
//				tab_1.idw_tabpage[li_tab].object.ctype2[1] 		= ls_name[1]
//				tab_1.idw_tabpage[li_tab].object.ctype1[1] 		= ls_name[2]
//			END IF
//			
//			
//				
//			//Display
//			tab_1.idw_tabpage[li_tab].object.termdt.Protect 		= 1
//			tab_1.idw_tabpage[li_tab].object.customerid.Protect 		= 1
//			
//			tab_1.idw_tabpage[li_tab].object.termtype.Protect 		= 1
//			tab_1.idw_tabpage[li_tab].Object.termdt.Background.Color 	= RGB(255, 251, 240)
//			tab_1.idw_tabpage[li_tab].Object.termdt.Color 					= RGB(0, 0, 0)
//			tab_1.idw_tabpage[li_tab].Object.termtype.Background.Color 	= RGB(255, 251, 240)
//			tab_1.idw_tabpage[li_tab].Object.termtype.Color 				= RGB(0, 0, 0)
//				
//			//원상태로..
//			tab_1.idw_tabpage[li_tab].object.logid.Protect 					= 0
//			tab_1.idw_tabpage[li_tab].Object.logid.Color 					= RGB(0, 0, 255)
//			tab_1.idw_tabpage[li_tab].Object.logid.Background.Color 		= RGB(255, 255, 255)
//				
//			//Setting
//			tab_1.idw_tabpage[li_tab].object.enterdt[li_tab] 				= fdt_get_dbserver_now()			//가입일
//			tab_1.idw_tabpage[li_tab].object.partner[li_tab] 				= GS_SHOPID
//			
//			//ADD-2007-1-11
//			select basecod INTO :ls_basecod FROM partnermst 
//			 WHERE partner = :GS_SHOPID ;
//			IF IsNull(ls_basecod) OR sqlca.sqlcode < 0 THEN ls_basecod = ''
//			tab_1.idw_tabpage[li_tab].object.basecod[li_tab] 				= ls_basecod
//			//ADD end...
//			
////			tab_1.idw_tabpage[li_tab].object.partner_prefix[li_tab] = is_bonsa_prefix				
//		End  If
//
//
//
//		//Log
//		tab_1.idw_tabpage[li_tab].object.crt_user[1] 	= gs_user_id
//		tab_1.idw_tabpage[li_tab].object.crtdt[1] 		= fdt_get_dbserver_now()
//		tab_1.idw_tabpage[li_tab].object.pgm_id[1] 		= gs_pgm_id[gi_open_win_no]
//		tab_1.idw_tabpage[li_tab].object.updt_user[1] 	= gs_user_id
//		tab_1.idw_tabpage[li_tab].object.updtdt[1] 		= fdt_get_dbserver_now()
//			
//	Case 2		//Tab 2 청구지정보
//			//inv_method
//			//billinginfo_currency_type
//			ls_ref_desc 	= ""
//			ls_reqnum_dw 	= fs_get_control("C1", "A100", ls_ref_desc)
//			IF  ls_reqnum_dw <> '' THEN 
//				fi_cut_string(ls_reqnum_dw, ";", ls_name[])
//				tab_1.idw_tabpage[li_tab].object.inv_method[1] 		= ls_name[6]
//				tab_1.idw_tabpage[li_tab].object.billinginfo_currency_type[1] = ls_name[4]
//			END IF
//			
//		
//		//Setting
//		tab_1.idw_tabpage[li_tab].object.customerid[1] = ls_customerid
//		tab_1.idw_tabpage[li_tab].object.card_holder[1] = ls_customernm
//		
//		//Log
//		tab_1.idw_tabpage[li_tab].object.crt_user[1] 	= gs_user_id
//		tab_1.idw_tabpage[li_tab].object.crtdt[1] 		= fdt_get_dbserver_now()
//		tab_1.idw_tabpage[li_tab].object.pgm_id[1] 		= gs_pgm_id[gi_open_win_no]
//		tab_1.idw_tabpage[li_tab].object.updt_user[1] 	= gs_user_id
//		tab_1.idw_tabpage[li_tab].object.updtdt[1] 		= fdt_get_dbserver_now()
//		
//		p_insert.TriggerEvent("ue_disable")
//	
////	Case 3		//Tab 3 인증정보
////		//Setting
////		tab_1.idw_tabpage[li_tab].object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())
////		tab_1.idw_tabpage[li_tab].object.customerid[al_insert_row] = ls_customerid
////		tab_1.idw_tabpage[li_tab].object.use_yn[al_insert_row] = 'N'
////		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
////		tab_1.idw_tabpage[li_tab].SetColumn("validkey")
////		
////		//Log
////		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
////		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
////		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
////		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
////		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
//	
////	Case 4		//Tab 4 H/W 정보
////		//HW Seq 가져오기
////		lu_check.is_caller   = "b1w_reg_customer%new_hw"
////		lu_check.is_title    = Title
////		lu_check.il_data[1] 	= al_insert_row							
////
////		lu_check.ii_data[1]  = li_tab
////		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]		
////		lu_check.uf_prc_check_4()
////		li_rc = lu_check.ii_rc
////		If li_rc < 0 Then 
////			Destroy lu_check
////			Return li_rc
////		End If
////		
////		//Setting
////		tab_1.idw_tabpage[li_tab].object.customerid[al_insert_row] = ls_customerid
////		tab_1.idw_tabpage[li_tab].object.rectype[al_insert_row] = "C"
////		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
////		tab_1.idw_tabpage[li_tab].SetColumn("adtype")
////		
////		//Log
////		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
////		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
////		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
////		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
////		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
////	
//////  Case 9     //국가별할인
//////		tab_1.idw_tabpage[li_tab].object.customerid[al_insert_row] = ls_customerid
//////		tab_1.idw_tabpage[li_tab].object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())
//////		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
//////		tab_1.idw_tabpage[li_tab].SetColumn("countrycod")
////
////	Case 10     //대역별 요율 등록
////		tab_1.idw_tabpage[li_tab].object.parttype[al_insert_row]  = "C"
////		tab_1.idw_tabpage[li_tab].object.partcod[al_insert_row]   = ls_customerid
////		tab_1.idw_tabpage[li_tab].object.opendt[al_insert_row]    = Date(fdt_get_dbserver_now())
////		tab_1.idw_tabpage[li_tab].object.roundflag[al_insert_row] = "U"
////		tab_1.idw_tabpage[li_tab].object.frpoint[al_insert_row]   = 0
////		tab_1.idw_tabpage[li_tab].object.unitsec[al_insert_row]   = 0
////		tab_1.idw_tabpage[li_tab].object.unitfee[al_insert_row]   = 0
////		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
////		tab_1.idw_tabpage[li_tab].SetColumn("zoncod")
////		
////		//Log
////		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row]  = gs_user_id
////		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row]     = fdt_get_dbserver_now()
////		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
////		 
////	Case 11     //착신지 제한번호 등록
//////		tab_1.idw_tabpage[li_tab].object.parttype[al_insert_row] = "C"
//////		tab_1.idw_tabpage[li_tab].object.partcod[al_insert_row]  = ls_customerid
//////		tab_1.idw_tabpage[li_tab].object.opendt[al_insert_row]   = Date(fdt_get_dbserver_now())
//////		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
//////		tab_1.idw_tabpage[li_tab].SetColumn("areanum")
//////		
////		//Log
////		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
////		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
////		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]  
////
//End Choose
//
//Destroy lu_check
Return 0
//
end event

event ue_extra_save;////Save Check
//Integer 	li_tab, 				li_rc
//Long 		i, 					ll_row, 			ll_master_row
//String 	ls_customerid, 	ls_bank_chg, 	ls_paymethod, 		ls_drawingtype, 	ls_enddt, &
//       	ls_osvccod, 		ls_svccod, 		ls_svccod1, 		ls_svccod2
//Boolean 	lb_check1
//
//String 	ls_parttype1, 		ls_partcod1, 	ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_areanum1, ls_itemcod1
//String 	ls_parttype2, 		ls_partcod2, 	ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_areanum2, ls_itemcod2
//Long   	ll_rows1, 			ll_rows2, 		li_pre_cnt, li_old_cnt
//
//String 	ls_firstnm, ls_lastnm, ls_midnm, ls_email1_1, ls_email1_2, ls_email2_1, ls_email2_2, ls_bil_email_1, ls_bil_email_2, ls_card_no_1, ls_card_no_2
//String   ls_logid_1, ls_logid_2
//
//li_tab = ai_select_tab
//If tab_1.idw_tabpage[li_tab].RowCount() = 0 Then Return 0
//
//b1u_check1_v20 lu_check
//lu_check = Create b1u_check1_v20
//
//Choose Case li_tab
//	Case 1
//		//customernm 컬럼 set 
//		ls_firstnm 	= trim(tab_1.idw_tabpage[li_tab].object.firstname[1])
//		ls_midnm 	= trim(tab_1.idw_tabpage[li_tab].object.midname[1])
//		ls_lastnm 	= trim(tab_1.idw_tabpage[li_tab].object.lastname[1]) 
//		IF IsNull(ls_firstnm) 	then	ls_firstnm 	= ''
//		IF IsNull(ls_midnm) 		then	ls_midnm 	= ''
//		IF IsNull(ls_lastnm) 	then	ls_lastnm 	= ''
//		
//		tab_1.idw_tabpage[li_tab].object.customernm[1] = ls_firstnm + ls_midnm + ls_lastnm
//		lu_check.is_caller 	= "b1w_reg_customer_d_v20%save_tab1"
//		lu_check.is_title 	= Title
//		lu_check.ii_data[1] 	= li_tab
//		lu_check.ib_data[1] 	= ib_new
//		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
//				
//		lu_check.uf_prc_check_07()
//		li_rc = lu_check.ii_rc
//		
//		//필수 항목 오류
//		If li_rc = -2 Then
//			Destroy lu_check
//			Return -2
//		End If
//		
//	   //납입자 오류
//		If li_rc = -3 Then
//			Destroy lu_check
//			Return -3
//		End If
//		Destroy lu_check
//	   
//		//Update Log
//		tab_1.idw_tabpage[li_tab].object.updt_user[1] 	= gs_user_id
//		tab_1.idw_tabpage[li_tab].object.updtdt[1] 		= fdt_get_dbserver_now()
//		
//   Case 2
//		
//		ls_card_no_1 = tab_1.idw_tabpage[li_tab].object.card_no_1[1] + tab_1.idw_tabpage[li_tab].object.card_no_2[1]
//		ls_card_no_2 = tab_1.idw_tabpage[li_tab].object.card_no_3[1] + tab_1.idw_tabpage[li_tab].object.card_no_4[1]
//			
//		tab_1.idw_tabpage[li_tab].object.card_no[1] = trim(ls_card_no_1 + ls_card_no_2);
//		
//		lu_check.is_caller 		= "b1w_reg_customer_d%save_tab2"
//		lu_check.is_title 		= Title
//		lu_check.ii_data[1] 		= li_tab
//		lu_check.is_data[1] 		= is_method
//		lu_check.is_data[2] 		= is_credit
//		lu_check.is_data[3] 		= is_inv_method
//		lu_check.is_data[4] 		= is_bank_chg_ori	
//		lu_check.idw_data[1] 	= tab_1.idw_tabpage[li_tab]
//		lu_check.uf_prc_check_2()
//		li_rc = lu_check.ii_rc
//		
//		//필수 항목 오류
//		If li_rc < 0 Then
//			Destroy lu_check
//			Return -2
//		End If
//      
//		//Update Log
//		tab_1.idw_tabpage[li_tab].object.updt_user[1] 	= gs_user_id
//		tab_1.idw_tabpage[li_tab].object.updtdt[1] 		= fdt_get_dbserver_now()
//	
//		//변경시 - 변경전정보 before 컬럼에 저장....
//		ls_bank_chg 	= tab_1.idw_tabpage[li_tab].object.bank_chg[1] 
//		ls_paymethod 	= tab_1.idw_tabpage[li_tab].object.pay_method[1] 
//		ls_drawingtype = tab_1.idw_tabpage[li_tab].object.drawingtype[1] 		
//		
//		//변경check = 'Y' & 결재방법 = '자동이체' & 신청유형 = '변경' 일때만... before 저장...
//		If ls_bank_chg = 'Y' and ls_paymethod = is_method and ls_drawingtype = is_drawingtype[3]Then
//			If is_bank_chg_ori = 'Y' Then
//			Else 
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_bank[1] 			= is_bank_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acctno[1] 			= is_acctno_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_owner[1] 	= is_acct_owner_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_ssno[1] 		= is_acct_ssno_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingresult[1] = is_drawingresult_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingtype[1] 	= is_drawingtype_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingreqdt[1] 	= id_drawingreqdt_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptdt[1] 		= id_receiptdt_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_resultcod[1] 		= is_resultcod_ori
//				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptcod[1] 	= is_receiptcod_ori
//			End IF
//		End If
//	
////  Case 3
////	
////	   //tab3 인증정보는 delete만 save 되고... insert 나 update는 모두 popup window를 이용하여 저장된다.	   
////		lu_check.is_caller = "b1w_reg_customer%save_tab3"
////		lu_check.is_title = Title
////		lu_check.ii_data[1] = li_tab
////		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
////		lu_check.uf_prc_check_2()
////		li_rc = lu_check.ii_rc
////		
////		//필수 항목 오류
////		If li_rc < 0 Then
////			Destroy lu_check
////			Return -2
////		End If
////		
////		//Update Log
////		ll_row = tab_1.idw_tabpage[li_tab].RowCount()
////		For i = 1 To ll_row
////			If tab_1.idw_tabpage[li_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
////				tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
////				tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()
////			End If
////	   Next
//
//	Case 4
//		lu_check.is_caller 	= "b1w_reg_customer%save_tab4"
//		lu_check.is_title 	= Title
//		lu_check.ii_data[1] 	= li_tab
//		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
//		lu_check.uf_prc_check_4()
//		li_rc = lu_check.ii_rc
//		
//		//필수 항목 오류
//		If li_rc < 0 Then
//			Destroy lu_check
//			Return -2
//		End If
//		
//		//Update Log
//		ll_row = tab_1.idw_tabpage[li_tab].RowCount()
//		For i = 1 To ll_row
//			If tab_1.idw_tabpage[li_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
//				tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
//				tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()
//			End If
//	   Next
//	   
////	Case 9
////		lu_check.is_caller = "b1w_reg_customer%save_tab9"
////		lu_check.is_title = Title
////		lu_check.ii_data[1] = li_tab
////		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
////		lu_check.uf_prc_check_9()
////		li_rc = lu_check.ii_rc
////		
////		//필수 항목 오류
////		If li_rc < 0 Then
////			Destroy lu_check
////			Return -2
////		End If
//
//	Case 10
//		lu_check.is_caller	= "b1w_reg_customer%save_tab10"
//		lu_check.is_title 	= Title
//		lu_check.ii_data[1] 	= li_tab
//		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
//		lu_check.uf_prc_check_10()
//		li_rc = lu_check.ii_rc
//		
//		//필수 항목 오류
//		If li_rc < 0 Then
//			Destroy lu_check
//			Return -2
//		End If
//		
//		//******************************************//
//		
//		Long ll_rows, ll_findrow
//		long ll_i, ll_zoncodcnt
//		String ls_zoncod, ls_tmcod, ls_opendt, ls_priceplan, ls_parttype
//		String ls_date, ls_sort
//		Dec lc_data, lc_frpoint, lc_Ofrpoint
//
//		String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt
//		Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
//		String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
//		Boolean lb_addX, lb_notExist
//		Constant Integer li_MAXTMKIND = 3
//
//		If tab_1.idw_tabpage[li_tab].RowCount()  = 0 Then Return 0
//
//		//  대역/시간대코드/개시일자
//		ls_Ozoncod = ""
//		ls_Otmcod  = ""
//		ls_tmcodX = ""
//		li_tmcodcnt = 0
//		li_cnt_tmkind = 0
//
//		//고객의 priceplan = ALL
//		ls_priceplan = 'ALL'
//
////2005.07.26 ohj 주석처리 서비스, 고객별로 개별요율등록해야하나... 시간없어 입력만 되게히고
// //추후 로직 수정...
////		//arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음
////		li_return = wfl_get_arezoncod(ls_zoncod, ls_arezoncod[])
////		If li_return < 0 Then Return -2
////
////		ll_rows = tab_1.idw_tabpage[li_tab].RowCount()
////		If ll_rows < 1 And UpperBound(ls_arezoncod) < 1 Then Return 0
////
////
////		//정리하기 위해서 Sort
////		tab_1.idw_tabpage[li_tab].SetRedraw(False)
////		ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod, frpoint"
////		tab_1.idw_tabpage[li_tab].SetSort(ls_sort)
////		tab_1.idw_tabpage[li_tab].Sort()
////
////
////		For ll_row = 1 To ll_rows
////			ls_zoncod = Trim(tab_1.idw_tabpage[li_tab].object.zoncod[ll_row])
////			ls_tmcod  = Trim(tab_1.idw_tabpage[li_tab].object.tmcod[ll_row])
////			ls_opendt = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_row], 'yyyymmdd')
////			
////			//시작Point - khpark 추가 -
////			lc_frpoint = tab_1.idw_tabpage[li_tab].Object.frpoint[ll_row]
////			If IsNull(lc_frpoint) Then tab_1.idw_tabpage[li_tab].Object.frpoint[ll_row] = 0
////
////			If tab_1.idw_tabpage[li_tab].Object.frpoint[ll_row] < 0 Then
////				f_msg_usr_err(200, Title, "사용범위는 0보다 커야 합니다.")
////				tab_1.idw_tabpage[li_tab].SetColumn("frpoint")
////				tab_1.idw_tabpage[li_tab].SetRow(ll_row)
////				tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
////				tab_1.idw_tabpage[li_tab].SetRedraw(True)
////				Return -2
////			End If
////	
////			// 1 zoncod가 같으면 
////			If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
////		
////				//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
////				If Mid(ls_tmcod, 2, 1) <> Mid(ls_Otmcod, 2, 1) Then
////					f_msg_usr_err(9000, Title, "동일한 대역은 시간대코드의 구분이 동일해야합니다.")
////					tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
////					tab_1.idw_tabpage[li_tab].SetRow(ll_row)
////					tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
////					tab_1.idw_tabpage[li_tab].SetRedraw(True)
////					Return -2
////	
////				ElseIf ls_tmcod <> ls_Otmcod Then 		//tmcode 같은지 비교	
////					li_tmcodcnt += 1							//tmcod가 다르면 count 1 추가
////				End If	// 2 close						
////	
////			// 1 else	
////			Else
////				//3. zoncod가 같지 않으면 arecod에 있는것 인지 비교.
////				If lb_notExist = False Then
////					lb_notExist = True
////					For ll_i = 1 To UpperBound(ls_arezoncod)
////						If ls_arezoncod[ll_i] = ls_zoncod Then 
////							lb_notExist = False
////							Exit
////						End If
////					Next
////				End If	 // 3 close	
////				If ls_Ozoncod <>  ls_zoncod Then 
////	      		ll_zoncodCnt += 1								// zoncod 코드가 다르면 count 1 추가
////			   End If
////        
////				// 4 zonecod가  바뀌었거나 처음 row 일때
////				// X Preifx 는 "X"가 아니면 다 있어야 한다. 기본이 3개이다
////				If ll_row > 1 Then
////			
////					If ls_tmcodX <> 'X' and Len(ls_tmcodX) <> li_MAXTMKIND Then
////						f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
////						tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
////						tab_1.idw_tabpage[li_tab].SetRow(ll_row - 1)
////						tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row - 1)
////						tab_1.idw_tabpage[li_tab].SetRedraw(True)
////						Return -2
////					End If 
////			
////					li_rtmcnt = -1
////					//이미 Select됐된 시간대인지 Check
////					For li_i = 1 To li_cnt_tmkind
////						If Left(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
////					Next
////		
////					// 5 tmcod에 해당 pricecod 별로 tmcod check
////					If li_rtmcnt < 0 Then
////						li_return = b0fi_chk_tmcod(ls_priceplan, Left(ls_Otmcod, 2), li_rtmcnt, Title)
////						If li_return < 0 Then 
////							tab_1.idw_tabpage[li_tab].SetRedraw(True)
////							Return -2
////						End If
////				
////						li_cnt_tmkind += 1
////						ls_tmkind[li_cnt_tmkind,1] = Left(ls_Otmcod, 2)
////						ls_tmkind[li_cnt_tmkind,2] = String(li_rtmcnt)
////					End If // 5 close
////			
////					//누락된 시간대코드가 없는지 Check
////					If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
////						f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
////						tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
////						tab_1.idw_tabpage[li_tab].SetRow(ll_row - 1)
////						tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row - 1)
////						tab_1.idw_tabpage[li_tab].SetRedraw(True)
////						Return -2
////					End If
////	
////					li_tmcodcnt = 1		//올바르면 tmcod count 초기화 한다. 
////				   ls_tmcodX = ""
////				Else // 4 else	 
////					li_tmcodcnt += 1	// 처음 row 이면 + 1 해준다. 
////			
////				End If // 4 close
////			End If // 1 close ls_Ozoncod = ls_zoncod 조건 
////	
////			// 6 X Prefix "X" 이면 다른것과 같이 쓸 수 없다
////			If Left(ls_tmcod, 1) = 'X' Then
////				If Len(ls_tmcodX) > 0 And ls_tmcodX <> 'X' Then
////					f_msg_usr_err(9000, Title, "모든 시간대는 다른 시간대랑 같이 사용 할 수 없습니다." )
////					tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
////					tab_1.idw_tabpage[li_tab].SetRow(ll_row)
////					tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
////					tab_1.idw_tabpage[li_tab].SetRedraw(True)
////					Return -2
////				ElseIf Len(ls_tmcodX) = 0 Then 
////					ls_tmcodX += Left(ls_tmcod, 1)
////				End If
////			Else
////				lb_addX = True
////				For li_i = 1 To Len(ls_tmcodX)
////					If Mid(ls_tmcodX, li_i, 1) = Left(ls_tmcod, 1) Then lb_addX = False
////				Next
////				If lb_addX Then ls_tmcodX += Left(ls_tmcod, 1)
////			End If				
////	
////			ll_findrow = 0
////			If ls_Ozoncod <> ls_zoncod Or ls_Otmcod <> ls_tmcod Or ls_Oopendt <> ls_opendt Then
////		
////				ll_findrow = tab_1.idw_tabpage[li_tab].Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
////		   	                         "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
////												"' and frpoint = 0", 1, ll_rows)
////
////				If ll_findrow <= 0 Then
////					f_msg_usr_err(9000, Title, "해당 대역/적용개시일/시간대별에 사용범위 0은 필수입력입니다." )		
////					tab_1.idw_tabpage[li_tab].SetColumn("frpoint")
////					tab_1.idw_tabpage[li_tab].SetRow(ll_row)
////					tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
////					tab_1.idw_tabpage[li_tab].SetRedraw(True)
////					return -2
////				End If
////		
////			End If
////		
////			ls_Ozoncod = ls_zoncod
////			ls_Otmcod  = ls_tmcod
////			ls_Oopendt = ls_opendt
////		Next
//
//
////		// zoncod가 하나만 있을경우 
////		If Len(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
////			f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
////			tab_1.idw_tabpage[li_tab].SetFocus()
////			tab_1.idw_tabpage[li_tab].SetRedraw(True)
////			Return -2
////		End If
////
////		li_rtmcnt = -1
////		//이미 Select됐된 시간대인지 Check
////		For li_i = 1 To li_cnt_tmkind
////			If Left(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
////		Next
//
////		//새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
////		If li_rtmcnt < 0 Then
////			li_return = b0fi_chk_tmcod(ls_priceplan, Left(ls_Otmcod, 2), li_rtmcnt, Title)
////			If li_return < 0 Then
////				tab_1.idw_tabpage[li_tab].SetRedraw(True)
////				Return -2
////			End If
////		End If
//
////		//누락된 시간대코드가 없는지 Check
////		If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
////			f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
////			tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
////			tab_1.idw_tabpage[li_tab].SetRow(ll_rows)
////			tab_1.idw_tabpage[li_tab].ScrollToRow(ll_rows)
////			tab_1.idw_tabpage[li_tab].SetRedraw(True)
////			Return -2
////		End If
//
//		//같은 시간대  code error 처리
//		ls_Ozoncod = ""
//		ls_Otmcod  = ""
//		ls_Oopendt = ""
//		lc_Ofrpoint = -1
//		ls_Osvccod = ''
//		For ll_row = 1 To ll_rows
//			ls_svccod 	= fs_snvl(tab_1.idw_tabpage[li_tab].Object.svccod[ll_row], '')
//			ls_zoncod 	= Trim(tab_1.idw_tabpage[li_tab].Object.zoncod[ll_row])
//			ls_opendt 	= String(tab_1.idw_tabpage[li_tab].object.opendt[ll_row],'yyyymmdd')
//			ls_tmcod 	= Trim(tab_1.idw_tabpage[li_tab].Object.tmcod[ll_row])
//			lc_frpoint 	= tab_1.idw_tabpage[li_tab].Object.frpoint[ll_row]
//		
//			If ls_svccod = ls_Osvccod and ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod and lc_frpoint = lc_Ofrpoint Then
//				f_msg_usr_err(9000, Title, "동일한 대역에 같은 시간대에 같은 사용범위가 존재합니다.")
//				tab_1.idw_tabpage[li_tab].SetColumn("frpoint")
//				tab_1.idw_tabpage[li_tab].SetRow(ll_row)
//				tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
//				tab_1.idw_tabpage[li_tab].SetRedraw(True)
//				Return -2
//			End If
//			ls_Ozoncod = ls_zoncod
//			ls_Oopendt = ls_opendt
//			ls_Otmcod = ls_tmcod
//			lc_Ofrpoint = lc_frpoint
//			ls_Osvccod   = ls_svccod
//		Next		
//
////		If lb_notExist Then
////			f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 대역입니다." )
////			//Return -2
////		End If
//
////		If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
////			f_msg_info(9000, Title, "정의된 모든대역에 대해서 요율을 등록해야 합니다.")
////			//Return -2
////		End If
////
//
//		ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
//		tab_1.idw_tabpage[li_tab].SetSort(ls_sort)
//		tab_1.idw_tabpage[li_tab].Sort()
//		tab_1.idw_tabpage[li_tab].SetRedraw(True)
//	
//		//******************************************//
//		
//		//적용종료일 체크
//		For i = 1 To tab_1.idw_tabpage[li_tab].RowCount()
//			ls_opendt = Trim(String(tab_1.idw_tabpage[li_tab].object.opendt[i], 'yyyymmdd'))
//			ls_enddt  = Trim(String(tab_1.idw_tabpage[li_tab].object.enddt[i], 'yyyymmdd'))
//			
//			If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
//			
//			If ls_opendt > ls_enddt Then
//				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//				tab_1.idw_tabpage[li_tab].setColumn("enddt")
//				tab_1.idw_tabpage[li_tab].setRow(i)
//				tab_1.idw_tabpage[li_tab].scrollToRow(i)
//				tab_1.idw_tabpage[li_tab].setFocus()
//				Return -2
//			End If
//		Next
//		
//		//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
//		For ll_rows1 = 1 To tab_1.idw_tabpage[li_tab].RowCount()
//			ls_svccod1     = fs_snvl(tab_1.idw_tabpage[li_tab].Object.svccod[ll_rows1], '')
//			ls_parttype1  = Trim(tab_1.idw_tabpage[li_tab].object.parttype[ll_rows1])
//			ls_partcod1   = Trim(tab_1.idw_tabpage[li_tab].object.partcod[ll_rows1])
//			ls_zoncod1    = Trim(tab_1.idw_tabpage[li_tab].object.zoncod[ll_rows1])
//			ls_tmcod1     = Trim(tab_1.idw_tabpage[li_tab].object.tmcod[ll_rows1])
//			ls_frpoint1   = String(tab_1.idw_tabpage[li_tab].object.frpoint[ll_rows1])
//			ls_areanum1   = Trim(tab_1.idw_tabpage[li_tab].object.areanum[ll_rows1])
//			ls_itemcod1   = Trim(tab_1.idw_tabpage[li_tab].object.itemcod[ll_rows1])
//			ls_opendt1    = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_rows1], 'yyyymmdd')
//			ls_enddt1     = String(tab_1.idw_tabpage[li_tab].object.enddt[ll_rows1], 'yyyymmdd')
//	
//			If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
//	
//			For ll_rows2 = tab_1.idw_tabpage[li_tab].RowCount() To ll_rows1 - 1 Step -1
//				If ll_rows1 = ll_rows2 Then
//					Exit
//				End If
//				ls_svccod2 = fs_snvl(tab_1.idw_tabpage[li_tab].Object.svccod[ll_rows2], '')
//				ls_parttype2 = Trim(tab_1.idw_tabpage[li_tab].object.parttype[ll_rows2])
//				ls_partcod2  = Trim(tab_1.idw_tabpage[li_tab].object.partcod[ll_rows2])
//				ls_zoncod2   = Trim(tab_1.idw_tabpage[li_tab].object.zoncod[ll_rows2])
//				ls_tmcod2    = Trim(tab_1.idw_tabpage[li_tab].object.tmcod[ll_rows2])
//				ls_frpoint2  = String(tab_1.idw_tabpage[li_tab].object.frpoint[ll_rows2])
//				ls_areanum2  = Trim(tab_1.idw_tabpage[li_tab].object.areanum[ll_rows2])
//				ls_itemcod2  = Trim(tab_1.idw_tabpage[li_tab].object.itemcod[ll_rows2])
//				ls_opendt2   = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_rows2], 'yyyymmdd')
//				ls_enddt2    = String(tab_1.idw_tabpage[li_tab].object.enddt[ll_rows2], 'yyyymmdd')
//				
//				If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
//				
//				If (ls_svccod1 = ls_svccod2) and (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_zoncod1 =  ls_zoncod2) &
//					And (ls_tmcod1 = ls_tmcod2) And (ls_frpoint1 = ls_frpoint2) And (ls_areanum1 = ls_areanum2) And (ls_itemcod1 = ls_itemcod2) Then
//					
//					If ls_enddt1 >= ls_opendt2 Then
//						f_msg_info(9000, Title, "같은 서비스 [ " + ls_svccod1 + "], 같은 대역[ " + ls_zoncod1 + " ], 같은 착신지번호[ " + ls_areanum1 + " ], 같은 시간대[ " + ls_tmcod1 + " ], " &
//														+ "같은 사용범위[ " + ls_frpoint1 + " ], 같은 품목[ " + ls_itemcod1 + " ]으로 적용개시일이 중복됩니다.")
//						Return -1
//					End If
//				End If
//				
//			Next
//		Next
//
//		
//		//Update Log
//		ll_row = tab_1.idw_tabpage[li_tab].RowCount()
//		For i = 1 To ll_row
//			If tab_1.idw_tabpage[li_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
//				tab_1.idw_tabpage[li_tab].object.updt_user[i] = gs_user_id
//				tab_1.idw_tabpage[li_tab].object.updtdt[i] = fdt_get_dbserver_now()
//			End If
//	   Next
//		
//	Case 11
//		lu_check.is_caller = "b1w_reg_customer%save_tab11"
//		lu_check.is_title = Title
//		lu_check.ii_data[1] = li_tab
//		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
//		lu_check.uf_prc_check_11()
//		li_rc = lu_check.ii_rc
//		
//		//필수 항목 오류
//		If li_rc < 0 Then
//			Destroy lu_check
//			Return -2
//		End If
//		
//		//적용종료일 체크
//		For i = 1 To tab_1.idw_tabpage[li_tab].RowCount()
//			ls_opendt = Trim(String(tab_1.idw_tabpage[li_tab].object.opendt[i], 'yyyymmdd'))
//			ls_enddt  = Trim(String(tab_1.idw_tabpage[li_tab].object.enddt[i], 'yyyymmdd'))
//			
//			If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
//			
//			If ls_opendt > ls_enddt Then
//				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//				tab_1.idw_tabpage[li_tab].setColumn("enddt")
//				tab_1.idw_tabpage[li_tab].setRow(i)
//				tab_1.idw_tabpage[li_tab].scrollToRow(i)
//				tab_1.idw_tabpage[li_tab].setFocus()
//				Return -2
//			End If
//		Next
//		
//		//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
//		For ll_rows = 1 To tab_1.idw_tabpage[li_tab].RowCount()
//			ls_parttype1 = Trim(tab_1.idw_tabpage[li_tab].object.parttype[ll_rows])
//			ls_partcod1  = Trim(tab_1.idw_tabpage[li_tab].object.partcod[ll_rows])
//			ls_areanum1  = Trim(tab_1.idw_tabpage[li_tab].object.areanum[ll_rows])
//			ls_opendt1   = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_rows], 'yyyymmdd')
//			ls_enddt1    = String(tab_1.idw_tabpage[li_tab].object.enddt[ll_rows], 'yyyymmdd')
//			
//			If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
//			
//			For ll_rows1 = tab_1.idw_tabpage[li_tab].RowCount() To ll_rows - 1 Step -1
//				If ll_rows = ll_rows1 Then
//					Exit
//				End If
//				ls_parttype2 = Trim(tab_1.idw_tabpage[li_tab].object.parttype[ll_rows1])
//				ls_partcod2  = Trim(tab_1.idw_tabpage[li_tab].object.partcod[ll_rows1])
//				ls_areanum2  = Trim(tab_1.idw_tabpage[li_tab].object.areanum[ll_rows1])
//				ls_opendt2   = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_rows1], 'yyyymmdd')
//				ls_enddt2    = String(tab_1.idw_tabpage[li_tab].object.enddt[ll_rows1], 'yyyymmdd')
//				
//				If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
//				
//				If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_areanum1 = ls_areanum2) Then
//					If ls_enddt1 >= ls_opendt2 Then
//						f_msg_info(9000, Title, "같은 제한번호[ " + ls_areanum1 + " ]로 적용개시일이 중복됩니다.")
//						Return -1
//					End If
//				End If
//				
//			Next
//			
//		Next
//
//
//		//Update Log
//		ll_row = tab_1.idw_tabpage[li_tab].RowCount()
//		For i = 1 To ll_row
//			If tab_1.idw_tabpage[li_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
//				tab_1.idw_tabpage[li_tab].object.updt_uer[i] = gs_user_id
//				tab_1.idw_tabpage[li_tab].object.updtdt[i] = fdt_get_dbserver_now()
//			End If
//	   Next
//		
//End Choose
//
//If ib_billing = True	 Then ib_billing = False
//		
Return 0
end event

event ue_save;////Override
//Constant Int LI_ERROR = -1
//Int li_tab_index, li_return
//
//li_tab_index = tab_1.SelectedTab
//
//If tab_1.idw_tabpage[li_tab_index].AcceptText() < 0 Then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = tab_1.is_parent_title
//
//	iu_cust_db_app.uf_prc_db()
//
//	If iu_cust_db_app.ii_rc = -1 Then
//		tab_1.idw_tabpage[li_tab_index].SetFocus()
//		Return LI_ERROR
//	End If
//
//	tab_1.SelectedTab = li_tab_index
//	tab_1.idw_tabpage[li_tab_index].SetFocus()
//	Return LI_ERROR
//End If
//
//li_return = Trigger Event ue_extra_save(li_tab_index)
//Choose Case li_return
//	Case -3
//		ib_billing = True 	
//	Case -2
//		//필수항목 미입력
//		tab_1.idw_tabpage[li_tab_index].SetFocus()
//		Return -2
//	Case -1
//		//ROLLBACK와 동일한 기능
//		iu_cust_db_app.is_caller = "ROLLBACK"
//		iu_cust_db_app.is_title = tab_1.is_parent_title
//		iu_cust_db_app.uf_prc_db()
//		If iu_cust_db_app.ii_rc = -1 Then
//			ib_update = False
//			Return -1
//		End If
//
//		f_msg_info(3010, tab_1.is_parent_title, "Save")
//		ib_update = False
//		Return -1
//End Choose
//
//IF li_tab_index = 1 AND is_check <> "DEL" THEN
//	// payid에 공백 안들어가게.. added by hcjung 2007-08-09
//	tab_1.idw_tabpage[li_tab_index].object.payid[1] = trim(tab_1.idw_tabpage[li_tab_index].object.payid[1])
//END IF
//
//If tab_1.idw_tabpage[li_tab_index].Update(True,False) < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = tab_1.is_parent_title
//	iu_cust_db_app.uf_prc_db()
//	If iu_cust_db_app.ii_rc = -1 Then
//		tab_1.idw_tabpage[li_tab_index].SetFocus()
//		Return LI_ERROR
//	End If
//
//	tab_1.SelectedTab = li_tab_index
//	tab_1.idw_tabpage[li_tab_index].SetFocus()
//	f_msg_info(3010,tab_1.is_parent_title,"Save")
//	Return LI_ERROR
//End If
//
////COMMIT와 동일한 기능
//iu_cust_db_app.is_caller = "COMMIT"
//iu_cust_db_app.is_title = tab_1.is_parent_title
//iu_cust_db_app.uf_prc_db()
//If iu_cust_db_app.ii_rc = -1 Then
//	Return LI_ERROR
//End If
//
//tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
//f_msg_info(3000,tab_1.is_parent_title,"Save")
//
////cuesee
////저장 되어있으므로
//String ls_customerid, ls_payid
//Int li_rc, li_selectedTab
//Long ll_row, ll_tab_rowcount, ll_master_row
//Boolean lb_check2
//
//li_selectedTab = tab_1.SelectedTab
//If li_selectedTab = 1 Then						//Tab 1
//	
//	//신규등록
//	If ib_new Then
//		ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
//		If ll_tab_rowcount < 1 Then Return 0
//		dw_cond.Reset()
//		dw_cond.InsertRow(0)
//		ls_customerid 						= tab_1.idw_tabpage[1].object.customerid[1]
//		dw_cond.object.customerid[1] 	= ls_customerid 
//		dw_cond.object.memberid[1] 	= tab_1.idw_tabpage[1].object.memberid[1]
//		
////		dw_cond.object.name[1] = ls_customerid
//		TriggerEvent("ue_ok")
//		tab_1.SelectedTab = 2
//		ib_new = False
//	End If
//	
//	//청구 정보를 입력하게 한다.	
//	If ib_billing Then						
//		ll_master_row = dw_master.GetSelectedRow(0)
//		If ll_master_row <> 0 Then
//			ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
//			
//			//wfi_get_ctype3(ls_customerid, lb_check1)
//			wfi_get_payid(ls_customerid, lb_check2)
//
//			If Not (lb_check2) Then
//				tab_1.SelectedTab = 2
//				TriggerEvent("ue_insert")
//				p_insert.TriggerEvent("ue_disable") 		
//			End If
//		End If
//  End If
//  
//ElseIf li_selectedTab = 2 Then	
//	
//	tab_1.idw_tabpage[2].Reset()
//	tab_1.ib_tabpage_check[2] = False
//	
//	tab_1.Trigger Event SelectionChanged(2, 2)
// 
//End If
//
//If is_check = "DEL" Then	//Delete 
//	If  li_selectedTab = 1 Then
//		 TriggerEvent("ue_reset")
//
//		 is_check = ""
//	End If
//End If
//
Return 0
end event

event ue_extra_delete;//Delete
Integer li_tab

li_tab = tab_1.SelectedTab
If li_tab = 1 Then
  is_check = "DEL"
End If
Return 0 
end event

event type integer ue_delete();Constant Int LI_ERROR = -1
Long ll_row, ll_exist
String ls_rectype


If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End If

If tab_1.Selectedtab = 4 Then
	If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
		ll_row = tab_1.idw_tabpage[tab_1.SelectedTab].GetRow()
	   If ll_row <= 0 Then Return 0
		
		tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
		tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
		
		//delete 버튼 비활성화
		ll_exist = tab_1.idw_tabpage[tab_1.SelectedTab].Find("rectype = 'C'", 1, &
					tab_1.idw_tabpage[tab_1.SelectedTab].RowCount())
		
		If ll_exist = 0 Then
			p_delete.TriggerEvent("ue_disable")
		Else
			p_delete.TriggerEvent("ue_enable")
		End If
	End if
Else
	If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
	   	tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
		tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
	End if
End If

Return 0

end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//

CALL w_a_m_master::resize

Integer	li_index

If sizetype = 1 Then Return

SetRedraw(False)
// Call the resize functions
of_ResizeBars()
of_ResizePanels()

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	p_insert.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_view.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_active.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_active_mobile.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	cb_comment.Y= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 250
	Next


	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_view.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_active.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_active_mobile.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	cb_comment.Y= newheight - iu_cust_w_resize.ii_button_space_1	
End If

If newwidth < tab_1.X  Then
	tab_1.Width = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = 0
	Next
Else
	tab_1.Width = newwidth - tab_1.X - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = tab_1.Width - 50
	Next
End If



SetRedraw(True)

end event

event ue_insert;//Constant Int LI_ERROR = -1
//String 	ls_cusid, 	ls_cusnm
//Long 		ll_row,  	ll_master_row
//Integer 	li_curtab
////Int li_return
//
//ll_master_row = dw_master.GetSelectedRow(0)
//If ll_master_row < 0 Then Return -1
//
//li_curtab = tab_1.Selectedtab
//
//If li_curtab = 3 Then
////		ls_cusid = Trim(dw_master.object.customerm_customerid[ll_master_row])
////		ls_cusnm = Trim(dw_master.object.customerm_customernm[ll_master_row])
////
////		iu_cust_msg = Create u_cust_a_msg
////		iu_cust_msg.is_pgm_name = "인증정보 INSERT"
////		iu_cust_msg.is_grp_name = "고객등록"
////		iu_cust_msg.is_data[1] = ls_cusid			   //고객 ID
////		iu_cust_msg.is_data[2] = ls_cusnm            //고객명
////		iu_cust_msg.is_data[3] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
////	
////		OpenWithParm(b1w_reg_validinfo_popup, iu_cust_msg)
////
////		If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, 3) < 0 Then
////			Return -1
////		End If
////
////		tab_1.ib_tabpage_check[3] = True
//
//ElseIf li_curtab = 13 Then
//	ls_cusid = Trim(dw_master.object.customerm_customerid[ll_master_row])
//	ls_cusnm = Trim(dw_master.object.customerm_customernm[ll_master_row])
//	
//	iu_cust_msg = Create u_cust_a_msg
//	iu_cust_msg.is_pgm_name = "민원접수"
//	iu_cust_msg.is_grp_name = "고객등록"
//	iu_cust_msg.is_data[1] = "Insert"
//	iu_cust_msg.is_data[2] = ls_cusid
//	iu_cust_msg.is_data[3] = ls_cusnm
//	
//	//	Popup window open
//	OpenWithParm(b1w_reg_customertrouble_sub_v20, iu_cust_msg)
//	
//	//	Insert후 tab retrieve
//	If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, 13) < 0 Then
//		Return -1
//	End If
//	
//	tab_1.ib_tabpage_check[13] = true
//	
//Else
//	
//		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)
//		
//		tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
//		tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
//		tab_1.idw_tabpage[li_curtab].SetFocus()
//		
//		If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
//			Return LI_ERROR
//		End if
//	
//End if
//
////ii_error_chk = 0
Return 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within w_term_cust_info
integer x = 82
integer y = 52
integer width = 3282
integer height = 212
string dataobject = "d_cnd_term_cust_info"
end type

event dw_cond::clicked;call super::clicked;String ls_selectcod

Choose Case dwo.Name
	Case "location"
		ls_selectcod = This.Object.value_1[row]
		If IsNull(ls_selectcod) or ls_selectcod = "" Then
			 f_msg_usr_err(9000, parent.Title, "지역분류 선택을 먼저 선택하세요!")
			 return -1
		End If
	Case "name"
		   ls_selectcod = This.Object.value[row]
			If IsNull(ls_selectcod) or ls_selectcod = "" Then
			 f_msg_usr_err(9000, parent.Title, "조건항목을 먼저 선택하세요!")
			 return -1
		End If
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;CHOOSE CASE dwo.name
	case 'new'
		tab_1.SelectedTab 	= 1		//Tab 1 Select	
		tab_1.Enabled 			= True
		tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
		
		
	case else
end choose


//
////분류선택에서 대분류, 중분류, 소분류를 선택함에 따라 location 컬럼의 dddw를 바꾼다.
//Choose Case dwo.Name
//	Case "value_1"
//		Choose Case data
//			Case "A"         //소분류
//				is_select_cod = "locationA"
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1c_dddw_locategorya")
//				Modify("location.dddw.DataColumn='locategorya_locategorya'")
//				Modify("location.dddw.DisplayColumn='locategorya_locategoryanm'")
//				
//			Case "B"			//중분류
//				is_select_cod = "locationB"				
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1c_dddw_locategoryb")
//				Modify("location.dddw.DataColumn='locategoryb_locategoryb'")
//				Modify("location.dddw.DisplayColumn='locategoryb_locategorybnm'")
//				 
//			Case "C"			//대분류
//				is_select_cod = "locationC"				
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1c_dddw_locategoryc")
//				Modify("location.dddw.DataColumn='locategoryc'")
//				Modify("location.dddw.DisplayColumn='locategorycnm'")
//			Case "L"
//				is_select_cod = "locationL"				
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1dc_dddw_location")
//				Modify("location.dddw.DataColumn='location'")
//				Modify("location.dddw.DisplayColumn='locationnm'")
//				
//			Case else					//분류선택 안했을 경우...
//				is_select_cod = ""				
//				Modify("location.dddw.name=''")
//				This.Object.location[row] = ''
//		End Choose
//End Choose
//
//Return 0
end event

type p_ok from w_a_reg_m_tm2`p_ok within w_term_cust_info
integer x = 3429
integer y = 40
end type

type p_close from w_a_reg_m_tm2`p_close within w_term_cust_info
integer x = 3730
integer y = 40
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within w_term_cust_info
integer x = 37
integer width = 3365
integer height = 276
end type

type dw_master from w_a_reg_m_tm2`dw_master within w_term_cust_info
integer y = 312
integer width = 3534
integer height = 656
string dataobject = "d_inq_term_cust_info1"
end type

event dw_master::ue_init;call super::ue_init;
dwObject ldwo_SORT
ldwo_SORT = this.Object.customerm_memberid_t
//customerm_customernm_t
uf_init(ldwo_SORT)
end event

event dw_master::clicked;//Override
Integer li_SelectedTab
Long ll_selected_row
Long ll_old_selected_row
Int li_tab_index,li_rc

String ls_customerid
Boolean lb_check1, lb_check2

ll_old_selected_row = This.GetSelectedRow(0)

Call w_a_m_master`dw_master::clicked

li_SelectedTab = tab_1.SelectedTab
ll_selected_row 	= This.GetSelectedRow(0)
il_mst_row 			=  ll_selected_row

//Override - w_a_reg_m_tm2

//CUSTOMER.LOG 에 기록 남기기...
IF ll_selected_row > 0 THEN
	ls_customerid = This.Object.customerm_customerid[ll_selected_row]
	
	INSERT INTO TERMCUST.CUSTOMER_LOG
		( EMP_ID, ACTION, TIMESTAMP, CUSTOMERID )
	VALUES
		( :gs_user_id, 'CLICK', SYSDATE, :ls_customerid );
	
	IF sqlca.sqlcode < 0 THEN
		ROLLBACK;
	ELSE
		COMMIT;
	END IF		
END IF

If (tab_1.idw_tabpage[li_SelectedTab].ModifiedCount() > 0) or &
	(tab_1.idw_tabpage[li_SelectedTab].DeletedCount() > 0)	Then

// 확인 메세지 두번 나오는 문제 해결(tab_1)
//	tab_1.SelectedTab = li_tab_index
//	li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.!" + &
//		"Do you want to cancel?",Question!,YesNo!)
	If li_rc <> 1 Then
		If ll_selected_row > 0 Then
			SelectRow(ll_selected_row ,FALSE)
		End If
		SelectRow(ll_old_selected_row , TRUE )
		ScrollToRow(ll_old_selected_row)
		tab_1.idw_tabpage[li_SelectedTab].SetFocus()
		Return 
	End If
End If
		
tab_1.idw_tabpage[li_SelectedTab].Reset()
tab_1.ib_tabpage_check[li_SelectedTab] = False

// Button Enable Or Disable
tab_1.Trigger Event SelectionChanged(li_SelectedTab, li_SelectedTab)	

Return 0




end event

type p_insert from w_a_reg_m_tm2`p_insert within w_term_cust_info
boolean visible = false
integer y = 2200
end type

type p_delete from w_a_reg_m_tm2`p_delete within w_term_cust_info
boolean visible = false
integer y = 2200
end type

type p_save from w_a_reg_m_tm2`p_save within w_term_cust_info
boolean visible = false
integer x = 622
integer y = 2200
end type

type p_reset from w_a_reg_m_tm2`p_reset within w_term_cust_info
integer x = 1207
integer y = 2200
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within w_term_cust_info
string tag = "thisbackcolor"
integer y = 1028
integer width = 3534
integer height = 1160
boolean enabled = false
fontcharset fontcharset = ansi!
end type

event tab_1::ue_init;call super::ue_init;String    ls_code, ls_codenm, ls_yn, ls_dwnm
long    ll_chk, ll_cnt, i, ll_num, ll_n

//start - 고객정보 텝정보를 테이블에서 읽어드림. jwlee - 2005.12.13

DECLARE CUSTOMER_cur CURSOR FOR
	  SELECT CODE,
                 CODENM,
                 DWNM,
                 USE_YN
          FROM TERMCUST.TABINFO
         WHERE GUBUN = 'term_cust_info'
        ORDER  BY 1,2; 
	
OPEN CUSTOMER_cur;

DO WHILE SQLCA.SQLCODE = 0
	
	FETCH CUSTOMER_cur 
	 INTO  :ls_code    ,
			 :ls_codenm  ,
			 :ls_dwnm    ,
			 :ls_yn      ;
			 
	If sqlca.sqlcode <> 0 then
		exit;
	end if
	
	ll_cnt ++
	//Tab 초기화
	//Tab Title
		is_tab_title[ll_cnt] = ls_codenm
		is_dwObject[ll_cnt]  = ls_dwnm
LOOP 
CLOSE CUSTOMER_cur;
//end

////Tab 초기화
ii_enable_max_tab = ll_cnt		//Tab 갯수


end event

event tab_1::ue_tabpage_retrieve;call super::ue_tabpage_retrieve;//Tab Retrieve
DataWindowChild ldc
String 	ls_customerid, ls_payid, ls_zoncod, ls_priceplan, ls_contractseq, ls_validkey
String 	ls_where, ls_filter, ls_type, ls_desc
Long 		ll_row, i, ll_cnt, ll_rowcount, ll_exist
Integer 	li_rc, li_tab
Boolean 	lb_check
Dec     	lc_data, ldc_contractseq, ldc_balance
string ls_soldier_yn, ls_onoff_base

//b1u_check	lu_check
//lu_check = Create b1u_check

b1u_check1_v20		lu_check
lu_check = Create b1u_check1_v20

li_tab 	= ai_select_tabpage
If al_master_row = 0 Then Return -1

ls_customerid 	= Trim(dw_master.object.customerm_customerid[al_master_row])
ls_payid 		= Trim(dw_master.object.customerm_payid[al_master_row])
//ls_validkey = Trim(dw_master.object.validinfo_validkey[al_master_row])

Choose Case li_tab
	Case 1								//Tab 1	
		ls_where 		= "customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		

		ll_row 			= idw_tabpage[li_tab].Retrieve()
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		SELECT NVL(SUM(DECODE(B.IN_YN, 'N', A.TRAMT, 0)) + SUM(DECODE(B.IN_YN, 'Y', A.TRAMT, 0)), 0)
		INTO	 :ldc_balance
		FROM   SAMS.REQDTL A, SAMS.TRCODE B
		WHERE  A.PAYID = :ls_payid
		AND    A.TRDT <= TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD')
		AND    A.TRCOD = B.TRCOD;
		
		tab_1.idw_tabpage[li_tab].object.balance[1] = ldc_balance	
		
		tab_1.idw_tabpage[li_tab].SetItemStatus(1, 0, Primary!, NotModified!)
		
		lu_check.is_caller   = "b1w_reg_customer_v20%inq_customer_tab1"
		lu_check.is_title    = Title
		lu_check.ii_data[1]  = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]		
		//lu_check.uf_prc_check()
//		li_rc = lu_check.ii_rc
//		If li_rc < 0 Then 
//			Destroy 	lu_check
//			Return 	li_rc
//		End If
//		
		//logid의 데이터가 없을경우
		String ls_logid
		ls_logid 		= tab_1.idw_tabpage[li_tab].object.logid[1]
		If IsNull(ls_logid) Then ls_logid = ""
		
		If ls_logid <> "" Then
			tab_1.idw_tabpage[li_tab].object.logid.Pointer 	= "Arrow!"
			tab_1.idw_tabpage[li_tab].idwo_help_col[1] 		= idw_tabpage[ai_select_tabpage].object.crt_user
		Else
			tab_1.idw_tabpage[li_tab].object.logid.Pointer 	= "help!"
			tab_1.idw_tabpage[li_tab].idwo_help_col[1] 		= idw_tabpage[ai_select_tabpage].object.logid
		End If
		is_payid_old = tab_1.idw_tabpage[li_tab].object.payid[1]
		

		
		//2005-12-14 kem modify start
		//신청내역 존재하면 고객 삭제 불가능...
//		SELECT NVL(COUNT(ORDERNO),0)  INTO :ll_exist  FROM SAMS.SVCORDER
//		 WHERE CUSTOMERID = :ls_customerid;
//		
//		If ll_exist = 0 Then
//			p_delete.TriggerEvent("ue_enable")
//		Else
//			p_delete.TriggerEvent("ue_disable")
//		End If
//		//kem end
		
	Case 2
		
		//선불 고객인지 확인
//		wfi_get_ctype3(ls_customerid, ib_ctype3)
//		If ib_ctype3 Then
//		   idw_tabpage[li_tab].Reset()
//			Return 0		//조회하지 않는다.
//		End If	
		  
		//고객과 납입자가 다를 경우
//		wfi_get_payid(ls_customerid,lb_check)
//		If lb_check Then
//			idw_tabpage[li_tab].Reset()
//			Return 0		//조회하지 않는다.
//		End If
		
		ls_where 		= "customerm_a.customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row 			= idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
		
		//origin data
		is_pay_method_ori 	= tab_1.idw_tabpage[li_tab].object.pay_method[1]
		is_bank_ori 			= tab_1.idw_tabpage[li_tab].object.bank[1]
		is_acctno_ori 			= tab_1.idw_tabpage[li_tab].object.acctno[1]
		is_acct_owner_ori 	= tab_1.idw_tabpage[li_tab].object.acct_owner[1]
		is_acct_ssno_ori 		= tab_1.idw_tabpage[li_tab].object.acct_ssno[1]			
		is_drawingresult_ori = tab_1.idw_tabpage[li_tab].object.drawingresult[1]
		is_drawingtype_ori 	= tab_1.idw_tabpage[li_tab].object.drawingtype[1]
		id_drawingreqdt_ori 	= tab_1.idw_tabpage[li_tab].object.drawingreqdt[1]
		id_receiptdt_ori 		= tab_1.idw_tabpage[li_tab].object.receiptdt[1]
		is_resultcod_ori 		= tab_1.idw_tabpage[li_tab].object.resultcod[1]		
		is_receiptcod_ori		= tab_1.idw_tabpage[li_tab].object.receiptcod[1]			

		If is_drawingtype_ori 	= is_drawingtype[3] and &
		   is_drawingresult_ori = is_drawingresult[2] Then
			is_bank_chg_ori 		= 'Y' 
        	tab_1.idw_tabpage[li_tab].object.bank_chg[1]  = 'Y'
			tab_1.idw_tabpage[li_tab].SetitemStatus(1, "bank_chg", Primary!, NotModified!)   //수정 안되었다고 인식.				
			is_bank_bef 			= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_bank[1]
			is_acctno_bef 			= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acctno[1]
			is_acct_owner_bef 	= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_owner[1]
			is_acct_ssno_bef 		= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_ssno[1]			
			is_drawingresult_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingresult[1]
			is_drawingtype_bef 	= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingtype[1]
			id_drawingreqdt_bef 	= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingreqdt[1]
			id_receiptdt_bef 		= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptdt[1]
			is_resultcod_bef 		= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_resultcod[1]		
			is_receiptcod_bef		= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptcod[1]
		End If
		
		wf_paymethod_chg_check()
		
		lu_check.is_caller   = "b1w_reg_customer_d_v20%inq_customer_tab2"
		lu_check.is_title    = Title
		lu_check.ii_data[1]  = li_tab
		lu_check.is_data[1] 	= is_method
		lu_check.is_data[2] 	= is_credit
		lu_check.is_data[3] 	= is_inv_method
		lu_check.is_data[4] 	= is_chg_flag
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]		
//		lu_check.uf_prc_check_11()
//		li_rc = lu_check.ii_rc
//		If li_rc < 0 Then 
//			Destroy lu_check
//			Return li_rc
//		End If
	   //화폐
	   is_currency_old = tab_1.idw_tabpage[li_tab].object.billinginfo_currency_type[1]
// 	Case 3
//	    ll_row = idw_tabpage[li_tab].Retrieve(ls_customerid)	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//		
//	Case 4 
//		ls_where = "customer_hw.customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//		
//	Case 5
//		ls_where = "customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//	Case 6
//		ls_where = "customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//	Case 7
//		ls_where = "sus.customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//   
// 	Case 8
//		ls_where = "quo.customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//	
////	//국가별할인
////	Case 9
////		ls_where = "customerid = '" + ls_customerid + "' "
////		idw_tabpage[li_tab].is_where = ls_where		
////		ll_row = idw_tabpage[li_tab].Retrieve()	
////		If ll_row < 0 Then
////			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
////			Return -1
////		ElseIf ll_row = 0 Then 
////			Return 0 		//해당자료 없는것
////		End If 
//		
//	//선불충전로그
//	Case 9
//		ls_where = " r.customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If 
//		
//	//대역별요율
//	Case 10
//		ls_where = " partcod = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where
//		ll_row = idw_tabpage[li_tab].Retrieve()
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//		
//		ls_type = fs_get_control("B1", "Z100", ls_desc)
//		
//		If ls_type = "0" Then
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0"
//			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0"
//		ElseIf ls_type = "1" Then
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0.0"
//			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0.0"
//		ElseIf ls_type = "2" Then
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0.00"
//			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0.00"
//		ElseIF ls_type = "3" Then
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0.000"
//			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0.000"
//		Else
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0.0000"
//		End If
//		
//		For i =1 To tab_1.idw_tabpage[10].RowCount()
//	   	lc_data = tab_1.idw_tabpage[10].object.unbilsec[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unbilsec[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.confee[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.confee[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitfee1[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee1[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.tmrange1[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange1[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitsec1[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec1[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitfee2[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee2[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.tmrange2[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange2[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitsec2[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec2[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitfee3[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee3[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.tmrange3[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange3[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitsec3[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec3[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitfee4[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee4[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.tmrange4[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange4[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitsec4[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec4[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitfee5[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee5[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.tmrange5[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange5[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.unitsec5[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec5[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitfee1[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee1[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.mtmrange1[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange1[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitsec1[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec1[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitfee2[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee2[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.mtmrange2[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange2[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitsec2[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec2[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitfee3[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee3[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.mtmrange3[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange3[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitsec3[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec3[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitfee4[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee4[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.mtmrange4[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange4[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitsec4[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec4[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitfee5[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee5[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.mtmrange5[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange5[i] = 0
//			lc_data = tab_1.idw_tabpage[10].object.munitsec5[i]
//			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec5[i] = 0	 
//			
//			tab_1.idw_tabpage[10].SetItemStatus(i, 0, Primary!, NotModified!)
//		Next
//
//	//Daily Payment
//	Case 11
//		ls_where = " customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//		
//	Case 12
//		ls_where = "customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If		
//		
//	Case 13
//		ls_where = "customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If		
////2010.01.28 jhchoi 주석처리		
////	Case 14
////		
//////		select contractseq
//////		into  :ldc_contractseq
//////		from  validinfo
//////		where customerid =:ls_customerid and validkey =:ls_validkey;
//////		
//////				
//////     dw_master.object.validinfo_contractseq[al_master_row] = ldc_contractseq
//////	  
//////	  ls_contractseq = Trim(String(dw_master.object.validinfo_contractseq[al_master_row]))
////		
////		ls_where = "c.customerid = '" + ls_customerid + "' "
////		idw_tabpage[li_tab].is_where = ls_where
////		ll_row = idw_tabpage[li_tab].Retrieve()
////		If ll_row < 0 Then
////			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
////			Return -1
////		ElseIf ll_row = 0 Then
////			Return 0
////		End If
//		
//	Case 14, 15		
//		ll_row = idw_tabpage[li_tab].Retrieve(ls_customerid)
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If
//		
End Choose

Destroy lu_check

Return 0

end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row, ll_exist
String ls_customerid, ls_payid, ls_type, ls_desc, ls_tab
Boolean lb_check2


ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 
	
ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()

//Sort 정렬 click 했을때
If ll_master_row = 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_disable")
	p_view.TriggerEvent("ue_disable")	
    Return 0
End If

//선불 고객 이거나 납입고객 아닌 경우
ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
//wfi_get_ctype3(ls_customerid, lb_check1)
//wfi_get_payid(ls_customerid, lb_check2)

//CUSTOMER.LOG 에 기록 남기기...
//IF newindex = 1 OR newindex = 2 THEN
//	IF newindex = 1 THEN ls_tab = 'TAB1'
//	IF newindex = 2 THEN ls_tab = 'TAB2'
//	
//	INSERT INTO CUSTOMER_LOG
//		( EMP_ID, ACTION, TIMESTAMP, CUSTOMERID )
//	VALUES
//		( :gs_user_id, :ls_tab, SYSDATE, :ls_customerid );
//	
//	IF sqlca.sqlcode < 0 THEN
//		ROLLBACK;
//	ELSE
//		COMMIT;
//	END IF		
//END IF

//Choose Case newindex
//	Case 1
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")	
//		
//		//2005-12-14 kem modify start
//		//신청내역 존재하면 고객 삭제 불가능...
//		SELECT NVL(COUNT(ORDERNO),0)
//		  INTO :ll_exist
//		  FROM SAMS.SVCORDER
//		 WHERE CUSTOMERID = :ls_customerid;
//		
//		If ll_exist = 0 Then
//			p_delete.TriggerEvent("ue_enable")
//		Else
//			p_delete.TriggerEvent("ue_disable")
//		End If
//		// kem end
//		
//	Case 2		//Billing 정보
//		
//		//신규 납입 고객은 반드시 청구정보 존재
//		//그래서 reset 할 수 없다.
//		If ll_tab_row > 0  Then
//			p_insert.TriggerEvent("ue_disable") 		
//			p_delete.TriggerEvent("ue_disable")
//			p_save.TriggerEvent("ue_enable")
//			p_reset.TriggerEvent("ue_enable")	
//			p_view.TriggerEvent("ue_enable")		
//		Else
//			p_insert.TriggerEvent("ue_enable") 		
//			p_delete.TriggerEvent("ue_disable")
//			p_save.TriggerEvent("ue_enable")
//			p_reset.TriggerEvent("ue_enable")
//			p_view.TriggerEvent("ue_enable")		
//		End If
//	Case 3		//인증 정보
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_enable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")
//	Case 4		//H/W 정보								
//		p_insert.TriggerEvent("ue_enable")
//		p_delete.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")	
//	Case 5		//신청정보										
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")		
//	Case 6		//계약정보
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")		
//	Case 7		//일시정지 기간 정보
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")		
//	Case 8		//할부 계약 정보
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")	
//	Case 9		//선불충전로그
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")
//	Case 10     //대역별 요율등록
//		p_insert.TriggerEvent("ue_enable")
//		p_delete.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")
//		
//		ls_type = fs_get_control("B1", "Z100", ls_desc)
//		
//		If ls_type = "0" Then
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0"
//		ElseIf ls_type = "1" Then
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.0"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.0"
//		ElseIf ls_type = "2" Then
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.00"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.00"
//		ElseIF ls_type = "3" Then
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.000"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.000"
//		Else
//			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.0000"
//			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.0000"
//		End If
//		
//	Case 11     //Sales Log
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")
//	Case 13
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_disable")	
//		
//	Case 14
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_disable")
		
//End Choose

Return 0
	
end event

event tab_1::constructor;call super::constructor;Integer li_exist
//DataWindowChild ldc_priceplan
//help Window
//idw_tabpage[1].is_help_win[1] 		= "b1w_hlp_logid_1"
//idw_tabpage[1].idwo_help_col[1] 		= idw_tabpage[1].Object.logid
//idw_tabpage[1].is_data[1] 				= "CloseWithReturn"
//
//idw_tabpage[1].is_help_win[2] 		= "b1w_hlp_payid"
//idw_tabpage[1].idwo_help_col[2] 		= idw_tabpage[1].Object.payid
//idw_tabpage[1].is_data[2] 				= "CloseWithReturn"
//
//idw_tabpage[1].is_help_win[3] 		= "w_hlp_post"
//idw_tabpage[1].idwo_help_col[3] 		= idw_tabpage[1].Object.zipcode
//idw_tabpage[1].is_data[3] 				= "CloseWithReturn"
//
//idw_tabpage[2].is_help_win[1] 		= "w_hlp_post"
//idw_tabpage[2].idwo_help_col[1] 		= idw_tabpage[2].Object.bil_zipcod
//idw_tabpage[2].is_data[1] 				= "CloseWithReturn"
//
//idw_tabpage[2].is_help_win[4] = "w_hlp_post"
//idw_tabpage[2].idwo_help_col[4] = idw_tabpage[2].Object.bil_zipcod
//idw_tabpage[2].is_data[4] = "CloseWithReturn"

//가로로 출력 
//tab_1.idw_tabpage[3].object.datawindow.print.orientation = 1
//tab_1.idw_tabpage[4].object.datawindow.print.orientation = 1
//tab_1.idw_tabpage[5].object.datawindow.print.orientation = 1
//tab_1.idw_tabpage[6].object.datawindow.print.orientation = 1
//tab_1.idw_tabpage[12].object.datawindow.print.orientation = 1

//li_exist = tab_1.idw_tabpage[3].GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")

//ldc_priceplan.SetTransObject(SQLCA)
//ldc_priceplan.Retrieve("I")
//start - 선택한 정보의 텝만 보이게 함. jwlee - 2005.12.13
String    ls_code, ls_codenm, ls_yn, ls_dwnm
long      ll_chk, ll_cnt, ll_num, ll_n


DECLARE CUSTOMER_cur CURSOR FOR
	  SELECT CODE,
                 CODENM,
                 DWNM,
                 USE_YN
          FROM TERMCUST.TABINFO
         WHERE GUBUN = 'term_cust_info'
        ORDER  BY 1,2; 
	
OPEN CUSTOMER_cur;

DO WHILE SQLCA.SQLCODE = 0
	
	FETCH CUSTOMER_cur 
	 INTO  :ls_code    ,
			 :ls_codenm  ,
			 :ls_dwnm    ,
			 :ls_yn      ;
			 
	If sqlca.sqlcode <> 0 then
		exit;
	end if
	
	ll_cnt ++
	IF ls_yn = 'N' THEN
		This.Control[ll_cnt].Visible = False
	END IF
LOOP 
CLOSE CUSTOMER_cur;
//end
end event

event tab_1::ue_dw_doubleclicked;Long		ll_master_row		//dw_master의 row 선택 여부
String	ls_logid = ""
String	ls_svctype, ls_customerid, ls_temp
Integer	li_exist
Dec		ldc_balance
 
Choose Case ai_tabpage
	Case 1
		Choose Case adwo_dwo.name
			Case "logid"		//Log ID
				ls_logid = Trim(idw_tabpage[ai_tabpage].Object.logid[al_row])
				If IsNull(ls_logid) Then ls_logid = ""
				If ls_logid = ""  Then
					If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
						 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					End If
					
					idw_tabpage[ai_tabpage].Object.password.Color = RGB(255,255,255)		
			      idw_tabpage[ai_tabpage].Object.password.Background.Color = RGB(108, 147, 137)
				End If
			Case "payid"		//납입자 번호
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.payid[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					
					ls_customerid = tab_1.idw_tabpage[1].Object.customerid[1]
//				  	
//					  Select count(*) Into:li_exist from  svcorder where customerid = :ls_customerid;
//					  
//				  	If li_exist > 0 Then 
//						f_msg_usr_err(404, title, "")
//					 	tab_1.idw_tabpage[1].Object.payid[1] = is_payid_old
//					 	tab_1.idw_tabpage[1].SetitemStatus(1, "payid", Primary!, NotModified!)   //수정 안되었다고 인식.
//					 	Return 0
//				 	End If
				
					
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.zipcode[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.zipcode[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.zipcode[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					End If
//					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.addr1[al_row])) or &
//					    Trim(idw_tabpage[ai_tabpage].Object.addr1[al_row]) = ""  Then
//						idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
//						idw_tabpage[ai_tabpage].iu_cust_help.is_data[4]
//					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.addr2[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.addr2[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[5]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.homephone[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.homephone[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.homephone[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[6]
					End If
					
					
//					//명의인 정보에 넣기
//					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row])) or &
//					    Trim(idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row]) = ""  Then
//						idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
//						idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
//					End If
//					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_addr1[al_row])) or &
//					    Trim(idw_tabpage[ai_tabpage].Object.holder_addr1[al_row]) = ""  Then
//						idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
//						idw_tabpage[ai_tabpage].iu_cust_help.is_data[4]
//					End If
//					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_addr2[al_row])) or &
//					    Trim(idw_tabpage[ai_tabpage].Object.holder_addr2[al_row]) = ""  Then
//						idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
//						idw_tabpage[ai_tabpage].iu_cust_help.is_data[5]
//					End If
					
				End If
			Case "zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					
//					idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//					idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
			Case "holder_zipcod"
//				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//					idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//					idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
//				End If
		End Choose
	Case 2
		Choose Case adwo_dwo.name
			Case "bil_zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.bil_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.bil_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.bil_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose
		
//	Case 3
//
//		idw_tabpage[3].accepttext()
//		
//		ll_master_row = dw_master.GetSelectedRow(0)
//		If ll_master_row <= 0 Then Return 0
//		
//		If idw_tabpage[ai_tabpage].object.use_yn[al_row] = 'Y' Then		
//			iu_cust_msg = Create u_cust_a_msg
//			iu_cust_msg.is_pgm_name = "인증정보수정"
//			iu_cust_msg.is_grp_name = "고객등록"
//			iu_cust_msg.is_data[1] = Trim(idw_tabpage[ai_tabpage].object.svctype[al_row])  //svctype
//			iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]							   //프로그램 ID
//			iu_cust_msg.is_data[3] = Trim(idw_tabpage[ai_tabpage].object.validkey[al_row]) //validkey
//			iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.fromdt[al_row],'yyyymmdd')  //fromdt
//		
////			ohj 2005.02.21 인증방법 추가(패스워드인증, 일반인증)로 인한 로직 추가로 popup변경
////			OpenWithParm(b1w_reg_validinfo_popup_update_cl, iu_cust_msg)
//			OpenWithParm(b1w_reg_validinfo_popup_update_cl_v20, iu_cust_msg)
//	
//			If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, 3) < 0 Then
//				Return -1
//			End If
//			
//			tab_1.ib_tabpage_check[3] = True
//		End IF
//		
//	Case 5
//		
//		//row Double Click시 해당 청구 자료 보여줌
//		ll_master_row = dw_master.GetSelectedRow(0)
//		If ll_master_row <= 0 Then Return 0
//		
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "신청정보 상세품목"
//		iu_cust_msg.is_grp_name = "고객관리"
//		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.orderno[al_row])
//		iu_cust_msg.is_data[2] = Trim(dw_master.object.customerm_customerid[ll_master_row])
//		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customernm[ll_master_row])
//		iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.ref_contractseq[al_row])
//		iu_cust_msg.is_data[5] = String(idw_tabpage[ai_tabpage].object.status[al_row])		 // status
//		
//		//명의변경일때 팝업 - 2015.03.12. lys
//		If iu_cust_msg.is_data[5] = '65' Then
//			iu_cust_msg.is_pgm_name = "명의변경 양도자 정보"
//			OpenWithParm(b1w_inq_customer_chg_mobile_popup_v20, iu_cust_msg)
//		//그외
////		Elseif iu_cust_msg.is_data[5] = '60' Then
////			iu_cust_msg.is_pgm_name = "기기변경정보"
////			OpenWithParm(b1w_inq_svcorder_popup_v20_new, iu_cust_msg)
//		else
//			
//			OpenWithParm(b1w_inq_svcorder_popup_v20, iu_cust_msg)
//		End If
//	
//	Case 6
//		ll_master_row = dw_master.GetSelectedRow(0)
//	  	If ll_master_row <= 0 Then Return 0
//	  
//	  	ls_svctype = idw_tabpage[ai_tabpage].object.svcmst_svctype[al_row]
//		  
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "계약정보 상세품목"
//		iu_cust_msg.is_grp_name = "고객관리"
//		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.contractseq[al_row])
//		iu_cust_msg.is_data[2] = Trim(dw_master.object.customerm_customerid[ll_master_row])
//		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customernm[ll_master_row])
//		
//		If ls_svctype = is_svctype_pre Then
//		  	OpenWithParm(b1w_inq_contmst_popup_pre_v20, iu_cust_msg) 
//		Else
//		  	OpenWithParm(b1w_inq_contmst_popup_v20, iu_cust_msg) 			
//		End If
//	
//	Case 8
//		
//		ll_master_row = dw_master.GetSelectedRow(0)
//	  	If ll_master_row <= 0 Then Return 0
//	  
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "할부 내역 상세정보"
//		iu_cust_msg.is_grp_name = "고객관리"
//		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.contractmst_contractseq[al_row])
//		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customerid[ll_master_row])
//		iu_cust_msg.is_data[4] = Trim(dw_master.object.customerm_customernm[ll_master_row])
//		
//		OpenWithParm(b1w_inq_quota_popup, iu_cust_msg)
//		
//	Case 13
//		//	민원접수 Popup Window Open Coding
//		ll_master_row = dw_master.GetSelectedRow(0)
//		If ll_master_row <= 0 Then Return 0
//		
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "민원접수상세및처리내역"
//		iu_cust_msg.is_grp_name = "고객등록"
//		iu_Cust_msg.is_data[1] = "Query"
//		iu_cust_msg.is_data[2] = String(idw_tabpage[ai_tabpage].object.troubleno[al_row])  //svctype
//		iu_cust_msg.is_data[3] = gs_pgm_id[gi_open_win_no]							   //프로그램 ID
//		
//      parent.setredraw(False)
//		OpenWithParm(b1w_reg_customertrouble_sub_v20, iu_cust_msg)
//		
//		If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, 13) < 0 Then
//			Return -1
//		End If
//			
//	   tab_1.ib_tabpage_check[13] = True
//
//      parent.setredraw(true)
//		
//	Case 15		
//		//인증장비..맥 복사기능..ㅡㅡ
//		IF adwo_dwo.name = 'mac_addr' THEN
//			ls_temp = tab_1.idw_tabpage[ai_tabpage].Object.mac_addr[al_row]
//		ELSEIF adwo_dwo.name = 'mac_addr2' THEN
//			ls_temp = tab_1.idw_tabpage[ai_tabpage].Object.mac_addr2[al_row]
//		END IF
//		
//		IF IsNull(ls_temp) OR ls_temp = "" THEN RETURN -1		
//		PARENT.POST Event ue_clip(ls_temp)			
//		
End Choose  

Return 0
end event

event tab_1::selectionchanging;//Occurs when another tab is about to be selected.
//Long. Return code choices (specify in a RETURN statement):

//0  Allow the selection to change
//1  Prevent the selection from changing

//신규 등록이면
If ib_new = TRUE Then Return 1

end event

event tab_1::ue_dw_buttonclicked;//Butonn Click
String ls_payid, ls_zip, ls_addr1, ls_addr2
String ls_svccod, ls_priceplan, ls_customerid, ls_where, ls_acct_ssno
Long i, ll_master_row

If ai_tabpage = 1 Then		//납입자 청구정보
	tab_1.idw_tabpage[1].AcceptText()
	ls_payid = Trim(tab_1.idw_tabpage[1].object.payid[al_row])
	OpenWithParm(b1w_inq_payid_billing_info, ls_payid)				//Open
End If

//INSOOK 수정 주민등록번호 유효성 Check 버튼(2004.06.29)
If ai_tabpage = 2 Then  //주민번호 check

	Choose Case adwo_dwo.name
		Case "b_check"
			tab_1.idw_tabpage[2].AcceptText()
			ls_acct_ssno = Trim(tab_1.idw_tabpage[2].object.acct_ssno[al_row])
		
			//주민등록 번호(13자리),법인번호(10자리)format)
			If LenA(ls_acct_ssno) = 13 Then
				If fi_check_juminnum(ls_acct_ssno) = -1 Then
					f_msg_usr_err(201, gs_title, "잘못된 주민번호 입니다.")
					tab_1.idw_tabpage[2].SetFocus()
					tab_1.idw_tabpage[2].SetColumn("acct_ssno")
					Return -1
				else
					MessageBox("주민번호 Check", "유효한 주민번호입니다.", information!, OK!, 1)
					tab_1.idw_tabpage[2].SetFocus()
					tab_1.idw_tabpage[2].SetColumn("acct_ssno")
				End If
			else
				f_msg_usr_err(201, gs_title, "잘못된 주민번호 입니다.")
				tab_1.idw_tabpage[2].SetFocus()
				tab_1.idw_tabpage[2].SetColumn("acct_ssno")
				Return -1
		
			End If	
		Case "b_copy"
			ls_customerid = Trim(tab_1.idw_tabpage[2].object.customerid[al_row])
			
			SELECT ZIPCODe
			     , ADDR1
				  , ADDR2
			  INTO :ls_zip
			     , :ls_addr1
				  , :ls_addr2
			  FROM CUSTOMERM
			 WHERE CUSTOMERID = :ls_customerid ;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, " Select Error(customerm)")
				Return  -1
			End If 
			
			tab_1.idw_tabpage[2].Object.bil_zipcod[al_row] = ls_zip
			tab_1.idw_tabpage[2].Object.bil_addr1[al_row]  = ls_addr1
			tab_1.idw_tabpage[2].Object.bil_addr2[al_row]  = ls_addr2
			
	End Choose
elseif ai_tabpage = 14 then
	Choose Case adwo_dwo.name
		Case "b_popup"	
			ll_master_row = dw_master.GetSelectedRow(0)
		  	If ll_master_row <= 0 Then Return 0
	  
			iu_cust_msg = Create u_cust_a_msg
			iu_cust_msg.is_pgm_name = "COMMENT"
			iu_cust_msg.is_grp_name = "고객등록"
			iu_cust_msg.is_data[1] = Trim(dw_master.object.customerm_customerid[ll_master_row])
			iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]
						
			OpenWithParm(b1w_pop_customer_comment, iu_cust_msg)		
			
			Trigger Event ue_tabpage_retrieve(ll_master_row, ai_tabpage)
			
	end choose			

end if


Return 0 
end event

event tab_1::ue_itemchanged;call super::ue_itemchanged;////Item Changed
//Boolean 	lb_check1, 	lb_check2
//String 	ls_data ,	ls_ctype2, 		ls_filter, 		ls_svctype, 	ls_opendt, 			ls_prefixno
//String  	ls_payid, 	ls_customerid, ls_munitsec, 	ls_card_type, 	ls_card_group,		ls_basecod
//Integer 	li_exist, 	li_exist1, 		li_rc
//
//DataWindowChild ldc_priceplan
//b1u_check	lu_check
//lu_check = Create b1u_check
//
//Choose Case tab_1.SelectedTab
//	Case 1		//Tab 1
//		ls_ctype2 	= Trim(tab_1.idw_tabpage[1].Object.ctype2[1])
//		b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check1)
//		b1fb_check_control("B0", "P110", "", ls_ctype2,lb_check2)
//		
//	    Choose Case dwo.name
//			case 'memberid'
//				select Count(*) INTO :li_exist1 FROM CUSTOMERM where memberid = :data ;
//				IF li_exist1 > 0 then
//					f_msg_usr_err(9000, title, "Please, Check the memberID")
//					tab_1.idw_tabpage[1].Object.memberid[1] = ""
//					return 2
//				END IF
//				
//		   Case "logid"
//				If IsNull(data) Or data = "" Then
//					tab_1.idw_tabpage[1].Object.password.Color 				= RGB(0,0,0)		
//					tab_1.idw_tabpage[1].Object.password.Background.Color = RGB(255,255,255)
//				Else //필수
//					tab_1.idw_tabpage[1].Object.password.Color 				= RGB(255,255,255)		
//					tab_1.idw_tabpage[1].Object.password.Background.Color = RGB(108, 147, 137)
//				End If
//				
//			 //납입자 정보 바꿀 시
//		   Case "payid"
//			  ls_customerid = tab_1.idw_tabpage[1].Object.customerid[1]
////			  Select count(*) Into:li_exist from  svcorder where customerid = :ls_customerid;
////			  If li_exist > 0 Then 
////				 f_msg_usr_err(404, title, "")
////				 tab_1.idw_tabpage[1].Object.payid[1] = is_payid_old
////				 tab_1.idw_tabpage[1].SetitemStatus(1, "payid", Primary!, NotModified!)   //수정 안되었다고 인식.
////				 Return 2
////			 End If
//			 
//			Case "partner"				
//				select basecod
//				  into :ls_basecod
//				  from partnermst
//				 where partner = :data ;
//				tab_1.idw_tabpage[1].Object.basecod[1] =	ls_basecod	 
////		   //sms 수신여부
////		   Case "sms_yn"
////			  If data = 'Y' Then 
////				  tab_1.idw_tabpage[1].Object.smsphone.Color = RGB(255,255,255)		
////				  tab_1.idw_tabpage[1].Object.smsphone.Background.Color = RGB(108, 147, 137)
////  			  Else
////				  tab_1.idw_tabpage[1].Object.smsphone.Color = RGB(0,0,0)				
////				  tab_1.idw_tabpage[1].Object.smsphone.Background.Color = RGB(255,255,255)
////			  End If
//
//		   //email 수신여부
//		   Case "email_yn"
//			  If data = 'Y' Then 
//				  tab_1.idw_tabpage[1].Object.email1_t.Color = NAVY	
//				  tab_1.idw_tabpage[1].Object.email1_t.Background.Color = WHITE
//   			  Else
//				  tab_1.idw_tabpage[1].Object.email1_t.Color = BLACK				
//				  tab_1.idw_tabpage[1].Object.email1_t.Background.Color = WHITE
//			  End If
//			 
//			 
//			Case "ctype2"
////				If lb_check1 Then		//개인이면 주민등록 번호 필수
////					tab_1.idw_tabpage[1].Object.socialsecurity.Color = RGB(255,255,255)		
////					tab_1.idw_tabpage[1].Object.socialsecurity.Background.Color = RGB(108, 147, 137)
//////					tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@@@@@@@@@@@"
//////					tab_1.idw_tabpage[1].object.holder[row] = tab_1.idw_tabpage[1].object.customernm[row]
//////					tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.ssno[row]
////				Else
////					tab_1.idw_tabpage[1].Object.socialsecurity.Color = RGB(0, 0, 0)		
////					tab_1.idw_tabpage[1].Object.socialsecurity.Background.Color = RGB(255, 255, 255)
////				End If	
//				
////				If lb_check2 Then		//법인이면 사업장 정보 필수
////					tab_1.idw_tabpage[1].Object.corpnm.Color = RGB(255, 255, 255)			
////					tab_1.idw_tabpage[1].Object.corpnm.Background.Color = RGB(108, 147, 137)
////					
////					//법인등록번호 필수아님 20050725 ohj
////					tab_1.idw_tabpage[1].Object.corpno.Color = RGB(0, 0, 0)			
////					tab_1.idw_tabpage[1].Object.corpno.Background.Color = RGB(255, 255, 255)
////					
////					tab_1.idw_tabpage[1].Object.cregno.Color = RGB(255, 255, 255)	
////					tab_1.idw_tabpage[1].Object.cregno.Background.Color = RGB(108, 147, 137)
////					tab_1.idw_tabpage[1].Object.representative.Color = RGB(255, 255, 255)		
////					tab_1.idw_tabpage[1].Object.representative.Background.Color = RGB(108, 147, 137)
////					tab_1.idw_tabpage[1].Object.businesstype.Color = RGB(255, 255, 255)	
////					tab_1.idw_tabpage[1].Object.businesstype.Background.Color = RGB(108, 147, 137)
////					tab_1.idw_tabpage[1].Object.businessitem.Color = RGB(255, 255, 255)
////					tab_1.idw_tabpage[1].Object.businessitem.Background.Color = RGB(108, 147, 137)
////					tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.cregno[row]
////					tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@-@@-@@@@@"
////				   Choose Case dwo.name
////						Case "corpnm"
////					   	tab_1.idw_tabpage[1].object.holder[row] = tab_1.idw_tabpage[1].object.cprpnm[row]
////						Case "cregno"
////							tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.cregno[row]
////							tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@-@@-@@@@@"
////						Case "businesstype"
////							tab_1.idw_tabpage[1].object.holder_type[row] = tab_1.idw_tabpage[1].object.businesstype[row]
////						Case "businessitem"
////							tab_1.idw_tabpage[1].object.holder_item[row] = tab_1.idw_tabpage[1].object.businessitem[row]
////					End Choose
////				Else
////					tab_1.idw_tabpage[1].Object.corpnm.Color = RGB(0, 0, 0)		
////					tab_1.idw_tabpage[1].Object.corpnm.Background.Color = RGB(255, 255, 255)
//					
////					tab_1.idw_tabpage[1].Object.corpno.Color = RGB(0, 0, 0)		
////					tab_1.idw_tabpage[1].Object.corpno.Background.Color = RGB(255, 255, 255)
////					
////					tab_1.idw_tabpage[1].Object.cregno.Color = RGB(0, 0, 0)		
////					tab_1.idw_tabpage[1].Object.cregno.Background.Color = RGB(255, 255, 255)
////
////					tab_1.idw_tabpage[1].Object.representative.Color = RGB(0, 0, 0)		
////					tab_1.idw_tabpage[1].Object.representative.Background.Color = RGB(255, 255, 255)
//					
////					tab_1.idw_tabpage[1].Object.businesstype.Color = RGB(0, 0, 0)		
////					tab_1.idw_tabpage[1].Object.businesstype.Background.Color = RGB(255, 255, 255)
////					
////					tab_1.idw_tabpage[1].Object.businessitem.Color = RGB(0, 0, 0)		
////					tab_1.idw_tabpage[1].Object.businessitem.Background.Color = RGB(255, 255, 255)
////
////				End If
////			Case "addrtype"
////					tab_1.idw_tabpage[1].object.holder_addrtype[row] = data
////			Case "zipcod"
////					tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
////			Case "addr1"
////					tab_1.idw_tabpage[1].object.holder_addr1[row] = data
////			Case "addr2"
////					tab_1.idw_tabpage[1].object.holder_addr2[row] = data
//		  End Choose
//		  
//		  //개인이면
//		  If lb_check1 Then
////				Choose Case dwo.name
////					Case "customernm"
////						tab_1.idw_tabpage[1].object.holder[row] = data
////					Case "zipcode" 
////						tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
////					Case "ssno"
////						tab_1.idw_tabpage[1].object.holder_ssno[row] = data
////				End Choose
//			ElseIf lb_check2 Then		//법인이면
////				Choose Case dwo.name
////					Case "corpnm"
////					   tab_1.idw_tabpage[1].object.holder[row] = data
////					Case "cregno"
////						tab_1.idw_tabpage[1].object.holder_ssno[row] = data
////						tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@-@@-@@@@@"
////					Case "businesstype"
////						tab_1.idw_tabpage[1].object.holder_type[row] = data
////					Case "businessitem"
////						tab_1.idw_tabpage[1].object.holder_item[row] = data
////				End Choose
//			End If
////Billing Info		
//	Case 2		//Tab
//		Choose Case dwo.name
//			Case "inv_method"
//				If is_inv_method = Trim(data) Then
//					tab_1.idw_tabpage[2].Object.bil_email.Color = RGB(255, 255, 255)		
//					tab_1.idw_tabpage[2].Object.bil_email.Background.Color = RGB(108, 147, 137)
//				Else
//					tab_1.idw_tabpage[2].Object.bil_email.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[2].Object.bil_email.Background.Color = RGB(255, 255, 255)
//				End If
////			
////			Case "card_no"
////				If is_card_prefix_yn = 'Y' Then
////					SELECT CARD_TYPE
////					  INTO :ls_card_type
////					  FROM CARDPREFIX  
////					 WHERE CARDPREFIX = (SELECT MAX(CARDPREFIX)
////												  FROM CARDPREFIX  
////												 WHERE :data LIKE CARDPREFIX ||'%' );
////												 
////					If sqlca.sqlcode < 0 Then
////						f_msg_sql_err(Title, "SELECT ERROR CARDPREFIX")
////						Return -1
////					ElseIf sqlca.sqlcode = 100 Then
////						f_msg_info(9000, title, "신용카드번호[" + data +"]의 prefix가 존재하지 않습니다.")	
////						tab_1.idw_tabpage[2].setcolumn("card_no")
////						Return -1
////					Else
////						tab_1.idw_tabpage[2].object.card_type[1] = ls_card_type
////					End If							
////				End If
////			Case "card_remark1"
////				If is_card_prefix_yn = 'Y' Then
////					SELECT card_group 
////					  INTO :ls_card_group
////					  FROM CARDREMARK
////					 WHERE CARD_REMARK = :data ;
////					 
////					If sqlca.sqlcode < 0 Then
////						f_msg_sql_err(Title, "SELECT ERROR CARDREMARK")
////						Return -1
////					ElseIf sqlca.sqlcode = 100 Then
////						f_msg_info(9000, title, "신용카드유형[" + data +"]가 존재하지 않습니다.")	
////						tab_1.idw_tabpage[2].setcolumn("card_remark1")
////						Return -1
////					Else
////						tab_1.idw_tabpage[2].object.card_group1[1] = ls_card_group
////					End If
////					 
////				End If
//			 Case "billinginfo_currency_type"
//				 
//				 ls_payid = tab_1.idw_tabpage[2].object.customerid[1]		//Pay ID
//				 
//				 Select count(customerid) into :li_exist from customerm where customerid <> payid and payid = :ls_payid;
//				 Select count(customerid) into :li_exist1 From svcorder where customerid = :ls_payid;
//				 If li_exist > 0  Or li_exist1 > 0 Then 
//					f_msg_usr_err(404, title, "") 
//					//다시 원복 한다.
//					tab_1.idw_tabpage[2].object.billinginfo_currency_type[1] = is_currency_old
//					tab_1.idw_tabpage[2].SetitemStatus(1, "billinginfo_currency_type", Primary!, NotModified!)   //수정 안되었다고 인식.
//					Return 2
//				 End If
//			
//			Case "pay_method"
////				Choose case is_pay_method_ori     //변경전데이타
////					case is_method    			  //자동이체
////						If Trim(data) <> is_pay_method_ori Then   //변경된데이타: 자동이체가 아닌경우
////							If is_drawingresult_ori = is_drawingresult[4] Then   //변경전 신청결과가 처리성공인경우
////								tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= idt_sysdate			   //신청일자:sysdate
////								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype[4]     //신청유형:해지
////								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]   //신청결과:미처리
////								tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod         //신청접수처:이용이관
////							Else
////								tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= idt_sysdate			   //신청일자:sysdate
////								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype[1]		   //신청유형:없음
////								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[1]	   //신청결과:없음
////								tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod			   //신청접수처:이용기관
////							End If
////						Elseif Trim(data) = is_pay_method_ori Then      //자동이체 -> 지로, 기타 -> 자동이체 일경우가 존재 할 수 있기 때문에...원래대로 setting
////								tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= id_drawingreqdt_ori
////								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype_ori
////								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori
////								tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod_ori
////								tab_1.idw_tabpage[2].Object.receiptdt[1] 		= id_receiptdt_ori
////								tab_1.idw_tabpage[2].Object.resultcod[1] 		= is_resultcod_ori	
////								tab_1.idw_tabpage[2].Object.bank[1] 			= is_bank_ori
////								tab_1.idw_tabpage[2].Object.acctno[1] 			= is_acctno_ori
////								tab_1.idw_tabpage[2].Object.acct_owner[1] 	= is_acct_owner_ori
////								tab_1.idw_tabpage[2].Object.acct_ssno[1] 		= is_acct_ssno_ori
////    					End IF
////					case else    //변경전데이타가 자동이체가 아닌경우
////						If Trim(data) = is_method Then      //변경한 데이타가 자동이체인 경우
////						    //지로/카드->자동이체로 변경시 해지 미처리일때 는  자동이체의 신규 처리성공으로 셋팅...
////							If is_drawingtype_ori = is_drawingtype[4] and is_drawingresult_ori = is_drawingresult[2] Then
////								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype[2]		//신청유형:신규
////								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[4]	//신청결과:처리성공
////							Else
////								ls_ctype2 = Trim(tab_1.idw_tabpage[2].Object.customerm_ctype2[1])
////								b1fb_check_control("B0", "P111", "", ls_ctype2,lb_check1)
////								b1fb_check_control("B0", "P110", "", ls_ctype2,lb_check2)
////								tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= idt_sysdate			//신청일자:sysdate
////								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype[2]		//신청유형:신규
////								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]	//신청결과:미처리
////								tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod			//접수처:이용기관
////								If lb_check1 Then //개인이면 주민등록 번호 필수
////									tab_1.idw_tabpage[2].object.acct_ssno[1] 	= tab_1.idw_tabpage[2].Object.customerm_ssno[1]
////								End If	
////								If lb_check2 Then //법인이면 사업장 정보 필수					
////									tab_1.idw_tabpage[2].object.acct_ssno[1] 	= tab_1.idw_tabpage[2].Object.customerm_cregno[1]
////								End If
////							End If
////					    Else
////							tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= id_drawingreqdt_ori
////							tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype_ori
////							tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori
////							tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod_ori
////							tab_1.idw_tabpage[2].Object.receiptdt[1] 		= id_receiptdt_ori
////							tab_1.idw_tabpage[2].Object.resultcod[1] 		= is_resultcod_ori								
////    					End IF
////				End Choose
//				
//				lu_check.is_caller   = "b1w_reg_customer_d_v20%inq_customer_tab2"
//				lu_check.is_title    = Title
//				lu_check.ii_data[1]  = tab_1.SelectedTab
//				lu_check.is_data[1] 	= is_method
//				lu_check.is_data[2] 	= is_credit
//				lu_check.is_data[3] 	= is_inv_method
//				lu_check.is_data[4] 	= is_chg_flag
//				lu_check.idw_data[1] = tab_1.idw_tabpage[tab_1.SelectedTab]		
//				lu_check.uf_prc_check_11()
//				li_rc 					= lu_check.ii_rc
//				If li_rc < 0 Then 
//					Destroy 	lu_check
//					Return 	li_rc
//				End If				
//
//			Case "bank_chg"			
//				If data = 'Y' Then
//					tab_1.idw_tabpage[2].Object.bank.Color = RGB(255, 255, 255)		
//					tab_1.idw_tabpage[2].Object.bank.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[2].Object.acctno.Color = RGB(255, 255, 255)	
//					tab_1.idw_tabpage[2].Object.acctno.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[2].Object.acct_owner.Color = RGB(255, 255, 255)			
//					tab_1.idw_tabpage[2].Object.acct_owner.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[2].Object.acct_ssno.Color = RGB(255, 255, 255)			
//					tab_1.idw_tabpage[2].Object.acct_ssno.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[2].Object.bank.Protect =0
//					tab_1.idw_tabpage[2].Object.acctno.Protect = 0
//					tab_1.idw_tabpage[2].Object.acct_owner.Protect =0
//					tab_1.idw_tabpage[2].Object.acct_ssno.Protect =0
//					tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			//신청일자:sysdate
//					tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[3]		//신청유형:변경
//					tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]	//신청결과:미처리
//					tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod			//접수처:이용기관
//				Else
////					If is_bank_chg_ori = 'Y' Then
////						tab_1.idw_tabpage[2].Object.bank[1] = is_bank_bef				        //은행:before
////						tab_1.idw_tabpage[2].Object.acctno[1] = is_acctno_bef					//계좌번호:before
////						tab_1.idw_tabpage[2].Object.acct_owner[1] = is_acct_owner_bef 			//계좌명:before
////						tab_1.idw_tabpage[2].Object.acct_ssno[1] = is_acct_ssno_bef				//계좌주민번호:before
////						tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_bef		//신청일자:before
////						tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_bef 		//신청유형:before
////						tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_bef 	//신청결과:before
////						tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_bef			//접수처:before
////						tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_bef 	        //신청접수일자:before
////						tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_bef			    //신청결과코드:before
////					Else
////						tab_1.idw_tabpage[2].Object.bank[1] = is_bank_ori					    //은행:origin
////						tab_1.idw_tabpage[2].Object.acctno[1] = is_acctno_ori 					//계좌번호:origin
////						tab_1.idw_tabpage[2].Object.acct_owner[1] = is_acct_owner_ori 			//계좌명:origin
////						tab_1.idw_tabpage[2].Object.acct_ssno[1] = is_acct_ssno_ori				//계좌주민번호:origin
////						tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_ori		//신청일자:origin
////						
////						tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_ori 		//신청유형:origin
////						tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori 	//신청결과:origin
////						tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_ori			//접수처:origin
////						tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_ori 	        //신청접수일자:origin
////						tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_ori			    //신청결과코드:origin
//					End If
////					lu_check.is_caller   = "b1w_reg_customer_d_v20%inq_customer_tab2"
////					lu_check.is_title    = Title
////					lu_check.ii_data[1]  = tab_1.SelectedTab
////					lu_check.is_data[1] = is_method
////					lu_check.is_data[2] = is_credit
////					lu_check.is_data[3] = is_inv_method
////					lu_check.is_data[4] = is_chg_flag
////					lu_check.idw_data[1] = tab_1.idw_tabpage[tab_1.SelectedTab]		
////					lu_check.uf_prc_check_11()
////					li_rc = lu_check.ii_rc
////					If li_rc < 0 Then 
////						Destroy lu_check
////						Return li_rc
////					End If				
////			  End If		
//		End Choose
//	//	
//	Case 3
//		Choose Case dwo.name
//			Case "svccod"
//				li_exist = tab_1.idw_tabpage[3].GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//				If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
//			
//				ldc_priceplan.SetTransObject(SQLCA)
//				ldc_priceplan.Retrieve(data)
//				
//		End Choose
//	
//	Case 10
//		If (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!) = New!) Or (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!)) = NewModified!	Then
//			ls_munitsec = "0"
//		Else
//			ls_munitsec = String(tab_1.idw_tabpage[10].object.munitsec[row])
//			If IsNull(ls_munitsec) Then ls_munitsec = ""
//		End If
//		
//		Choose Case dwo.name
//			Case "zoncod"
//				If data <> "ALL" Then
//					tab_1.idw_tabpage[10].Object.areanum[row] = "ALL"
//					tab_1.idw_tabpage[10].Object.areanum.Protect = 1
//				Else
//					tab_1.idw_tabpage[10].Object.areanum[row] = ""
//					tab_1.idw_tabpage[10].Object.areanum.Protect = 0
//				End If
//				
//			Case "enddt"
//				//적용종료일 체크
//				ls_opendt	= Trim(String(tab_1.idw_tabpage[10].Object.opendt[row],'yyyymmdd'))
//		
//				If data <> "" Then
//					If ls_opendt > data Then
//						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//						tab_1.idw_tabpage[10].setColumn("enddt")
//						tab_1.idw_tabpage[10].setRow(row)
//						tab_1.idw_tabpage[10].scrollToRow(row)
//						tab_1.idw_tabpage[10].setFocus()
//						Return -1
//					End If
//				End If
//				
//			Case "unitsec"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange1[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange1[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].object.munitsec1[row] > 0) Then
//					tab_1.idw_tabpage[10].object.munitsec1[row] = Long(data)
//				End If
//			End If
//		
//		Case "unitfee1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].object.munitfee[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee1[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange2[row] = Long(data)
//				End If
//			End If
//		
//			
//		Case "unitsec2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec2[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee2[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange3[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec3[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee3[row] = Long(data)
//				End If
//			End If
//
//			
//		Case "tmrange4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange4[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec4[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee4[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange5[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec5[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee5[row] = Long(data)
//				End If
//			End If
//		End Choose
//	
//	Case 11
//		Choose Case dwo.name
//			Case "enddt"
//				//적용종료일 체크
//				ls_opendt	= Trim(String(tab_1.idw_tabpage[11].Object.opendt[row],'yyyymmdd'))
//		
//				If data <> "" Then
//					If ls_opendt > data Then
//						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//						tab_1.idw_tabpage[11].setColumn("enddt")
//						tab_1.idw_tabpage[11].setRow(row)
//						tab_1.idw_tabpage[11].scrollToRow(row)
//						tab_1.idw_tabpage[11].setFocus()
//						Return -1
//					End If
//				End If
//		End Choose
//End Choose
Return 0
//
end event

event tab_1::ue_dw_clicked;String ls_rectype, ls_status

//신청 상태일때만 delete

Choose Case ai_tabpage
//	case 1
//		If al_row = 0 then Return -1
//		IF tab_1.idw_tabpage[ai_tabpage].GetClickedColumn() = 3 THEN
//			mle_note.Position()
//			mle_note.text = '* First letter can not be a number. ~r~n ' + &
//								 '* Special characters can not be used. ~r~n ' + &
//								 '* Your email id needs to be under eight characters. ~r~n ' + &
//								 '* Capital letter can not be used.  '
//
//			mle_note.x = This.PointerX()
//			mle_note.y = This.PointerY()
//			mle_note.BringToTop = True
//			mle_note.Visible = True
//		ELSEIF tab_1.idw_tabpage[ai_tabpage].GetClickedColumn() = 5 THEN
//			mle_note.Position()
//			mle_note.text = "* Make the password into at least nine characters.~r~n " + &
//"* The password can be either in upper case or in lower case letters or in numbers.~r~n " + &
//"* Three letters need to be different from each others. ~r~n " + &
//"* Succeeding letters (ex. abcdef….., bcdefg……..)or consecutive numbers ~r~n " + &
//"* (ex. 12345…..,234567……) can't be used.~r~n " + & 
//"* Certain characters such as * , [ ,] , ^ , $ …..can't be used.~r~n " + &
//"* Overlapping letters can't be used. ( ex . aaaa…, bbbbb….., ccccc…..)~r~n " + &
//"'* Characteristic words such as (beautiful123, computer, korea…) can't be used. ~r~n " 
//			mle_note.x = This.PointerX() + 200
//			mle_note.y = This.PointerY() 
//			mle_note.BringToTop = True
//			mle_note.Visible = True
//		ELSE
//			mle_note.Visible = false
//		END IF
		
	Case 3
		If al_row = 0 then Return -1
		
		If tab_1.idw_tabpage[ai_tabpage].IsSelected( al_row ) then
			 tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row ,FALSE)
		Else
			tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
			tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
		End If
	
	Case 13
//	RQ-UBS-201305-05 컬럼크기조정 필요해서 막음. 2014/05/09 by hmk
//		If al_row = 0 then Return -1
		

//		If tab_1.idw_tabpage[ai_tabpage].IsSelected( al_row ) then
//			 tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row ,FALSE)
//		Else
//			tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
//			tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
//		End If
		
End Choose

Return 0
end event

event tab_1::clicked;STRING	ls_customerid,		ls_tab
LONG		ll_master_row

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])

//CUSTOMER.LOG 에 기록 남기기...
IF index = 1 OR index = 2 THEN
	IF index = 1 THEN ls_tab = 'TAB1'
	IF index = 2 THEN ls_tab = 'TAB2'
	
	INSERT INTO CUSTOMER_LOG
		( EMP_ID, ACTION, TIMESTAMP, CUSTOMERID )
	VALUES
		( :gs_user_id, :ls_tab, SYSDATE, :ls_customerid );
	
	IF sqlca.sqlcode < 0 THEN
		ROLLBACK;
	ELSE
		COMMIT;
	END IF		
END IF
end event

event tab_1::ue_tabpage_update;return -1
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within w_term_cust_info
integer y = 988
end type

type p_view from u_p_view within w_term_cust_info
boolean visible = false
integer x = 914
integer y = 2200
boolean bringtotop = true
string pointer = "HyperLink!"
end type

event ue_disable();call super::ue_disable;dw_cond.SetFocus()
dw_cond.setColumn("memberid")
end event

type p_active from picture within w_term_cust_info
boolean visible = false
integer x = 1669
integer y = 2200
integer width = 599
integer height = 96
boolean bringtotop = true
string picturename = "svcRequest_e.gif"
boolean focusrectangle = false
end type

event clicked;
IF il_mst_row > 0 then
	gs_CID = dw_master.Object.customerm_customerid[il_mst_row]
	gs_onOff = '1'
ELSE
	gs_CID = ""
	gs_onOff = '0'
	
END IF
//f_call_menu("b1w_1_reg_svc_actorder_v20_sams_test")

f_call_menu("ubs_w_reg_activeorder")
end event

type cb_comment from commandbutton within w_term_cust_info
boolean visible = false
integer x = 3109
integer y = 2200
integer width = 434
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Comment Log"
end type

event clicked;LONG		ll_master_row

ll_master_row = dw_master.GetSelectedRow(0)

IF ll_master_row <= 0 THEN RETURN 0
	  
iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "COMMENT"
iu_cust_msg.is_grp_name = "고객등록"
iu_cust_msg.is_data[1] = Trim(dw_master.object.customerm_customerid[ll_master_row])
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]
			
OpenWithParm(b1w_pop_customer_comment, iu_cust_msg)

Destroy iu_cust_msg
end event

type cb_bill from commandbutton within w_term_cust_info
boolean visible = false
integer x = 3493
integer y = 164
integer width = 283
integer height = 96
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "BILL"
end type

event clicked;window active_window, wSheet, wSheet1
//ulong l_handle
long    l_handle
boolean lb_valid, lb_rtn
string  ls_payid, ls_pgm_id, ls_wname, ls_title
integer li_i, li_ret, li_valid, li_message
LONG	  ll_master_row, ll_row, ll_ret, ll_rtn

//messagebox("gs_pgm_id", gs_pgm_id[1])

ll_row   = tab_1.idw_tabpage[1].RowCount()


IF ll_row <= 0 THEN 
	messagebox("Retrieve payid", "Retrieve payid")
	RETURN 0
end if

//ls_payid = Trim(dw_master.object.customerm_customerid[ll_row])
//ls_payid = tab_1.idw_tabpage[1].object.payid[1] 
ls_payid = tab_1.idw_tabpage[1].object.payid[1] 

gs_payid = ls_payid

if IsNull(ls_payid ) or ls_payid = '' then
	messagebox("Retrieve payid", "Retrieve payid1")
	return	0
end if

//messagebox("gi_open_win_no", string(gi_open_win_no))
ls_pgm_id = '96210000' // Bill화면

//같은 프로그램 작동 중인지를 검사
For li_i = 1 To gi_open_win_no
	If gs_pgm_id[li_i] = ls_pgm_id Then // 같은 프로그램이 작동 중이면
			messagebox("확인", "BILL메뉴가 열려 있습니다. 해당 화면을 종료 후 처리해 주세요")
			//close(m_a_reg_m_sql:b5w_reg_mtr_inp_sams)
			//post event close(b5w_reg_mtr_inp_sams)
			//w_mdi_main:b5w_reg_mtr_inp_sams
			//call b5w_reg_mtr_inp_sams::close
			//call w_a_reg_m_tm2::close
			//call w_a_condition`p_close::clicked
			//call w_a_reg_m_tm2`p_close::clicked
			//close(w_a_reg_m_sql)
			//close(b5w_reg_mtr_inp_sams)
			//close(parent) //-- 이것은 처리가 되는데???
			//close(w_a_reg_m_sql) // 작동안함
			//call w_a_reg_m_tm2::close
			//call w_a_m_master::resize
			// close(w_a_condition)
			//call b5w_reg_mtr_inp_sams.p_close::clicked
			//w_a_reg_m_tm2.b5w_reg_mtr_inp_sams::event ue_close()
			//call super:: ue_close()
			//b5w_reg_mtr_inp_sams.event ue_close()
			//b5w_reg_mtr_inp_sams.event close()
			//b5w_reg_mtr_inp_sams.event clicked!(cb_close2)
			//b5w_reg_mtr_inp_sams.event cb_close2.clicked!
			///cb_close2.cliecked()
			// f_close_win() // 이 방법도 안됨
			return
	End If
Next

f_call_menu("b5w_reg_mtr_inp_sams")
end event

type p_active_mobile from picturebutton within w_term_cust_info
boolean visible = false
integer x = 2336
integer y = 2200
integer width = 599
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "     Mobile Request"
boolean originalsize = true
alignment htextalign = left!
end type

event clicked;
IF il_mst_row > 0 then
	gs_CID = dw_master.Object.customerm_customerid[il_mst_row]
	gs_onOff = '1'
ELSE
	gs_CID = ""
	gs_onOff = '0'
	
END IF
//f_call_menu("b1w_1_reg_svc_actorder_v20_sams_test")

f_call_menu("mobile_w_reg_activeorder_new")
end event

