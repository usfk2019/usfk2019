$PBExportHeader$ubs_w_reg_equiporder.srw
$PBExportComments$[jhchoi] 인증장비 신청 조회 및 신청 - 2009.04.10
forward
global type ubs_w_reg_equiporder from w_a_reg_m_m
end type
end forward

global type ubs_w_reg_equiporder from w_a_reg_m_m
integer width = 2962
integer height = 1708
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
end type
global ubs_w_reg_equiporder ubs_w_reg_equiporder

type variables
STRING	is_orderstatus[]
end variables

forward prototypes
public subroutine wf_protect (string ai_gubun)
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

event ue_processvalidcheck(ref integer ai_return);LONG		ll_row
STRING	ls_orderstatus,	ls_shopid

ll_row = dw_detail.GetRow()

ls_orderstatus = dw_detail.Object.status[ll_row]
ls_shopid		= dw_detail.Object.partner[ll_row]

IF ls_orderstatus <> is_orderstatus[1] THEN
	F_MSG_INFO(9000, Title, "신청상태만 저장 가능합니다.")
	ai_return = -1
	RETURN
END IF

IF ls_shopid <> gs_shopid THEN
	F_MSG_INFO(9000, Title, "로그인 Shop ID 와 데이터 Shop ID 가 틀립니다.")
	ai_return = -1
	RETURN
END IF

ai_return = 0

RETURN
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

on ubs_w_reg_equiporder.create
call super::create
end on

on ubs_w_reg_equiporder.destroy
call super::destroy
end on

event open;call super::open;//=========================================================//
// Desciption : 인증장비 신청 조회 및 신청                 //
// Name       : ubs_w_reg_equiporder		                 //
// Contents   : 샵에서 인증장비를 신청하거나 신청내역을    //
//              조회한다.						                 //
// Data Window: dw - ubs_dw_reg_equiporder_cond	           // 
//							ubs_dw_reg_equiporder_mas 				  //
//							ubs_dw_reg_equiporder_det				  //
// 작성일자   : 2009.04.10                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc,		ls_temp

//조회조건 기본 세팅!
dw_cond.Object.partner[1] = gs_shopid
dw_cond.Object.new[1]	  = "N"
dw_cond.Object.orderdt[1] = fdt_get_dbserver_now()


//Order Status 값! - 신청 상태일 경우만 변경할 수 있도록 하기 위함! sysctl1t 에서 가져온다
ls_ref_desc = ""
ls_temp     = fs_get_control("U0", "E100", ls_ref_desc)
IF ls_temp  = "" THEN RETURN
fi_cut_string(ls_temp, ";", is_orderstatus[])

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
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
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

event ue_ok();call super::ue_ok;//해당 서비스에 해당하는 품목 조회
STRING	ls_shopid,		ls_new,		ls_orderdt,		ls_order_status,	&
			ls_where
LONG		ll_row			

ls_shopid			= Trim(dw_cond.object.partner[1]) 
ls_new				= Trim(dw_cond.object.new[1])
ls_orderdt			= Trim(String(dw_cond.object.orderdt[1], 'yyyymmdd'))
ls_order_status	= Trim(dw_cond.object.order_status[1])

IF ISNULL(ls_shopid)			THEN ls_shopid			 = ""
IF ISNULL(ls_new)				THEN ls_new				 = ""
IF ISNULL(ls_orderdt)		THEN ls_orderdt		 = ""
IF ISNULL(ls_order_status)	THEN ls_order_status	 = ""

IF ls_shopid = "" THEN
	F_MSG_INFO(200, Title, "Shop")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	RETURN
END IF

IF ls_new = 'N' THEN		//신규가 아닐경우
	ls_where = "" 

	ls_where += " EQUIPORDER.PARTNER = '" + ls_shopid + "' "

	IF ls_orderdt <> "" THEN
		ls_where += " AND EQUIPORDER.ORDERDT = TO_DATE('" + ls_orderdt + "', 'YYYYMMDD') "
	END IF

	IF ls_order_status <> "" THEN
		ls_where += " AND EQUIPORDER.STATUS = '" + ls_order_status + "' "
	END IF							
	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()

	IF ll_row < 0 THEN
		F_MSG_INFO(2100, Title, "Retrieve()")
	   RETURN
	ELSEIF ll_row = 0 THEN
		F_MSG_INFO(1000, Title, "Equipment Order")
		RETURN
	END IF

	SetRedraw(FALSE)

	IF ll_row > 0 THEN
		dw_master.SetFocus()

		dw_cond.Enabled = FALSE
		p_ok.TriggerEvent("ue_disable")
	END IF

	SetRedraw(TRUE)	
ELSE
	//신규 입력
	This.TriggerEvent('ue_insert')
	dw_detail.SetFocus()	
END IF

dw_cond.Enabled = FALSE
p_ok.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_enable")
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;LONG	ll_eqorderno
DATE	ld_sysdate

//신규 입력. dw_cond 에 있는 내용중 gs_shopid 만 옮긴다. operator 는 현재 사용자로 세팅!
dw_detail.Enabled = TRUE

SELECT SEQ_EQORDERNO.NEXTVAL, TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD')
INTO   :ll_eqorderno, :ld_sysdate
FROM	 DUAL;


dw_detail.Object.eqorderno[al_insert_row]	= ll_eqorderno
dw_detail.Object.partner[al_insert_row]	= gs_shopid
dw_detail.Object.orderdt[al_insert_row]	= ld_sysdate
dw_detail.Object.operator[al_insert_row] 	= gs_user_id
dw_detail.Object.status[al_insert_row] 	= is_orderstatus[1]
dw_detail.Object.crt_user[al_insert_row]	= gs_user_id
dw_detail.Object.crtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[1]

p_save.TriggerEvent("ue_enable")

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)

RETURN 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
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
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"Save")
End if

Return 0

end event

event type integer ue_extra_save();call super::ue_extra_save;INTEGER		 li_rc
CONSTANT	INT LI_ERROR = -1

// Ue_inputValidCheck  호출 ( 필수값 확인 )
TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

// 저장 프로세스 확인!!!
TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

RETURN 0
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_master.Reset()
dw_detail.Reset()

dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)

//조회조건 기본 세팅!
dw_cond.Object.partner[1] = gs_shopid
dw_cond.Object.new[1]	  = "N"
dw_cond.Object.orderdt[1] = fdt_get_dbserver_now()
dw_cond.SetFocus()

Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within ubs_w_reg_equiporder
integer width = 2423
string dataobject = "ubs_dw_reg_equiporder_cond"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within ubs_w_reg_equiporder
integer x = 2583
integer y = 112
end type

type p_close from w_a_reg_m_m`p_close within ubs_w_reg_equiporder
integer x = 667
integer y = 1464
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within ubs_w_reg_equiporder
integer width = 2866
end type

type dw_master from w_a_reg_m_m`dw_master within ubs_w_reg_equiporder
integer x = 32
integer width = 2862
integer height = 520
string dataobject = "ubs_dw_reg_equiporder_mas"
boolean hsplitscroll = false
end type

event dw_master::ue_init();call super::ue_init;//Sort 지정
dwObject ldwo_SORT
ldwo_SORT = Object.orderdt_t
uf_init(ldwo_SORT)
end event

type dw_detail from w_a_reg_m_m`dw_detail within ubs_w_reg_equiporder
integer x = 32
integer y = 872
integer width = 2862
integer height = 552
string dataobject = "ubs_dw_reg_equiporder_det"
end type

event dw_detail::constructor;SetTransObject(SQLCA)
f_modify_dw_title(this)

end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;STRING	ls_status
LONG		ll_row,			ll_eqorderno

IF al_select_row = 0 THEN RETURN -1

SetRedraw(FALSE)

ll_eqorderno = dw_master.Object.eqorderno[al_select_row]
ls_status	 = TRIM(dw_master.Object.status[al_select_row])

ll_row = THIS.retrieve(ll_eqorderno)

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN -1
END IF

IF ll_row >= 0 THEN
	//THIS.SetFocus()	
END IF

//상태값이 신청이 아니면 수정 불가!
IF ls_status <> is_orderstatus[1] THEN	
	THIS.Enabled = FALSE
ELSE
	THIS.Enabled = TRUE	
	THIS.Object.updt_user[1] = gs_user_id
	THIS.Object.updtdt[1]	 = fdt_get_dbserver_now()	
	
	//수정된 내용이 없도록 하기 위해서 강제 세팅!
	THIS.SetItemStatus(1, 0, Primary!, NotModified!)
	
	p_save.TriggerEvent("ue_enable")	
END IF

SetRedraw(TRUE)
	
RETURN 0
end event

event dw_detail::doubleclicked;//
end event

event dw_detail::retrieveend;call super::retrieveend;STRING	ls_status

ls_status	 = TRIM(dw_detail.Object.status[1])

wf_protect(ls_status)
end event

type p_insert from w_a_reg_m_m`p_insert within ubs_w_reg_equiporder
boolean visible = false
integer x = 1568
integer y = 1372
end type

type p_delete from w_a_reg_m_m`p_delete within ubs_w_reg_equiporder
boolean visible = false
integer x = 1883
integer y = 1368
end type

type p_save from w_a_reg_m_m`p_save within ubs_w_reg_equiporder
integer x = 32
integer y = 1464
end type

type p_reset from w_a_reg_m_m`p_reset within ubs_w_reg_equiporder
integer x = 347
integer y = 1464
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ubs_w_reg_equiporder
integer y = 840
end type

