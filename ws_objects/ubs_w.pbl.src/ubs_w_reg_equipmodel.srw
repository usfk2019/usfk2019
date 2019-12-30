$PBExportHeader$ubs_w_reg_equipmodel.srw
$PBExportComments$[jhchoi] 인증장비 모델관리 - 2011.02.16
forward
global type ubs_w_reg_equipmodel from w_base
end type
type cb_model from commandbutton within ubs_w_reg_equipmodel
end type
type cb_maker from commandbutton within ubs_w_reg_equipmodel
end type
type p_insert from u_p_insert within ubs_w_reg_equipmodel
end type
type p_delete from u_p_delete within ubs_w_reg_equipmodel
end type
type p_save from u_p_save within ubs_w_reg_equipmodel
end type
type p_reset from u_p_reset within ubs_w_reg_equipmodel
end type
type p_ok from u_p_ok within ubs_w_reg_equipmodel
end type
type dw_master from u_d_base within ubs_w_reg_equipmodel
end type
type dw_cond from u_d_help within ubs_w_reg_equipmodel
end type
type p_close from u_p_close within ubs_w_reg_equipmodel
end type
type gb_1 from groupbox within ubs_w_reg_equipmodel
end type
end forward

global type ubs_w_reg_equipmodel from w_base
integer width = 3625
integer height = 1744
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event ue_ok ( )
event type integer ue_reset ( )
event ue_save ( )
event type integer ue_insert ( )
event type integer ue_delete ( )
cb_model cb_model
cb_maker cb_maker
p_insert p_insert
p_delete p_delete
p_save p_save
p_reset p_reset
p_ok p_ok
dw_master dw_master
dw_cond dw_cond
p_close p_close
gb_1 gb_1
end type
global ubs_w_reg_equipmodel ubs_w_reg_equipmodel

type variables
u_cust_db_app iu_cust_db_app

Int ii_error_chk

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop						//The virtual top of the window
Integer		ii_WindowMiddle					//The virtual middle of the window
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Middle							//Reference to the Top Middle control
Dragobject	idrg_Bottom							//Reference to the Top Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides


String is_cus_status, is_hotbillflag, is_admst_status, is_amt_check, is_print_check
Dec    idc_bil_amt   
Long   il_extdays
end variables

forward prototypes
public subroutine of_refreshbars ()
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
public subroutine wf_protect (string ai_gubun)
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
end prototypes

event ue_close();CLOSE(THIS)
end event

event ue_inputvalidcheck;BOOLEAN	lb_check
LONG		ll_row
INTEGER	ii

ai_return = 0

FOR ii = 1 TO dw_master.RowCount()
	lb_check = FB_SAVE_REQUIRED(dw_master, ii)
	
	IF lb_check = FALSE THEN
		ai_return = -1
		exit
	END IF
NEXT	

RETURN
end event

event ue_processvalidcheck(ref integer ai_return);ai_return = 0

RETURN
end event

event ue_process;INTEGER	ii
DATETIME	ldt_sysdate
dwItemStatus l_status

dw_master.AcceptText()

SELECT SYSDATE INTO :ldt_sysdate
FROM   DUAL;

FOR ii = 1 TO dw_master.RowCount()
	l_status = dw_master.GetItemStatus(ii, 0, Primary!)

	IF l_status = DataModified! THEN
		dw_master.Object.updt_user[ii] 	= gs_user_id
		dw_master.Object.updtdt[ii]	 	= ldt_sysdate
		dw_master.Object.pgm_id[ii]	= gs_pgm_id[gi_open_win_no]
	END IF
NEXT

ai_return = 0

RETURN
end event

event ue_ok;//해당 서비스에 해당하는 품목 조회
STRING	ls_where,		ls_maker,		ls_model
LONG		ll_row,			ll_result
DATE		ld_paydt

dw_cond.AcceptText()

ls_maker	= Trim(dw_cond.object.makercd[1])
ls_model = Trim(dw_cond.object.modelno[1])

IF ISNULL(ls_maker) THEN ls_maker = ""
IF ISNULL(ls_model) THEN ls_model = ""

//Dynamic SQL
ls_where = ""

IF ls_maker <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MAKERCD = '" + ls_maker + "'"
END IF

IF ls_model <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MODELNO = '" + ls_model + "'"
END IF

//Retrieve
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN
ELSEIF ll_row = 0 THEN
	f_msg_info(1000, Title, "")	
END IF	

SetRedraw(FALSE)

p_save.TriggerEvent("ue_enable")
p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")	
dw_master.SetFocus()
dw_cond.Enabled = FALSE
p_ok.TriggerEvent("ue_disable")

SetRedraw(TRUE)
end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_rc

dw_master.AcceptText()

If (dw_master.ModifiedCount() > 0) Or (dw_master.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

//초기화
p_ok.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")

dw_cond.Enabled = True

dw_master.Reset()
dw_cond.ReSet()
dw_cond.InsertRow(0)

dw_cond.SetFocus()
dw_cond.SetColumn("makercd")

Return 0



end event

event ue_save;INTEGER		 li_rc
CONSTANT	INT LI_ERROR = -1

// Ue_inputValidCheck  호출
// 가격정보를 가지고 수납을 위한 팝업을 띄움.

TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN
END IF

//TRIGGER EVENT ue_processvalidcheck(li_rc)
//
//IF li_rc <> 0 THEN
//	RETURN
//END IF

TRIGGER EVENT ue_process(li_rc)

IF li_rc <> 0 THEN
	//ROLLBACK와 동일한 기능
	F_MSG_INFO(3010, Title, "Save")
	
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()
	
	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_master.SetFocus()
		RETURN
	END IF
	
	RETURN
ELSEIF li_rc = 0 THEN
	IF dw_master.Update() < 0 THEN
		//ROLLBACK와 동일한 기능
	
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = Title
	
		iu_cust_db_app.uf_prc_db()
		
		IF iu_cust_db_app.ii_rc = -1 THEN
			dw_master.SetFocus()
			F_MSG_INFO(3010, Title, "Save")			
			RETURN
		END IF

		F_MSG_INFO(3010, Title, "Save")					
		RETURN	
	ELSE		
		//COMMIT와 동일한 기능
		iu_cust_db_app.is_caller = "COMMIT"
		iu_cust_db_app.is_title = Title
	
		iu_cust_db_app.uf_prc_db()
	
		IF iu_cust_db_app.ii_rc = -1 THEN
			dw_master.SetFocus()
			F_MSG_INFO(3010, Title, "Save")			
			RETURN
		END IF

		F_MSG_INFO(3000, Title, "Save")	
	END IF	
END IF
end event

event ue_insert;Constant Int LI_ERROR = -1
Long 		ll_row
DATETIME ldt_sysdate
STRING	ls_maker,			ls_model

ls_maker = dw_cond.Object.makercd[1]
ls_model = dw_cond.Object.modelno[1]


ll_row = dw_master.InsertRow(dw_master.rowcount()+1)

SELECT SYSDATE INTO :ldt_sysdate
FROM   DUAL;

dw_master.Object.makercd[ll_row]		= ls_maker
dw_master.Object.modelno[ll_row]		= ls_model
dw_master.Object.sale_amt[ll_row]	= 0
dw_master.Object.use_yn[ll_row]		= 'Y'
dw_master.Object.crt_user[ll_row]	= gs_user_id
dw_master.Object.crtdt[ll_row]		= ldt_sysdate
dw_master.Object.updt_user[ll_row]	= gs_user_id
dw_master.Object.updtdt[ll_row]		= ldt_sysdate
dw_master.Object.pgm_id[ll_row]		= gs_pgm_id[gi_open_win_no]

dw_master.ScrollToRow(ll_row)
dw_master.SetRow(ll_row)
dw_master.SetFocus()
dw_master.SetColumn("makercd")

Return 0

end event

event ue_delete;dwItemStatus l_status

dw_master.AcceptText()

l_status = dw_master.GetItemStatus(dw_master.GetRow(), 0, Primary!)

IF l_status = NewModified! OR l_status = New! THEN
	dw_master.Deleterow(0)
END IF	

return 0
end event

public subroutine of_refreshbars ();
end subroutine

public subroutine of_resizebars ();
end subroutine

public subroutine of_resizepanels ();
end subroutine

public subroutine wf_protect (string ai_gubun);
end subroutine

public function integer wfi_get_customerid (string as_customerid, string as_memberid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
STRING 	ls_customernm, 	ls_payid, 	ls_partner, 	ls_customerid, 	ls_memberid
Integer	li_sw

IF as_customerid <> "" THEN
	li_sw = 1
ELSE
	li_sw = 2
END IF

IF li_sw = 1  THEN
	SELECT  CUSTOMERNM
			, STATUS
			, PAYID
			, PARTNER
			, MEMBERID
	INTO	  :ls_customernm,
		     :is_cus_status,
		     :ls_payid,
		     :ls_partner,
			  :ls_memberid
	FROM    CUSTOMERM
	WHERE   CUSTOMERID = :as_customerid;
	 
	ls_customerid = as_customerid
ELSE
	SELECT  CUSTOMERID
			, CUSTOMERNM
			, STATUS
			, PAYID
			, PARTNER
	INTO	  :ls_customerid,
	        :ls_customernm,
		     :is_cus_status,
		     :ls_payid,
		     :ls_partner
	FROM    CUSTOMERM
	WHERE   MEMBERID = :as_memberid;
	
	ls_memberid = as_customerid
END IF

IF SQLCA.SQLCODE = 100 THEN		//Not Found
	IF li_sw = 1 THEN
   	F_MSG_USR_ERR(201, Title, "Customer ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("customerid")
	ELSE
   	F_MSG_USR_ERR(201, Title, "Member ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("memberid")
	END IF
   RETURN -1
END IF

SELECT HOTBILLFLAG
INTO   :is_hotbillflag
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_payid;

IF SQLCA.SQLCODE = 100 THEN		//Not Found
   F_MSG_USR_ERR(201, Title, "고객번호(납입자번호)")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   RETURN -1
END IF

IF IsNull(is_hotbillflag) THEN is_hotbillflag = ""
IF is_hotbillflag = 'S' THEN    //현재 Hotbilling고객이면 개통신청 못하게 한다.
   F_MSG_USR_ERR(201, Title, "즉시불처리중인고객")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   RETURN -1
END IF

dw_cond.object.customernm[1] 	= ls_customernm
dw_cond.object.customerid[1] 	= ls_customerid
dw_cond.object.memberid[1] 	= ls_memberid

RETURN 0

end function

on ubs_w_reg_equipmodel.create
int iCurrent
call super::create
this.cb_model=create cb_model
this.cb_maker=create cb_maker
this.p_insert=create p_insert
this.p_delete=create p_delete
this.p_save=create p_save
this.p_reset=create p_reset
this.p_ok=create p_ok
this.dw_master=create dw_master
this.dw_cond=create dw_cond
this.p_close=create p_close
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_model
this.Control[iCurrent+2]=this.cb_maker
this.Control[iCurrent+3]=this.p_insert
this.Control[iCurrent+4]=this.p_delete
this.Control[iCurrent+5]=this.p_save
this.Control[iCurrent+6]=this.p_reset
this.Control[iCurrent+7]=this.p_ok
this.Control[iCurrent+8]=this.dw_master
this.Control[iCurrent+9]=this.dw_cond
this.Control[iCurrent+10]=this.p_close
this.Control[iCurrent+11]=this.gb_1
end on

on ubs_w_reg_equipmodel.destroy
call super::destroy
destroy(this.cb_model)
destroy(this.cb_maker)
destroy(this.p_insert)
destroy(this.p_delete)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.p_ok)
destroy(this.dw_master)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.gb_1)
end on

event open;call super::open;//=========================================================//
// Desciption : 인증장비 모델을 관리한다.						  //
// Name       : ubs_w_reg_equipmodel		                 //
// Contents   : 모델 아이템, 금액을 관리한다.				  //
// Data Window: dw - ubs_dw_reg_equipmodel_cnd   		     // 
//							ubs_dw_reg_equipmodel_mas				  //
// 작성일자   : 2011.02.16                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc

iu_cust_db_app = CREATE u_cust_db_app

// Set the Top, Bottom Controls
//idrg_Top = dw_master
//idrg_Bottom = dw_detail

//Change the back color so they cannot be seen.
//ii_WindowTop = idrg_Top.Y
//st_horizontal.BackColor = BackColor
//il_HiddenColor = BackColor

// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()

dw_cond.InsertRow(0)

p_ok.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")

end event

event close;call super::close;DESTROY iu_cust_db_app
end event

event resize;//2009-03-17 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

IF newheight < (dw_master.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_master.Height = 0
  
	p_save.Y		= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space	
	p_close.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
	p_insert.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space	
	cb_maker.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
	cb_model.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
	
ELSE
	dw_master.Height = newheight - dw_master.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	cb_maker.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	cb_model.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	
END IF

IF newwidth < dw_master.X  THEN
	dw_master.Width = 0
ELSE
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
END IF

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(TRUE)

end event

event closequery;Int li_rc

dw_master.AcceptText()

If (dw_master.ModifiedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

type cb_model from commandbutton within ubs_w_reg_equipmodel
integer x = 2427
integer y = 1476
integer width = 325
integer height = 104
integer taborder = 40
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "MODEL"
end type

event clicked;iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Model Management"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_master

//샵 선택 팝업
OpenWithParm(ubs_w_pop_equipmodel, iu_cust_msg)

DESTROY iu_cust_msg
end event

type cb_maker from commandbutton within ubs_w_reg_equipmodel
integer x = 2021
integer y = 1476
integer width = 325
integer height = 104
integer taborder = 40
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "MAKER"
end type

event clicked;iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Maker Management"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_master

//샵 선택 팝업
OpenWithParm(ubs_w_pop_equipmaker, iu_cust_msg)

DESTROY iu_cust_msg
end event

type p_insert from u_p_insert within ubs_w_reg_equipmodel
integer x = 23
integer y = 1476
end type

type p_delete from u_p_delete within ubs_w_reg_equipmodel
integer x = 329
integer y = 1476
boolean originalsize = false
end type

type p_save from u_p_save within ubs_w_reg_equipmodel
integer x = 635
integer y = 1476
boolean originalsize = false
end type

type p_reset from u_p_reset within ubs_w_reg_equipmodel
integer x = 1344
integer y = 1476
boolean originalsize = false
end type

type p_ok from u_p_ok within ubs_w_reg_equipmodel
integer x = 3255
integer y = 56
end type

type dw_master from u_d_base within ubs_w_reg_equipmodel
integer x = 14
integer y = 208
integer width = 3557
integer height = 1224
integer taborder = 30
string dataobject = "ubs_dw_reg_equipmodel_mas"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

event clicked;IF row <= 0 THEN RETURN



end event

event constructor;SetTransObject(SQLCA)
end event

type dw_cond from u_d_help within ubs_w_reg_equipmodel
integer x = 46
integer y = 36
integer width = 2720
integer height = 140
integer taborder = 10
string dataobject = "ubs_dw_reg_equipmodel_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event constructor;SetTransObject(SQLCA)


end event

event doubleclicked;//
return 0
end event

type p_close from u_p_close within ubs_w_reg_equipmodel
integer x = 942
integer y = 1476
boolean originalsize = false
end type

type gb_1 from groupbox within ubs_w_reg_equipmodel
integer x = 14
integer y = 8
integer width = 3557
integer height = 176
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

