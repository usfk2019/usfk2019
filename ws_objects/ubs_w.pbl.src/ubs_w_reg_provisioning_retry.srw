$PBExportHeader$ubs_w_reg_provisioning_retry.srw
$PBExportComments$[jhchoi] 재인증 처리 - 2009.12.15
forward
global type ubs_w_reg_provisioning_retry from w_a_reg_m_m
end type
type cb_1 from commandbutton within ubs_w_reg_provisioning_retry
end type
end forward

global type ubs_w_reg_provisioning_retry from w_a_reg_m_m
integer width = 2962
integer height = 1708
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_clip ( string as_value )
cb_1 cb_1
end type
global ubs_w_reg_provisioning_retry ubs_w_reg_provisioning_retry

type variables
STRING	is_orderstatus[]
end variables

forward prototypes
public subroutine wf_protect (string ai_gubun)
public function integer wf_get_actioncode (string as_status, string as_priceplan, ref string as_code)
end prototypes

event ue_clip;Clipboard(as_value)
end event

public subroutine wf_protect (string ai_gubun);dw_detail.AcceptText()

CHOOSE CASE ai_gubun
	CASE "100"
		dw_detail.Object.adtype.Color 				= RGB(255,255,255)
		dw_detail.Object.adtype.Background.Color	= RGB(107,146,140)
		dw_detail.Object.adtype.Border				= 2
		dw_detail.modify("adtype.dddw.useasborder=~'yes~'")
		
		dw_detail.Object.modelno.Color 				= RGB(255,255,255)
		dw_detail.Object.modelno.Background.Color = RGB(107,146,140)		
		dw_detail.Object.modelno.Border				= 2
		dw_detail.modify("modelno.dddw.useasborder=~'yes~'")
		
		dw_detail.Object.makercd.Color 				= RGB(255,255,255)
		dw_detail.Object.makercd.Background.Color = RGB(107,146,140)
		dw_detail.Object.makercd.Border				= 2	
		dw_detail.modify("makercd.dddw.useasborder=~'yes~'")		
		
	CASE ELSE
		dw_detail.Object.adtype.Color					= RGB(0,0,0)	
		dw_detail.Object.adtype.Background.Color	= RGB(255,251,240)
		dw_detail.Object.adtype.Border				= 0		
		dw_detail.modify("adtype.dddw.useasborder=~'no~'")		
		
		dw_detail.Object.modelno.Color				= RGB(0,0,0)	
		dw_detail.Object.modelno.Background.Color = RGB(255,251,240)		
		dw_detail.Object.modelno.Border				= 0		
		dw_detail.modify("modelno.dddw.useasborder=~'no~'")		
		
		dw_detail.Object.makercd.Color				= RGB(0,0,0)	
		dw_detail.Object.makercd.Background.Color = RGB(255,251,240)
		dw_detail.Object.makercd.Border				= 0		
		dw_detail.modify("makercd.dddw.useasborder=~'no~'")

END CHOOSE
end subroutine

public function integer wf_get_actioncode (string as_status, string as_priceplan, ref string as_code);STRING	ls_gubunnm

IF IsNull(as_status)    OR as_status    = "" THEN RETURN -1
IF IsNull(as_priceplan) OR as_priceplan = "" THEN RETURN -1

SELECT GUBUN_NM 
INTO :ls_gubunnm
FROM   PRICEPLANINFO
WHERE  PRICEPLAN = :as_priceplan;

CHOOSE CASE as_status
	CASE 'CHANGE'					//장비변경
		IF ls_gubunnm = "전화" THEN
			as_code = "TEL310RTY"
		ELSE
			as_code = "INT312RTY"
			//as_code = "INT312"
		END IF
	CASE '10', '20'				//신규신청
		IF ls_gubunnm = "전화" THEN
			as_code = "TEL100RTY"
		ELSE
			as_code = "INT100RTY"
		END IF	
	CASE '30', '40'				//정지신청
		IF ls_gubunnm = "전화" THEN
			as_code = "TEL412RTY"
		ELSE
			as_code = "INT400RTY"
		END IF
	CASE '50'						//해소신청
		IF ls_gubunnm = "전화" THEN
			as_code = "TEL512RTY"
		ELSE
			as_code = "INT500RTY"
		END IF		
	CASE '80', '85'				//번호변경
		IF ls_gubunnm = "전화" THEN
			as_code = "TEL322RTY"
		END IF		
	CASE '70', '90', '99'		//해지신청
		IF ls_gubunnm = "전화" THEN
			as_code = "TEL200RTY"
		ELSE
			as_code = "INT200RTY"
		END IF
		
END CHOOSE		

return 0
end function

on ubs_w_reg_provisioning_retry.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on ubs_w_reg_provisioning_retry.destroy
call super::destroy
destroy(this.cb_1)
end on

event open;call super::open;/***********************************************************/
/* Desciption : 재인증 화면					                 */
/* Name       : ubs_w_reg_provisioning_retry               */
/* Contents   : 재인증 화면										  */
/* Data Window: dw - ubs_dw_reg_provisioning_retry_cond    */ 
/*							ubs_dw_reg_provisioning_retry_mas     */
/*							ubs_dw_reg_provisioning_retry_det     */
/* 작성일자   : 2009.12.15                                 */
/* 작 성 자   : 최재혁 대리                                */
/* 수정일자   :                                            */
/* 수 정 자   :                                            */
/***********************************************************/

//조회조건 기본 세팅!
dw_cond.Object.change[1]  = "N"

end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
	cb_1.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space		
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
	cb_1.Y		= newheight - iu_cust_w_resize.ii_button_space_1		
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)



end event

event ue_ok;call super::ue_ok;//해당 서비스에 해당하는 품목 조회
STRING	ls_customerid,			ls_equipchange
LONG		ll_row

ls_customerid		= Trim(dw_cond.Object.customerid[1])
ls_equipchange		= Trim(dw_cond.Object.change[1])

IF ISNULL(ls_customerid)	THEN ls_customerid	 = ""
IF ISNULL(ls_equipchange)	THEN ls_equipchange	 = ""

IF ls_customerid = "" THEN
	F_MSG_INFO(200, Title, "CustomerID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	RETURN
END IF

ll_row = dw_master.Retrieve(ls_customerid)

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
	RETURN
ELSEIF ll_row = 0 THEN
	F_MSG_INFO(1000, Title, "")
	RETURN
END IF

SetRedraw(FALSE)

IF ll_row > 0 THEN
	dw_master.SetFocus()

	dw_cond.Enabled = FALSE
	p_ok.TriggerEvent("ue_disable")
END IF

SetRedraw(TRUE)	

p_reset.TriggerEvent("ue_enable")
end event

event ue_save;Constant Int LI_ERROR = -1 

If This.Trigger Event ue_extra_save() < 0 Then
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
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_master.SetFocus()
		Return LI_ERROR
	End If
End if

Return 0

end event

event ue_extra_save;STRING	ls_change,		ls_customerid,		ls_svccod,			ls_priceplan,		ls_partner,	&
			ls_status,		ls_action,			ls_errmsg,			ls_prov_check,		ls_new_validkey
LONG		ll_mas_row,		ll_det_row,			ll_contractseq,	ll_troubleno,		ll_orderno,	&
			ll_return,		ll_return_code,	ll_det_cnt
long     ll_equipseq
INTEGER	li_rc
CONSTANT	INT LI_ERROR = -1

dw_cond.AcceptText()
dw_master.AcceptText()
dw_detail.AcceptText()

ll_mas_row = dw_master.GetSelectedRow(0)
ll_det_row = dw_detail.GetSelectedRow(0)
ll_det_cnt = dw_detail.RowCount()

IF ll_det_cnt <= 0 THEN RETURN -1

ls_change       = dw_cond.Object.change[1]
ls_prov_check   = "Y"
ls_new_validkey = ""

ls_customerid	= dw_master.Object.customerid [ll_mas_row]
ll_contractseq = dw_master.Object.contractseq[ll_mas_row]
ls_svccod		= dw_master.Object.svccod     [ll_mas_row]
ls_priceplan	= dw_master.Object.priceplan  [ll_mas_row]	
ls_partner		= dw_master.Object.partner    [ll_mas_row]

//장비변경일 경우...
IF ls_change = "Y" THEN
	ls_status    = "CHANGE"
	ll_troubleno = dw_detail.Object.troubleno[ll_det_row]
	ll_orderno   = ll_troubleno			//오더번호에 트러블 번호를 넘긴다.
ELSE
	ls_status    = dw_detail.Object.status[ll_det_row]
	ll_orderno   = dw_detail.Object.svcorder_orderno[ll_det_row]
END IF

//번호변경일 경우 새로운 인증키를 찾아야 한다.
IF ls_status = "80" OR ls_status = "85" THEN	 // 번호변경
	SELECT NVL(MAX(VALIDKEY), '0') 
	INTO   :ls_new_validkey
	FROM   VALIDINFO
	WHERE  CUSTOMERID  = :ls_customerid
	AND    CONTRACTSEQ = :ll_contractseq
	AND    STATUS      NOT IN ('99', '90');
END IF		
	
IF ls_new_validkey = "0" THEN
	ls_new_validkey = ""
END IF

ll_return_code = wf_get_actioncode(ls_status, ls_priceplan, ls_action)

IF ll_return_code < 0 THEN
	f_msg_usr_err(9000, Title, "인증 ACTION 정보가 없습니다(wf_get_actioncode)")
END IF	

//ll_equipseq = long('')

ls_errmsg = space(1000)

//SQLCA.UBS_PROVISIONNING(ll_orderno,             ls_action,           ll_equipseq,                &
SQLCA.UBS_PROVISIONNING(ll_orderno,             ls_action,           0,                &
								ls_new_validkey,        ls_partner,                            &
								gs_pgm_id[1],           ll_return,           ls_errmsg)
								
IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ROLLBACK;
	ls_prov_check = "N"
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
	ROLLBACK;
	ls_prov_check = "N"
END IF

//로그남기기
INSERT INTO PROVISIONING_RETRY_LOG
	( CUSTOMERID    , CONTRACTSEQ    , ORDERNO     , ACTION    , STATUS         , PARTNER, 
	  SVCCOD        , PRICEPLAN      , CRT_USER    , CRTDT     , PROV_CHECK    )
VALUES
	( :ls_customerid, :ll_contractseq, :ll_orderno , :ls_action, :ls_status     , :ls_partner,
	  :ls_svccod    , :ls_priceplan  , :gs_user_id , SYSDATE   , :ls_prov_check);

IF SQLCA.SQLCODE <> 0 THEN		//For Programer
	MESSAGEBOX('확인', STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ROLLBACK;
	RETURN -1
END IF

//실패면 로그 커밋하고 실패로 리턴시킴
IF ls_prov_check = "N" THEN
	COMMIT;
	RETURN -1
END IF

COMMIT;

f_msg_info(3000, THIS.Title, "Save")	

RETURN 0
end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

dw_detail.DataObject = "ubs_dw_reg_provisioning_retry_det"
dw_detail.SetTransObject(SQLCA)

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_master.Reset()
dw_detail.Reset()

dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)

//조회조건 기본 세팅!
dw_cond.Object.change[1]	  = "N"
dw_cond.SetFocus()

Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within ubs_w_reg_provisioning_retry
integer width = 2423
string dataobject = "ubs_dw_reg_provisioning_retry_cond"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;STRING	ls_customerid,		ls_customernm

ls_customerid = dw_cond.Object.customerid[1]

SELECT CUSTOMERNM INTO :ls_customernm
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_customerid;

dw_cond.Object.customernm[1] = ls_customernm


end event

event dw_cond::doubleclicked;call super::doubleclicked;If dwo.name = "customerid" Then
	If dw_cond.iu_cust_help.ib_data[1] Then
			 THIS.Object.customerid[row] 	= iu_cust_help.is_data[1]
			 THIS.Object.customernm[row]	= iu_cust_help.is_data[2]
	End If
End if
end event

event dw_cond::ue_init;//고객
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"

end event

event dw_cond::rbuttondown;STRING ls_temp, ls_coltype

IF dwo.type = "column" THEN
	
	IF MidA(String(dwo.coltype), 1, 2) = "ch" THEN											//Char
		ls_temp = THIS.GetItemString(row, String(dwo.name))
	ELSEIF MidA(String(dwo.coltype), 1, 2) = "da" THEN										//Datetime
		ls_temp = String(THIS.GetItemDateTime(row, String(dwo.name)), 'mm-dd-yyyy')
	ELSEIF MidA(String(dwo.coltype), 1, 2) = "nu" THEN										//Number
		ls_temp = String(THIS.GetItemNumber(row, String(dwo.name)))
	ELSEIF MidA(String(dwo.coltype), 1, 2) = "de" THEN										//Decimal
		ls_temp = String(THIS.GetItemDecimal(row, String(dwo.name)))
	ELSEIF MidA(String(dwo.coltype), 1, 2) = "st" THEN										//string
		ls_temp = String(THIS.GetItemDecimal(row, String(dwo.name)))		
	ELSE																									//Else
		RETURN
	END IF
	
	IF IsNull(ls_temp) OR ls_temp = "" THEN RETURN			
	PARENT.POST Event ue_clip(ls_temp)	
	
END IF
end event

type p_ok from w_a_reg_m_m`p_ok within ubs_w_reg_provisioning_retry
integer x = 2583
end type

type p_close from w_a_reg_m_m`p_close within ubs_w_reg_provisioning_retry
integer x = 667
integer y = 1464
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within ubs_w_reg_provisioning_retry
integer width = 2866
end type

type dw_master from w_a_reg_m_m`dw_master within ubs_w_reg_provisioning_retry
integer x = 32
integer width = 2862
integer height = 520
string dataobject = "ubs_dw_reg_provisioning_retry_mas"
boolean hsplitscroll = false
end type

event dw_master::ue_init;call super::ue_init;//Sort 지정
dwObject ldwo_SORT
ldwo_SORT = Object.contractseq_t
uf_init(ldwo_SORT)
end event

type dw_detail from w_a_reg_m_m`dw_detail within ubs_w_reg_provisioning_retry
integer x = 32
integer y = 872
integer width = 2862
integer height = 552
string dataobject = "ubs_dw_reg_provisioning_retry_det"
end type

event dw_detail::constructor;SetTransObject(SQLCA)
//f_modify_dw_title(this)

end event

event dw_detail::ue_retrieve;STRING	ls_customerid,	ls_change
LONG		ll_row,			ll_contractseq

IF al_select_row = 0 THEN RETURN -1

SetRedraw(FALSE)

ls_change = dw_cond.Object.change[1]

IF ls_change = 'Y' THEN
	THIS.DataObject = "ubs_dw_reg_provisioning_retry_det2"
	THIS.SetTransObject(SQLCA)
ELSE
	THIS.DataObject = "ubs_dw_reg_provisioning_retry_det"	
	THIS.SetTransObject(SQLCA)	
END IF	

ll_contractseq = dw_master.Object.contractseq[al_select_row]
ls_customerid  = TRIM(dw_master.Object.customerid[al_select_row])

ll_row = THIS.retrieve(ls_customerid, ll_contractseq)

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN -1
END IF

IF ll_row >= 0 THEN
	THIS.SetFocus()	
END IF

SetRedraw(TRUE)
	
RETURN 0
end event

event dw_detail::doubleclicked;//
end event

event dw_detail::retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )
End If

end event

event dw_detail::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

type p_insert from w_a_reg_m_m`p_insert within ubs_w_reg_provisioning_retry
boolean visible = false
integer x = 1568
integer y = 1396
end type

type p_delete from w_a_reg_m_m`p_delete within ubs_w_reg_provisioning_retry
boolean visible = false
integer x = 1883
integer y = 1392
end type

type p_save from w_a_reg_m_m`p_save within ubs_w_reg_provisioning_retry
integer x = 32
integer y = 1464
end type

type p_reset from w_a_reg_m_m`p_reset within ubs_w_reg_provisioning_retry
integer x = 347
integer y = 1464
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ubs_w_reg_provisioning_retry
integer y = 840
end type

type cb_1 from commandbutton within ubs_w_reg_provisioning_retry
integer x = 1115
integer y = 1464
integer width = 283
integer height = 96
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "결과조회"
end type

event clicked;STRING	ls_change,		ls_set_value,		ls_worktype,		ls_pgm_id,			ls_pgm_name,	&
			ls_p_pgm_id,	ls_call_type,		ls_pgm_type,		ls_call_name[],	ls_p_pgm_name
LONG		ll_mas_row,		ll_det_row,			ll_det_cnt
DEC		lc_upd_auth
INTEGER	li_i
u_cust_a_msg lu_cust_msg
Window lw_temp

ls_change = dw_cond.Object.change[1]

dw_master.AcceptText()
dw_detail.AcceptText()

ll_mas_row = dw_master.GetSelectedRow(0)
ll_det_row = dw_detail.GetSelectedRow(0)
ll_det_cnt = dw_detail.RowCount()

IF ll_det_cnt <= 0 THEN RETURN -1

IF ls_change = "Y" THEN // CUSTOMER_TROUBLE 검색
	ls_set_value = STRING(dw_detail.Object.troubleno[ll_det_row])
	ls_worktype  = '200'
ELSE  // SVCORDER 검색
	ls_set_value = STRING(dw_detail.Object.svcorder_orderno[ll_det_row])
	ls_worktype  = '100'	
END IF

//인증결과조회 호출	
//화면띄워주기 위해 강제로 코딩!!! - 2009.06.03 최재혁			
SetPointer(HourGlass!)

SELECT PGM_ID    , PGM_NM      , P_PGM_ID    ,  UPD_AUTH   , CALL_TYPE    , PGM_TYPE    , CALL_NM1
INTO   :ls_pgm_id, :ls_pgm_name, :ls_p_pgm_id, :lc_upd_auth, :ls_call_type, :ls_pgm_type, :ls_call_name[1]
FROM   SYSPGM1T
WHERE  CALL_NM1 = 'ubs_w_reg_validresult'
AND    ROWNUM = 1;
			
//같은 프로그램 작동 중인지를 검사
For li_i = 1 To gi_open_win_no
	If gs_pgm_id[li_i] = ls_pgm_id Then
		f_msg_usr_err_app(504, Parent.Title, ls_pgm_name)
		Return
	End If
Next
		
//Window가 Max값 이상 열려있닌지 비교
If gi_open_win_no + 1 > gi_max_win_no Then
	f_msg_usr_err_app(505, Parent.Title, "")
	Return -1
End If
		
//Clicked TreeViewItem의 상위 TreeViewItem 정보 
//ls_p_pgm_id = '15000000'

SELECT PGM_NM 
INTO :ls_p_pgm_name
FROM   SYSPGM1T
WHERE  PGM_ID = :ls_p_pgm_id;

//*** 메세지 전달 객체에 자료 저장 ***
lu_cust_msg = Create u_cust_a_msg

lu_cust_msg.is_pgm_id   	 = ls_pgm_id
lu_cust_msg.is_grp_name 	 = ls_p_pgm_name
lu_cust_msg.is_pgm_name	    = ls_pgm_name
lu_cust_msg.is_call_name[1] = ls_call_name[1]
lu_cust_msg.is_call_name[2] = ls_worktype
lu_cust_msg.is_call_name[3] = ls_set_value

lu_cust_msg.is_pgm_type 	 = ls_pgm_type

If OpenSheetWithParm(lw_temp, lu_cust_msg, ls_call_name[1], gw_mdi_frame, 1, Original!) <> 1 Then
	f_msg_usr_err_app(503, Parent.Title, "'" + ls_call_name[1] + "' " + "window is not opened")
	Return -1
End If
end event

