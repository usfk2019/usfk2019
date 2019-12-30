$PBExportHeader$ubs_w_pop_equipvalid_dsl.srw
$PBExportComments$[jhchoi] 장비인증 팝업2(dsl)- 2011.03.02
forward
global type ubs_w_pop_equipvalid_dsl from w_a_hlp
end type
type dw_master from datawindow within ubs_w_pop_equipvalid_dsl
end type
type p_save from u_p_save within ubs_w_pop_equipvalid_dsl
end type
type dw_split from datawindow within ubs_w_pop_equipvalid_dsl
end type
type dw_detail from datawindow within ubs_w_pop_equipvalid_dsl
end type
type cb_next from commandbutton within ubs_w_pop_equipvalid_dsl
end type
type cb_pre from commandbutton within ubs_w_pop_equipvalid_dsl
end type
type p_reset from u_p_reset within ubs_w_pop_equipvalid_dsl
end type
type gb_1 from groupbox within ubs_w_pop_equipvalid_dsl
end type
end forward

global type ubs_w_pop_equipvalid_dsl from w_a_hlp
integer width = 3131
integer height = 1412
string title = ""
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event type long ue_retrieve_left ( )
event type long ue_retrieve_right ( )
event ue_reset ( )
dw_master dw_master
p_save p_save
dw_split dw_split
dw_detail dw_detail
cb_next cb_next
cb_pre cb_pre
p_reset p_reset
gb_1 gb_1
end type
global ubs_w_pop_equipvalid_dsl ubs_w_pop_equipvalid_dsl

type variables
u_cust_db_app iu_cust_db_app

STRING 	is_print_check, 	is_amt_check, 	is_customerid, 	is_phone_type, 	&
       	is_paycod,			is_format,		is_reqdt,		 	is_method[], 		&
		   is_trcod[],			is_save_check,	is_work
DATE 	 	idt_shop_closedt
DOUBLE	ib_seq
DEC{2} 	idc_amt[], 			idc_total, 		idc_income_tot
INTEGER 	ii_method_cnt,		ii_equipselect = 0

STRING	is_orderno,			is_partner,			is_userid,			&
			is_rental700[],	is_rental800[],	is_rental900[],	&
			is_old_sql,			is_priceplan,		is_svccod,			&
			is_vocm,				is_ref_orderno,	is_status,			&
			is_gubunnm,			is_worktype,		is_troubleno,		&
			is_wifi[],			is_equipdate,		is_bad_status,		&
			is_contractseq
	

end variables

forward prototypes
public subroutine wf_set_total ()
end prototypes

event ue_process;STRING	ls_data_check,		ls_errmsg,			ls_action,			ls_adtype,			&
			ls_first_adtype,	ls_second_adtype,	ls_work,				ls_spec_item1,		&
			ls_data_chk_gg,	ls_spec_item_gg,	ls_action_gg, 		&
			ls_work_gg,			ls_adtype_gg,		ls_adtype_w
LONG		ll_equipseq,		ll_return,			ll_row,				ll_return2
LONG		ll_contractseq,	ll_insert_equip,	ll_row_det
INT		ii,					iii,					jj,					cc, 					&
			gg,					g,						r
LONG		ll_insert_case,	ll_retrie_case,	ll_delete_case,	ll_etc_case,	ll_equip_gg
LONG 		ll_return_c,		ll_delete_gg,		ll_insert_gg,		ll_equipseq_w
LONG		ll_func_check,		ll_func_chg_check

dw_detail.AcceptText()

ll_row = dw_detail.RowCount()

IF ll_row <= 0 THEN
	f_msg_usr_err(9000, Title, "임대/예약중 장비가 없습니다.")
	ai_return = -1
	ROLLBACK;
	RETURN	
END IF

//수정된 내용이 없도록 하기 위해서 강제 세팅!
FOR ii = 1 TO ll_row
	dw_detail.SetItemStatus(ii, 0, Primary!, NotModified!)
NEXT

ai_return = 0

RETURN
end event

event ue_retrieve_left;STRING	ls_modelno,			ls_searchno,		ls_shop,		ls_new_sql,		&
			ls_status_where,	ls_new_sql2
INT		li_i,					li_exist

dw_hlp.AcceptText()

ls_modelno	= Trim(dw_hlp.object.modelno[1])
ls_searchno = dw_hlp.object.searchno[1]
ls_shop		= Trim(dw_hlp.object.shop[1])

IF IsNull(ls_modelno)  OR ls_modelno  = ""  THEN RETURN 0
IF IsNull(ls_searchno) OR ls_searchno = "" THEN ls_searchno = ""
IF IsNull(ls_shop) 	  OR ls_shop = "" 	 THEN ls_shop = ""

ls_status_where = ""
FOR li_i = 1 TO UpperBound(is_rental700[])
	IF ls_status_where <> ""  THEN ls_status_where += ", "
	ls_status_where += "'" + is_rental700[li_i] + "'"
NEXT

ls_new_sql = " WHERE STATUS IN (" + ls_status_where + ") "	
ls_new_sql += " AND SN_PARTNER = '" + ls_shop + "' "
 
IF ls_modelno <> "" THEN
	ls_new_sql += " AND MODELNO = '" + ls_modelno + "' "
END IF

IF ls_searchno <> "" THEN
	ls_new_sql += " AND ( DACOM_MNG_NO = UPPER('" + ls_searchno + "') OR SERIALNO = UPPER('" + ls_searchno + "') OR MAC_ADDR = LOWER('" + ls_searchno + "')) "
END IF

ls_new_sql2 = is_old_sql + ls_new_sql

dw_master.SetSQLSelect(ls_new_sql2)
li_exist =dw_master.Retrieve()
	
If li_exist < 0 Then 				
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 1  	
End If  

RETURN 0
end event

event ue_retrieve_right;STRING	ls_modelno,			ls_searchno,		ls_shop
INT		li_exist
STRING   ls_status_where,	ls_old_sql,		ls_new_sql, ls_customerid, ls_contractseq 

ls_modelno	= Trim(dw_hlp.object.modelno[1])
ls_searchno = dw_hlp.object.searchno[1]
ls_shop		= Trim(dw_hlp.object.shop[1])

IF IsNull(ls_modelno)  OR ls_modelno = ""  THEN ls_modelno = ""
IF IsNull(ls_searchno) OR ls_searchno = "" THEN ls_searchno = ""
IF IsNull(ls_shop) 	  OR ls_shop = "" 	 THEN ls_shop = ""

ls_status_where = ""
ls_old_sql = "SELECT  DECODE(SALE_FLAG, '0', DACOM_MNG_NO||':'||MAC_ADDR, '1', SERIALNO||':'||MAC_ADDR) AS RENTAL_EQUIP " +&
			 ", EQUIPSEQ , DECODE(SPEC_ITEM1, 'Y', 'I', 'R') AS DATA_CHECK, SPEC_ITEM1, 'N' AS NEW_CHECK " +&
			 "FROM    EQUIPMST " 			 
		 
IF is_worktype <> '100' AND is_worktype <> '400' THEN				//신규, auto가 아닐경우	
	SELECT CUSTOMERID, CONTRACTSEQ INTO :ls_customerid, :ls_contractseq 
	FROM   CUSTOMER_TROUBLE 
	WHERE  TROUBLENO = TO_NUMBER(:is_troubleno);
		
	ls_new_sql = " WHERE CONTRACTSEQ = '" + ls_contractseq + "' "
ELSE
	ls_new_sql = " WHERE ORDERNO = TO_NUMBER('" + is_orderno + "') "
END IF	

ls_status_where = ls_old_sql + ls_new_sql

dw_detail.SetSqlSelect(ls_old_sql + ls_new_sql)

li_exist =dw_detail.Retrieve()
	
If li_exist < 0 Then 				
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 1  	
End If  

RETURN 0

end event

event ue_reset;dw_master.Reset()
dw_detail.Reset()

//dw_master.Retrieve()
dw_detail.Retrieve()
end event

public subroutine wf_set_total ();DEC{2}	ldc_TOTAL

ldc_total = 0

IF dw_master.RowCount() > 0 THEN
	ldc_total = dw_master.GetItemNumber(dw_master.RowCount(), "all_sum") 
END IF

dw_hlp.Object.total[1] 		= ldc_total

//
F_INIT_DSP(2, "", String(ldc_total))

RETURN
end subroutine

on ubs_w_pop_equipvalid_dsl.create
int iCurrent
call super::create
this.dw_master=create dw_master
this.p_save=create p_save
this.dw_split=create dw_split
this.dw_detail=create dw_detail
this.cb_next=create cb_next
this.cb_pre=create cb_pre
this.p_reset=create p_reset
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_master
this.Control[iCurrent+2]=this.p_save
this.Control[iCurrent+3]=this.dw_split
this.Control[iCurrent+4]=this.dw_detail
this.Control[iCurrent+5]=this.cb_next
this.Control[iCurrent+6]=this.cb_pre
this.Control[iCurrent+7]=this.p_reset
this.Control[iCurrent+8]=this.gb_1
end on

on ubs_w_pop_equipvalid_dsl.destroy
call super::destroy
destroy(this.dw_master)
destroy(this.p_save)
destroy(this.dw_split)
destroy(this.dw_detail)
destroy(this.cb_next)
destroy(this.cb_pre)
destroy(this.p_reset)
destroy(this.gb_1)
end on

event open;call super::open;//=========================================================//
// Desciption : 장비연결 팝업							           //
// Name       : ubs_w_pop_equipvalid_dsl                   //
// contents   : 비인증 장비를 관리하기 위해 사용하는 팝업  //
// call Window: ubs_w_pop_equipvalid_dsl                   // 
// 작성일자   : 2011.03.02                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//
DataWindowChild 	ldc_modelno
Long 					li_exist,			ll_row,				ll_cnt,			ll_cnt2,		&
						ll_orderno
String 				ls_filter,			ls_sql,				old_sql,			new_sql,		&
						ls_ref_desc,		ls_temp,				ls_customerid, ls_contractseq,	&
						ls_siid,				ls_status

iu_cust_db_app = Create u_cust_db_app

//스케쥴관리 화면에서 인증 버튼 클릭시 넘어오는 값
//iu_cust_msg = Create u_cust_a_msg
//iu_cust_msg.is_pgm_name = ""
////iu_cust_msg.is_grp_name = ""
//iu_cust_msg.is_data2[1] = ls_worktype
//iu_cust_msg.is_data2[2] = ls_troubleno
//iu_cust_msg.is_data[1] = "CloseWithReturn"
//iu_cust_msg.il_data[1] = row
//iu_cust_msg.idw_data[1] = dw_master
//iu_cust_msg.is_data[2] = ls_orderno
//iu_cust_msg.is_data[3] = ls_partner
//iu_cust_msg.is_data[4] = gs_user_id
//iu_cust_msg.is_data[5]  = ls_priceplan
//iu_cust_msg.is_data[6]  = ls_svccod
//iu_cust_msg.is_data[7]  = 'VOCM'
//iu_cust_msg.is_data[8]  = ls_status	
//iu_cust_msg.is_data[9]  = ls_gubunnm

dw_hlp.InsertRow(0)

is_orderno 	 = iu_cust_help.is_data[2]
is_partner 	 = iu_cust_help.is_data[3]
is_userid  	 = iu_cust_help.is_data[4]
is_priceplan = iu_cust_help.is_data[5]
is_svccod 	 = iu_cust_help.is_data[6]
is_vocm 		 = iu_cust_help.is_data[7]
is_status	 = iu_cust_help.is_data[8]
is_gubunnm	 = iu_cust_help.is_data[9]
is_worktype  = iu_cust_help.is_data2[1]
is_troubleno = iu_cust_help.is_data2[2]

IF IsNull(is_orderno) OR is_orderno = "" THEN
	is_orderno = is_troubleno
END IF

This.Title =  iu_cust_help.is_pgm_name 

li_exist 	= dw_hlp.GetChild("modelno", ldc_modelno)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 장비종류")
//ls_filter = 

ldc_modelno.SetTransObject(SQLCA)

old_sql = "SELECT  EQUIPMODEL.MODELNO, EQUIPMODEL.MODELNM FROM    EQUIPMODEL, PRICEPLAN_EQUIP, SVCORDER " +&
			 "WHERE   EQUIPMODEL.EQUIPTYPE = PRICEPLAN_EQUIP.ADTYPE " +&
			 "AND     PRICEPLAN_EQUIP.PRICEPLAN = SVCORDER.PRICEPLAN " 

IF is_worktype <> '100' AND is_worktype <> '400'  THEN				//신규, auto가 아닐경우
	SELECT CUSTOMERID, CONTRACTSEQ INTO :ls_customerid, :ls_contractseq 
	FROM   CUSTOMER_TROUBLE 
	WHERE  TROUBLENO = TO_NUMBER(:is_troubleno);
	
	is_contractseq = ls_contractseq
	is_customerid  = ls_customerid
	
	SELECT MAX(ORDERNO) INTO :ll_orderno
	FROM   SVCORDER
	WHERE  CUSTOMERID = :ls_customerid
	AND    REF_CONTRACTSEQ = :ls_contractseq;
	
	is_orderno = String(ll_orderno)
	
	new_sql = old_sql + " AND SVCORDER.CUSTOMERID = '" + ls_customerid + "' " +&
							  " AND SVCORDER.REF_CONTRACTSEQ = '" + ls_contractseq + "' "
ELSE
	SELECT CUSTOMERID INTO :is_customerid
	FROM   SVCORDER
	WHERE  ORDERNO = :is_orderno;
	
	new_sql = old_sql + " AND SVCORDER.ORDERNO = TO_NUMBER('" + is_orderno + "') "
END IF


new_sql = new_sql + " GROUP BY EQUIPMODEL.MODELNO, EQUIPMODEL.MODELNM ORDER BY EQUIPMODEL.MODELNM ASC "

ldc_modelno.SetSQLSelect(new_sql)
li_exist =ldc_modelno.Retrieve()
	
If li_exist < 0 Then 				
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 1  	
End If  
//shop 세팅!
dw_hlp.Object.shop[1] = is_partner

//임대가능 장비상태 코드
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "E700", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_rental700[])

//임대상태 코드
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "E800", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_rental800[])

//임대가능상태 코드
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "E900", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_rental900[])

//고장상태 코드(교체)
ls_ref_desc = ""
is_bad_status = fs_get_control("U0", "S800", ls_ref_desc)

is_old_sql = dw_master.GetSQLSelect()

IF TRIGGER EVENT ue_retrieve_right() < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve() Right")
	RETURN -1		
END IF

ll_row = dw_detail.RowCount()

IF is_worktype = '400' THEN   //AUTO 재인증만 허용!
	cb_next.Enabled = False
	cb_pre.Enabled = False
	p_save.Triggerevent("ue_disable")
END IF

//수정된 내용이 없도록 하기 위해서 강제 세팅!
//dw_hlp.SetItemStatus(1, 0, Primary!, NotModified!)

end event

event ue_close();//iu_cust_help.ib_data[1] = TRUE
//iu_cust_help.is_data[1] = is_amt_check    //수납 했는지 확인 후 값 넘김

Destroy iu_cust_db_app

Close( This )
end event

event close;call super::close;iu_cust_help.ib_data[1] = TRUE

return 0

			
end event

event closequery;call super::closequery;Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_equipvalid_dsl
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_equipvalid_dsl
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_equipvalid_dsl
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_equipvalid_dsl
integer x = 347
integer y = 1176
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_equipvalid_dsl
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_equipvalid_dsl
integer x = 41
integer y = 36
integer width = 3026
integer height = 172
string dataobject = "ubs_dw_pop_equipvalid_dsl_cond"
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_hlp::itemchanged;call super::itemchanged;IF dwo.name = "modelno" OR dwo.name = "searchno" THEN
	IF PARENT.TRIGGER EVENT ue_retrieve_left() < 0 THEN
		f_msg_usr_err(2100, Title, "Retrieve() Left")
		RETURN -1
	END IF
	
//	IF PARENT.TRIGGER EVENT ue_retrieve_right() < 0 THEN
//		f_msg_usr_err(2100, Title, "Retrieve() Right")
//		RETURN -1		
//	END IF		
END IF

RETURN 0
end event

event dw_hlp::clicked;//
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::ue_init();//
end event

event dw_hlp::losefocus;call super::losefocus;STRING	ls_searchno

dw_hlp.AcceptText()

ls_searchno = THIS.object.searchno[1]

IF IsNull(ls_searchno) OR ls_searchno = "" THEN RETURN 0

IF PARENT.TRIGGER EVENT ue_retrieve_left() < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve() Left")
	RETURN -1
END IF

IF PARENT.TRIGGER EVENT ue_retrieve_right() < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve() Right")
	RETURN -1		
END IF		

RETURN 0
end event

type dw_master from datawindow within ubs_w_pop_equipvalid_dsl
integer x = 18
integer y = 256
integer width = 1266
integer height = 868
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_pop_equipvalid_dsl_mas"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(SQLCA)
end event

event clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If
end event

type p_save from u_p_save within ubs_w_pop_equipvalid_dsl
integer x = 18
integer y = 1176
integer height = 100
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;Integer li_rc
Constant Int LI_ERROR = -1

PARENT.TRIGGER EVENT ue_process(li_rc)

IF li_rc <> 0 THEN
	ROLLBACK;
	f_msg_info(3010, PARENT.Title, "Save")	
ELSEIF li_rc = 0 THEN
	COMMIT;
	f_msg_info(3000, PARENT.Title, "Save")	
END IF

cb_next.Enabled = False
cb_pre.Enabled = False

//수정된 내용이 없도록 하기 위해서 강제 세팅!
//dw_master.SetItemStatus(1, 0, Primary!, NotModified!)
//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

PARENT.TRIGGEREVENT('ue_close')
end event

type dw_split from datawindow within ubs_w_pop_equipvalid_dsl
boolean visible = false
integer x = 1838
integer y = 1168
integer width = 969
integer height = 148
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "b5d_reg_mtr_inp_split_sams"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

type dw_detail from datawindow within ubs_w_pop_equipvalid_dsl
integer x = 1458
integer y = 256
integer width = 1627
integer height = 868
integer taborder = 30
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_pop_equipvalid_dsl_det"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(SQLCA)
end event

event clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If
end event

event retrieveend;return 0
end event

type cb_next from commandbutton within ubs_w_pop_equipvalid_dsl
integer x = 1321
integer y = 512
integer width = 114
integer height = 108
integer taborder = 30
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = roman!
string facename = "바탕체"
string text = ">"
end type

event clicked;STRING	ls_equip,		ls_adtype,			ls_data_check,	ls_new_yn,		ls_new_check,	&
			ls_action
LONG		ll_row,			ll_equipseq,		ll_row_det,		ll_new_row,		ll_ret_cnt,	&
			ll_use_cnt
INT		ii

ll_row = dw_master.GetSelectedRow(0)

IF ll_row <= 0 THEN
	f_msg_usr_err(9000, Title, "임대가능장비중 선택된 행이 없습니다.")
	RETURN -1
END IF

ls_equip 	= dw_master.Object.rental_equip[ll_row]
ll_equipseq = dw_master.Object.equipseq[ll_row]
ls_new_check= dw_master.Object.new_check[ll_row]

SELECT ADTYPE, NVL(NEW_YN, 'N'), NVL(USE_CNT, 0)
INTO   :ls_adtype, :ls_new_yn, :ll_use_cnt
FROM   EQUIPMST
WHERE  EQUIPSEQ = :ll_equipseq;

IF ii_equipselect > 1 THEN 
	f_msg_usr_err(9000, Title, "선택가능한 장비수를 초과했습니다.")
	RETURN -1
END IF

ll_row_det = dw_detail.RowCount()

//로그 행위(action)추출 - 인증
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A108';	

ll_new_row = ll_row_det + 1
dw_detail.Insertrow(ll_new_row)

dw_detail.Object.rental_equip[ll_new_row] = ls_equip
dw_detail.Object.equipseq[ll_new_row]		= ll_equipseq
dw_detail.Object.data_check[ll_new_row]	= "I" 				//추가 라고 표시
dw_detail.Object.new_check[ll_new_row]	   = ls_new_check		//신규 장비 구분...

IF is_worktype = '100' THEN
	IF ls_new_check = 'N' THEN		
		UPDATE EQUIPMST
		SET    STATUS 	   = :is_rental800[1],
				 CUSTOMERID = :is_customerid,
				 ORDERNO	   = TO_NUMBER(:is_orderno),
				 NEW_YN		= 'N',					 
				 USE_CNT    = NVL(USE_CNT, 0) + 1,
				 UPDT_USER  = :gs_user_id,
				 UPDTDT		= SYSDATE
		WHERE  EQUIPSEQ   = :ll_equipseq;
	ELSE		//신규장비...
		UPDATE EQUIPMST
		SET    STATUS 	   = :is_rental800[1],
				 CUSTOMERID = :is_customerid,
				 ORDERNO	   = TO_NUMBER(:is_orderno),
				 NEW_YN		= 'N',
				 USE_CNT    = NVL(USE_CNT, 0) + 1,
				 FIRST_CUSTOMER = :is_customerid,
				 FIRST_SALEDT   = SYSDATE,
				 FIRST_SELLER   = :gs_user_id,
				 FIRST_PARTNER  = :gs_shopid,
				 FIRST_SALE_AMT = NVL(SALE_AMT, 0),
				 UPDT_USER  = :gs_user_id,
				 UPDTDT		= SYSDATE					 
		WHERE  EQUIPSEQ   = :ll_equipseq;
	END IF			

	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPMST UPDATE ERROR!')
		ROLLBACK;
		RETURN -1			
	END IF
ELSEIF is_worktype = '200' THEN	
	IF ls_new_check = 'N' THEN				
		UPDATE EQUIPMST
		SET    STATUS		 = :is_rental800[1],
				 CUSTOMERID  = :is_customerid,
				 ORDERNO	    = TO_NUMBER(:is_orderno),
				 CONTRACTSEQ = TO_NUMBER(:is_contractseq),
				 NEW_YN		 = 'N',					 
				 USE_CNT     = NVL(USE_CNT, 0) + 1,
				 UPDT_USER   = :gs_user_id,
				 UPDTDT		 = SYSDATE					 
		WHERE  EQUIPSEQ    = :ll_equipseq;
	ELSE
		UPDATE EQUIPMST
		SET    STATUS 	   = :is_rental800[1],
				 CUSTOMERID = :is_customerid,
				 ORDERNO	   = TO_NUMBER(:is_orderno),
				 NEW_YN		= 'N',
				 USE_CNT    = NVL(USE_CNT, 0) + 1,
				 FIRST_CUSTOMER = :is_customerid,
				 FIRST_SALEDT   = SYSDATE,
				 FIRST_SELLER   = :gs_user_id,
				 FIRST_PARTNER  = :gs_shopid,
				 FIRST_SALE_AMT = NVL(SALE_AMT, 0),
				 UPDT_USER  = :gs_user_id,
				 UPDTDT		= SYSDATE					 
		WHERE  EQUIPSEQ   = :ll_equipseq;
	END IF					
	
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPMST UPDATE ERROR!')
		ROLLBACK;
		RETURN -1			
	END IF		
END IF

//INSERT EQUIPLOG
INSERT INTO EQUIPLOG
(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
		 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
		 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
		 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
		 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
		 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
		 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
		 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
		 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
		 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
FROM   EQUIPMST
WHERE  EQUIPSEQ = :ll_equipseq;					
	
IF SQLCA.SQLCODE < 0 THEN		//For Programer
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPLOG INSERT ERROR!')
	ROLLBACK;
	RETURN -1			
END IF	
	
COMMIT;

ii_equipselect = ii_equipselect + 1

F_MSG_INFO(3000, Title, 'SAVE')

PARENT.TRIGGER EVENT ue_retrieve_left()

RETURN 0
	

end event

type cb_pre from commandbutton within ubs_w_pop_equipvalid_dsl
integer x = 1321
integer y = 768
integer width = 114
integer height = 108
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = roman!
string facename = "바탕체"
string text = "<"
end type

event clicked;STRING	ls_equip,		ls_data_check,		ls_new_check,	ls_action
LONG		ll_row,			ll_equipseq,		ll_row_mas,		ll_new_row,		ll_days

dw_detail.Accepttext()

ll_row = dw_detail.GetSelectedRow(0)

IF ll_row <= 0 THEN
	f_msg_usr_err(210, Title, "임대장비중 선택된 행이 없습니다.")
	RETURN -1
END IF

ls_equip 	= dw_detail.Object.rental_equip[ll_row]
ll_equipseq = dw_detail.Object.equipseq[ll_row]
ls_data_check = dw_detail.Object.data_check[ll_row]
ls_new_check  = dw_detail.Object.new_check[ll_row]

IF ls_data_check = "R" THEN
	dw_detail.Object.data_check[ll_row] = "D"     //삭제
End IF

SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') - 
		 TO_DATE(TO_CHAR(NVL(FIRST_SALEDT, TO_DATE('20090701', 'YYYYMMDD')),'YYYYMMDD'), 'YYYYMMDD')
INTO   :ll_days
FROM   EQUIPMST
WHERE  EQUIPSEQ = :ll_equipseq;

IF ls_new_check = 'N' THEN
	IF ll_days <= 14 THEN
		ls_new_check = 'Y'
	ELSE
		ls_new_check = 'N'
	END IF
END IF	

//로그 행위(action)추출 - 인증
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A108';	

IF is_worktype = '100' THEN    //장애...즉 변경건 아니면...
	IF ls_new_check = 'Y' THEN
		UPDATE EQUIPMST
		SET    STATUS 	    = :is_rental900[1],
				 NEW_YN		 = 'Y',					 
				 USE_CNT     = USE_CNT - 1,
				 CUSTOMERID  = NULL,
				 ORDERNO	    = NULL,
				 CONTRACTSEQ = NULL,
				 CUST_NO     = NULL,
				 FIRST_CUSTOMER 	= NULL,
				 FIRST_SALEDT 		= NULL,
				 FIRST_SELLER 		= NULL,
				 FIRST_PARTNER 	= NULL,
				 FIRST_SALE_AMT 	= NULL,						 				 
				 UPDT_USER   = :gs_user_id,
				 UPDTDT		 = SYSDATE						 
		WHERE  EQUIPSEQ    = :ll_equipseq;				
	ELSE
		UPDATE EQUIPMST
		SET    STATUS 	    = :is_rental900[1],
				 USE_CNT     = USE_CNT - 1,
				 CUSTOMERID  = NULL,
				 ORDERNO	    = NULL,
				 CONTRACTSEQ = NULL,
				 CUST_NO     = NULL,
				 UPDT_USER   = :gs_user_id,
				 UPDTDT		 = SYSDATE								 
		WHERE  EQUIPSEQ    = :ll_equipseq;		
	END IF
	
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPMST UPDATE ERROR!')
		ROLLBACK;
		RETURN -1
	END IF				
ELSEIF is_worktype = '200' THEN
	IF ls_new_check = 'Y' THEN	
		UPDATE EQUIPMST
		SET    STATUS 	    = :is_rental900[1],
				 NEW_YN		 = 'Y',					 				
				 USE_CNT     = USE_CNT - 1,
				 CUSTOMERID  = NULL,
				 ORDERNO	    = NULL,
				 CONTRACTSEQ = NULL,
				 CUST_NO     = NULL,
				 FIRST_CUSTOMER 	= NULL,
				 FIRST_SALEDT 		= NULL,
				 FIRST_SELLER 		= NULL,
				 FIRST_PARTNER 	= NULL,
				 FIRST_SALE_AMT 	= NULL,						 				 
				 UPDT_USER   = :gs_user_id,
				 UPDTDT		 = SYSDATE								 
		WHERE  EQUIPSEQ    = :ll_equipseq;
	ELSE
		UPDATE EQUIPMST
		SET    STATUS 	    = :is_rental900[1],
				 USE_CNT     = USE_CNT - 1,
				 CUSTOMERID  = NULL,
				 ORDERNO	    = NULL,
				 CONTRACTSEQ = NULL,
				 CUST_NO     = NULL,
				 UPDT_USER   = :gs_user_id,
				 UPDTDT		 = SYSDATE								 
		WHERE  EQUIPSEQ    = :ll_equipseq;
	END IF						
		
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPMST UPDATE ERROR!')
		ROLLBACK;
		RETURN -1
	END IF				
END IF	

//INSERT EQUIPLOG
INSERT INTO EQUIPLOG
(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
		 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
		 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
		 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
		 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
		 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
		 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
		 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
		 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
		 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
FROM   EQUIPMST
WHERE  EQUIPSEQ = :ll_equipseq;					

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPLOG INSERT ERROR!')
	ROLLBACK;
	RETURN -1			
END IF				

IF ls_data_check = "I" THEN
	dw_detail.Deleterow(0)
END IF

COMMIT;

ii_equipselect = ii_equipselect - 1

IF ii_equipselect < 0 THEN
	ii_equipselect = 0
END IF

F_MSG_INFO(3000, Title, 'SAVE')

PARENT.TRIGGER EVENT ue_retrieve_left()

RETURN 0
	

end event

type p_reset from u_p_reset within ubs_w_pop_equipvalid_dsl
integer x = 681
integer y = 1176
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;Parent.TriggerEvent('ue_reset')
end event

type gb_1 from groupbox within ubs_w_pop_equipvalid_dsl
integer x = 18
integer y = 8
integer width = 3072
integer height = 224
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

