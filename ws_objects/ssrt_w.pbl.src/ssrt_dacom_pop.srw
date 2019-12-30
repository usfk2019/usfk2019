$PBExportHeader$ssrt_dacom_pop.srw
$PBExportComments$[hcjung] 데이콤 연동 조회
forward
global type ssrt_dacom_pop from w_a_hlp
end type
end forward

global type ssrt_dacom_pop from w_a_hlp
integer width = 1573
integer height = 944
string title = ""
long backcolor = 29412800
end type
global ssrt_dacom_pop ssrt_dacom_pop

type variables

end variables

on ssrt_dacom_pop.create
call super::create
end on

on ssrt_dacom_pop.destroy
call super::destroy
end on

event open;This.Title = " Uplus Card Inquery"
p_ok.TriggerEvent("ue_enable")

DEC{2}	ldc_rate

//window 중앙에
f_center_window(this)

dw_cond.Reset()
dw_cond.InsertRow(0)
 
IF IsNull(ldc_rate) then ldc_rate = 0

//dw_cond.Object.rate[1] =  ldc_rate
dw_cond.SetFocus()
dw_cond.SetColumn('key_value')





end event

event ue_ok();String ls_search_method, ls_key_value, ls_serialno, ls_contno, ls_pid
Integer test,li_rc, i
b5u_dbmgr_ssrt lu_dacomif

dw_cond.AcceptText()
ls_search_method	=  dw_cond.Object.search_method[1]
ls_key_value		=  dw_cond.Object.key_value[1]

dw_cond.Object.serialno[1] = ''
dw_cond.Object.pid[1]		= ''
dw_cond.Object.controlno[1]= ''
dw_cond.Object.balance[1]	= 0

SetRedraw(True)

lu_dacomif = Create b5u_dbmgr_ssrt
lu_dacomif.is_title 		= title

IF IsNull(ls_search_method) THEN RETURN
IF ls_search_method = 'P' THEN // PIN 번호로 조회
	SELECT serialno, contno INTO :ls_serialno, :ls_contno FROM admst
	WHERE pid = :ls_key_value;
	
	IF IsNull(ls_serialno) OR ls_serialno = '' OR SQLCA.SQLCODE < 0 THEN
			ROLLBACK;
			f_msg_usr_err(201, title, "Unable PIN Number.")
			dw_cond.Object.key_value[1] = ''
			dw_cond.SetFocus()
			dw_cond.SetColumn('search_method')
			RETURN
	END IF
	
	dw_cond.Object.serialno[1] 	=  ls_serialno
	dw_cond.Object.pid[1]			=	ls_key_value
	dw_cond.Object.controlno[1]	=	ls_contno
	
	lu_dacomif.is_caller 	= "inquery_serial"
	lu_dacomif.is_data[1] 	= ls_serialno
	lu_dacomif.idw_data[1]	= dw_cond
	
ELSEIF ls_search_method = 'A' THEN // ANI 번호로 조회
	lu_dacomif.is_caller 	= "inquery_ani"
	lu_dacomif.is_data[1] 	= ls_key_value	
	lu_dacomif.idw_data[1]	= dw_cond
	
ELSEIF ls_search_method = 'C' THEN // Control No로 조회
	SELECT serialno, pid INTO :ls_serialno, :ls_pid FROM admst
	WHERE contno = :ls_key_value;
	
	IF IsNull(ls_serialno) OR ls_serialno = '' OR SQLCA.SQLCODE < 0 THEN
			ROLLBACK;
			f_msg_usr_err(201, title, "Unable Control Number.")
			dw_cond.Object.key_value[1] = ''
			dw_cond.SetFocus()
			dw_cond.SetColumn('search_method')
			RETURN
	END IF
	
	dw_cond.Object.serialno[1] 	=  ls_serialno
	dw_cond.Object.pid[1]			=	ls_pid
	dw_cond.Object.controlno[1]	=	ls_key_value
	
	lu_dacomif.is_caller		= "inquery_serial"
	lu_dacomif.is_data[1]	= ls_serialno
	lu_dacomif.idw_data[1]	= dw_cond
	
END IF
	
lu_dacomif.uf_dacom_if()

li_rc = lu_dacomif.ii_rc
Destroy lu_dacomif


end event

event ue_close();call super::ue_close;Close(This)
end event

type p_1 from w_a_hlp`p_1 within ssrt_dacom_pop
boolean visible = false
integer x = 535
integer y = 696
end type

type dw_cond from w_a_hlp`dw_cond within ssrt_dacom_pop
integer x = 46
integer y = 84
integer width = 1422
integer height = 552
string dataobject = "ssrt_cnd_dacom"
boolean livescroll = false
end type

event dw_cond::itemerror;call super::itemerror;return 0
end event

type p_ok from w_a_hlp`p_ok within ssrt_dacom_pop
integer x = 928
integer y = 696
end type

type p_close from w_a_hlp`p_close within ssrt_dacom_pop
integer x = 1234
integer y = 696
end type

type gb_cond from w_a_hlp`gb_cond within ssrt_dacom_pop
integer x = 23
integer y = 32
integer width = 1499
integer height = 612
end type

type dw_hlp from w_a_hlp`dw_hlp within ssrt_dacom_pop
boolean visible = false
integer x = 123
integer y = 660
integer width = 306
integer height = 68
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_hlp::clicked;call super::clicked;//MessageBox("xpos",String (xpos) + "  "  + String(ypos) + String (dwo))
end event

