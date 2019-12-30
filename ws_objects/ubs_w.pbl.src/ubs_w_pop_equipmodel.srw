$PBExportHeader$ubs_w_pop_equipmodel.srw
$PBExportComments$[jhchoi] 인증장비 모델 등록 팝업 - 2011.02.17
forward
global type ubs_w_pop_equipmodel from w_a_hlp
end type
type p_insert from u_p_insert within ubs_w_pop_equipmodel
end type
type p_delete from u_p_delete within ubs_w_pop_equipmodel
end type
type p_save from u_p_save within ubs_w_pop_equipmodel
end type
type gb_1 from groupbox within ubs_w_pop_equipmodel
end type
end forward

global type ubs_w_pop_equipmodel from w_a_hlp
integer width = 4439
integer height = 1192
string title = ""
event ue_print ( )
event ue_psetup ( )
event type integer ue_insert ( )
event type integer ue_delete ( )
event ue_save ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
p_insert p_insert
p_delete p_delete
p_save p_save
gb_1 gb_1
end type
global ubs_w_pop_equipmodel ubs_w_pop_equipmodel

type variables
u_cust_db_app iu_cust_db_app
String is_print_check
end variables

event ue_insert;Constant Int LI_ERROR = -1
Long 		ll_row
DATETIME ldt_sysdate

ll_row = dw_hlp.InsertRow(dw_hlp.rowcount()+1)

SELECT SYSDATE INTO :ldt_sysdate
FROM   DUAL;

dw_hlp.Object.cl[ll_row]			= 'Y'
dw_hlp.Object.crt_user[ll_row]	= gs_user_id
dw_hlp.Object.crtdt[ll_row]		= ldt_sysdate
dw_hlp.Object.updt_user[ll_row]	= gs_user_id
dw_hlp.Object.updtdt[ll_row]		= ldt_sysdate
dw_hlp.Object.pgm_id[ll_row]		= gs_pgm_id[gi_open_win_no]

dw_hlp.ScrollToRow(ll_row)
dw_hlp.SetRow(ll_row)
dw_hlp.SetFocus()
dw_hlp.SetColumn("modelno")

Return 0

end event

event ue_delete;dwItemStatus l_status

dw_hlp.AcceptText()

l_status = dw_hlp.GetItemStatus(dw_hlp.GetRow(), 0, Primary!)

IF l_status = NewModified! OR l_status = New! THEN
	dw_hlp.Deleterow(0)
END IF	

return 0
end event

event ue_save;INTEGER		 li_rc
CONSTANT	INT LI_ERROR = -1

// Ue_inputValidCheck  호출
// 가격정보를 가지고 수납을 위한 팝업을 띄움.

TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN
END IF

TRIGGER EVENT ue_process(li_rc)

IF li_rc <> 0 THEN
	//ROLLBACK와 동일한 기능
	ROLLBACK;
	F_MSG_INFO(3010, Title, "Save")
	RETURN
ELSEIF li_rc = 0 THEN
	IF dw_hlp.Update() < 0 THEN
		//ROLLBACK와 동일한 기능
		ROLLBACK;
		F_MSG_INFO(3010, Title, "Save")			
		RETURN
	ELSE		
		//COMMIT와 동일한 기능
		COMMIT;
		F_MSG_INFO(3000, Title, "Save")	
	END IF	
END IF
end event

event ue_inputvalidcheck;BOOLEAN	lb_check
LONG		ll_row
INTEGER	ii

ai_return = 0

FOR ii = 1 TO dw_hlp.RowCount()
	lb_check = FB_SAVE_REQUIRED(dw_hlp, ii)
	
	IF lb_check = FALSE THEN
		ai_return = -1
		exit
	END IF
NEXT	

RETURN
end event

event ue_process;INTEGER	ii
DATETIME	ldt_sysdate
dwItemStatus l_status

dw_hlp.AcceptText()

SELECT SYSDATE INTO :ldt_sysdate
FROM   DUAL;

FOR ii = 1 TO dw_hlp.RowCount()
	l_status = dw_hlp.GetItemStatus(ii, 0, Primary!)

	IF l_status = DataModified! THEN
		dw_hlp.Object.updt_user[ii] 	= gs_user_id
		dw_hlp.Object.updtdt[ii]	 	= ldt_sysdate
		dw_hlp.Object.pgm_id[ii]		= gs_pgm_id[gi_open_win_no]
	END IF
NEXT

ai_return = 0

RETURN
end event

on ubs_w_pop_equipmodel.create
int iCurrent
call super::create
this.p_insert=create p_insert
this.p_delete=create p_delete
this.p_save=create p_save
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_insert
this.Control[iCurrent+2]=this.p_delete
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.gb_1
end on

on ubs_w_pop_equipmodel.destroy
call super::destroy
destroy(this.p_insert)
destroy(this.p_delete)
destroy(this.p_save)
destroy(this.gb_1)
end on

event open;call super::open;//=============================================================//
// Desciption : 인증장비 메이커를 관리하는 POP UP					//
// Name       : ubs_w_pop_equipmaker							      //
// Contents   : 인증장비 메이커를 관리한다.					      //
// Data Window: dw - ubs_dw_pop_equipmaker_mas			         // 
// 작성일자   : 2011.02.17                                     //
// 작 성 자   : 최재혁 대리                                    //
// 수정일자   :                                                //
// 수 정 자   :                                                //
//=============================================================//

LONG		  ll_row

//==========================================================//
//ubs_w_reg_equipmodel maker 버튼 클릭시 넘어오는 값	  		//
//iu_cust_msg 				= CREATE u_cust_a_msg					//
//iu_cust_msg.is_pgm_name = "Maker Management"					//
//iu_cust_msg.is_data[1]  = "CloseWithReturn"					//
//iu_cust_msg.il_data[1]  = 1  		//현재 row					//
//iu_cust_msg.is_data[2]  = data										//
//iu_cust_msg.idw_data[1] = dw_master								//
//==========================================================//

This.Title =  iu_cust_help.is_pgm_name 

dw_hlp.Retrieve()
dw_hlp.SetFocus()


end event

event ue_close;STRING	ls_contractseq
LONG		ll_row

dw_hlp.AcceptText()

iu_cust_help.ib_data[1] = TRUE

CLOSE(THIS)
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_equipmodel
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_equipmodel
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_equipmodel
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_equipmodel
integer x = 937
integer y = 964
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_equipmodel
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_equipmodel
integer x = 18
integer y = 20
integer width = 4389
integer height = 888
string dataobject = "ubs_dw_pop_equipmodel_mas"
boolean hscrollbar = true
boolean border = false
boolean hsplitscroll = false
end type

event dw_hlp::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

event dw_hlp::doubleclicked;If row = 0 Then
	Return
Else
	SelectRow(0, False)
	SelectRow(row, True)
End If

Parent.TriggerEvent('ue_close')
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::sqlpreview;//
end event

type p_insert from u_p_insert within ubs_w_pop_equipmodel
integer x = 18
integer y = 964
boolean bringtotop = true
end type

type p_delete from u_p_delete within ubs_w_pop_equipmodel
integer x = 325
integer y = 964
boolean bringtotop = true
boolean originalsize = false
end type

type p_save from u_p_save within ubs_w_pop_equipmodel
integer x = 631
integer y = 964
boolean bringtotop = true
boolean originalsize = false
end type

type gb_1 from groupbox within ubs_w_pop_equipmodel
integer x = 5
integer width = 4416
integer height = 924
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

