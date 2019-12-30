$PBExportHeader$ubs_w_reg_prepay.srw
$PBExportComments$[jhchoi] 선수금 관리 - 2009.04.29
forward
global type ubs_w_reg_prepay from w_a_reg_m_m
end type
end forward

global type ubs_w_reg_prepay from w_a_reg_m_m
integer width = 2962
integer height = 1756
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
end type
global ubs_w_reg_prepay ubs_w_reg_prepay

type variables
STRING	is_orderstatus[], is_amt_check
end variables

forward prototypes
public subroutine wf_protect (string ai_gubun)
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
end prototypes

event ue_inputvalidcheck(ref integer ai_return);ai_return = 0

RETURN
end event

event ue_processvalidcheck(ref integer ai_return);ai_return = 0

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

public function integer wfi_get_customerid (string as_customerid, string as_memberid);STRING	ls_customerid,		ls_payid,		ls_customernm,		ls_memberid,	&
			ls_lastname,		ls_firstname

ls_customerid 		= as_customerid

IF ls_customerid <> '' THEN
	Select Customernm, lastname, firstname
	Into   :ls_customernm, :ls_lastname, :ls_firstname
	From   Customerm
   Where  customerid = :ls_customerid;
ELSE
	Select CUSTOMERID, Customernm, lastname, firstname
	Into   :ls_customerid, :ls_customernm, :ls_lastname, :ls_firstname
	From   Customerm
   Where  MEMBERID = :as_memberid;
END IF

IF IsNull(ls_customernm) THEN ls_customernm 		= ''
IF IsNull(ls_customerid) THEN ls_customerid 		= ''
IF IsNull(ls_lastname) 	 THEN ls_lastname 	= ''
IF IsNull(ls_firstname)  THEN ls_firstname 	= ''

IF SQLCA.SQLCode < 0 THEN
	f_msg_sql_err(Title, "Customer ID(wfi_get_customerid)")
	RETURN -1
ELSEIF SQLCA.SQLCode = 100 THEN
	RETURN -1
END IF

dw_cond.object.lastname[1]   = ls_lastname
dw_cond.object.firstname[1]  = ls_firstname
dw_cond.object.customerid[1] = ls_customerid

Return 0

end function

on ubs_w_reg_prepay.create
call super::create
end on

on ubs_w_reg_prepay.destroy
call super::destroy
end on

event open;call super::open;//=========================================================//
// Desciption : 선수금 관리 화면					              //
// Name       : ubs_w_reg_prepay				                 //
// Contents   : 선수금을 관리하며 추가수납, 환불 가능		  //
// Data Window: dw - ubs_dw_reg_prepay_cond		           // 
//							ubs_dw_reg_prepay_mas 					  //
//							ubs_dw_reg_prepay_det					  //
// 작성일자   : 2009.04.29                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc,		ls_temp

//조회조건 기본 세팅!
//dw_cond.Object.partner[1] = gs_shopid
//dw_cond.Object.new[1]	  = "N"
//dw_cond.Object.orderdt[1] = fdt_get_dbserver_now()


//Order Status 값! - 신청 상태일 경우만 변경할 수 있도록 하기 위함! sysctl1t 에서 가져온다
//ls_ref_desc = ""
//ls_temp     = fs_get_control("U0", "E100", ls_ref_desc)
//IF ls_temp  = "" THEN RETURN
//fi_cut_string(ls_temp, ";", is_orderstatus[])
is_amt_check = 'N'

dw_cond.SetFocus()

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

event ue_ok();call super::ue_ok;STRING	ls_customerid,		ls_lastname,		ls_firstname,		ls_homephone,		&
			ls_emailid,			ls_roomno,			ls_buildingno,		ls_cellphone,		&
			ls_where
LONG		ll_row			

ls_customerid = Trim(dw_cond.Object.customerid[1])
ls_lastname	  = Trim(dw_cond.Object.lastname[1])
ls_firstname  = Trim(dw_cond.Object.firstname[1])
ls_homephone  = Trim(dw_cond.Object.homephone[1])
ls_emailid    = Trim(dw_cond.Object.emailid[1])
ls_roomno     = Trim(dw_cond.Object.roomno[1])
ls_buildingno = Trim(dw_cond.Object.buildingno[1])
ls_cellphone  = Trim(dw_cond.Object.cellphone[1])

IF ISNULL(ls_customerid)	THEN ls_customerid	= ""
IF ISNULL(ls_lastname)		THEN ls_lastname		= ""
IF ISNULL(ls_firstname)		THEN ls_firstname		= ""
IF ISNULL(ls_homephone)		THEN ls_homephone	 	= ""
IF ISNULL(ls_emailid)		THEN ls_emailid		= ""
IF ISNULL(ls_roomno)			THEN ls_roomno			= ""
IF ISNULL(ls_buildingno)	THEN ls_buildingno	= ""
IF ISNULL(ls_cellphone)		THEN ls_cellphone	 	= ""

IF ls_customerid = "" AND ls_lastname = "" AND ls_firstname = ""  AND ls_homephone = "" AND &
   ls_emailid = ""	 AND ls_roomno = ""	 AND ls_buildingno = "" AND ls_cellphone = "" THEN
	f_msg_info(200, Title, "검색조건을 하나 이상 입력하세요!")
	RETURN
END IF

ls_where = "" 

IF ls_customerid <> "" THEN
	ls_where += " CUS.CUSTOMERID = '" + ls_customerid + "' "
ELSE
	IF ls_lastname <> "" THEN
		ls_where += " CUS.LASTNAME = '" + ls_lastname + "' "
		IF ls_firstname <> "" THEN
			ls_where += " AND CUS.FIRSTNAME = '" + ls_firstname + "' "			
		END IF
	ELSE
		IF ls_firstname <> "" THEN
			ls_where += " CUS.FIRSTNAME = '" + ls_firstname + "' "
		END IF
	END IF		
END IF	

IF ls_homephone <> "" THEN
	IF ls_where = "" THEN
		ls_where += " CUS.HOMEPHONE = '" + ls_homephone + "' "
	END IF
	ls_where += " AND CUS.HOMEPHONE = '" + ls_homephone + "' "
END IF

IF ls_emailid <> "" THEN
	IF ls_where = "" THEN
		ls_where += " CUS.EMAIL1 = '" + ls_emailid + "' "
	END IF
	ls_where += " AND CUS.EMAIL1 = '" + ls_emailid + "' "
END IF

IF ls_roomno <> "" THEN
	IF ls_where = "" THEN
		ls_where += " CUS.ROOMNO = '" + ls_roomno + "' "
	END IF
	ls_where += " AND CUS.ROOMNO = '" + ls_roomno + "' "
END IF

IF ls_buildingno <> "" THEN
	IF ls_where = "" THEN
		ls_where += " CUS.BUILDINGNO = '" + ls_buildingno + "' "
	END IF
	ls_where += " AND CUS.BUILDINGNO = '" + ls_buildingno + "' "
END IF

IF ls_cellphone <> "" THEN
	IF ls_where = "" THEN
		ls_where += " CUS.CELLPHONE = '" + ls_cellphone + "' "
	END IF
	ls_where += " AND CUS.CELLPHONE = '" + ls_cellphone + "' "
END IF

	
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN
ELSEIF ll_row = 0 THEN
	F_MSG_INFO(1000, Title, "")
END IF

SetRedraw(FALSE)

dw_master.SetFocus()

SetRedraw(TRUE)	

dw_cond.Enabled = FALSE
p_ok.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_enable")
p_insert.TriggerEvent("ue_enable")
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

event type integer ue_extra_save();call super::ue_extra_save;return 0
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//dw_detail.AcceptText()

//If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
//	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
//		Question!, YesNo!)
//   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
//End If

//p_save.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_master.Reset()
dw_detail.Reset()

dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)

//조회조건 기본 세팅!
dw_cond.SetFocus()
is_amt_check = 'N'
Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within ubs_w_reg_prepay
integer width = 2423
integer height = 296
string dataobject = "ubs_dw_reg_prepay_cond"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Help Window
THIS.idwo_help_col[1] 	= THIS.Object.customerid
THIS.is_help_win[1] 		= "SSRT_hlp_customer"
THIS.is_data[1] 			= "CloseWithReturn"

THIS.SetFocus()
THIS.SetRow(1)
THIS.SetColumn('customerid')
end event

event dw_cond::doubleclicked;call super::doubleclicked;STRING	ls_cus_status

CHOOSE CASE dwo.name
	CASE "customerid"
		IF iu_cust_help.ib_data[1] THEN
			ls_cus_status 				= iu_cust_help.is_data[3]
			
			IF wfi_get_customerid(iu_cust_help.is_data[1], "") = -1 THEN
				RETURN -1	
			END IF
		END IF
END CHOOSE

RETURN 0 
end event

event dw_cond::itemchanged;call super::itemchanged;CHOOSE CASE dwo.name
	CASE "customerid" 
   	  wfi_get_customerid(data, "")

END CHOOSE

RETURN 0
end event

type p_ok from w_a_reg_m_m`p_ok within ubs_w_reg_prepay
integer x = 2583
integer y = 112
end type

type p_close from w_a_reg_m_m`p_close within ubs_w_reg_prepay
integer x = 667
integer y = 1520
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within ubs_w_reg_prepay
integer width = 2866
integer height = 364
end type

type dw_master from w_a_reg_m_m`dw_master within ubs_w_reg_prepay
integer x = 32
integer y = 376
integer width = 2373
integer height = 612
string dataobject = "ubs_dw_reg_prepay_mas"
boolean hsplitscroll = false
end type

event dw_master::ue_init();call super::ue_init;//Sort 지정
dwObject ldwo_SORT
ldwo_SORT = Object.payid_t
uf_init(ldwo_SORT)
end event

event dw_master::retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )

	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
	p_insert.TriggerEvent("ue_enable")

	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
End If

end event

event dw_master::clicked;call super::clicked;is_amt_check = 'N'

return 0
end event

type dw_detail from w_a_reg_m_m`dw_detail within ubs_w_reg_prepay
integer x = 32
integer y = 1024
integer width = 2053
integer height = 460
string dataobject = "ubs_dw_reg_prepay_det"
end type

event dw_detail::constructor;SetTransObject(SQLCA)
f_modify_dw_title(this)

end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;STRING	ls_payid
LONG		ll_row

IF al_select_row = 0 THEN RETURN -1

SetRedraw(FALSE)

ls_payid = dw_master.Object.payid[al_select_row]

ll_row = THIS.retrieve(ls_payid)

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN -1
ELSEIF ll_row = 0 THEN
	F_MSG_INFO(1000, Title, "")
   RETURN -1
END IF

SetRedraw(TRUE)
	
RETURN 0
end event

event dw_detail::doubleclicked;//
end event

type p_insert from w_a_reg_m_m`p_insert within ubs_w_reg_prepay
integer y = 1520
boolean enabled = true
end type

event p_insert::clicked;//----------------------------------------------------
//선수금 수납을 위한 팝업 연결
// OpenWithParm(ubs_w_reg_prepayrefund, iu_cust_msg)
//----------------------------------------------------
INTEGER	li_rc
STRING	ls_payid,		ls_customernm,		ls_save_check
LONG		ll_row

ll_row = dw_master.GetRow()

IF ll_row <= 0 THEN   //신규로 들어가는 거 때문에..
	ls_payid     = dw_cond.Object.customerid[1]
	IF IsNull(ls_payid) OR ls_payid = "" THEN 
		f_msg_info(200, Title, "Customer ID!")
		RETURN -1
	END IF

	SELECT CUSTOMERNM 
	INTO :ls_customernm
	FROM   CUSTOMERM
	WHERE  CUSTOMERID = :ls_payid;
	
	IF IsNull(ls_customernm) OR ls_customernm = "" THEN
		f_msg_info(200, Title, "Customer ID!")
		RETURN -1
	END IF		
	
ELSE
	ls_payid			 = dw_master.Object.payid[ll_row]
	ls_customernm 	 = dw_master.Object.customernm[ll_row]
END IF

//이미 수납을 했는지 확인
IF is_amt_check = "Y" THEN 
	ls_save_check = "Y"
ELSE
	ls_save_check = "N"
END IF	

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Pre-Payment"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = ll_row  				//현재 row
iu_cust_msg.idw_data[1] = dw_master
iu_cust_msg.idw_data[2] = dw_detail
iu_cust_msg.is_data[2]  = ls_payid
iu_cust_msg.is_data[3]  = ls_customernm
iu_cust_msg.is_data[4]  = ""						//이 화면에서는 사용 안함
iu_cust_msg.is_data[5]  = ls_save_check
//품목넘김
iu_cust_msg.il_data[2]  = 1			//item 갯수
iu_cust_msg.is_data2[1] = "014SSRT" //기본으로 itemcod는 Pre-Payment Amount(INT)
iu_cust_msg.ic_data[1]  = 0	   	//

//선수금 수납을 위한 팝업 연결
OpenWithParm(ubs_w_reg_prepayrefund, iu_cust_msg)

//is_amt_check 값 세팅 : 수납 팝업에서 반환되는 값. 미완료:'N', 완료:'Y'
IF iu_cust_msg.ib_data[1] THEN
	is_amt_check = iu_cust_msg.is_data[1]
END IF

IF is_amt_check = 'Y' THEN
	PARENT.TRIGGER EVENT ue_ok()
END IF

DESTROY iu_cust_msg

RETURN 0
end event

type p_delete from w_a_reg_m_m`p_delete within ubs_w_reg_prepay
boolean visible = false
integer x = 1883
integer y = 1368
end type

type p_save from w_a_reg_m_m`p_save within ubs_w_reg_prepay
boolean visible = false
integer x = 2578
integer y = 1528
end type

type p_reset from w_a_reg_m_m`p_reset within ubs_w_reg_prepay
integer x = 347
integer y = 1520
boolean enabled = true
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ubs_w_reg_prepay
integer y = 988
end type

