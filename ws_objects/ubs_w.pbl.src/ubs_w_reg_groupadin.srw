$PBExportHeader$ubs_w_reg_groupadin.srw
$PBExportComments$[jhchoi] 그룹물품등록 - 2009.05.05
forward
global type ubs_w_reg_groupadin from w_a_reg_m
end type
type cb_1 from commandbutton within ubs_w_reg_groupadin
end type
end forward

global type ubs_w_reg_groupadin from w_a_reg_m
integer width = 3113
integer height = 1828
event type integer ue_confirm ( )
event type integer ue_transfer ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
cb_1 cb_1
end type
global ubs_w_reg_groupadin ubs_w_reg_groupadin

type variables
String is_move, is_sale, is_return, is_all
end variables

forward prototypes
public subroutine wf_set_total ()
public subroutine wf_protect_det (string action)
public subroutine wf_protect (string action)
end prototypes

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_detail.GetRow()

lb_check = fb_save_required(dw_detail, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_process;STRING	ls_action,	ls_modelno,		ls_maker,			ls_entstore,		ls_remark,		&
			ls_errmsg,	ls_shop
LONG		ll_row,		ll_amount,		ll_seqno,			ll_return
INT		ii
DATE		ld_workdt

ls_action = dw_cond.Object.action[1]
ld_workdt = dw_cond.Object.sysdt[1]
ls_shop	 = dw_cond.Object.shop[1]
ll_row	 = dw_detail.RowCount()

FOR ii = 1 TO ll_row
	ls_modelno	 = dw_detail.Object.modelno[ii]
	ll_amount	 = dw_detail.Object.amount[ii]
	ls_maker		 = dw_detail.Object.makercd[ii]
	ls_entstore  = dw_detail.Object.entstore[ii]
	ls_remark	 = dw_detail.Object.remark[ii]
	
	IF ls_action = "I" THEN
		ls_errmsg = space(1000)
	
		SQLCA.UBS_REG_GROUPIN (ls_action,	ls_modelno,		gs_shopid,		'',			ll_seqno,	&
									  ll_amount,	ls_maker,		ls_entstore,	ld_workdt,	ls_remark,  &
									  gs_user_id,	gs_pgm_id[gi_open_win_no],	ll_return,		ls_errmsg)
		
		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX(ls_errmsg, 'UBS_REG_GROUPIN(I) ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			ai_return = -1
			RETURN
		ELSEIF ll_return < 0 THEN		//For User
			MESSAGEBOX('확인', 'UBS_REG_GROUPIN(I) ' + ls_errmsg,Exclamation!,OK!)
			ai_return = -1		
			RETURN
		END IF
		
		dw_detail.Object.data_check[ii] = "R"
	ELSEIF ls_action = "S" THEN
		ls_errmsg = space(1000)		
		if (gs_shopid = ls_shop) or (isnull(ls_shop) or ls_shop = '') then
			MESSAGEBOX('확인', '현재샵과 이동샵이 동일합니다. 이동할 샵을 선택하고 다시 이동하세요.' ,Exclamation!,OK!)
			ai_return = -1		
			RETURN
		end if
		
		SQLCA.UBS_REG_GROUPIN (ls_action,	ls_modelno,		ls_shop,			gs_shopid,	ll_seqno,	&
									  ll_amount,	'',				'',				ld_workdt,	ls_remark,	&
									  gs_user_id,	gs_pgm_id[gi_open_win_no],	ll_return,		ls_errmsg)
		
		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX(ls_errmsg, 'UBS_REG_GROUPIN(S) ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			ai_return = -1
			RETURN
		ELSEIF ll_return < 0 THEN		//For User
			MESSAGEBOX('확인', 'UBS_REG_GROUPIN(S) ' + ls_errmsg,Exclamation!,OK!)
			ai_return = -1		
			RETURN
		END IF	
		
		dw_detail.Object.data_check[ii] = "R"		
	ELSEIF ls_action = "R" THEN
		ll_seqno = dw_detail.Object.seqno[ii]
		ls_errmsg = space(1000)
		SQLCA.UBS_REG_GROUPIN (ls_action,	ls_modelno,		gs_shopid,		'',			ll_seqno,	&
									  ll_amount,	'',				'',				ld_workdt,	ls_remark,	&
									  gs_user_id,	gs_pgm_id[gi_open_win_no],	ll_return,		ls_errmsg)
		
		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX(ls_errmsg, 'UBS_REG_GROUPIN(R) ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			ai_return = -1
			RETURN
		ELSEIF ll_return < 0 THEN		//For User
			MESSAGEBOX('확인', 'UBS_REG_GROUPIN(R) ' + ls_errmsg,Exclamation!,OK!)
			ai_return = -1		
			RETURN
		END IF	
	ELSE
		ls_errmsg = space(1000)
		SQLCA.UBS_REG_GROUPIN (ls_action,	ls_modelno,		gs_shopid,		'',			ll_seqno,	&
									  ll_amount,	'',				'',				ld_workdt,	ls_remark,	&
									  gs_user_id,	gs_pgm_id[gi_open_win_no],	ll_return,		ls_errmsg)
		
		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX(ls_errmsg, 'UBS_REG_GROUPIN(E) ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			ai_return = -1
			RETURN
		ELSEIF ll_return < 0 THEN		//For User
			MESSAGEBOX('확인', 'UBS_REG_GROUPIN(E) ' + ls_errmsg,Exclamation!,OK!)
			ai_return = -1		
			RETURN
		END IF
		dw_detail.Object.data_check[ii] = "R"		
	END IF
	
	//수정된 내용이 없도록 하기 위해서 강제 세팅!
	dw_detail.SetItemStatus(ii, 0, Primary!, NotModified!)	
NEXT	

ai_return = 0



return
end event

event ue_processvalidcheck(ref integer ai_return);STRING	ls_action
LONG		ll_row,		ll_amount,		ll_current_amt
INT		ii

ls_action = dw_cond.Object.action[1]
ll_row	 = dw_detail.RowCount()

IF ls_action = "S" OR ls_action = "E" THEN
	FOR ii = 1 TO ll_row
		ll_amount		= dw_detail.Object.amount[ii]
		ll_current_amt = dw_detail.Object.current_amt[ii]

		IF ll_amount > ll_current_amt THEN
			f_msg_usr_err(200, Title, "현재수량보다 크게 입력할 수 없습니다.")
			ai_return = -1
			RETURN	
		END IF
	NEXT
END IF	

ai_return = 0

return
end event

public subroutine wf_set_total ();
end subroutine

public subroutine wf_protect_det (string action);IF action = "I" THEN
	dw_detail.object.makercd.visible = 1
	dw_detail.object.entstore.visible = 1	
	dw_detail.object.makercd_t.visible = 1
	dw_detail.object.entstore_t.visible = 1	

	dw_detail.Object.makercd.Color = RGB(255,255,255)						//글씨색
	dw_detail.Object.makercd.Background.Color = RGB(107, 146, 140)		//필수 배경색	
	dw_detail.Object.entstore.Color = RGB(255,255,255)						//글씨색
	dw_detail.Object.entstore.Background.Color = RGB(107, 146, 140)	//필수 배경색		
ELSE
	dw_detail.object.makercd.visible = 0
	dw_detail.object.entstore.visible = 0	
	dw_detail.object.makercd_t.visible = 0
	dw_detail.object.entstore_t.visible = 0
	
	dw_detail.Object.makercd.Color =RGB(0,0,0)							//글씨색
	dw_detail.Object.makercd.Background.Color = RGB(255,255,255)		//필수 배경색	
	dw_detail.Object.entstore.Color = RGB(0,0,0)						//글씨색
	dw_detail.Object.entstore.Background.Color = RGB(255,255,255)		//필수 배경색			
END IF

IF action = "R" THEN
	dw_detail.object.modelno.protect = 1
	dw_detail.object.amount.protect = 1
	dw_detail.object.makercd.protect = 1
	dw_detail.object.entstore.protect = 1
ELSE
	dw_detail.object.modelno.protect = 0
	dw_detail.object.amount.protect = 0
	dw_detail.object.makercd.protect = 0
	dw_detail.object.entstore.protect = 0
END IF	
end subroutine

public subroutine wf_protect (string action);IF action = "I" OR action = "R" THEN
	dw_cond.object.shop[1] = gs_shopid
	dw_cond.object.shop.protect = 1
ELSEIF action = "S" OR action = "E" THEN
	dw_cond.object.shop.protect = 0
END IF
	
end subroutine

on ubs_w_reg_groupadin.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on ubs_w_reg_groupadin.destroy
call super::destroy
destroy(this.cb_1)
end on

event ue_ok;STRING 	ls_where, 	ls_sysdt, 	ls_action,	ls_shop
LONG 		ll_row
INTEGER	li_cnt
DATE		ld_sysdt

ls_sysdt	 = Trim(String(dw_cond.object.sysdt[1], 'yyyymmdd'))
ld_sysdt	 = dw_cond.object.sysdt[1]
ls_action = Trim(dw_cond.object.action[1])
ls_shop	 = Trim(dw_cond.object.shop[1])

IF IsNull(ls_sysdt) 	THEN ls_sysdt 	= ""
IF IsNull(ls_action) THEN ls_action = ""
IF IsNull(ls_shop) 	THEN ls_shop 	= ""

IF ls_action = "" THEN
	f_msg_usr_err(200, Title, "Action")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("Action")
	RETURN
END IF

//입고권한 체크[RQ-UBS-201502-03]
SELECT COUNT(*) INTO :li_cnt
FROM SYSUSR1T
WHERE EMP_GROUP IN ( SELECT PARTNER FROM PARTNERMST WHERE BASECOD = '000SS')
  AND EMP_ID = :gs_user_id;

IF ls_action = 'I' and li_cnt = 0 THEN
	MESSAGEBOX("확인","입고권한이 없는 사용자 입니다. 다른 Action을 선택하세요")
	RETURN
END IF

IF ls_action <> "R" THEN
	THIS.TRIGGER EVENT ue_insert()
	
	p_ok.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
ELSE
	ls_where = ""
	
	ls_where += " DET.MV_PARTNER = '" + gs_shopid + "' "
	ls_where += " AND NVL(DET.PARTNER, '0') <> '" + gs_shopid + "' "

	dw_detail.is_where = ls_where
	ll_row = dw_detail.Retrieve()
	
	IF ll_row = 0 THEN
		f_msg_info(1000, Title, "")
	ELSEIF ll_row < 0 THEN
		f_msg_usr_err(2100, Title, "Retrieve()")
		RETURN
	END IF
	
	p_ok.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	
END IF

dw_cond.Enabled = False

wf_protect_det(ls_action)


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
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_enable")
dw_cond.Enabled = True

dw_cond.ReSet()
dw_detail.Reset()
dw_cond.InsertRow(0)

dw_cond.SetFocus()
dw_cond.SetColumn("action")

dw_cond.Object.action[1] = "I"				//registration 으로 기본세팅
dw_cond.Object.shop[1] 	 = gs_shopid
dw_cond.Object.sysdt[1]  = DATE(fdt_get_dbserver_now())

wf_protect("I")

Return 0
end event

event open;call super::open;//=========================================================//
// Desciption : 그룹물품등록						              //
// Name       : ubs_w_reg_groupadin			                 //
// Contents   : 그룹물품을 관리하는 화면이다.				  //
// Data Window: dw - ubs_dw_reg_groupadin_cnd	           // 
//							ubs_dw_reg_groupadin_mas 				  //
// 작성일자   : 2009.05.05                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

String ls_ref_desc

dw_cond.Object.action[1] = "I"				//registration 으로 기본세팅
dw_cond.Object.shop[1] 	 = gs_shopid
dw_cond.Object.sysdt[1]  = DATE(fdt_get_dbserver_now())

wf_protect("I")


//장비상태- Move
//is_move 			= fs_get_control("U0", "E300", ls_ref_desc)		//이동중인 상태
//is_return 		= fs_get_control("U0", "E400", ls_ref_desc)		//반환 상태
//is_sale 			= fs_get_control("U0", "E400", ls_ref_desc)		//완료 상태

end event

event ue_save;INT	li_rc
CONSTANT INT LI_ERROR = -1

IF dw_detail.AcceptText() < 0 THEN
	dw_detail.SetFocus()
	RETURN LI_ERROR
END IF

THIS.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

THIS.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

THIS.TRIGGER EVENT ue_process(li_rc)

IF li_rc <> 0 THEN
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = THIS.Title

	iu_cust_db_app.uf_prc_db()
	
	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_detail.SetFocus()
		RETURN LI_ERROR
	END IF

	f_msg_info(3010, THIS.Title,"Save")
	RETURN LI_ERROR
ELSE
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = THIS.Title

	iu_cust_db_app.uf_prc_db()

	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_detail.SetFocus()
		RETURN LI_ERROR
	END IF
	

	f_msg_info(3000, THIS.Title,"Save")

	
END IF

	
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")

RETURN 0
end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정

IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

IF newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_detail.Height = 0
   p_insert.Y		  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y		  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y			  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
	p_close.Y		  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y		  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	cb_1.Y		 	  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
	
ELSE
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y		  = newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	 	  = newheight - iu_cust_w_resize.ii_button_space
	p_save.Y			  = newheight - iu_cust_w_resize.ii_button_space	
	p_close.Y		  = newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y		  = newheight - iu_cust_w_resize.ii_button_space
	cb_1.Y		     = newheight - iu_cust_w_resize.ii_button_space	
END IF

IF newwidth < dw_detail.X  THEN
	dw_detail.Width = 0
ELSE
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
END IF

SetRedraw(TRUE)
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;
dw_detail.Object.data_check[al_insert_row] = "I"

return 0
end event

event type integer ue_extra_delete();call super::ue_extra_delete;STRING	ls_data_check
LONG		ll_row

ll_row = dw_detail.GetRow()

ls_data_check = dw_detail.Object.data_check[ll_row]

IF ls_data_check = "I" THEN
	RETURN 0
ELSE
	f_msg_usr_err(200, Title, "삭제할 수 없습니다.")	
	RETURN -1
END IF

end event

type dw_cond from w_a_reg_m`dw_cond within ubs_w_reg_groupadin
integer x = 55
integer y = 52
integer width = 2432
integer height = 196
integer taborder = 10
string dataobject = "ubs_dw_reg_groupadin_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;IF dwo.name = "action" THEN
	wf_protect(data)
END IF	
end event

type p_ok from w_a_reg_m`p_ok within ubs_w_reg_groupadin
integer x = 2729
integer y = 96
end type

type p_close from w_a_reg_m`p_close within ubs_w_reg_groupadin
integer x = 1262
integer y = 1592
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ubs_w_reg_groupadin
integer x = 23
integer width = 3026
integer height = 260
integer taborder = 0
end type

type p_delete from w_a_reg_m`p_delete within ubs_w_reg_groupadin
integer x = 329
integer y = 1592
end type

type p_insert from w_a_reg_m`p_insert within ubs_w_reg_groupadin
integer x = 23
integer y = 1592
end type

type p_save from w_a_reg_m`p_save within ubs_w_reg_groupadin
integer x = 640
integer y = 1592
end type

type dw_detail from w_a_reg_m`dw_detail within ubs_w_reg_groupadin
integer x = 23
integer y = 276
integer width = 3026
integer height = 1280
integer taborder = 20
string dataobject = "ubs_dw_reg_groupadin_mas"
end type

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_ok.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	dw_cond.Enabled = True
ELSE
	p_ok.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	dw_cond.Enabled = false
END IF


end event

event dw_detail::constructor;call super::constructor;//손모양을 막는다.
dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemerror;call super::itemerror;return 1
end event

event dw_detail::itemchanged;call super::itemchanged;STRING	ls_action,			ls_modelnm
LONG		ll_amount = 0,		ll_current

IF dwo.name = "modelno" THEN
	
	SELECT AMOUNT INTO :ll_amount
	FROM   AD_GROUPMST
	WHERE  MODELNO = :data
	AND    PARTNER = :gs_shopid;
	
	THIS.Object.current_amt[row] = ll_amount
	
	SELECT MODELNM INTO :ls_modelnm
	FROM   ADMODEL
	WHERE  MODELNO = :data
	AND    GROUPID_1 = 'G';
	
	THIS.Object.modelnm[row] = ls_modelnm	
	
ELSEIF dwo.name = "amount" THEN
	ls_action = dw_cond.object.action[1]
	
	IF ls_action = "S" OR ls_action = "E" THEN
		ll_current = THIS.object.current_amt[row]
		
		IF LONG(data) > ll_current THEN
			f_msg_usr_err(200, Title, "현재수량보다 크게 입력할 수 없습니다.")
			THIS.object.amount[row] = 0
			RETURN 2
		END IF
	END IF
END IF
end event

type p_reset from w_a_reg_m`p_reset within ubs_w_reg_groupadin
integer x = 951
integer y = 1592
end type

type cb_1 from commandbutton within ubs_w_reg_groupadin
integer x = 1787
integer y = 1592
integer width = 389
integer height = 100
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Stock Status"
end type

event clicked;INTEGER	li_rc

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Group Item Retrieve"
iu_cust_msg.is_data[1]  = "Close"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_cond
iu_cust_msg.idw_data[2] = dw_detail

//수량 조회 팝업 연결
OpenWithParm(ubs_w_pop_group_retrieve, iu_cust_msg)

DESTROY iu_cust_msg

RETURN 0


end event

