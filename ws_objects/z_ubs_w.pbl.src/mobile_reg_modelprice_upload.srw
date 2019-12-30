$PBExportHeader$mobile_reg_modelprice_upload.srw
$PBExportComments$단말판매정책관리
forward
global type mobile_reg_modelprice_upload from w_a_reg_m_tm2
end type
type st_1 from statictext within mobile_reg_modelprice_upload
end type
type st_2 from statictext within mobile_reg_modelprice_upload
end type
type sle_filename from singlelineedit within mobile_reg_modelprice_upload
end type
type mle_filedesc from multilineedit within mobile_reg_modelprice_upload
end type
type dw_temp from u_d_sgl_sel within mobile_reg_modelprice_upload
end type
type dw_rate from u_d_external within mobile_reg_modelprice_upload
end type
type p_find from u_p_find within mobile_reg_modelprice_upload
end type
type p_fileread from u_p_fileread within mobile_reg_modelprice_upload
end type
type p_deleteall from u_p_alldelete within mobile_reg_modelprice_upload
end type
type gb_file from gb_cond within mobile_reg_modelprice_upload
end type
end forward

global type mobile_reg_modelprice_upload from w_a_reg_m_tm2
integer width = 4078
integer height = 2624
st_1 st_1
st_2 st_2
sle_filename sle_filename
mle_filedesc mle_filedesc
dw_temp dw_temp
dw_rate dw_rate
p_find p_find
p_fileread p_fileread
p_deleteall p_deleteall
gb_file gb_file
end type
global mobile_reg_modelprice_upload mobile_reg_modelprice_upload

type prototypes
Function Long SetCurrentDirectoryA (String lpPathName ) Library "kernel32" alias for "SetCurrentDirectoryA;Ansi" 
end prototypes

type variables

string is_file
end variables

forward prototypes
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
public function integer wf_create_rate_mobile (string as_fromdt, integer ai_seq)
end prototypes

public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[]);//문자열을 특정구분자(as_cut)로 자른다.
Long ll_rc = 1
Int li_index = 0

as_source = Trim(as_source)
If as_source <> '' Then
	Do While(ll_rc <> 0 )
		li_index ++
		ll_rc = PosA(as_source, as_cut)
		If ll_rc <> 0 Then
			as_result[li_index] = Trim(LeftA(as_source, ll_rc - 1))
		Else
			as_result[li_index] = Trim(as_source)
		End If

		as_source = MidA(as_source, ll_rc + 2)
	Loop
End If

Return li_index
end function

public function integer wf_create_rate_mobile (string as_fromdt, integer ai_seq);
string ls_priceplan, ls_sale_modelcd, ls_itemcod, ls_pitemcod, ls_svccod, ls_fromdt, ls_modelno, ls_sales_item
dec 		ld_ubs_amt, ld_p_total, ld_mth_amt, ld_facto_amt, ld_ubs_factamt, ld_rate, ld_margin
integer i, li_mon, li_cnt, li_cnt1, li_cnt2, li_cnt3


ls_svccod = dw_cond.object.svccod[1]
ld_rate = dw_rate.object.exrate[1]
ld_margin = dw_rate.object.margin[1]

//단말모델 설정확인
SELECT COUNT(*) INTO :li_cnt 
FROM SYSCOD2T
WHERE GRCODE = 'ZM100'
  AND REF_CODE1 = :ls_svccod;

IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "SELECT Error(판매모델명)")
		RETURN -1
ELSEIF li_cnt = 0 THEN //NOT FOUND
		MESSAGEBOX("판매모델설정","설정된 단말모델명이 없습니다. CODE CONTROL1 메뉴의 ZM100 코드에 판매모델명울 설정하세요")
		RETURN -1
END IF

//단말할부개월수 확인
SELECT COUNT(*) INTO :li_cnt1 
FROM SYSCOD2T
WHERE GRCODE = 'ZM102';

IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "SELECT Error(단말할부개월수)")
		RETURN -1
ELSEIF li_cnt1 = 0 THEN //NOT FOUND
		MESSAGEBOX("단말할부개월수설정","설정된 단말할부개월수가 없습니다. CODE CONTROL1 메뉴의 ZM102 코드에 개월수를 설정하세요")
		RETURN -1
END IF

//단말할부아이템 확인
SELECT COUNT(*) INTO :li_cnt2 
FROM SYSCOD2T
WHERE GRCODE = 'ZM101'
  AND REF_CODE1 = :ls_svccod;
	
IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "SELECT Error(단말할부아이템)")
		RETURN -1
ELSEIF li_cnt2 = 0 THEN //NOT FOUND
		MESSAGEBOX("단말할부아이템설정","설정된 단말할부아이템이 없습니다. CODE CONTROL1 메뉴의 ZM101 코드에 단말할부아이템을 설정하세요")
		RETURN -1
END IF

//위약아이템 확인
SELECT COUNT(*) INTO :li_cnt3 
FROM SYSCOD2T
WHERE GRCODE = 'ZM202'
  AND REF_CODE1 = :ls_svccod;

IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "SELECT Error(위약아이템)")
		RETURN -1
ELSEIF li_cnt3 = 0 THEN //NOT FOUND
		MESSAGEBOX("위약아이템설정","설정된 위약아이템이 없습니다. CODE CONTROL1 메뉴의 ZM202 코드에 위약아이템을 설정하세요")
		RETURN -1
END IF


//할부정책생성
DECLARE CUR_PRICEPLAN_UPLOAD  CURSOR FOR

			SELECT  	SVCCOD,
						(SELECT CODE FROM SYSCOD2T WHERE GRCODE= 'ZM101' AND REF_CODE1 = B.REF_CODE1) AS ITEMCOD, /*단말할부아이템*/
						(SELECT CODE FROM SYSCOD2T WHERE GRCODE = 'ZM202'  AND REF_CODE1 = :ls_svccod) AS P_ITEMCOD, /*위약아이템*/
						PRICEPLAN,  
						SALE_MODELCD, 
						UBS_AMT, 
						NVL(SUB_AMT1,0),// + NVL(SUB_AMT2, 0),
						TO_NUMBER(C.CODE) AS MON,
						ROUND(UBS_AMT/ TO_NUMBER(C.CODE),0)
        FROM MODEL_PRICEPLAN_UPLOAD A, SYSCOD2T B, SYSCOD2T C
        WHERE A.SALE_MODELCD = B.CODE
		  		AND A.SVCCOD = B.REF_CODE1
            AND B.GRCODE = 'ZM100'  /*기준단말모델*/
				AND C.GRCODE = 'ZM102'  /*단말할부 개월수*/
				AND A.SVCCOD = :ls_svccod
            AND FROMDT = :AS_FROMDT
		  AND SEQ = :AI_SEQ;
          
		  
OPEN CUR_PRICEPLAN_UPLOAD;

		DO WHILE SQLCA.SQLCODE = 0
			FETCH CUR_PRICEPLAN_UPLOAD INTO :ls_svccod, :ls_itemcod, :ls_pitemcod, :ls_priceplan, :ls_sale_modelcd, 
			      :ld_ubs_amt, :ld_p_total, :li_mon, :ld_mth_amt;
			
			IF sqlca.sqlcode <> 0 THEN
					EXIT;
			END IF
			  	  
				  INSERT INTO PRICEPLAN_RATE_MOBILE
				  VALUES
				  (:ls_svccod, :ls_priceplan, :ls_sale_modelcd, :li_mon , :as_fromdt, null, :ls_itemcod, :ld_mth_amt,
				   :ld_p_total, :ls_pitemcod, sysdate,null,  :gs_user_id, null, null);
				  
				  IF SQLCA.SQLCODE < 0 THEN
							f_msg_sql_err(Title, "Insert Error(PRICEPLAN_RATE_MOBILE)")
							ROLLBACK;
							RETURN -1
				  END IF
									  
		LOOP
		
CLOSE CUR_PRICEPLAN_UPLOAD;


//모델출고가 생성
DECLARE CUR_UPLOAD_MOBILE_SALES  CURSOR FOR

			SELECT DISTINCT A.FROMDT, A.SVCCOD, A.SALE_MODELCD, B.MODELNO, D.ITEMCOD, A.FACTO_AMT 
			FROM MODEL_PRICEPLAN_UPLOAD A, ADMODEL B, SYSCOD2T C, ADMODEL_ITEM D
			WHERE A.SALE_MODELCD = B.SALE_MODELCD
				AND A.SVCCOD = C.REF_CODE1
				AND C.GRCODE = 'ZM100'
				AND B.MODELNO = D.MODELNO
				AND A.SVCCOD = :ls_svccod
				AND A.FROMDT = :AS_FROMDT
				AND A.SEQ = :AI_SEQ;
				 
		  
OPEN CUR_UPLOAD_MOBILE_SALES;

		DO WHILE SQLCA.SQLCODE = 0
			FETCH CUR_UPLOAD_MOBILE_SALES INTO :ls_fromdt, :ls_svccod, :ls_sale_modelcd, :ls_modelno, :ls_sales_item, :ld_facto_amt;
			
			IF sqlca.sqlcode <> 0 THEN
					EXIT;
			END IF
			
			//UBS 출고금액(달러변환)
			ld_ubs_factamt = (ld_facto_amt  * ld_margin) / ld_rate 
							 
			// f_roundup ( ag_num , ag_pos)
			// 아규먼트 
			// ag_num 값
			// ag_pos 자릿수       
			
			dec ld_pos 
			ld_pos = 10.^1
			
			ld_ubs_factamt =  Ceiling( ld_ubs_factamt / ld_pos  ) * ld_pos  
					  	  
		  INSERT INTO MODEL_PRICE
		  ( MODELNO, FROMDT, IN_UNITAMT, SALE_UNITAMT, SALE_ITEM, PR_SALEAMT, PR_DEPOSITAMT, NOTE, 
			 CRT_USER, UPDT_USER, CRTDT, UPDTDT, PGM_ID)
		  VALUES
		  (:ls_modelno, to_date(:ls_fromdt,'yyyy-mm-dd'), 0, :ld_ubs_factamt , :ls_sales_item, 0, 0, :ls_sale_modelcd,
			 :gs_user_id,  null, sysdate , null, null);
		  
		  IF SQLCA.SQLCODE < 0 THEN
					f_msg_sql_err(Title, "Insert Error(MODEL_PRICE)")
					ROLLBACK;
					RETURN -1
		  END IF
									  
		LOOP
		
CLOSE CUR_UPLOAD_MOBILE_SALES;


COMMIT;

return 0
end function

on mobile_reg_modelprice_upload.create
int iCurrent
call super::create
this.st_1=create st_1
this.st_2=create st_2
this.sle_filename=create sle_filename
this.mle_filedesc=create mle_filedesc
this.dw_temp=create dw_temp
this.dw_rate=create dw_rate
this.p_find=create p_find
this.p_fileread=create p_fileread
this.p_deleteall=create p_deleteall
this.gb_file=create gb_file
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.st_2
this.Control[iCurrent+3]=this.sle_filename
this.Control[iCurrent+4]=this.mle_filedesc
this.Control[iCurrent+5]=this.dw_temp
this.Control[iCurrent+6]=this.dw_rate
this.Control[iCurrent+7]=this.p_find
this.Control[iCurrent+8]=this.p_fileread
this.Control[iCurrent+9]=this.p_deleteall
this.Control[iCurrent+10]=this.gb_file
end on

on mobile_reg_modelprice_upload.destroy
call super::destroy
destroy(this.st_1)
destroy(this.st_2)
destroy(this.sle_filename)
destroy(this.mle_filedesc)
destroy(this.dw_temp)
destroy(this.dw_rate)
destroy(this.p_find)
destroy(this.p_fileread)
destroy(this.p_deleteall)
destroy(this.gb_file)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: mobile_reg_modelprice_upload
	Desc.	: 단말정책 업로드
	Ver.	: 1.0
	Date	: 2015.02.01
	Programer : HMK
------------------------------------------------------------------------*/
string ls_today

//tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)



dw_cond.object.fromdt[1] = today()
ls_today = string(today(),'yyyy/mm/dd')

dw_rate.retrieve(ls_today)



//버튼 조정
p_fileread.TriggerEvent("ue_disable")
p_deleteall.visible = false

end event

event ue_ok;//dw_master 조회
String ls_sale_modelcd, ls_fromdt, ls_todt, ls_where, ls_svccod
Date ld_fromdt, ld_todt
Long ll_row


dw_cond.AcceptText()

ld_fromdt       = dw_cond.object.fromdt[1]
ls_fromdt       = String(ld_fromdt, 'yyyymmdd')
ld_todt			 = dw_cond.object.todt[1]
ls_todt			 = string(ld_todt,'yyyymmdd')
ls_sale_modelcd = dw_cond.object.sale_modelcd[1]
ls_svccod 		 = dw_cond.object.svccod[1]

dw_rate.retrieve(ls_fromdt)

//Null Check
If IsNull(ls_fromdt)     		  Then ls_fromdt     = ""
If IsNull(ls_sale_modelcd)      Then ls_sale_modelcd      = ""
If IsNull(ls_svccod)      		  Then ls_svccod      = ""


IF ls_fromdt = "" THEN //처리..
//	필수입력 Check
	f_msg_usr_err(200, This.Title, "적용시작일")
	dw_cond.SetRow(1)
	dw_cond.SetColumn("fromdt")
	dw_cond.SetFocus()
	Return
END IF

// Retrieve
ls_where = ""
If ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "fromdt = '" + ls_fromdt + "' "
End If

If ls_todt <> "" Then
	ls_where = ""
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "fromdt between '" + ls_fromdt + "'  AND '" + ls_todt + "' "
End If

If ls_svccod <> '' THEN
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "svccod = '" + ls_svccod + "' "
End If
//MESSAGEBOX("", ls_where)


dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")


ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
Else
	//마지막 row로 간다.
	dw_master.ScrollToRow(ll_row)
	dw_master.selectrow(0, false)
	dw_master.selectrow(ll_row, true)
	dw_master.SetFocus()	
	
	//검색을 찾으면 Tab를 활성화 시킨다.
	tab_1.Trigger Event SelectionChanged(1, 1)
	tab_1.Enabled = True
	
End If

//버튼처리
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
end event

event ue_extra_insert;//Insert시 조건
DEC		lc_troubleno,		lc_num
LONG		ll_master_row,		ll_seq,			i,			ll_row
STRING	ls_partner

ll_master_row = dw_master.GetRow()

Choose Case ai_selected_tab
	Case 1								//Tab 1
//		Select seq_troubleno.nextval 
//		Into :lc_num
//		From dual;
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select seq_troubleno.nextval")
//			RollBack;
//			Return -1
//		End If	
		
//		SELECT CODENM INTO :ls_partner
//		FROM   SYSCOD2T
//		WHERE  GRCODE = 'B333'
//		AND    CODE = :gs_shopid;
		
//		IF IsNull(ls_partner) OR ls_partner = '' THEN ls_partner = "A100013"   //없으면 빌링센터로 기본..
//				
//		tab_1.idw_tabpage[1].object.customer_trouble_troubleno.Protect      = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_customerid.Protect     = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_cregno.Protect         = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_pid.Protect            = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_contractseq.Protect    = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_validkey.Protect       = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_svccod.Protect         = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_priceplan.Protect      = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_receiptdt.Protect      = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_requestdt.Protect      = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_receipt_user.Protect   = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_trouble_note.Protect   = 0
//		tab_1.idw_tabpage[1].object.troubletypeb_troubletypec.Protect       = 0
//		tab_1.idw_tabpage[1].object.troubletypea_troubletypeb.Protect       = 1
//		tab_1.idw_tabpage[1].object.troubletypemst_troubletypea.Protect     = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_troubletype.Protect    = 1
//		tab_1.idw_tabpage[1].object.partner_auth.Protect                    = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_trouble_status.Protect = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_sms_yn.Protect         = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_email_yn.Protect       = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_partner.Protect        = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_send_msg.Protect       = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_sacnum.Protect         = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_callforwardno.Protect  = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_sendno.Protect         = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_country.Protect        = 0	
////		tab_1.idw_tabpage[1].object.customer_trouble_partner.Protect        = 0	
//	   tab_1.idw_tabpage[1].object.customer_trouble_troubleno[al_insert_row]    = lc_num	//Trouble Num Setting
//		tab_1.idw_tabpage[1].object.customer_trouble_receipt_user[al_insert_row] = gs_user_id //접수자
//		tab_1.idw_tabpage[1].object.customer_trouble_receiptdt[al_insert_row]    = fdt_get_dbserver_now() //date
////		tab_1.idw_tabpage[1].object.customer_trouble_requestdt[al_insert_row]    = fd_date_next(Date(fdt_get_dbserver_now()),0) //date
//		tab_1.idw_tabpage[1].object.customer_trouble_requestdt[al_insert_row]    = fdt_get_dbserver_now() //date
//		//Log
//		tab_1.idw_tabpage[1].object.customer_trouble_crt_user[al_insert_row] = gs_user_id
//		tab_1.idw_tabpage[1].object.customer_trouble_crtdt[al_insert_row]    = fdt_get_dbserver_now()
//		tab_1.idw_tabpage[1].object.customer_trouble_pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]
//		tab_1.idw_tabpage[1].object.customer_trouble_updt_user[1]            = gs_user_id
//		tab_1.idw_tabpage[1].object.customer_trouble_updtdt[1]               = fdt_get_dbserver_now()
//		//receipt_partner 항목에 로그인샵으로 변경 요청함 - 이윤주 대리(2011.09.21)
//		//현재는 파라미터로 open시 전달받은 user를 sysusr1t의 emp_group으로 처리하고 있었음.
//		//2011.09.22 kem modify
////		tab_1.idw_tabpage[1].object.customer_trouble_receipt_partner[1]      = gs_user_group
//		tab_1.idw_tabpage[1].object.customer_trouble_receipt_partner[1]      = GS_ShopID
//		
////		tab_1.idw_tabpage[1].object.customer_trouble_partner[1]     		   = gs_user_group		
//		tab_1.idw_tabpage[1].object.customer_trouble_partner[1]     		   = ls_partner		
////		customer_trouble_receipt_partner
	Case 2							   //Tab 2
		
//		If ll_master_row = 0 Then Return -1
//		lc_troubleno = dw_master.object.troubleno[ll_master_row]
//		
//		//Seq Number
//		Select nvl(max(seq) + 1, 1)
//		Into :ll_seq
//		From troubl_response
//		Where troubleno = :lc_troubleno ;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select Seq")
//			RollBack;
//			Return -1
//		End If				
//		
//		//Seq 비교 확인
//		ll_row = tab_1.idw_tabpage[2].RowCount()
//		If ll_row <> 0 Then
//			For i = 1 To ll_row
//				//seq number 이 같으면
//				If ll_seq = tab_1.idw_tabpage[2].object.troubl_response_seq[i] Then
//					ll_seq += 1
//				End If	
//			Next
//		End If	
//		
//		//모든 row 를 삭제하고 다시 insert할때.
////		If al_insert_row = 1 Then
////			tab_1.idw_tabpage[2].object.customer_trouble_troubleno[al_insert_row] = &
////				lc_troubleno
////			tab_1.idw_tabpage[2].object.customer_trouble_troubletype[al_insert_row] = &
////				dw_master.object.customer_trouble_troubletype[ll_master_row]
////			tab_1.idw_tabpage[2].object.customer_trouble_customerid[al_insert_row] = &
////				dw_master.object.customer_trouble_customerid[ll_master_row]
////			tab_1.idw_tabpage[2].object.customer_trouble_note[al_insert_row] = &
////			 	dw_master.object.customer_trouble_note[ll_master_row]
////		End If
//			
//		tab_1.idw_tabpage[2].object.troubl_response_seq[al_insert_row]            = ll_seq  //seq
//		tab_1.idw_tabpage[2].object.troubl_response_response_user[al_insert_row]  = gs_user_id //처리자
//		tab_1.idw_tabpage[2].object.troubl_response_responsedt[al_insert_row]     = Date(fdt_get_dbserver_now()) //date
//		tab_1.idw_tabpage[2].object.troubl_response_partner[al_insert_row]        = gs_user_group //조치자의 Parter
//		tab_1.idw_tabpage[2].object.troubl_response_troubleno[al_insert_row]      = lc_troubleno
//		tab_1.idw_tabpage[2].object.close_yn[al_insert_row]                       = is_closeyn  //처리완료
//		tab_1.idw_tabpage[2].object.troubl_response_trouble_status[al_insert_row] = is_trouble_status //master에 있는 내용
//		tab_1.idw_tabpage[2].object.partner[al_insert_row]                        = is_partner
//		//Log
//		tab_1.idw_tabpage[2].object.troubl_response_crt_user[al_insert_row]  = gs_user_id
//		tab_1.idw_tabpage[2].object.troubl_response_crtdt[al_insert_row]     = fdt_get_dbserver_now()
//		tab_1.idw_tabpage[2].object.troubl_response_pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
//		tab_1.idw_tabpage[2].object.troubl_response_updt_user[al_insert_row] = gs_user_id	
//		tab_1.idw_tabpage[2].object.troubl_response_updtdt[al_insert_row]    = fdt_get_dbserver_now()
//
//		tab_1.idw_tabpage[2].SetColumn("troubl_response_response_note")
//		tab_1.idw_tabpage[2].SetFocus()
//			
	
End Choose

Return 0 
end event

event ue_reset;call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("fromdt")
dw_cond.object.fromdt[1] = today()
dw_cond.object.todt[1] = today()

tab_1.SelectedTab = 1
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_deleteall.visible = false


dw_cond.Object.sale_modelcd[1] = ''  

p_find.TriggerEvent("ue_enable")
p_fileread.TriggerEvent("ue_disable")
sle_filename.text = ''
mle_filedesc.text = ''

dw_rate.Reset()
dw_temp.Reset()
Return 0 
end event

event ue_extra_delete;////Delete 조건
//Dec lc_troubleno
//Long ll_master_row, ll_cnt
//String ls_receipt_user, ls_troubletype
//Integer li_check = 1
//
//ll_master_row = dw_master.GetRow()
//If ll_master_row = 0 Then  Return 0    //삭제 가능
//
//Choose Case tab_1.SelectedTab
//	Case 1						//Tab
//		lc_troubleno = dw_master.object.troubleno[ll_master_row]
//		ls_receipt_user = dw_master.object.receipt_user[ll_master_row]	
//		ls_troubletype = dw_master.object.troubletype[ll_master_row]		
//		
////		=========================================================================================
////		2008-03-05 hcjung				
////		보스 연동 대상인 장애는 삭제할 수 없다. 
////		=========================================================================================	
//		SELECT COUNT(*) 
//		  INTO :li_check
//		  FROM TROUBLE_BOSS 
//		 WHERE USE_YN = 'Y'
//		   AND TROUBLETYPE = :ls_troubletype;
//
//		IF SQLCA.SQLCode < 0 THEN
//			f_msg_sql_err(This.Title,"TROUBLETYPE Select Error")
//			Return -1
//		END IF	
//		
//		IF  li_check > 0 THEN
//			f_msg_usr_err(9000, Title, "삭제불가! 보스 연동 대상은 삭제할 수 없습니다.")  //삭제 안됨
//			RETURN -1
//		END IF	
//		
//		If ls_receipt_user <> gs_user_id Then
//			f_msg_usr_err(9000, Title, "삭제불가! 접수자만 삭제가능합니다.")  //삭제 안됨
//			Return -1
//		End if			
//		
//		//trouble_shoothing table에 해당 사항이 있으면 삭제 불가능
//		Select count(*)
//		Into :ll_cnt
//		From troubl_response
//		Where troubleno = :lc_troubleno;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select Error")
//			RollBack;
//			Return -1
//		End If				
//		
//		If ll_cnt <> 0 Then
//			f_msg_usr_err(9000, Title, "삭제불가! 민원처리건이 존재합니다.")  //삭제 안됨 
//			Return -1
//		Else 							
//			is_check = "DEL"							   //삭제 가능
//		End If
//		
//End Choose
//
Return 0 
end event

event ue_save;call super::ue_save;//

return 0
end event

event type integer ue_insert();//tab2는 맨 마지막에만 insert 되어야 하므로... 조상 스크립트 수정!!

Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return
//ii_error_chk = -1

li_curtab = tab_1.Selectedtab

Choose Case li_curtab
	Case 1
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)		
		
	Case 2  //tab2는 항상 맨 마지막줄에 insert 시킨다... 
		
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].RowCount() + 1)		
End Choose

tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetFocus()

If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
	Return LI_ERROR
End if

//ii_error_chk = 0
Return 0


end event

event ue_extra_save;////Save
long ll_master_row, li_rtn
integer li_seq, li_return
string ls_fromdt

choose case ai_select_tab
	case 1
		
		ll_master_row = dw_master.GetSelectedRow(0)
		IF ll_master_row < 0 THEN RETURN  -1 
		ls_fromdt = dw_master.object.fromdt[ll_master_row]
		li_seq = dw_master.object.seq[ll_master_row]

		  li_return = messagebox("가격정책 생성",ls_fromdt + " 새로운 정책을 생성하시겠습니까?",none!, YesNoCancel!, 3)
		  if li_return = 1 then
				  SetPointer(HourGlass!) 
				  li_rtn = wf_create_rate_mobile(ls_fromdt, li_seq)
				  if li_rtn = 0 then
						messagebox("가격정책 생성", "가격정책이 생성되었습니다.")
						tab_1.Trigger Event SelectionChanged(2, 2)
						SetPointer(Arrow!) 
				  else
						messagebox("가격정책 생성실패", "가격정책을 생성하지 못했습니다.")
						return -1
				  end if 
		
		  end if 

	case 2	
end choose

Return 0
end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
Integer	li_index

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	p_insert.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_deleteall.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
	Next


	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_deleteall.Y	= newheight - iu_cust_w_resize.ii_button_space_1
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

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

type dw_cond from w_a_reg_m_tm2`dw_cond within mobile_reg_modelprice_upload
integer x = 46
integer y = 72
integer width = 1138
integer height = 280
string dataobject = "mobile_cnd_modelprice_upload"
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;
this.accepttext()



CHOOSE CASE dwo.name
	CASE 'fromdt'
		dw_rate.retrieve(data)
		dw_cond.object.todt[row] = date(data)
END CHOOSE
end event

type p_ok from w_a_reg_m_tm2`p_ok within mobile_reg_modelprice_upload
integer x = 1193
integer y = 108
end type

type p_close from w_a_reg_m_tm2`p_close within mobile_reg_modelprice_upload
integer x = 1193
integer y = 224
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within mobile_reg_modelprice_upload
integer x = 1499
integer width = 1769
integer height = 388
integer taborder = 0
end type

type dw_master from w_a_reg_m_tm2`dw_master within mobile_reg_modelprice_upload
integer y = 412
integer width = 3237
integer height = 592
integer taborder = 50
string dataobject = "mobile_mst_modelprice_upload"
end type

event dw_master::clicked;long ll_old_selected_row, ll_selected_row
integer li_tab_index, li_rc

IF row < 1 THEN return

//Call Super::clicked

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_old_selected_row > 0 Then
		For li_tab_index = 1 To tab_1.ii_enable_max_tab
			If tab_1.ib_tabpage_check[li_tab_index] = True Then
				tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
				If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
					(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
					tab_1.SelectedTab = li_tab_index
					li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.!" + &
						"Do you want to cancel?",Question!,YesNo!)
					If li_rc <> 1 Then
						If ll_selected_row > 0 Then
							SelectRow(ll_selected_row ,FALSE)
						End If
						SelectRow(ll_old_selected_row , TRUE )
						ScrollToRow(ll_old_selected_row)
						tab_1.idw_tabpage[li_tab_index].SetFocus()
						Return 
					End If
				End If
			End If	
		Next
	End If
		
	For li_tab_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_tab_index].Reset()
		tab_1.ib_tabpage_check[li_tab_index] = False
	Next
		
	If ll_selected_row > 0 Then
		tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)
//		p_insert.TriggerEvent('ue_enable') 
//		p_delete.TriggerEvent('ue_enable')
//		p_save.TriggerEvent('ue_enable')
//		p_reset.TriggerEvent('ue_enable')
//		tab_1.enabled = true
//		tab_1.idw_tabpage[Tab_1.SelectedTab].SetFocus()
//	Else		
//		p_insert.TriggerEvent('ue_disable')
//		p_delete.TriggerEvent('ue_disable')
//		p_save.TriggerEvent('ue_disable')
//		p_reset.TriggerEvent('ue_disable')
//		tab_1.enabled = false
	End If
End If
end event

type p_insert from w_a_reg_m_tm2`p_insert within mobile_reg_modelprice_upload
integer y = 2300
end type

type p_delete from w_a_reg_m_tm2`p_delete within mobile_reg_modelprice_upload
integer y = 2300
end type

type p_save from w_a_reg_m_tm2`p_save within mobile_reg_modelprice_upload
integer x = 622
integer y = 2300
end type

type p_reset from w_a_reg_m_tm2`p_reset within mobile_reg_modelprice_upload
integer x = 914
integer y = 2300
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within mobile_reg_modelprice_upload
integer x = 32
integer y = 1048
integer width = 3237
integer height = 1212
integer taborder = 60
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init;call super::ue_init;//Tab 초기화
ii_enable_max_tab = 2 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "원본자료"
is_tab_title[2] = "판매정책"

is_dwobject[1] = "mobile_reg_modelprice_t1_upload"
is_dwobject[2] = "mobile_reg_modelprice_t2_upload"

end event

event tab_1::ue_tabpage_retrieve;call super::ue_tabpage_retrieve;
String ls_fromdt, ls_where
Int li_seq
long ll_row

IF al_master_row = 0 THEN RETURN -1		//해당 정보 없음

tab_1.idw_tabpage[ai_select_tabpage].accepttext()
ls_fromdt = dw_master.object.fromdt[al_master_row]
li_seq = dw_master.object.seq[al_master_row]

CHOOSE CASE ai_select_tabpage
	CASE 1								//Tab 1
		
		ls_where = "fromdt = '" + ls_fromdt + "' " 
		If ls_where <> "" Then ls_where += " And "
		ls_where += ls_where + "seq = '" + string(li_seq) + "' "
		
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			RETURN -1
		END IF
		
		//버튼처리
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		p_deleteall.TriggerEvent("ue_disable")
		
	CASE 2								//Tab 2
		
		ls_where = "fromdt = '" + ls_fromdt + "' " 
		
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			RETURN -1
		END IF
		
		//버튼처리
		p_deleteall.visible = true
		p_deleteall.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
END CHOOSE

RETURN 0 
		

		
end event

event tab_1::selectionchanged;call super::selectionchanged;int li_rtn, li_seq, li_return
long ll_master_row
string ls_fromdt



CHOOSE CASE newindex
	CASE 1
//		//버튼처리
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		p_deleteall.TriggerEvent("ue_disable")
	CASE 2
		ll_master_row = dw_master.GetSelectedRow(0)
		IF ll_master_row < 0 THEN RETURN 
		ls_fromdt = dw_master.object.fromdt[ll_master_row]
		li_seq = dw_master.object.seq[ll_master_row]
		
		if tab_1.idw_tabpage[1].rowcount() > 0 and tab_1.idw_tabpage[newindex].rowcount() = 0 then
		     li_return = messagebox("가격정책 생성",ls_fromdt + " 일자의 가격정책이 없습니다. 새로운 정책을 생성하시겠습니까?",none!, YesNoCancel!, 3)
			  if li_return = 1 then
					  SetPointer(HourGlass!) 
					  li_rtn = wf_create_rate_mobile(ls_fromdt, li_seq)
					  if li_rtn = 0 then
							messagebox("가격정책 생성", "가격정책이 생성되었습니다.")
							tab_1.Trigger Event SelectionChanged(2, 2)
							SetPointer(Arrow!) 
							
//							//버튼처리
//							p_deleteall.visible = true
//							p_deleteall.TriggerEvent("ue_enable")
//							p_delete.TriggerEvent("ue_enable")
//							p_save.TriggerEvent("ue_enable")
//							p_reset.TriggerEvent("ue_enable")
							
					  end if 
			  end if 
		end if
		
		
END CHOOSE


end event

event tab_1::ue_dw_clicked;If al_row  <> 0 then

   tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
	tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
End If

return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within mobile_reg_modelprice_upload
integer y = 1024
end type

type st_1 from statictext within mobile_reg_modelprice_upload
integer x = 1522
integer y = 92
integer width = 133
integer height = 48
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "파일"
boolean focusrectangle = false
end type

type st_2 from statictext within mobile_reg_modelprice_upload
integer x = 1522
integer y = 200
integer width = 155
integer height = 112
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "설명"
boolean focusrectangle = false
end type

type sle_filename from singlelineedit within mobile_reg_modelprice_upload
integer x = 1641
integer y = 72
integer width = 1029
integer height = 84
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 1090519039
long backcolor = 25793388
end type

type mle_filedesc from multilineedit within mobile_reg_modelprice_upload
integer x = 1641
integer y = 180
integer width = 1605
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 1090519039
long backcolor = 25793388
integer limit = 100
end type

type dw_temp from u_d_sgl_sel within mobile_reg_modelprice_upload
integer x = 3282
integer y = 24
integer width = 704
integer height = 532
integer taborder = 70
boolean bringtotop = true
string dataobject = "mobile_reg_modelprice_t1_excel"
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;this.hide()
end event

type dw_rate from u_d_external within mobile_reg_modelprice_upload
integer x = 2030
integer y = 280
integer width = 1230
integer height = 80
integer taborder = 50
boolean bringtotop = true
string dataobject = "mobile_cnd_rate"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

type p_find from u_p_find within mobile_reg_modelprice_upload
integer x = 2679
integer y = 68
boolean bringtotop = true
end type

event clicked;call super::clicked;
string pathName, fileName , ls_save_file , ls_svccod
long ll_xls
integer  li_len
	
int value, li_rtn
string ls_win_path 
ls_win_path = space(250) 
GetCurrentDirectoryA(250, ls_win_path) 

ls_svccod = dw_cond.object.svccod[1]
if isnull(ls_svccod)  or ls_svccod = '' then
	messagebox("서비스", "서비스를 선택하세요")
	Return
end if

tab_1.idw_tabpage[1].reset()


		
value = GetFileOpenName("Select File", pathName, fileName, "XLS", &
"Excel Files (*.xls),*.xls," + "All Files(*.*),*.xlsx")
		
IF value = 1 THEN
	parent.sle_filename.text = pathName
END IF

OleObject oleExcel 

oleExcel = Create OleObject 
li_rtn = oleExcel.connecttonewobject("excel.application") 

IF value = 1 THEN
	IF li_rtn = 0 THEN
		oleExcel.WorkBooks.Open(pathName) 
	ELSE
		Messagebox("Information", "Error Occured!!") 
		Destroy oleExcel 
		Return -1
	END IF
ELSE
	Destroy oleExcel 
	Return -1
END IF
		

oleExcel.Application.Visible = False 

ll_xls = PosA(pathName, 'xls')
ls_save_file = MidA(pathName, 1, ll_xls -2) + string(now(),'hhmmss') + '.txt'
is_file = ls_save_file

li_len = LenA(ls_save_file)
if li_len >= 150 then	 
	    messagebox("확인", string(li_len) + "파일 경로가 너무 깁니다. 파일의 위치를 경로가 짧은 곳으로 이동 후 다시 업로드 처리하세요")
		 return
end if 

				
oleExcel.Application.workbooks(1).SaveAs(ls_save_file,-4158) 
oleExcel.Application.workbooks(1).Saved = True
oleExcel.Application.Quit 
oleExcel.DisConnectObject() 
Destroy oleExcel

//버튼 그림파일 경로 되돌려주기
SetCurrentDirectoryA( ls_win_path )


//버튼 조정
p_fileread.TriggerEvent("ue_enable")

end event

type p_fileread from u_p_fileread within mobile_reg_modelprice_upload
integer x = 2971
integer y = 68
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;call super::clicked;
Long		ll_cnt = 0, ll_add_row, ll_row, ll_rtn_cnt, ll_filerow = 0	
String   ls_fromdt, ls_file_desc, ls_priceplan, ls_priceplan_kor, ls_filename, ls_svccod, ls_sale_modelcd, ls_old_modelcd
integer  li_seq, li_rtn, li_dup
dec 		ld_ucube_amt, ld_ubs_amt, ld_rate, ld_margin, ld_old_factoamt

//원본자료로 생성정보
ls_svccod = dw_cond.object.svccod[1]
ls_fromdt = string(dw_cond.object.fromdt[1],'yyyymmdd')
ld_rate = dw_rate.object.exrate[1]
ld_margin = dw_rate.object.margin[1]
ls_filename = sle_filename.text 

SELECT NVL(COUNT(*), 0) + 1 INTO :li_seq
FROM MODEL_PRICE_UPLOG
WHERE FROMDT = :ls_fromdt;

ls_file_desc = trim(parent.mle_filedesc.text)

IF ls_file_desc = '' THEN
	f_msg_info(200, "", "파일설명을 입력하세요.")
	This.SetFocus()
	RETURN 0
END IF		

//UBS 환율
if isnull(ld_rate)  then
	messagebox("환율", "입력된 환율이 없습니다.")
	return
end if
	
//UBS 마진율
if  isnull(ld_margin) then
	messagebox("마진율", "입력된 마진율이 없습니다.")
	return
end if


//업로드파일 체크
IF isNull(is_file) THEN is_file = ""
		
IF is_file = "" THEN
	f_msg_info(200, "", "File Name")
	This.SetFocus()
	RETURN 0
END IF		

//파일 임포트
dw_temp.reset()
tab_1.idw_tabpage[1].reset()
ll_rtn_cnt = dw_temp.ImportFile(is_file,1)

//임포트 에러 메세지
Choose case ll_rtn_cnt
	case  0
		Messagebox("Information",'End of file; too many rows ') 
		Return
	CASE -1   
		MessageBox('Information', 'No rows') 
		RETURN 
	CASE -2   
		MessageBox('Information', 'Empty file') 
		RETURN 
	CASE -3   
		MessageBox('Information', 'Invalid argument') 
		RETURN 
	CASE -4   
		MessageBox('Information', 'Invalid input') 
		RETURN 
	CASE -5   
		MessageBox('Information', 'Could not open the file') 
		RETURN 
	CASE -6   
		MessageBox('Information', 'Could not close the file') 
		RETURN 
	CASE -7   
		MessageBox('Information', 'Error reading the text') 
		RETURN 
	CASE -8   
		MessageBox('Information', 'Not a TXT file') 
		RETURN 
	CASE -9   
		MessageBox('Information', 'The user canceled the import') 
		RETURN 
	CASE ELSE 
				
	END CHOOSE 


//원본자료로 생성
ll_cnt = 0
ll_filerow = dw_temp.rowcount()
			
FOR ll_row = 1 to ll_filerow 
	
	tab_1.idw_tabpage[1].InsertRow(tab_1.idw_tabpage[1].rowcount()+1)
	ll_cnt = ll_cnt + 1
	tab_1.idw_tabpage[1].object.svccod[ll_row]			= ls_svccod
	tab_1.idw_tabpage[1].object.fromdt[ll_row] 			= ls_fromdt
	tab_1.idw_tabpage[1].object.seq[ll_row] 				= li_seq
	tab_1.idw_tabpage[1].object.sale_modelcd[ll_row] 	= dw_temp.object.sale_modelcd[ll_row]
	tab_1.idw_tabpage[1].object.nickname[ll_row] 		= dw_temp.object.nickname[ll_row]
	tab_1.idw_tabpage[1].object.facto_amt[ll_row] 		= dw_temp.object.facto_amt[ll_row]	   
	tab_1.idw_tabpage[1].object.priceplan_kor[ll_row] 	= dw_temp.object.priceplan_kor[ll_row]
	tab_1.idw_tabpage[1].object.sub_amt1[ll_row] 		= dw_temp.object.sub_amt1[ll_row]	   
	tab_1.idw_tabpage[1].object.sub_amt2[ll_row] 		= dw_temp.object.sub_amt2[ll_row]
	ld_ucube_amt = dw_temp.object.facto_amt[ll_row]	- dw_temp.object.sub_amt1[ll_row] - dw_temp.object.sub_amt2[ll_row]
	tab_1.idw_tabpage[1].object.ucube_amt[ll_row] 		= ld_ucube_amt
	tab_1.idw_tabpage[1].object.rate[ll_row]				= ld_rate
	tab_1.idw_tabpage[1].object.margin[ll_row]			= ld_margin
	tab_1.idw_tabpage[1].object.crtdt[ll_row]				= today()
	tab_1.idw_tabpage[1].object.crt_user[ll_row]			= gs_user_id
	
	//업로드 시 동일 판매모델 출고가가 상이할 경우 메시지 표시
	if ls_old_modelcd = tab_1.idw_tabpage[1].object.sale_modelcd[ll_row] then  //동일모델이면
		if ld_old_factoamt <> tab_1.idw_tabpage[1].object.facto_amt[ll_row] then //동일모델인데 출고가가 다르면
			messagebox("가격정책 맵핑", "동일모델 : " +ls_old_modelcd + ' 의 출고가가 상이한 자료가 있습니다. RESET 버튼을 눌러 다시 업로드 하세요')
			tab_1.idw_tabpage[1].resetupdate()
			p_find.TriggerEvent("ue_disable")
			p_fileread.TriggerEvent("ue_disable")
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
			return -1
		end if
	end if
	
	

	
	
	//UBS 가격정책 가져오기
	ls_priceplan_kor  = dw_temp.object.priceplan_kor[ll_row]
	ls_sale_modelcd	= dw_temp.object.sale_modelcd[ll_row]
	
	SELECT PRICEPLAN INTO :ls_priceplan
	FROM PRICEPLANMST_MOBILE
	WHERE PRICEPLAN_DESC_KR = :ls_priceplan_kor
	  AND SVCCOD = :ls_svccod
	  AND USEYN = 'Y';
	
   IF SQLCA.SQLCODE <> 0 THEN
		messagebox("가격정책 맵핑", ls_priceplan_kor + ' 에 상응하는 영문 가격정책이 없습니다. RESET 버튼을 눌러 다시 업로드 하세요')
		tab_1.idw_tabpage[1].resetupdate()
		p_find.TriggerEvent("ue_disable")
		p_fileread.TriggerEvent("ue_disable")
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		return -1
	END IF
	
	tab_1.idw_tabpage[1].object.priceplan[ll_row] = ls_priceplan
	
	
	//중복자료 확인
	SELECT COUNT(*) INTO :li_dup
	FROM PRICEPLAN_RATE_MOBILE
	WHERE SVCCOD = :ls_svccod
		AND PRICEPLAN = :ls_priceplan
		AND SALE_MODELCD = :ls_sale_modelcd
		AND TO_CHAR(FROMDT,'YYYYMMDD') = :ls_fromdt;
		
	If SQLCA.SQLCode < 0 Then
			f_msg_sql_err("확인", " SELCET COUNT(*) Error(PRICEPLAN_RATE_MOBILE)")
			Return 
	End If	
	
	IF li_dup > 0  THEN
			messagebox("가격정책 중복","(가격정책 :" + ls_priceplan_kor + " / 모델 :" + ls_sale_modelcd + ") 업로드 파일에 해당적용 시작일이 중복되는 정책이 존재합니다. RESET 버튼을 눌러 다시 업로드 하세요")
			tab_1.idw_tabpage[1].resetupdate()
			p_find.TriggerEvent("ue_disable")
			p_fileread.TriggerEvent("ue_disable")
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
			return -1
	END IF
	//중복자료 확인
		
	//UBS 달러금액
	ld_ubs_amt = (ld_ucube_amt  * ld_margin) / ld_rate 
					 
	// f_roundup ( ag_num , ag_pos), // 아규먼트(ag_num 값,  ag_pos 자릿수)       
	dec ld_pos 
	ld_pos = 10.^1
	
	ld_ubs_amt =  Ceiling( ld_ubs_amt / ld_pos  ) * ld_pos  

   if ld_ucube_amt < 0 then ld_ubs_amt = 0 // ucube_amt가 - 값이면  ubs_amt = 0
	tab_1.idw_tabpage[1].object.ubs_amt[ll_row] = ld_ubs_amt
	
	
	ls_old_modelcd = tab_1.idw_tabpage[1].object.sale_modelcd[ll_row]
	ld_old_factoamt = tab_1.idw_tabpage[1].object.facto_amt[ll_row]

NEXT

li_rtn = tab_1.idw_tabpage[1].update()

IF li_rtn = 1 THEN
	
	INSERT INTO MODEL_PRICE_UPLOG
	(FROMDT, SEQ, SVCCOD, FILENM, FILENM_DESC, REQCNT, CRTDT, UPDTDT, CRT_USER, UPDT_USER, PGM_ID)
	VALUES
	(:ls_fromdt, :li_seq, :ls_svccod, :ls_filename, :ls_file_desc, :ll_cnt, sysdate, null, :gs_user_id, null, null);
	
	If SQLCA.SQLCode < 0 Then
			f_msg_sql_err("확인", " INSERT Error(MODEL_PRICE_UPLOG)")
			rollback;
			Return 
	End If	
	
	commit;
	
	parent.Trigger Event ue_ok()
	messagebox("완료", string(ll_rtn_cnt) + "개의 자료가 업로드 되었습니다.")
	
else
	messagebox("실패", "자료가 업로드 되지 않았습니다. 자료를 확인하시고 RESET 버튼을 눌러 다시 업로드 하세요.")
	return
end if
			 
//마지막 row로 간다.
tab_1.idw_tabpage[1].ScrollToRow(ll_cnt)
tab_1.idw_tabpage[1].SetRow(ll_cnt)
tab_1.idw_tabpage[1].SetFocus()	

//ue_reset()
end event

type p_deleteall from u_p_alldelete within mobile_reg_modelprice_upload
integer x = 1362
integer y = 2300
boolean bringtotop = true
end type

event clicked;call super::clicked;string ls_fromdt
integer li_return, li_rtn
date ld_fromdt

if tab_1.idw_tabpage[2].rowcount() <= 0 then
		messagebox("확인", "삭제할 자료가 없습니다.")
	   return
end if

ld_fromdt = date(tab_1.idw_tabpage[2].object.fromdt[1])

li_return = messagebox("삭제",string(ld_fromdt) + " 일자의 가격정책을 모두 삭제합니다. 계속 진행 하시겠습니까?",none!, YesNoCancel!, 3)
if li_return = 1 then
		  SetPointer(HourGlass!) 	
		  
		  //삭제
		  DELETE FROM PRICEPLAN_RATE_MOBILE
		  WHERE fromdt = :ld_fromdt;
		  
		  IF SQLCA.SQLCODE < 0 THEN
				f_msg_sql_err(Title, "DELETE Error(PRICEPLAN_RATE_MOBILE)")
				ROLLBACK;
				RETURN -1
		 
		  ELSE
			   COMMIT;
				messagebox("완료", "삭제 되었습니다.")
				tab_1.Trigger Event SelectionChanged(2, 2)				
		  END IF
		  SetPointer(Arrow!) 
end if 
end event

type gb_file from gb_cond within mobile_reg_modelprice_upload
integer x = 32
integer width = 1477
end type

