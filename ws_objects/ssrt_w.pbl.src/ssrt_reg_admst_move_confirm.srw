$PBExportHeader$ssrt_reg_admst_move_confirm.srw
$PBExportComments$[1hera] 단품이동 및 확인관리
forward
global type ssrt_reg_admst_move_confirm from w_a_reg_m
end type
type p_transfer from u_p_transfer within ssrt_reg_admst_move_confirm
end type
type p_confirm from u_p_confirm within ssrt_reg_admst_move_confirm
end type
type st_1 from statictext within ssrt_reg_admst_move_confirm
end type
type dw_shop from datawindow within ssrt_reg_admst_move_confirm
end type
type gb_1 from groupbox within ssrt_reg_admst_move_confirm
end type
end forward

global type ssrt_reg_admst_move_confirm from w_a_reg_m
integer width = 3881
integer height = 2136
event type integer ue_confirm ( )
event type integer ue_transfer ( )
p_transfer p_transfer
p_confirm p_confirm
st_1 st_1
dw_shop dw_shop
gb_1 gb_1
end type
global ssrt_reg_admst_move_confirm ssrt_reg_admst_move_confirm

type variables
String is_move, is_sale, is_return, is_all
end variables

forward prototypes
public subroutine wf_set_total ()
end prototypes

event ue_confirm;INTEGER	li_chk
STRING	ls_chk,		ls_status, 		ls_contno,		ls_emp_group,		ls_partner,		&
			ls_action
LONG		ll_cnt,		ll_adseq,		ii,				ll_seq

// Move ==> Sale 

ll_cnt =  dw_detail.rowCount()
IF dw_detail.Object.cp_tot[ll_cnt]  =  0 then
	f_msg_usr_err(9000, Title, "처리하고자 하는 장비를 선택하세요.")
	dw_detail.SetFocus()
	Return 	-1
END IF

select emp_group into :ls_emp_group from sysusr1t where emp_id = :gs_user_id;

//ADMSTLOG_NEW 테이블에 ACTION 값 ( 입고 확정 )
SELECT ref_content INTO :ls_action FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A102';

FOR ii = 1 to ll_cnt
	li_chk 		= dw_detail.Object.chk[ii]
	ls_status 	= Trim(dw_detail.Object.status[ii])
	ls_contno 	= Trim(dw_detail.Object.contno[ii])
		ll_adseq =  dw_detail.Object.adseq[ii]
	IF li_chk = 1 then
		
		IF ls_status <> is_move THEN
			f_msg_usr_err(9000, Title, "Control No : " + ls_contno + "의 상태를 확인하세요")
			Rollback ;
			dw_detail.SetFocus()
			dw_detail.SetRow(ii)
			Return 	-1
		END IF
		
		select to_partner into :ls_partner from admst where adseq = :ll_adseq;
		
		IF ls_partner <> ls_emp_group THEN
			f_msg_usr_err(9000, Title, "샵 권한이 불충분합니다. Control No : " + ls_contno )
			Rollback ;
			dw_detail.SetFocus()
			dw_detail.SetRow(ii)
			Return 	-1
		END IF
		
		//Update 
	   UPDATE ADMST  
		   SET STATUS 	= :is_sale,
				 movedt   = sysdate,
				 mv_partner = :gs_shopid,
				 updtdt      = sysdate,
				 updt_user   = :gs_user_id					
		 WHERE ADSEQ 	= :ll_adseq  
		   AND status 	= :is_move;
			  
		IF sqlca.sqlcode < 0 then
			Rollback ;			
			f_msg_usr_err(9000, Title, "Update Error( ADMST ) ==> ADSEQ : " + String(ll_adseq))
			Return -1
		END IF
		
		//장비이력(admstlog) Table에 정보저장
		//일련번호(seq)추출
		SELECT seq_admstlog.nextval	INTO :ll_seq	FROM dual;		
		
		INSERT INTO ADMSTLOG_NEW		
			( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
			  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
			  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
			  PGM_ID, IDATE )
		SELECT ADSEQ, :ll_seq, :ls_action, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, STATUS,
				 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
				 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
				 :gs_pgm_id[gi_open_win_no], IDATE
		FROM   ADMST
		WHERE  ADSEQ = :ll_adseq;

		IF sqlca.sqlcode < 0 then
			Rollback ;			
			f_msg_usr_err(9000, Title, "INSERT Error( ADMSTLOG_NEW ) ==> ADSEQ : " + String(ll_adseq))
			Return -1
		END IF			
	END IF
NEXT
Commit ;
f_msg_info(3000, Title, "Confirm")

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
This.TriggerEvent("ue_ok")

return 0

end event

event ue_transfer;INTEGER	ii,			li_chk
String 	ls_chk,		ls_shop,			ls_status,			ls_contno,			ls_emp_group,		&
			ls_partner,	ls_action	
LONG		ll_cnt,		ll_adseq,		ll_seq

ls_shop = Trim(dw_shop.Object.shop[1])
IF IsNull(ls_shop) then ls_shop = ''
IF ls_shop = "" then
	f_msg_usr_err(200, Title, "shop")
	dw_shop.SetFocus()
	dw_shop.SetRow(1)
	dw_shop.SetColumn("shop")
	Return -1
END IF

// Sale, Return ==> Move 
ll_cnt =  dw_detail.rowCount()
IF dw_detail.Object.cp_tot[ll_cnt]  =  0 then
	f_msg_usr_err(9000, Title, "처리하고자 하는 장비를 선택하세요.")
	dw_detail.SetFocus()
	Return 	-1
END IF

select emp_group into :ls_emp_group from sysusr1t where emp_id = :gs_user_id;

//ADMSTLOG_NEW 테이블에 ACTION 값 ( 이동 )
SELECT ref_content INTO :ls_action FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A101';

FOR ii = 1 to ll_cnt
	li_chk 		= dw_detail.Object.chk[ii]
	ls_status 	= Trim(dw_detail.Object.status[ii])
	ls_contno 	= Trim(dw_detail.Object.contno[ii])
	ll_adseq =  dw_detail.Object.adseq[ii]	

	IF li_chk = 1 then
		IF ( ls_status = is_sale OR ls_status = is_return ) THEN
		ELSE
			f_msg_usr_err(9000, Title, "Control No : " + ls_contno + "의 상태를 확인하세요")
			Rollback ;
			dw_detail.SetFocus()
			dw_detail.SetRow(ii)
			Return 	-1
		END IF
		
		select mv_partner into :ls_partner from admst where adseq = :ll_adseq;
		
   	IF ls_partner <> ls_emp_group THEN
			f_msg_usr_err(9000, Title, "해당 물품은 이동할 수 있는 권한이 없습니다. Control No : " + ls_contno )
			Rollback ;
			dw_detail.SetFocus()
			dw_detail.SetRow(ii)
			Return 	-1
		END IF

		//Update 
		  UPDATE ADMST  
           SET STATUS 		= :is_move,
					movedt		= sysdate,
					sn_partner  = :ls_partner,
					to_partner  = :ls_shop,
					updtdt      = sysdate,
					updt_user   = :gs_user_id
         WHERE ADSEQ 		= :ll_adseq         
			  AND ( STATUS		= :is_sale OR STATUS = :is_return);
			  
		IF sqlca.sqlcode < 0 then
			f_msg_usr_err(9000, Title, "Update Error( ADMST ) ==> ADSEQ : " + String(ll_adseq))
			Rollback ;
			Return -1
		END IF

		//장비이력(admstlog) Table에 정보저장
		//일련번호(seq)추출
		SELECT seq_admstlog.nextval	INTO :ll_seq	FROM dual;		
		
		INSERT INTO ADMSTLOG_NEW		
			( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
			  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
			  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
			  PGM_ID, IDATE )
		SELECT ADSEQ, :ll_seq, :ls_action, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, STATUS,
				 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
				 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
				 :gs_pgm_id[gi_open_win_no], IDATE
		FROM   ADMST
		WHERE  ADSEQ = :ll_adseq;

		IF sqlca.sqlcode < 0 then
			Rollback ;			
			f_msg_usr_err(9000, Title, "INSERT Error( ADMSTLOG_NEW ) ==> ADSEQ : " + String(ll_adseq))
			Return -1
		END IF
	END IF
NEXT
Commit ;
f_msg_info(3000, Title, "Transfer")
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
This.TriggerEvent("ue_reset")


return 0



end event

public subroutine wf_set_total ();dec{2} ldc_TOTAL, ldc_receive, ldc_change, &
			ldc_tot1, ldc_tot2, ldc_tot3

ldc_total = 0
ldc_tot1 = 0
ldc_tot2 = 0
ldc_tot3 = 0

IF dw_detail.RowCount() > 0 THEN
	ldc_total 	=  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_refund")
END IF
dw_cond.Object.total[1] 		= ldc_total

//
//F_INIT_DSP(2, "", String(ldc_total))
//
return 
end subroutine

on ssrt_reg_admst_move_confirm.create
int iCurrent
call super::create
this.p_transfer=create p_transfer
this.p_confirm=create p_confirm
this.st_1=create st_1
this.dw_shop=create dw_shop
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_transfer
this.Control[iCurrent+2]=this.p_confirm
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.dw_shop
this.Control[iCurrent+5]=this.gb_1
end on

on ssrt_reg_admst_move_confirm.destroy
call super::destroy
destroy(this.p_transfer)
destroy(this.p_confirm)
destroy(this.st_1)
destroy(this.dw_shop)
destroy(this.gb_1)
end on

event ue_ok;String 	ls_where,  		ls_partner, 	ls_status, &
		 	ls_contno_fr, 	ls_contno_to,	ls_adtype, ls_serialno_fr, ls_serialno_to, ls_modelno, ls_modelnm
Long 		ll_row

dw_cond.accepttext()

ls_contno_fr	= Trim(dw_cond.object.contno_fr[1])
ls_contno_to	= Trim(dw_cond.object.contno_to[1])
ls_STATUS 		= Trim(dw_cond.object.status[1])
ls_adtype 		= Trim(dw_cond.object.adtype[1])
//검색조건추가
ls_serialno_fr = Trim(dw_cond.object.serialno_fr[1])
ls_serialno_to = Trim(dw_cond.object.serialno_to[1])
ls_modelno = Trim(dw_cond.object.modelno[1])
//ls_modelnm  = Trim(dw_cond.object.modelnm[1])

If IsNull(ls_contno_fr) 	Then ls_contno_fr 	= ""
If IsNull(ls_contno_to) 	Then ls_contno_to 	= ""
If IsNull(ls_status) 		Then ls_status 		= ""
If IsNull(ls_adtype) 		Then ls_adtype 		= ""

IF ls_status = "" then
	f_msg_usr_err(200, Title, "Status")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("status")
	Return 
END IF

ls_where = ""

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.status = '" + ls_status + "' "
	
	IF ls_status = is_move THEN
		ls_where += " And "
		ls_where += "a.to_partner = '" + GS_SHOPID + "' "
	ELSE 
		ls_where += " And "
		ls_where += "a.mv_partner = '" + GS_SHOPID + "' "	
	END IF
End If

//ADTYPE
If ls_adtype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.adtype = '" + ls_adtype + "' "
End If

//Contno From ~ To
If ls_contno_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.contno >= '" + ls_contno_fr + "' "
End If
If ls_contno_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.contno <= '" + ls_contno_to + "' "
End If

//serialno from To
IF ls_serialno_fr <> "" THEN
IF ls_where <> "" THEN ls_where += " AND "
	  ls_where += "a.serialno >= '" + ls_serialno_fr + "'"
 END IF
 
 IF ls_serialno_to <> "" THEN
	  IF ls_where <> "" THEN ls_where += " AND "
	  ls_where += "a.serialno <= '" + ls_serialno_to + "'"
 END IF
 
//modelno 
IF ls_modelno <> "" THEN
        IF ls_where <> "" THEN ls_where += " AND "
        ls_where += "a.modelno = '" + ls_modelno + "' "
END IF

//modelname
//IF ls_modelnm <> "" THEN
//        IF ls_where <> "" THEN ls_where += " AND "
//        ls_where += "b.modelnm like '%" + ls_modelnm + "%' "
//END IF
//messagebox("", ls_where)

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
//

end event

event type integer ue_extra_save();//Long 		ll_row, 		i, 	ll_seq, 		ll_tmp
//Dec{2} 	lc_amt[], 	lc_totalamt,		ldc_tmp
//Dec 		lc_saleamt
//Integer 	li_rc, 		li_rtn,				li_tmp
//String 	ls_itemcod, ls_paydt, 			ls_customerid, 		ls_memberid, &
//			ls_rf_type, ls_partner,			ls_tmp,					ls_operator, &
//			ls_remark
//
//b1u_dbmgr_dailypayment	lu_dbmgr
//dw_cond.AcceptText()
//
//idc_total 		= 0
//ls_remark 		= trim(dw_cond.Object.remark[1])
//ls_customerid 	= trim(dw_cond.Object.customerid[1])
//ls_Operator 	= trim(dw_cond.Object.operator[1])
//ls_MEMBERid 	= trim(dw_cond.Object.memberid[1])
//idc_total 		= dw_cond.Object.total[1]
//idc_receive 	= dw_cond.Object.cp_receive[1]
//idc_change 		= dw_cond.Object.cp_change[1]
//ls_paydt 		= String(dw_cond.Object.paydt[1], 'yyyymmdd')
//ls_partner 		= Trim(dw_cond.object.partner[1])
//
////고객번호 및 오퍼레이터 존재여부 확인
//IF IsNUll(ls_remark) 		then ls_remark 	= ''
//IF IsNUll(ls_customerid) 	then ls_customerid 	= ''
//IF IsNUll(ls_operator) 		then ls_operator 		= ''
//li_rtn = f_check_ID(ls_customerid, ls_operator)
//IF li_rtn =  -1 THEN
//		f_msg_usr_err(9000, Title, "Customerid가 존재하지 않습니다.")
//		dw_cond.SetFocus()
//		dw_cond.SetRow(1)
//		dw_cond.Object.customerid[1] = ''
//		dw_cond.Object.customernm[1] = ''
//		dw_cond.SetColumn("customerid")
//		Return -1 
//ELSEIF li_rtn = -2 THEN 
//		f_msg_usr_err(9000, Title, "Operator가 존재하지 않습니다.")
//		dw_cond.SetFocus()
//		dw_cond.SetRow(1)
//		dw_cond.Object.operator[1] = ''
//		dw_cond.SetColumn("operator")
//		Return -1 
//END IF
//
//
//
//
//FOR i =  1 to dw_detail.rowCount()
//	dw_detail.Object.remark[i]	= ls_remark
//	ls_rf_type = dw_detail.Object.refund_type[i]
//	IF IsNull(ls_rf_type) then ls_rf_type = ""
//	IF ls_rf_type <> "" THEN
//		idc_total 	+= dw_detail.Object.refund_price[i]
//	END IF
//NEXT
//
//IF idc_total <> idc_receive then
//	f_msg_usr_err(9000, Title, "입금액이 맞지 않습니다. 확인 바랍니다.")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("amt1")
//	Return -2	
//END IF
////==========================================================
//// 입금액이 sale금액보다 크거나 같으면.... 처리
////==========================================================
//
////li_rtn = MessageBox("Result", "영수증 출력을 하시겠습니까?", Exclamation!, YesNo!, 1)
//li_rtn = 1
////저장
//lu_dbmgr = Create b1u_dbmgr_dailypayment
//
//lu_dbmgr.is_caller 	= "save_refund"
//lu_dbmgr.is_title 	= Title
//lu_dbmgr.idw_data[1] = dw_cond 	//조건
//lu_dbmgr.idw_data[2] = dw_detail //조건
//
//lu_dbmgr.is_data[1] 	= ls_customerid
//lu_dbmgr.is_data[2] 	= ls_paydt  //paydt(shop별 마감일 )
//lu_dbmgr.is_data[3] 	= ls_partner //shopid
//lu_dbmgr.is_data[4] 	= GS_USER_ID //Operator
//IF li_rtn = 1 THEN 
//	lu_dbmgr.is_data[5] 	= "Y"
//ELSE
//	lu_dbmgr.is_data[5] 	= "N"
//END IF
//
//lu_dbmgr.is_data[6] 	= gs_pgm_id[gi_open_win_no]
//lu_dbmgr.is_data[7] 	= "Y" //ADMST Update 여부
//lu_dbmgr.is_data[8] 	= ls_memberid //memberid
//lu_dbmgr.is_data[9] 	= "N" //ADLOG Update여부
//lu_dbmgr.is_data[10]	= "REFUND" //PGM_ID
//
//
//lu_dbmgr.uf_prc_db_07()
////위 함수에서 이미 commit 한 상태임.
//li_rc = lu_dbmgr.ii_rc
//Destroy lu_dbmgr
//
//If li_rc = -1 Or li_rc = -3 Then
//	Return -1
//ELSEIf li_rc = -2 Then
//	f_msg_usr_err(9000, Title, "!!")
//	Return -1
//End If
//
//dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
//dw_cond.SetFocus()
//dw_detail.Reset()
Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화

p_ok.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_disable")
p_confirm.TriggerEvent("ue_disable")
p_transfer.TriggerEvent("ue_disable")
dw_cond.Enabled = True

dw_cond.ReSet()
dw_cond.InsertRow(0)
dw_shop.ReSet()
dw_shop.InsertRow(0)

dw_cond.SetFocus()
dw_cond.SetColumn("status")
is_all = '0'

Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:  ssrt_reg_admst_move_confirm
	Desc.	: 	단품이동 및 확인
	Ver.	:	1.0
	Date	: 	2006.9.11
	Programer : Cho Kyung Bok [ 1hera ]
--------------------------------------------------------------------------*/
String ls_ref_desc

//장비상태- Move
is_move 			= fs_get_control("E1", "A100", ls_ref_desc)
is_return 		= fs_get_control("E1", "A102", ls_ref_desc)
is_sale 			= fs_get_control("E1", "A104", ls_ref_desc)

end event

event type integer ue_save();//Constant Int LI_ERROR = -1
//
//If dw_detail.AcceptText() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
//End If
//
//If This.Trigger Event ue_extra_save() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
//End If
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
//
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
//	f_msg_info(3000,This.Title,"Save")
//	This.Trigger Event ue_reset() 
//	
//End If
//
Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_admst_move_confirm
integer x = 46
integer y = 52
integer width = 1819
integer height = 412
integer taborder = 10
string dataobject = "ssrt_cnd_admst_move_confirm"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;datawindowchild ldc_modelno
string ls_filter, ls_adtype
integer li_exist

this.accepttext()

Choose Case dwo.name
	case "contno_fr"
		this.Object.contno_to[1] =  data
		
	case "serialno_fr"
		this.Object.serialno_to[1] =  data
		
	case "adtype"
		
		li_exist = This.GetChild("modelno", ldc_modelno)        //DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 모델명")
		ls_filter = "adtype = '" + data  + "'  " 
		ldc_modelno.SetTransObject(SQLCA)
		li_exist =ldc_modelno.Retrieve()
		ldc_modelno.SetFilter(ls_filter)            //Filter정함
		ldc_modelno.Filter()
	case "modelno"
		
//		li_exist = This.GetChild("modelno", ldc_modelno)        //DDDW 구함
//		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 모델명")
//		ls_filter = "adtype = '" + data  + "'  " 
//		ldc_modelno.SetTransObject(SQLCA)
//		li_exist =ldc_modelno.Retrieve()
//		ldc_modelno.SetFilter(ls_filter)            //Filter정함
//		ldc_modelno.Filter()
		
End Choose

end event

type p_ok from w_a_reg_m`p_ok within ssrt_reg_admst_move_confirm
integer x = 2080
integer y = 116
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_admst_move_confirm
integer x = 2679
integer y = 116
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_admst_move_confirm
integer width = 1870
integer height = 480
integer taborder = 0
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_admst_move_confirm
boolean visible = false
integer x = 329
integer y = 1880
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_admst_move_confirm
boolean visible = false
integer x = 37
integer y = 1880
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_admst_move_confirm
boolean visible = false
integer y = 1880
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_admst_move_confirm
integer x = 37
integer y = 496
integer width = 3680
integer height = 1336
integer taborder = 20
string dataobject = "ssrt_reg_admst_move_confirm"
end type

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_ok.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_confirm.TriggerEvent("ue_disable")
	p_transfer.TriggerEvent("ue_disable")
	dw_cond.Enabled = True
ELSE
	p_ok.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_transfer.TriggerEvent("ue_enable")
	p_confirm.TriggerEvent("ue_enable")
	dw_cond.Enabled = false
END IF


end event

event dw_detail::constructor;call super::constructor;//손모양을 막는다.
dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemerror;call super::itemerror;return 1
end event

event dw_detail::buttonclicked;call super::buttonclicked;Long	ll,	ll_cnt

ll_cnt = this.rowCount()
IF ll_cnt  = 0 then Return
choose case dwo.name
	case 'b_all'
		IF is_all = '0' then
			is_all = '1'
		ELSE
			is_all = '0'
		END IF
		for ll =  1 to ll_cnt
			IF is_all = '1' then
				this.Object.chk[ll] = 1
			ELSE
				this.Object.chk[ll] = 0
			END IF
		NEXT
	case else
end choose
end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_admst_move_confirm
integer x = 2971
integer y = 116
end type

type p_transfer from u_p_transfer within ssrt_reg_admst_move_confirm
integer x = 3419
integer y = 348
boolean bringtotop = true
boolean originalsize = false
end type

type p_confirm from u_p_confirm within ssrt_reg_admst_move_confirm
integer x = 2382
integer y = 116
boolean bringtotop = true
boolean originalsize = false
end type

type st_1 from statictext within ssrt_reg_admst_move_confirm
integer x = 1957
integer y = 348
integer width = 329
integer height = 84
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "To Shop"
alignment alignment = center!
boolean border = true
borderstyle borderstyle = styleraised!
boolean focusrectangle = false
end type

type dw_shop from datawindow within ssrt_reg_admst_move_confirm
integer x = 2309
integer y = 344
integer width = 1097
integer height = 96
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_cnd_admst_move_confirm_shop"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;this.SetTransObject(sqlca)

end event

type gb_1 from groupbox within ssrt_reg_admst_move_confirm
integer x = 1911
integer y = 276
integer width = 1833
integer height = 204
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

